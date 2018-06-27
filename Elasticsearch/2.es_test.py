import json
import unittest
from pprint import pprint

from elasticsearch import Elasticsearch


class MonitorValueTest(unittest.TestCase):
    def __init__(self, repos_plpy, sdb_plpy, es_host_string):
        super().__init__()
        self._repos_plpy = repos_plpy
        self._sdb_plpy = sdb_plpy
        self._id = 0
        self._es = Elasticsearch([es_host_string], sniffer_timeout=60, verify_certs=False)
        self._sqls = {}
        self._containers = {}
        self._locations = {}

    def runTest(self):
        # self.test_index_log_create()
        # self.test_get_the_ma_by_mavalue_probe_time()
        # self.test_del_child_body()
        self._sync_monitor_data()
        self.test_get_the_device_latest_ma_value()
        self.test_get_the_device_agg_ma_value()
        self.test_get_the_country_agg_ma_value()
        self.test_search_specified_ma_value_by_model()
        self.test_search_latest_device_ma_value_by_model()
        self.test_search_latest_device_ma_value_by_vendor()
        self.test_search_latest_device_ma_value_by_pline()
        self.test_search_latest_device_ma_value_by_type()

    def _sync_monitor_data(self):
        # get monitor data by device , date time
        # 1. get all monitor devices in system
        rows = self._get_all_monitor_devices()
        device_ids = [r["id"] for r in rows]
        self._load_countainer_ids(device_ids)
        self._load_location_ids(device_ids)
        # 2. get device containers and locations

        # 3. loop the devices
        for r in rows:
            # loop until get all device monitor value
            before_days = 0
            while True:
                # 2.1 get device ma value by day
                monitor_rows = self._get_ma_value_by_day(r["deviceid"], before_days)
                if len(monitor_rows) == 0 :
                    break
                # 2.2 convert the device ma value to es body format
                # routing = self._get_routing_by_sid(r["deviceid"])
                routing = self._format_uuid_only_with_character(r["id"])
                monitor_child_body = self._conv_ma_esbody(r["id"], routing, monitor_rows)
                # 2.3 bulk add the monitor value
                # self._es.bulk()
                self._es.bulk(monitor_child_body, refresh=True)
                before_days += 1

    def _get_routing_by_sid(self, device_sid):
        return abs(device_sid) % 5 + 1

    def _get_all_monitor_devices(self):
        rows = self._repos_plpy.execute("""
            select m.deviceid ,d.id, d.name
                from mac.monitordevice m
                inner join di.device  d 
                    on d.sid = m.deviceid 
            --    where d.id = any(array[
            --    'ba532aca-d89c-4b9e-9f62-d85e5cbf8714',
            --    'ea46fc1e-c8c3-421b-8a4d-8168351ea36f'
            --    ]::uuid[])
            --union 
            --select m.deviceid , d.uuid as id, d.name
            --    from mac.monitordevice m
            --    inner join fd.location d 
            --        on d.id = -m.deviceid
                    ;
        """)
        return rows

    def _load_countainer_ids(self, device_ids):
        """
        Get the parrent device id .
        :param device_id:
        :return: Parrent id array
        """
        rows = self._repos_plpy.execute(self._sql_get_countainer_ids(), [device_ids])
        for r in rows:
            self._containers[r.get("source_id")] = r.get("ids")

    def _load_location_ids(self, device_ids):
        rows = self._repos_plpy.execute(self._sql_get_location_ids(), [device_ids])
        for r in rows:
            self._locations[r.get("source_id")] = r.get("ids")

    def _sql_get_countainer_ids(self):
        sql = self._sqls.get("_sql_get_countainer_ids")
        if sql is None:
            sql = self._repos_plpy.prepare("""
            with recursive s as (
                select id as source_id, id,aid 
                    from di.device_position_c
                    where id = any($1)
                union all 
                select s.source_id, c1.id,c1.aid 
                    from di.device_position_c c1 
                    inner join s on s.aid = c1.id  
            )
            select source_id, array_agg(aid) as ids from s
                group by source_id;
            """, ["uuid[]"])
            self._sqls["_sql_get_countainer_ids"] = sql
            return sql

    def _sql_get_location_ids(self):
        sql = self._sqls.get("_sql_get_location_ids")
        if sql is None:
            sql = self._repos_plpy.prepare("""
            with t1 as (select unnest($1) as id),
                t2 as (select id, (dz.device___get_location_info_v1(id)).* from t1)
            select  id as source_id,
                    array_cat(area_id,
                        array[floor_id,building_id,city_id,
                            state_id,nation_id]) as ids
                    from t2
                    where area_id is not null
                    group by id, area_id,floor_id,building_id,city_id,
                            state_id,nation_id;             
            """, ["uuid[]"])
            self._sqls["_sql_get_location_ids"] = sql
        return sql

    def _conv_ma_esbody(self, entity_id, routing, monitor_rows):
        """
        :param entity_id:       device or location
        :param monitor_rows:    rows get from _get_ma_value_by_day
        :return:                bulk body for monitor child
        """
        child_bodys = ""
        for r in monitor_rows:
            ma_value = self._get_transform_ma_value(r["data_type_id"], r["value"])
            index_body = {"index": {"_index": "monitor-201801", "_type": "_doc", "routing": routing}}
            doc_body = {
                "container_ids": self._containers.get(entity_id),
                "location_ids": self._locations.get(entity_id),
                "entity_id" : self._format_uuid_only_with_character(entity_id),
                "ma_id"     : r["ma_id"],
                r["ma_id"]: ma_value,
                "probe_time": r["probe_time"],
                "load_time": r["load_time"],
                "unit": r["unit"],
                "join_in": {"name": "value", "parent": self._format_uuid_only_with_character(entity_id)}
            }
            child_bodys += (json.dumps(index_body) + "\n")
            child_bodys += (json.dumps(doc_body) + "\n")

        pprint(child_bodys)
        return child_bodys

    def _get_transform_ma_value(self, type_id, ma_value):
        try:
            if type_id == 1:
                return ma_value
            elif type_id == 2:
                return int(ma_value)
            elif type_id == 3:
                return float(ma_value)
            elif type_id == 4:
                return ma_value.replace(" ", "T")
            else:
                return ma_value
        except Exception as e:
            return ma_value

    def _format_uuid_only_with_character(self, id):
        return id.replace("-", "")

    def _get_ma_value_by_day(self, device_sid, from_day):
        """
        :param from_day: 0: today , -1 : 1 day ago
        :return:
        """
        end_day = from_day - 1
        times = self._sdb_plpy.execute("""
            select date_trunc('day', (now() - '{0} day'::interval)) as start_date,
                date_trunc('day', (now() - '{1} day'::interval)) as end_date
                """.format(from_day, end_day))
        for dates in times:
            start_date = dates["start_date"]
            end_date = dates["end_date"]

        print("Get monitor data of device : {2} from {0} to {1}.".format(start_date, end_date, device_sid))
        monitor_rows = self._sdb_plpy.execute(self._sql_get_ma_value_by_day(), [device_sid, start_date, end_date])
        return monitor_rows

    def _sql_get_ma_value_by_day(self):
        sql = self._sqls.get("_sql_get_ma_value_by_day")
        if sql is None:
            sql = self._sdb_plpy.prepare("""
                select  m.ma_id as db_ma_id,  -- the standard uuid
                        replace(ma_id::text, '-' , '') as ma_id,
                        replace((probe_time at time zone INTERVAL '00:00')::text, ' ' , 'T') as probe_time,
                        replace((load_time at time zone INTERVAL '00:00')::text, ' ' , 'T') as load_time,
                        m2.data_type_id,
                        case 
                            when m2.data_type_id = 4 then
                                ((value::timestamp with time zone) at time zone INTERVAL '00:00')::text
                            else value 
                        end as value,
                        unit
                    from mon1.me m
                    inner join mon.ma_define m2 on m2.id = m.ma_id
                    where device_id = $1
                      and probe_time between $2 and $3
                      and m.value is not null;
            """, ["bigint", "timestamp with time zone", "timestamp with time zone"])
            self._sqls["_sql_get_location_ids"] = sql
        return sql

    def test_index_log_create(self):
        # self._es.create(index="event", doc_type="doc", id=2, body=json.dumps({"name":"test2", "user_group":[1,3]}))
        # self._es.delete(index="event")
        if self._es.indices.exists(index="monitor"):
            self._es.indices.delete(index="monitor")
        if not self._es.indices.exists(index="monitor"):
            self._es.indices.create(index="monitor")

    def test_get_the_ma_by_mavalue_probe_time(self):
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {"match": {"14bb6f3c-e0d7-11e3-956d-005056000011": "0.0"}}
                    ],
                    "filter": [
                        {"range": {"probe_time": {"gte": "2018-03-26"}}}
                    ]
                }
            },
            "sort": [{"probe_time": "desc"}]
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result)

    def test_del_child_body(self):
        search_body = {
            "query": {
                "bool": {
                    "filter": [
                        {"range": {"probe_time": {"gte": "2018-03-02"}}}
                    ]
                }
            }
        }
        result = self._es.delete_by_query(index="monitor-201801", body=json.dumps(search_body))
        print(result)

    def test_get_the_device_latest_ma_value(self):
        search_body = {
            "query": {
                "bool": {
                    "must": {
                        "query_string": {
                            "query": "84f508168b1511de91cd000d566af2f2:*"
                        }
                    },
                    "filter": {
                        "parent_id": {
                            "type": "value",
                            "id": "ba532acad89c4b9e9f62d85e5cbf8714"
                        }
                    }
                }
            },
            "sort": [
                {
                    "probe_time": "desc"
                }
            ],
            "size": 1
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_get_the_device_agg_ma_value(self):
        search_body = {
            "query": {
                "bool": {
                    "must": {
                        "query_string": {
                            "query": "84f508168b1511de91cd000d566af2f2:*"
                        }
                    },
                    "filter": {
                        "parent_id": {
                            "type": "value",
                            "id": "ba532acad89c4b9e9f62d85e5cbf8714"
                        }
                    }
                }
            },
            "aggs": {
                "avg_value": {
                    "avg": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "min_value": {
                    "min": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "sum_value": {
                    "sum": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "max_value": {
                    "max": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        pprint(result.get("hits"))
        pprint(result.get("aggregations"))

    def test_get_the_area_agg_ma_value(self):
        search_body = {
            "query": {
                "bool": {
                    "must": {
                        "query_string": {
                            "query": "84f508168b1511de91cd000d566af2f2:* && location_ids:330"
                        }
                    }
                }
            },
            "aggs": {
                "avg_value": {
                    "avg": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "min_value": {
                    "min": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "sum_value": {
                    "sum": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "max_value": {
                    "max": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        pprint(result.get("hits"))
        pprint(result.get("aggregations"))

    def test_get_the_country_agg_ma_value(self):
        search_body = {
            "query": {
                "bool": {
                    "must": {
                        "query_string": {
                            "query": "84f508168b1511de91cd000d566af2f2:* && location_ids:15"
                        }
                    }
                }
            },
            "aggs": {
                "avg_value": {
                    "avg": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "min_value": {
                    "min": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "sum_value": {
                    "sum": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                },
                "max_value": {
                    "max": {
                        "field": "84f508168b1511de91cd000d566af2f2"
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        pprint(result.get("hits"))
        pprint(result.get("aggregations"))

    def test_search_all_ma_value_by_model(self):
        """
        """
        search_body = {
            "query": {
                "has_parent": {
                    "parent_type": "entity",
                    "query": {
                        "term": {
                            "model": 4614
                        }
                    }
                }
            }
        }

        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_search_specified_ma_value_by_model(self):
        """
        """
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "has_parent": {
                                "parent_type": "entity",
                                "query": {
                                    "term": {
                                        "model": 4614
                                    }
                                }
                            }},
                        {
                            "query_string": {"query": "84f508168b1511de91cd000d566af2f2:*"}
                        }
                    ],
                    "filter": {
                        "range": {"probe_time": {"gte": "2018-03-26"}}
                    }
                }
            }
        }

        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_search_latest_device_ma_value_by_model(self):
        """
        Get all the devices whose model is 4614 latest monitor value
        """
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "has_parent": {
                                "parent_type": "entity",
                                "query": {
                                    "term": {
                                        "model": 4614
                                    }
                                }
                            }},
                        {
                            "query_string": {"query": "84f508168b1511de91cd000d566af2f2:*"}
                        }
                    ],
                    "filter": {
                        "range": {"probe_time": {"gte": "2018-03-26"}}
                    }
                }
            },
            "aggs": {
                "top_tags": {
                    "terms": {
                        "field": "entity_id.keyword"
                    },
                    "aggs": {
                        "top_ma_hits": {
                            "top_hits": {
                                "sort": [
                                    {
                                        "probe_time": {
                                            "order": "desc"
                                        }
                                    }
                                ],
                                "size" : 1
                            }
                        }
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_search_latest_device_ma_value_by_vendor(self):
        """
        Get all the devices whose vendor is 56 latest monitor value
        """
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "has_parent": {
                                "parent_type": "entity",
                                "query": {
                                    "term": {
                                        "vendor": 56
                                    }
                                }
                            }},
                        {
                            "query_string": {"query": "84f508168b1511de91cd000d566af2f2:*"}
                        }
                    ],
                    "filter": {
                        "range": {"probe_time": {"gte": "2018-03-26"}}
                    }
                }
            },
            "aggs": {
                "top_tags": {
                    "terms": {
                        "field": "entity_id.keyword"
                    },
                    "aggs": {
                        "top_ma_hits": {
                            "top_hits": {
                                "sort": [
                                    {
                                        "probe_time": {
                                            "order": "desc"
                                        }
                                    }
                                ],
                                "size" : 1
                            }
                        }
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_search_latest_device_ma_value_by_pline(self):
        """
        Get all the devices whose pline is 925 latest monitor value
        """
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "has_parent": {
                                "parent_type": "entity",
                                "query": {
                                    "term": {
                                        "pline": 925
                                    }
                                }
                            }},
                        {
                            "query_string": {"query": "84f508168b1511de91cd000d566af2f2:*"}
                        }
                    ],
                    "filter": {
                        "range": {"probe_time": {"gte": "2018-03-26"}}
                    }
                }
            },
            "aggs": {
                "top_tags": {
                    "terms": {
                        "field": "entity_id.keyword"
                    },
                    "aggs": {
                        "top_ma_hits": {
                            "top_hits": {
                                "sort": [
                                    {
                                        "probe_time": {
                                            "order": "desc"
                                        }
                                    }
                                ],
                                "size" : 1
                            }
                        }
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

    def test_search_latest_device_ma_value_by_type(self):
        """
        Get all the devices whose type is 532 latest monitor value
        """
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "has_parent": {
                                "parent_type": "entity",
                                "query": {
                                    "term": {
                                        "type": 532
                                    }
                                }
                            }},
                        {
                            "query_string": {"query": "84f508168b1511de91cd000d566af2f2:*"}
                        }
                    ],
                    "filter": {
                        "range": {"probe_time": {"gte": "2018-03-26"}}
                    }
                }
            },
            "aggs": {
                "top_tags": {
                    "terms": {
                        "field": "entity_id.keyword"
                    },
                    "aggs": {
                        "top_ma_hits": {
                            "top_hits": {
                                "sort": [
                                    {
                                        "probe_time": {
                                            "order": "desc"
                                        }
                                    }
                                ],
                                "size" : 1
                            }
                        }
                    }
                }
            }
        }
        result = self._es.search(body=json.dumps(search_body))
        print(result.get("hits").get("hits"))

