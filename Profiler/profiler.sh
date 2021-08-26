#!/bin/bash


#############################################################
# This Batch Script will Extract  the following metrics from a Hadoop Cluster :
# ------------------------------------------------------------------
#
# 1. YARN Application execution, Host , metrics and Scheduler Information 
#
# 2. If the Distribution is HDP, then it will extract
#     -  the blueprint from Ambari 
#     -  Ranger policies if Ranger is Used 
#
# 3. If the Distribution is CDP, then it will extract
#     -  the Services from CM        
#     -  Impala logs based on the input dates 
#
#############################################################


. `dirname ${0}`/profiler.conf 

## Init Variables 
export curr_date=`date +"%Y%m%d_%H%M%S"`

export output_dir=`dirname ${0}`/Output/

export CURL='curl ' 
export kerburl=' --negotiate -u : '
export http='http://'

export clusterinfo='/ws/v1/cluster/info'
export rmapps='/ws/v1/cluster/apps'
export rmmetrics='/ws/v1/cluster/metrics'
export rmscheduler='/ws/v1/cluster/scheduler'
export rmnodes='/ws/v1/cluster/nodes'

check_kerberos()  { 

    if [ $IS_SECURE == "Y" ]; then 
        CURL="$CURL -k"
        http="https://"
    fi 

    if [ $IS_KERBORIZED == "Y" ]; then

        echo " Kerberos is set as True. Make sure to Kinit before executing the script. Current Credential Cache is ... "
        eval klist
        echo "                   " 
        echo " Press Enter to Continue or Ctrl+C to cancel the execution to Kinit .... "
        read input
       
        ## Patch up Kerberos URL 
        url=$(echo $CURL$kerburl$http)
    else 
        ## Patch up Kerberos URL 
        url=$(echo $CURL$http)
    fi
}

check_active_rm() { 

    ##echo $RM_SERVER_URL

    activermserver=""
    rmserver=$(echo $RM_SERVER_URL | tr "," "\n")
  
     
    for rms in $rmserver 
    do 
       echo $rms 
       clusterinfourl=$url$rms:$RM_SERVER_PORT$clusterinfo
       echo $clusterinfourl

       activerm=`$clusterinfourl  |grep ACTIVE |wc -l`

       #echo $activerm

       if [ $activerm == 1 ]; then 
           activerm_url=$url$rms:$RM_SERVER_PORT 
           break
       fi
    done
   
    echo "Active RM URL is : " $activerm_url

    if [ "$activerm_url" == "" ]; then 
         echo "Active Resource manager URL not found ... aborting the process ...  " 
         exit 1 

    fi 

}

extract_yarn_appls() {

    apps=`$activerm_url$rmapps`

    mkdir -p $output_dir
    appdump=YarnApplicationDump_$curr_date.json

    echo $apps >  $output_dir$appdump

}


extract_yarn_hosts()  {

    rmnodes=`$activerm_url$rmnodes`
    nodedump=YarnNodesDump_$curr_date.json

    echo $rmnodes >  $output_dir$nodedump

}

extract_yarn_metrics()  {

    rmmetrics=`$activerm_url$rmmetrics`
    metricsdump=YarnMetricsDump_$curr_date.json

    echo $rmmetrics >  $output_dir$metricsdump

}



extract_yarn_scheduler()  {

    rmscheduler=`$activerm_url$rmscheduler`
    schedulerdump=YarnSchedulerDump_$curr_date.json

    echo $rmscheduler >  $output_dir$schedulerdump

}


extract_yarn() { 

    check_active_rm
    extract_yarn_appls

    ### Extract additional YARN Details only during initial run 
    
    if [ "$INITIAL_EXEC" == "Y" ]; then 
        extract_yarn_hosts
        extract_yarn_metrics
        extract_yarn_scheduler
    fi

}

extract_ambari_bp() { 
    echo " Extracting Ambari Blueprint .. "

    if [ $AMBARI_SECURED == "Y" ]; then 
        CURL="$CURL -k"
        http="https://"
    fi 

    ### Ambari Metrics 
    bpurl="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME?format=blueprint"
    ambariHosts="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/hosts?fields=Hosts/cpu_count,Hosts/disk_info,Hosts/total_mem,Host/os_arch,Hosts/os_type"
    ambariServices="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services"
    ambariComponents="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/hosts?fields=host_components/host_name"
    ambariStack="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/stack_versions/1"

    ### Ambari RM and HDFS Metrics 
    
    ambariHDFS="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/HDFS/components/NAMENODE"
    ambariRM="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/YARN/components/RESOURCEMANAGER"
    ambariNM="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$AMBARI_SERVER:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/YARN/components/NODEMANAGER"

    bp=`$bpurl`
    hosts=`$ambariHosts`
    services=`$ambariServices`
    components=`$ambariComponents`
    stack=`$ambariStack`

    ambarihdfs=`$ambariHDFS`
    ambarirm=`$ambariRM`
    ambarinm=`$ambariNM`


    bppath=AmbariBlueprint_$curr_date.json
    hostpath=AmbariHost_$curr_date.json
    servicepath=AmbariServices_$curr_date.json
    componentspath=AmbariComponents_$curr_date.json
    stackpath=AmbariStack_$curr_date.json


    ambarihdfspath=AmbariHDFS_$curr_date.json
    ambarirmpath=AmbariRM_$curr_date.json
    ambarinmpath=AmbariNM_$curr_date.json

    echo $bp > $output_dir$bppath
    echo $hosts > $output_dir$hostpath
    echo $components > $output_dir$componentspath
    echo $services > $output_dir$servicepath
    echo $stack > $output_dir$stackpath

    echo $ambarihdfs > $output_dir$ambarihdfspath
    echo $ambarirm > $output_dir$ambarirmpath
    echo $ambarinm > $output_dir$ambarinmpath
    
    
} 


extract_hdp() { 

    check_kerberos
    extract_yarn

    if [ "$INITIAL_EXEC" == "Y" ]; then 
       extract_ambari_bp
       #extract_ranger_policies
    fi

}

extract_cdp() { 

    check_kerberos
    extract_yarn

}

##########################################################################################################
################################## START of Main Code ####################################################
##########################################################################################################

echo "Dist: "  $DISTRIBUTION

if [ "$DISTRIBUTION" == "HDP" ]; then 

      echo " Distribution is Hortonworks. About to Extact ... "       
      extract_hdp

else if [ "$DISTRIBUTION" == "CDP" ]; then 
      echo " Distribtuion is Cloudera . Starting Extract ... " 
      echo " ***** NOTE : this script will only extract YARN logs. CM and impala logs needs to be extract manually ... "
      extract_cdp
     else 
        echo  "Invalid Distribution "  
        exit 1
     fi
fi
