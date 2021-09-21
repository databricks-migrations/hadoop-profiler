# Profiler For hadoop 

### This Batch Script will Extract  the following metrics from a Hadoop Cluster :

### 1. YARN Application execution, Host , metrics and Scheduler Information

### 2. If the Distribution is HDP, then  extract
####     -  the blueprint, Service, hosts and host components from Ambari
####     -  Ranger policies and Repos if Ranger is Used

### 3. If the Distribution is CDH, then  extract
####     -  the Services, host and components from CM  
####     -  Impala logs based on the input dates 

