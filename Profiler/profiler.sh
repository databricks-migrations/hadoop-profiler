#!/bin/bash

####################################################################################
# This Batch Script will Extract  the following metrics from a Hadoop Cluster :
# ------------------------------------------------------------------
#
# 1. YARN Application execution, Host , metrics and Scheduler Information
#
# 2. SPARH History Server logs
#
# 3. If the Distribution is HDP, then the script will extract
#     -  the blueprint from Ambari
#     -  Ranger policies if Ranger is Used
#
# 4. If the Distribution is CDH, then the script  will extract
#     -  the Services from CM
#     -  Impala logs based on the input dates
#     -  Time Series data from CM
#
# 5. If the Distribution is OTH, then the script will extract
#     -  YARN Extract
#     -  Spark History server Extract
#
#####################################################################################


. `dirname ${0}`/profiler.conf

## Init Variables

export curr_date=`date +"%Y%m%d_%H%M%S"`
export extract_date=`date +"%Y-%m-%d"`

export yesterday_impala_extract_dt=`date -d '-1 day' +"%Y-%m-%d"`

if [ -z $PROFILER_OUTPUT_PATH ]; then 
    export output_dir=`dirname ${0}`/Output/
else
    export output_dir=${PROFILER_OUTPUT_PATH}/Output/
fi 

export runtracker_dir=`dirname ${0}`/ExtractTracker/

export CURL='curl '
export http='http://'
export kerburl=' --negotiate -u : '

export clusterinfo='/ws/v1/cluster/info'
export rmapps="/ws/v1/cluster/apps${RM_APP_FILTER}"
export rmmetrics='/ws/v1/cluster/metrics'
export rmscheduler='/ws/v1/cluster/scheduler'
export rmnodes='/ws/v1/cluster/nodes'

check_kerberos()  {

    if [ "$RM_SECURE" == "Y" ]; then
        CURL="$CURL -k "
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi

    if [ "$RM_KERBERIZED" == "Y" ]; then

        echo " Kerberos is set as True. Make sure to Kinit before executing the script. Current Credential Cache is ... "
        eval klist
        echo "\n"

        if [ "$GOT_KEYTAB" == "Y" ]; then
            echo " Initializing with Keytab provided ..... "
            kinit="kinit -kt $KEYTAB_PATH/$KEYTAB $PRINCIPAL"
            eval $kinit
            eval klist
                #echo " Press Enter to Continue or Ctrl+C to cancel  .... "
                #read input
        fi

        ## Patch up Kerberos URL
        url=$(echo $CURL$kerburl$http)
    else

	## If HDI Flag is enabled then add the user id and password for YARN UI
        if [[ $DISTRIBUTION == 'HDP' && $IS_HDI == 'Y' ]]; then
	      AMBARI_ADMIN_PASSWORD_NOQT=$(echo $AMBARI_ADMIN_PASSWORD | sed 's/\"//g')
	      
	      url_noqt=$(echo $CURL -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD_NOQT $http)
	      url=$(echo $CURL -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http)
	else

             ## Patch up Non-Kerberos URL
             url=$(echo $CURL$http)
        fi
    fi
}

check_active_rm() {

    ##echo $RM_SERVER_URL

    activermserver=""
    rmserver=$(echo $RM_SERVER_URL | tr "," "\n")


    for rms in $rmserver
    do
       #echo $rms

       if [[ $DISTRIBUTION == 'HDP' && $IS_HDI == 'Y' ]]; then
           clusterinfourl=$url_noqt$rms$clusterinfo
       else
           clusterinfourl=$url$rms:$RM_SERVER_PORT$clusterinfo
       fi

       echo "curl command to check active rm: $clusterinfourl"

       activerm=`$clusterinfourl`
      
       activerm=`$clusterinfourl  | grep ACTIVE | wc -l`


       if [ $activerm == 1 ]; then
           if [[ $DISTRIBUTION == 'HDP' && $IS_HDI == 'Y' ]]; then
               activerm_url=$url$rms
           else
               activerm_url=$url$rms:$RM_SERVER_PORT
	   fi

           break
       fi
    done

    echo "Active RM URL is : " $rms

    if [ "$activerm_url" == "" ]; then
         echo "Active Resource manager URL not found ... aborting the process ...  "
         exit 1

    fi

}

###########################################
### Extract YARN Applications Logs
###########################################

extract_yarn_appls() {

    appdump=YarnApplicationDump_$curr_date.json
    echo "curl command to extract yarn apps: $activerm_url$rmapps $SEARCH_REPLACE"
    eval $activerm_url$rmapps $SEARCH_REPLACE >  $yarn_out_dir$appdump

}

###########################################
### Extract YARN Host Logs
###########################################
extract_yarn_hosts()  {

    nodedump=YarnNodesDump_$curr_date.json
    echo "curl command to extract yarn nodes: $activerm_url$rmnodes $SEARCH_REPLACE"
    eval $activerm_url$rmnodes $SEARCH_REPLACE >  $yarn_out_dir$nodedump

}

###########################################
### Extract YARN Metrics Logs
###########################################

extract_yarn_metrics()  {

    metricsdump=YarnMetricsDump_$curr_date.json
    echo "curl command to extract yarn metrics: $activerm_url$rmmetrics $SEARCH_REPLACE"
    eval $activerm_url$rmmetrics $SEARCH_REPLACE >  $yarn_out_dir$metricsdump

}

###########################################
### Extract YARN Scheduler Logs
###########################################

extract_yarn_scheduler()  {

    schedulerdump=YarnSchedulerDump_$curr_date.json

    eval $activerm_url$rmscheduler $SEARCH_REPLACE  >  $yarn_out_dir$schedulerdump
}


###############################################################
### Extract YARN Logs
### - Applications, Logs, Hosts, Metrics and Scheduler
###############################################################
extract_yarn() {

    yarn_out_dir=$output_dir/YARN/$extract_date/
    mkdir -p $yarn_out_dir

    check_active_rm
    extract_yarn_appls

    ### Extract additional YARN Details only during initial run

    if [ "$INITIAL_EXEC" == "Y" ]; then
        extract_yarn_hosts
        extract_yarn_metrics
        extract_yarn_scheduler
    fi

}

###############################################################
### Extract SPARK  Logs
### - Applications, Executors and Environment Variables
###############################################################

extract_spark_logs() {

    SPARK_out_dir=$output_dir/SPARK/$extract_date/
    mkdir -p $SPARK_out_dir

    if [ "$SPARK_HS_SECURE" == "Y" ]; then
        CURL="$CURL -k "
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi

    if [ "$SPARK_HS_KERBERIZED" == "Y" ]; then

        echo " Kerberos is set as True. Make sure to Kinit before executing the script. Current Credential Cache is ... "
        eval klist
        echo "                                                                   "

        ## Patch up Kerberos URL
        sparkurl=$(echo $CURL$kerburl$http)
    else
        ## Patch up Kerberos URL
        sparkurl=$(echo $CURL$http)
    fi


    if [ "$INITIAL_EXEC" == "Y" ]; then
         extract_start_date=`date -d '-1 week' +"%Y-%m-%d"`
    else
         extract_start_date=`date -d '-1 day' +"%Y-%m-%d"`
    fi


    sparkHSapps=$sparkurl$SPARK_HS_URL:$SPARK_HS_PORT/api/v1/applications?minDate=$extract_start_date
    sparkHSlist=`$sparkurl$SPARK_HS_URL:$SPARK_HS_PORT/api/v1/applications?minDate=$extract_start_date |grep id | cut -f2 -d":" |sed -e 's/"//g' | sed -e 's/,//g'`

    sparkApps=Spark_Applications_$curr_date.json

    eval $sparkHSapps $SEARCH_REPLACE > $SPARK_out_dir$sparkApps

    ### Comment out Extract of Executor and env data.
    #for apps in $sparkHSlist;
    #do
    #    echo $apps
    #    applEnv=$sparkurl$SPARK_HS_URL:$SPARK_HS_PORT/api/v1/applications/$apps/environment
    #    applExec=$sparkurl$SPARK_HS_URL:$SPARK_HS_PORT/api/v1/applications/$apps/executors

    #    eval  $applEnv $SEARCH_REPLACE > ${SPARK_out_dir}${apps}_env.json
    #    eval  $applExec $SEARCH_REPLACE > ${SPARK_out_dir}${apps}_executors.json
    #done


}


###########################################
### Ambari Blueprint Extract
###########################################


extract_ambari_bp() {
    echo " Extracting Ambari Blueprint .. "

    if [ $AMBARI_SECURED == "Y" ]; then
        CURL="$CURL -k "
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi

    if [[ $DISTRIBUTION == 'HDP' && $IS_HDI == 'Y' ]]; then
        ambari_url=$AMBARI_SERVER
    else
        ambari_url=$AMBARI_SERVER:$AMBARI_PORT
    fi

    ### Ambari Metrics
    bpurl="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME?format=blueprint"
    ambariHosts="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/hosts?fields=Hosts/cpu_count,Hosts/disk_info,Hosts/total_mem,Hosts/os_type"
    ambariServices="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/services"
    ambariComponents="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/hosts?fields=host_components/host_name"
    ambariStack="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/stack_versions/1"

    ### Ambari RM and HDFS Metrics

    ambariHDFS="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/services/HDFS/components/NAMENODE?fields=metrics"
    ambariDN="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/services/HDFS/components/DATANODE?fields=metrics"
    ambariRM="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/services/YARN/components/RESOURCEMANAGER"
    ambariNM="$CURL -X GET -u $AMBARI_ADMIN_USERID:$AMBARI_ADMIN_PASSWORD $http$ambari_url/api/v1/clusters/$CLUSTER_NAME/services/YARN/components/NODEMANAGER"

    bppath=AmbariBlueprint_$curr_date.json
    hostpath=AmbariHost_$curr_date.json
    servicepath=AmbariServices_$curr_date.json
    componentspath=AmbariComponents_$curr_date.json
    stackpath=AmbariStack_$curr_date.json

    ambarihdfspath=AmbariHDFS_$curr_date.json
    ambaridnpath=AmbariDN_$curr_date.json
    ambarirmpath=AmbariRM_$curr_date.json
    ambarinmpath=AmbariNM_$curr_date.json

    eval $bpurl $SEARCH_REPLACE > $ambari_out_dir$bppath
    eval $ambariHosts $SEARCH_REPLACE > $ambari_out_dir$hostpath
    eval $ambariComponents $SEARCH_REPLACE > $ambari_out_dir$componentspath
    eval $ambariServices $SEARCH_REPLACE > $ambari_out_dir$servicepath
    eval $ambariStack $SEARCH_REPLACE > $ambari_out_dir$stackpath

    eval $ambariHDFS $SEARCH_REPLACE > $ambari_out_dir$ambarihdfspath
    eval $ambariDN $SEARCH_REPLACE > $ambari_out_dir$ambaridnpath
    eval $ambariRM $SEARCH_REPLACE > $ambari_out_dir$ambarirmpath
    eval $ambariNM $SEARCH_REPLACE > $ambari_out_dir$ambarinmpath

}


###########################################
### Extract HDP Logs
###########################################

extract_ranger_policies() {

    if [ "$RANGER_SECURED" == "Y" ]; then
        CURL="$CURL -k "
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi


    if [[ $DISTRIBUTION == 'HDP' && $IS_HDI == 'Y' ]]; then
        ranger_url=$AMBARI_SERVER
    else
        ranger_url=$RANGER_URL:$RANGER_PORT
    fi


    rangerRepos="$CURL -X GET -u $RANGER_USER:$RANGER_PWD -X GET $http$ranger_url/service/public/api/repository"
    rangerPolicies="$CURL -X GET -u $RANGER_USER:$RANGER_PWD -X GET $http$ranger_url/service/public/api/policy"

    ranger_repos=Ranger_Repos_$curr_date.json
    ranger_policies=Ranger_Policies_$curr_date.json

    eval $rangerRepos > $ranger_out_dir$ranger_repos
    eval $rangerPolicies > $ranger_out_dir$ranger_policies

}

extract_hdp() {

    check_kerberos
    extract_yarn

    if [ "$SPARK_EXTRACT" == "Y" ]; then
        extract_spark_logs
    fi

    if [ "$INITIAL_EXEC" == "Y" ]; then
        ambari_out_dir=$output_dir/AMBARI/$extract_date/
        mkdir -p $ambari_out_dir

       extract_ambari_bp


       if [ "$IS_RANGER_SETUP" == "Y" ]; then
            ranger_out_dir=$output_dir/RANGER/$extract_date/
            mkdir -p $ranger_out_dir
            extract_ranger_policies
       fi
       echo " ####################################################################################################"
       echo " NOTE: This is an Initial Extract. Please inspect the files to make sure the extracts are fine .... "
       echo " ####################################################################################################"
    fi

}

### Extract Cloudera Manager Timeseries data for Usage, Roles, HDFS Usage and other Metrics

extract_cm_timeseries() {

    cm_extract_curr_date=`date +"%Y-%m-%d"`
    cm_extract_start_date=`date -d '-1 month' +"%Y-%m-%d"`

    ## CM Host Roles and HDFS Usage

    cmHostRoles="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?query=select%20scm_role_state,uptime%20where%20category=ROLE"
    cmHDFSUsage="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?query=SELECT%20dfs_capacity,dfs_capacity_used,dfs_capacity_free,dfs_capacity_used_non_hdfs,dfs_capacity_across_datanodes,dfs_capacity_used_across_datanodes,dfs_capacity_used_non_hdfs_across_datanodes"

    cm_HostRoles=cmHostRoles_$curr_date.json
    cm_HDFSUsage=cmHDFSUsage_$curr_date.json

    eval $cmHostRoles $SEARCH_REPLACE > $CM_out_dir$cm_HostRoles
    eval $cmHDFSUsage $SEARCH_REPLACE > $CM_out_dir$cm_HDFSUsage

    ## Yarn And Impala  Level Memory and CPU Utlization
    cmYarnUtilization="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD '$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?desiredRollup=HOURLY&mustUseDesiredRollup=true&from=$cm_extract_start_date&to=$cm_extract_curr_date&query=select%20allocated_memory_mb,allocated_memory_mb_cumulative,available_memory_mb,allocated_memory_gb,available_memory_mb,available_vcores,allocated_vcores,allocated_vcores_cumulative'"
    cmYarnMemCpu="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD '$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?desiredRollup=HOURLY&mustUseDesiredRollup=true&from=$cm_extract_start_date&to=$cm_extract_curr_date&query=SELECT%20yarn_reports_containers_used_vcores,total_allocated_vcores_across_yarn_pools,total_available_vcores_across_yarn_pools%20as%20vcores_available,yarn_reports_containers_used_memory,total_available_memory_mb_across_yarn_pools,total_allocated_memory_mb_across_yarn_pools%20as%20memory_available'"
    cmImpalaUtilization="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD '$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?desiredRollup=HOURLY&mustUseDesiredRollup=true&from=$cm_extract_start_date&to=$cm_extract_curr_date&query=select%20queries_successful_rate,queries_ingested_rate,queries_timed_out_rate,queries_rejected_rate,impala_query_thread_cpu_time_rate,impala_query_admission_wait_rate,impala_query_query_duration_rate,impala_query_memory_accrual_rate,mem_rss_across_impalads,total_mem_rss_across_impalads,num_queries_rate_across_impalads,total_num_queries_rate_across_impalads,impala_memory_rss,impala_memory_total_used,total_mem_tracker_process_limit_across_impalads,total_impala_admission_controller_local_backend_mem_reserved_across_impala_daemon_pools,total_impala_admission_controller_local_backend_mem_usage_across_impala_daemon_pools%20WHERE%20category=CLUSTER'"

    cm_YarnUtilization=cmYarnUtilization_$curr_date.json
    cm_Yarn_MemCPU=cmYarnMemoryAndCPU_$curr_date.json
    cm_ImpalaUtilization=cmImpalaUtilization_$curr_date.json

    eval $cmYarnUtilization $SEARCH_REPLACE > $CM_out_dir$cm_YarnUtilization
    eval $cmYarnMemCpu $SEARCH_REPLACE > $CM_out_dir$cm_Yarn_MemCPU
    eval $cmImpalaUtilization $SEARCH_REPLACE > $CM_out_dir$cm_ImpalaUtilization

    ## Cluster Level Memory and CPU Utlization
    cmClusterCPUUtilization="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD '$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?desiredRollup=HOURLY&mustUseDesiredRollup=true&from=$cm_extract_start_date&to=$cm_extract_curr_date&query=select%20cpu_percent_across_hosts,total_cores_across_hosts,total_cpu_percent_across_hosts%20WHERE%20category=CLUSTER'"
    cmClusterMemoryUtilization="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD '$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/timeseries?desiredRollup=HOURLY&mustUseDesiredRollup=true&from=$cm_extract_start_date&to=$cm_extract_curr_date&query=SELECT%20total_physical_memory_used_across_hosts,total_physical_memory_total_across_hosts,100*total_physical_memory_used_across_hosts/total_physical_memory_total_across_hosts%20as%20cluster_memory_percent_usage%20WHERE%20category=CLUSTER'"

    cm_ClusterCPUUtilization=cmClusterCPUUtilization_$curr_date.json
    cm_ClusterMemoryUtilization=cmClusterMemoryUtilization_$curr_date.json

    eval $cmClusterCPUUtilization $SEARCH_REPLACE > $CM_out_dir$cm_ClusterCPUUtilization
    eval $cmClusterMemoryUtilization $SEARCH_REPLACE > $CM_out_dir$cm_ClusterMemoryUtilization

}


###########################################
### Extract CDP Logs
###########################################

extract_cm_info() {

    CM_out_dir=$output_dir/CM/$extract_date/
    mkdir -p $CM_out_dir

    if [ "$CM_SECURED" == "Y" ]; then
        CURL="$CURL -k"
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi

    # saving the cluster name so we can output an error if they set it incorrectly
    CM_CLUSTER_ORIG=$CM_CLUSTER
    CM_CLUSTER=`echo $CM_CLUSTER | sed 's/ /%20/g'`

    # automatically get the API version
    cmCheckVersion="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/version"
    checkResult=`eval $cmCheckVersion | grep "Bad credentials" | wc -l`
    # check if invalid credentials were set
    if [ $checkResult -gt 0 ]; then
        echo "Bad Cloudera Manager credentials. Please validate credentials."
        exit -1
    fi
    # we got here, so set the API version
    CM_API_VERSION=`eval $cmCheckVersion`
    echo "API Version "$CM_API_VERSION

    # check the cluster is a valid name
    cmCheckClusterName="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/clusters/$CM_CLUSTER"
    # check if the cluster is found
    checkResult=`eval $cmCheckClusterName  | grep "not found" | wc -l`
    if [ $checkResult -gt 0 ]; then
        echo "Error: '"$CM_CLUSTER_ORIG"' does not exist. Please confirm value for CM_CLUSTER"
        exit -1
    fi

    # if we are checking impala queries, validate the impala service name is correct
    if [ "$CM_EXTRACT_IMPALA_QUERIES" == "Y" ]; then
        cmCheckImpalaServiceName="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/clusters/$CM_CLUSTER/services/$CM_IMPALA_SERVICE"
        checkResult=`eval $cmCheckImpalaServiceName | grep "not found" | wc -l`
        if [ $checkResult -gt 0 ]; then
            echo "Error: Impala service '"$CM_IMPALA_SERVICE"' not found. Please confirm value for CM_IMPALA_SERVICE"
            exit -1
        fi
    fi


    ###########################################
    ### Cloudera Manager Metrics (Only for Initial Run)
    ###########################################

    if [ "$INITIAL_EXEC" == "Y" ]; then

        cmservices="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/clusters/$CM_CLUSTER/services"
        cmhost="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/hosts"
        cmconfig="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/cm/allHosts/config"
        cmexport="$CURL -X GET -u $CM_ADMIN_USER:$CM_ADMIN_PASSWORD $http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/clusters/$CM_CLUSTER/export"

        cm_services=cmServices_$curr_date.json
        cm_hosts=cmHosts_$curr_date.json
        cm_config=cmConfig_$curr_date.json
        cm_export=cmExport_$curr_date.json

        eval $cmservices $SEARCH_REPLACE > $CM_out_dir$cm_services
        eval $cmhost $SEARCH_REPLACE > $CM_out_dir$cm_hosts
        eval $cmconfig $SEARCH_REPLACE > $CM_out_dir$cm_config
        eval $cmexport $SEARCH_REPLACE > $CM_out_dir$cm_export

    fi



    ###########################################
    #### Extract Cloudera TimeSeries metrics (Daily Extract due to CM Limitations)
    ###########################################

    extract_cm_timeseries

}

############################################################
## Impala Extract created by : Gui Bracialli
############################################################

extract_impala() {

    echo "Extracting Impala Queries "

    IMPALA_out_dir=${output_dir}IMPALA/$extract_date/
    echo $IMPALA_out_dir
    mkdir -p $IMPALA_out_dir

    if [ "$CM_SECURED" == "Y" ]; then
        CURL="$CURL -k "
        http="https://"
    else
        CURL="$CURL "
        http="http://"
    fi

    CM_CLUSTER=`echo $CM_CLUSTER | sed 's/ /%20/g'`
    BASE_URL="$http$CM_SERVER_URL:$CM_SERVER_PORT/api/$CM_API_VERSION/clusters/$CM_CLUSTER/services/$CM_IMPALA_SERVICE/impalaQueries"

    if [ "$INITIAL_EXEC" == "Y" ]; then
       dates=()
       for NUMBER_DAYS in $(seq -w 0 $CM_IMPALA_NUMBER_OF_DAYS)
       do
          dates+=($(date -d "-$NUMBER_DAYS  day" +"%Y-%m-%d"))
       done
    else
       echo "Running in Scheduled mode ... using $yesterday_impala_extract_dt for the extract"
       dates=($yesterday_impala_extract_dt)
    fi

    for DAY in "${dates[@]}"
    do
      for HOUR in $(seq -w 0 23)
      do
        INTERVALS=$(((60 / $CM_IMPALA_INTERVAL_MINUTES)-1))
        for RANGE in $(seq 0 $INTERVALS)
        do
          MINUTE_START=$(($RANGE * $CM_IMPALA_INTERVAL_MINUTES))
          if [ $MINUTE_START -lt 10 ]
          then
            MINUTE_START="0${MINUTE_START}"
          fi
          MINUTE_END=$(((($RANGE + 1) * $CM_IMPALA_INTERVAL_MINUTES) - 1))
          if [ $MINUTE_END -lt 10 ]
          then
            MINUTE_END="0${MINUTE_END}"
          fi
          PAGES=$(($CM_IMPALA_PAGES - 1))
          for PAGE in $(seq -w 0 $PAGES)
          do
             OFFSET=$(($PAGE * 1000))
             URL_FILTER="$BASE_URL?from=${DAY}T${HOUR}%3A${MINUTE_START}%3A00.000Z&to=${DAY}T${HOUR}%3A${MINUTE_END}%3A59.999Z&filter=&limit=1000&offset=$OFFSET"
             echo "extracting $URL_FILTER"

             cmimpala="$CURL -X GET -u ${CM_ADMIN_USER}:${CM_ADMIN_PASSWORD} '$URL_FILTER'"

             cm_impalaext=impala_${DAY}_${HOUR}_${MINUTE_START}_${MINUTE_END}_${OFFSET}.json

             impalaout=`eval $cmimpala $SEARCH_REPLACE`
             impalaoutexists=`echo $impalaout |grep queryId |wc -l`

             if [ $impalaoutexists == 0 ]; then
                continue
             else
                echo $impalaout > $IMPALA_out_dir$cm_impalaext
	         fi

             #eval $cmimpala > $IMPALA_out_dir$cm_impalaext

             #echo $IMPALA_out_dir$cm_impalaext
          done
        done
      done
    done

    if grep -q "Impala query scan limit reached" ${IMPALA_out_dir}*.json; then
      echo -e "\n\n\n\n\n\n\n********************************"
      echo "IMPALA QUERY SCAN LIMIT HIT, PLEASE REDUCE CM_IMPALA_INTERVAL_MINUTES AND INCREASE CM_IMPALA_PAGES"
      echo -e "********************************\n\n\n\n\n\n\n\n\n"
    fi

}



extract_cdp() {

    extract_cm_info

    check_kerberos
    extract_yarn

    if [ "$SPARK_EXTRACT" == "Y" ]; then
        extract_spark_logs
    fi


    if [ "$INITIAL_EXEC" == "Y" ]; then
        ### Extract Ranger Policies and Repos if set up CDP 
        if [ "$IS_RANGER_SETUP" == "Y" ]; then
            ranger_out_dir=$output_dir/RANGER/$extract_date/
            mkdir -p $ranger_out_dir
            extract_ranger_policies

            #extract_sentry_policies
        fi
    fi

    ####################################
    ## Extracting Impala
    ####################################
    if [ "$CM_EXTRACT_IMPALA_QUERIES" == "Y" ]; then
       extract_impala
    fi

    if [ "$INITIAL_EXEC" == "Y" ]; then
    echo " #################################################################################################################"
    echo " NOTE: This is an Initial Extract.  Please inspect the files to:                                                  "
    echo " -----  1. Make sure the extracts looks fine ....                                                                 "
    echo "        2. Cloudera Manager Export  for  any sensitive information like user id and passwords                     "
    echo "        3. Impala extract for hard coded NPI or PHI values in the queries                                         "
    echo " #################################################################################################################"
    fi

}

extract_other_oss() {

    check_kerberos
    extract_yarn

    if [ "$SPARK_EXTRACT" == "Y" ]; then
        extract_spark_logs
    fi

    echo " ####################################################################################################"
    echo " NOTE:  Please inspect the files to make sure the extracts are fine .... "
    echo " ####################################################################################################"

}


check_run_status() {

    tracker_file=$runtracker_dir"/initialrun.txt"

    if [ -f "$tracker_file" ]; then

        INITIAL_EXEC="N"
        echo " ####################################################################################################"
        echo "  Incremental Extract ... Checking for other $DISTRIBUTION files"
        echo " ####################################################################################################"

         ### Check for Ambari / CM / NodeDumps to confirm if the initial extract exists 

	if [ "$DISTRIBUTION" == "HDP" ]; then

            filecheck=`find ${output_dir}AMBARI/*/ -name Ambari*.json  | wc -l`

            if [ $filecheck -le 9 ]; then 
               INITIAL_EXEC="Y"
               echo "Missing Ambari Configs ... Reverting to Initial Extract ... " 
            fi

  	    else if [ "$DISTRIBUTION" == "CDH" ]; then

                 filecheck=`find ${output_dir}CM/*/ -name cm*.json  | wc -l`

                 if [ $filecheck -le 10 ]; then 
                    INITIAL_EXEC="Y"
                    echo "Missing Cloudera Manager Configs ... Reverting to Initial Extract ... " 
                 fi 

	      else if [ "$DISTRIBUTION" == "OTH" ]; then

                      yarnNodes=`find ${output_dir}YARN/*/ -name YarnNodesDump*.json  | wc -l`

                      if [ $yarnNodes -le 1 ]; then 
                           INITIAL_EXEC="Y"
                           echo "Missing Yarn Nodes ... Reverting to Initial Extract ... " 
                      fi
                 
                   else
		      echo  " Invalid Distribution"
		      exit 1
                   fi
              fi
         fi


    else
         INITIAL_EXEC="Y"
          echo " ####################################################################################################"
          echo "  Processing Initial Extract ... "
          echo " ####################################################################################################"
    fi


}

##########################################################################################################
################################## START of Main Code ####################################################
##########################################################################################################


echo "Trigger Time: " $curr_date
echo "Dist: "  $DISTRIBUTION

if [ -z $1 ]; then 
   echo " Please enter the secret Key to decrypt the password .. "
   echo " Syntax : ./profiler.sh mySecretKey " 
   exit 1 
else 
   saltKey=$1    
fi 


#echo " Creating Output Directory : "
mkdir -p $output_dir

## Check to see if the intial extract was executed
check_run_status

if [ "$DISTRIBUTION" == "HDP" ]; then

      echo " Distribution is Hortonworks. Starting  Extact ... "


      AMBARI_ADMIN_PASSWORD=`echo $AMBARI_ADMIN_PASSWORD | openssl enc -base64 -d -aes-256-cbc  -nosalt -pass pass:$saltKey`

      RANGER_PWD=`echo $RANGER_PWD | openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:$saltKey`

      extract_hdp

else if [ "$DISTRIBUTION" == "CDH" ]; then
      echo " Distribution is Cloudera . Starting Extract ... "
      
      CM_ADMIN_PASSWORD=`echo $CM_ADMIN_PASSWORD| openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:$saltKey`

      if [ "$IS_CDP" == "Y" ]; then 
            RANGER_PWD=`echo $RANGER_PWD | openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:$saltKey`
      fi 
  
      extract_cdp

      else if [ "$DISTRIBUTION" == "OTH" ]; then
              echo " Other Open Source Distribution . Starting Extract ... "
              extract_other_oss

           else
              echo  " Invalid Distribution"
              exit 1
	   fi
     fi
fi

## Create Tracker Directory
if [ "$INITIAL_EXEC" == "Y" ]; then
  mkdir -p $runtracker_dir
  echo "Initial Run" > $tracker_file
fi
