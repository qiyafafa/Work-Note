## 对连续存在断点的key聚合
```sql
drop table if exists tmp.test;
create table tmp.test(id int, value numeric);

insert into tmp.test values (1, 234.2);
insert into tmp.test values (2, 231.2);
insert into tmp.test values (3, 24.2);
 
insert into tmp.test values (5, 31.2);
insert into tmp.test values (6, 124.2);
insert into tmp.test values (7, 21.2);
insert into tmp.test values (8, 4.2);

insert into tmp.test values (51, 31.2);
insert into tmp.test values (52, 124.2);

insert into tmp.test values (71, 21.2);

insert into tmp.test values (81, 4.2);

select * from tmp.test;


with recursive s1 as (
       select id as range_min, t.id
        from tmp.test t 
        where not exists (select 1 from tmp.test t2 where t2.id = t.id-1)
       union 
       select s1.range_min, t2.id as range_max
       from s1 
         inner join tmp.test t2 on t2.id = s1.id + 1
   )
, t2 as (select range_min,max(id) as range_max from s1 group by range_min)
select t.id, t.value, min(t.value) over (partition by t2.range_min, t2.range_max) as min_value
  from t2
  inner join tmp.test t on t.id between t2.range_min and t2.range_max
  order by id ;


```
关键点：
```
- 找分组的key :连续id的范围
- 找起点， 找终点，递归


```

