#!/bin/bash
VDC_CONF=/opt/VDC/.conf
CONF_SDB_ID=
CONF_PROBE_ID=
VDC_TYPE_MASTER="master"
VDC_TYPE_MASTERDB="master-db"
VDC_TYPE_PROBE="probe"
VDC_TYPE_ALLINONE="all-in-one"
PROD="VDC 5.3 or VDC 5.2"
let MINIMUM_MEM=7000
let MINIMUM_CPU_CORES_NUM=4
let MINIMUM_FREE_BACKUP_SPACE=100  # GB
declare -a SUPPORTED_OS=('CentOS release 5.5' 'Red Hat Enterprise Linux Server release 5.5' 'CentOS release 5.8' 'Red Hat Enterprise Linux Server release 5.8' 'CentOS release 5.9' 'Red Hat Enterprise Linux Server release 5.9' 'CentOS release 6.2' 'Red Hat Enterprise Linux Server release 6.2' 'CentOS release 6.3' 'Red Hat Enterprise Linux Server release 6.3' 'CentOS release 6.4' 'Red Hat Enterprise Linux Server release 6.4' 'CentOS release 6.5' 'Red Hat Enterprise Linux Server release 6.5' 'CentOS release 6.6' 'Red Hat Enterprise Linux Server release 6.6' 'CentOS release 6.7' 'Red Hat Enterprise Linux Server release 6.7' 'CentOS release 6.8' 'Red Hat Enterprise Linux Server release 6.8' 'CentOS release 6.9' 'Red Hat Enterprise Linux Server release 6.9' 'CentOS Linux release 7.2' 'Red Hat Enterprise Linux Server release 7.2' 'CentOS Linux release 7.3' 'Red Hat Enterprise Linux Server release 7.3')
declare -a SERVERADMIN_SUPPORTED_OS=('CentOS release 6.2' 'Red Hat Enterprise Linux Server release 6.2' 'CentOS release 6.3' 'Red Hat Enterprise Linux Server release 6.3' 'CentOS release 6.4' 'Red Hat Enterprise Linux Server release 6.4' 'CentOS release 6.5' 'Red Hat Enterprise Linux Server release 6.5' 'CentOS release 6.6' 'Red Hat Enterprise Linux Server release 6.6' 'CentOS release 6.7' 'Red Hat Enterprise Linux Server release 6.7' 'CentOS release 6.8' 'Red Hat Enterprise Linux Server release 6.8' 'CentOS release 6.9' 'Red Hat Enterprise Linux Server release 6.9' 'CentOS Linux release 7.2' 'Red Hat Enterprise Linux Server release 7.2' 'CentOS Linux release 7.3' 'Red Hat Enterprise Linux Server release 7.3')

function abort 
{
    echo $1
    exit 1
}

function sql_run
{
    host=$1
    db_name=$2
    sql=$3
    tmp="`/usr/local/pgsql/bin/psql -h $host -U root $db_name -t -A -c "$sql" |grep -v "Welcome To VDC PSQL"`"
    echo "$tmp"
}

function is_mem_meet_req
{
    let y=`free -m |awk '/Mem:/{print $2}'`
    test $y -ge $MINIMUM_MEM  
    if (( $? != 0 )) ;then 
        abort "ERROR:The physical memory must be bigger than 8G ."
    fi
}

function is_cpu_meet_req
{
    let y=`lscpu|awk '/^CPU\(s\):/{print $2}'`
    test $y -ge $MINIMUM_CPU_CORES_NUM  
    if (( $? != 0 )) ;then 
        abort "ERROR:The cpu cores must be more than 4 ."
    fi
}

function is_space_meet_req
{
    let y=`df -BG /opt/VDC.BACKUP/ |awk '!/Filesystem/{print $4}'|grep -o '[0-9]*'`
    test $y -ge $MINIMUM_FREE_BACKUP_SPACE
    if (( $? != 0 )) ;then 
        abort "ERROR:The free disk space of the disk which /opt/VDC.BACKUP mounted must be bigger than $MINIMUM_FREE_BACKUP_SPACE GB ."
    fi
}

function is_valid_sdb_id
{
    CONF_SDB_ID="`grep "SDBUUID@/opt/VDC/bin/sdbinit.sh" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
    CONF_AGENT_SDB_ID="`grep "AGENTSDBID@/opt/VDC/monitor/vms/webapps/vms/WEB-INF/config/Agent.properties" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
    if [[ -z $CONF_SDB_ID || -z $CONF_AGENT_SDB_ID ]]; then 
        echo "CONF_SDB_ID : $CONF_SDB_ID "
        echo "CONF_AGENT_SDB_ID: $CONF_AGENT_SDB_ID "
        abort "ERROR:SDBUUID or CONF_AGENT_SDB_ID do not exist in file $VDC_CONF ."
    fi
    sql1="select * from mac.sdb where id = '$CONF_SDB_ID'"
    sql2="select * from rc.sdb_info where id = '$CONF_SDB_ID'"
    sql3="select * from mac.sdb_partition where sdb_id = '$CONF_SDB_ID' "
    sql4="select * from mac.probe_sdb_map where sdb_id = '$CONF_SDB_ID' "
    DB_SDB_ID="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql1 "|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $1}'`"
    PARTITION_SDB_ID="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql3 "|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $2}'`"
    DB_RC_SDB_ID="`/usr/local/pgsql/bin/psql -h 127.0.0.1 -U root vdc_sdb -t -A -c "$sql2 "|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $2}'`"
    DB_MAP_SDB_ID="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql4 "|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $2}'`"

    echo "SDBUUID in /opt/VDC/.conf                 : $CONF_SDB_ID ."
    echo "AGENTSDBUUIDin /opt/VDC/.conf             : $CONF_AGENT_SDB_ID ."
    echo "SDB id in sdb                             : $DB_SDB_ID ."
    echo "SDB id in sdb_partition                   : $PARTITION_SDB_ID ."
    echo "SDB id in probe_sdb_map                   : $DB_MAP_SDB_ID ."
    echo "SDB id in rc.sdb_info                     : $DB_RC_SDB_ID ."
    echo "--------------------------------------------------------------------------"

   if [[ $CONF_AGENT_SDB_ID != $CONF_SDB_ID || -z $DB_SDB_ID || -z $DB_RC_SDB_ID || -z $PARTITION_SDB_ID || -z $DB_MAP_SDB_ID || $CONF_SDB_ID != $DB_SDB_ID || $CONF_SDB_ID != $PARTITION_SDB_ID || $CONF_SDB_ID != $DB_MAP_SDB_ID ]]; then 
   	abort "ERROR:SDB ids in file $VDC_CONF and tables sdb,sdb_partition,probe_sdb_map,sdb_info are not consistent ."
   fi
}

function is_valid_probe_id
{
    CONF_DIS_PROBE_ID="`grep "DISCOVERYAGENTID@/opt/VDC/monitor/vms/webapps/discovery/WEB-INF/classes/agent.properties=" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
    CONF_PROBE_ID="`grep "AGENTID@/opt/VDC/monitor/vms/webapps/vms/WEB-INF/config/Agent.properties" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
    if [[ -z $CONF_DIS_PROBE_ID  || -z $CONF_PROBE_ID ]]; then 
        echo "CONF_DIS_PROBE_ID     : $CONF_DIS_PROBE_ID "
        echo "CONF_PROBE_ID         : $CONF_PROBE_ID "
        abort "ERROR:CONF_DIS_PROBE_ID or CONF_PROBE_ID do not exist in file $VDC_CONF ."
    fi
 
    sql1="select id from server.process_info where type_id = 1 and id = '$CONF_PROBE_ID'"
    sql2="select probe_id from mac.probe_sdb_map where probe_id = '$CONF_PROBE_ID'"
    sql_run vdchost-db vdc_repos $sql1  
    DB_PROBE_ID="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql1"|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $1}'`" 
    DB_MAP_PROBE_ID="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql2"|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $1}'`" 

    echo "Probe id(AGENTID)  in /opt/VDC/.conf              : $CONF_PROBE_ID ."
    echo "Probe id(DISCOVERYAGENTID)  in /opt/VDC/.conf     : $CONF_DIS_PROBE_ID ."
    echo "Probe id(AGENTID) in process_info                 : $DB_PROBE_ID ."
    echo "Probe id(AGENTID) in probe_sdb_map                : $DB_MAP_PROBE_ID ."
    echo "--------------------------------------------------------------------------"

    if [[ $CONF_PROBE_ID != $CONF_DIS_PROBE_ID || -z $DB_PROBE_ID || -z $DB_MAP_PROBE_ID ]] ; then
        abort "ERROR:Probe ids are not consistent in $VDC_CONF ,process_info and probe_sdb_map . "
    fi

}

function is_valid_probe_ip
{
    CONF_PROBE_IP="`grep "AGENTRMISERVICEIP@/opt/VDC/monitor/vms/webapps/vms/WEB-INF/config/Agent.properties=" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
    if [[ -z $CONF_PROBE_IP ]]; then 
        echo "CONF_PROBE_IP         : $CONF_PROBE_IP "
        abort "ERROR:CONF_PROBE_IP do not exist in file $VDC_CONF ."
    fi
 
    sql1="select s.location as probe_ip from server.process_info x inner join server.process_status s on x.id = s.id where x.type_id=1;"
    DB_PROBE_IP="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql1"|grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $1}'`" 

    echo "Probe ip  in /opt/VDC/.conf              : $CONF_PROBE_IP ."
    echo "Probe ip in process_status               : $DB_PROBE_IP ."
    echo "--------------------------------------------------------------------------"

    if [[ -z $DB_PROBE_IP || $CONF_PROBE_IP != $DB_PROBE_IP ]] ; then
        abort "ERROR: Probe ips are not consistent in $VDC_CONF ,process_status . "
    fi
    
    ifconfig |grep $DB_PROBE_IP >/dev/null 
    if (( $? != 0 )) ; then
        abort "ERROR: Probe ips are not consistent between $VDC_CONF and the ip of this server . "
    fi
    echo "Probe ips are consistent ."
}

function is_valid_sdb_ip
{
    sql1="select host from mac.sdb where id='$CONF_SDB_ID' ;"
    DB_SDB_IP="`/usr/local/pgsql/bin/psql -h vdchost-db -U root vdc_repos -t -A -c "$sql1" |grep -v "Welcome To VDC PSQL"|awk -F'|' '{print $1}'`" 

    echo "SDB ip  in sdb              			: $DB_SDB_IP ."
    echo "--------------------------------------------------------------------------"

    if [[ -z $DB_SDB_IP ]] ; then
        abort "ERROR: SDB ip does not exist when the SDB ID is $CONF_SDB_ID . "
    fi
    
    ifconfig |grep $DB_SDB_IP >/dev/null 
    if (( $? != 0 )) ; then
        ifconfig
        abort "ERROR: SDB ips are not consistent between table sdb and the ip of this server . "
    fi
    echo "SDB ips are consistent ."
}

function is_valid_ver
{
    VDC_TYPE="`awk -F"[()]" '{print $2}' /opt/VDC/.ver`"
    # check whether the server is master
    if [[ $VDC_TYPE == $VDC_TYPE_MASTER ]] ; then
        if [[ ! -e /opt/VDC/tomcat/webapps2/ ]]; then
            abort "ERROR: Master server does not have directory /opt/VDC/tomcat/webapps2/ ."
        fi
        if [[ -f /opt/VDC/monitor/vms/bin/vms ]]; then
            abort "ERROR: Master server should not have file /opt/VDC/monitor/vms/bin/vms ."
        fi
    fi
    # check whether the server is probe
    if [[ $VDC_TYPE == $VDC_TYPE_PROBE ]] ; then
        if [[ -e /opt/VDC/tomcat/webapps2/ ]]; then
            abort "ERROR: Probe server does not have directory /opt/VDC/tomcat/webapps2/ ."
        fi
        if [[ ! -f /opt/VDC/monitor/vms/bin/vms ]]; then
            abort "ERROR: Probe server should have file /opt/VDC/monitor/vms/bin/vms ."
        fi
        /usr/local/pgsql/bin/psql -h 127.0.0.1 -U root vdc_sdb -c "select now();"
        if (( $? != 0 )); then 
            abort "ERROR: Probe server should have database named vdc_sdb ."
        fi
    fi
    # check whether the masterdb server is correct
    if [[ $VDC_TYPE == $VDC_TYPE_MASTERDB ]] ; then
        if [[ -e /opt/VDC/tomcat/webapps2/ ]]; then
            abort "ERROR: MASTER DB server should not have directory /opt/VDC/tomcat/webapps2/ ."
        fi
        if [[ -f /opt/VDC/monitor/vms/bin/vms ]]; then
            abort "ERROR: MASTER DB server should not have file /opt/VDC/monitor/vms/bin/vms ."
        fi
        /usr/local/pgsql/bin/psql -h 127.0.0.1 -U root vdc_repos -c "select now();"
        if (( $? != 0 )); then 
            abort "ERROR: MASTER DB server should have database named vdc_repos ."
        fi
    fi
    # check whether the server is all-in-one, and the vdc files are correct
    if [[ $VDC_TYPE == $VDC_TYPE_ALLINONE ]] ; then
        if [[ ! -e /opt/VDC/tomcat/webapps2/ ]]; then
            abort "ERROR: ALL-IN-ONE server should have directory /opt/VDC/tomcat/webapps2/ ."
        fi
        if [[ ! -f /opt/VDC/monitor/vms/bin/vms ]]; then
            abort "ERROR: ALL-IN-ONE server should have file /opt/VDC/monitor/vms/bin/vms ."
        fi
        /usr/local/pgsql/bin/psql -h 127.0.0.1 -U root vdc_repos -t -A -c "select now() as repos_current " |grep -v "Welcome To VDC PSQL"
        if (( $? != 0 )); then 
            abort "ERROR: ALL-IN-ONE server should have database named vdc_repos ."
        fi
        /usr/local/pgsql/bin/psql -h 127.0.0.1 -U root vdc_sdb -t -A -c "select now() as sdb_current " |grep -v "Welcome To VDC PSQL"
        if (( $? != 0 )); then 
            abort "ERROR: ALL-IN-ONE server should have database named vdc_sdb ."
        fi
    fi
    echo "VDC type in /opt/VDC/.ver is consistent with the server ."
}

function does_ip_exist
{
    if (( $# != 1 )); then
        echo "Usage: does_ip_exist ip"
        return -1;
    fi

    /sbin/ifconfig |grep "inet addr:"|awk -F: '{print $2}'|awk '{print $1}'|grep "^$1$" > /dev/null
    if (( $? == 0 )); then
        return 1
    fi

    return 0
} 

function is_valid_vdc_host_ip
{
    if [[ -e /opt/VDC/tomcat/webapps2/ ]]; then
        echo "Checking VDC host ip ....................................."
        VDCHOSTURL="`grep "VDCURL@tomcat/webapps2/ROOT/index.html=" /opt/VDC/.conf|awk -F"=" '{print $2}' |sed 's/http\:\/\///'`"
        VDCHOSTIP="`grep "VDCIP@/opt/VDC/vdcmon/conf/content=" /opt/VDC/.conf|awk -F"=" '{print $2}'`"
        echo "VDCHOSTURL:  $VDCHOSTURL"
        echo "VDCHOSTIP:   $VDCHOSTIP"

        if [[ -z $VDCHOSTURL || -z $VDCHOSTIP ]]; then 
            abort "ERROR: VDCHOSTURL or VDCHOSTIP does not exist in file /opt/VDC/.conf . "
        fi 
        VDCHOSTIP_HOSTFILE="`grep $VDCHOSTURL /etc/hosts |tail -n 1 |awk '{print $1}' `"
        if [[ -z $VDCHOSTIP_HOSTFILE || $VDCHOSTIP_HOSTFILE != $VDCHOSTIP ]] ; then 
            echo "VDCHOSTIP_HOSTFILE:   $VDCHOSTIP_HOSTFILE"
            grep $VDCHOSTURL /etc/hosts 
            abort "ERROR: VDCHOSTIP and ip in file /etc/hosts are not consistent ."
        fi
        does_ip_exist $VDCHOSTIP
        if (( $? != 0 )); then 
            abort "ERROR: VDCHOSTIP does not exist on this server ."
        fi
        echo "Checking VDC host ip end .................................."
    fi   
}

function is_supported_os
{
    echo "Checking os ...................................."
    os=`cat /etc/redhat-release`
    osok=0
    for supported in "${SUPPORTED_OS[@]}"
    do
        #echo "Scaning for $supported..."

        echo "$os"|egrep "^$supported" > /dev/null 2>&1
        if (( $? == 0 )); then
            osok=1
            break
        fi

    done

    if (( $osok != 1 )); then
        abort 'ERROR: This OS[$os] is not a $PROD supported OS. '
    fi
    echo "Checking os end .................................."
}

# Checking probe, if the server is probe server, check the sdb id and probe id
if [[ -e /opt/VDC/monitor/vms/bin/vms ]]; then 
    is_valid_sdb_id
    is_valid_sdb_ip
    is_valid_probe_id
    is_valid_probe_ip
fi

is_mem_meet_req
is_cpu_meet_req
is_space_meet_req
is_valid_ver
is_valid_vdc_host_ip
is_supported_os

exit 0
