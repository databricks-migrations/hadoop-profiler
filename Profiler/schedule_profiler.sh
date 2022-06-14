#!/bin/bash

#######################################################################################################
# This Batch Script is used to schedule the profiler ONLY IF any scheduling options are not feasible
# ---------------------------------------------------------------------------------------------------
#
# This script will trigger the profiler extract to run on a specific frequency. 
# The Frequency of execution can be set on the profiler.conf 
#
# NOTE:- 
# 1. If executed in background mode make sure to check the Output folder to confirm if the extracts are collected 
#    On a particular frequency 
#
# 2. Run the command ps -ef |grep profiler to make sure the script is running on the background. 
#
# 3. The Default execution mode is "Interactive / Foreground" 
#
#####################################################################################


. `dirname ${0}`/profiler.conf

## Init Variables

export curr_date=`date +"%Y-%m-%d"`
export extract_end_date=`date +%Y-%m-%d -d "+ $NO_OF_DAYS day"`

run_profiler() { 

   sleep_time=`expr ${FREQUENCY_OF_EXECUTION} \* 60 \* 60`

   echo "Sleep Time: $sleep_time Current date: $curr_date Extract End Date: $extract_end_date" 

   mkdir -p ./logs

   while [ $curr_date != $extract_end_date ];  
   do
      
      . profiler.sh $saltKey  2>&1 | tee ./logs/profiler_extracts.log
      sleep $sleep_time
   done

}



##########################################################################################################
################################## START of Main Code ####################################################
##########################################################################################################

if [ -z $1 ]; then
   echo " Please enter the secret Key to decrypt the password .. "
   echo " Syntax : ./schedule_profiler.sh mySecretKey "
   exit 1
else
   saltKey=$1
fi


echo "Triggering profiler for ${NO_OF_DAYS} Days  on a ${FREQUENCY_OF_EXECUTION} Hour frequency" 

run_profiler
