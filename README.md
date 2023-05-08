# Hadoop Profiler

>### 1. About Hadoop Profiler
Hadoop Profiler is a Migration Assessment Tool to profile and generate metrics out of YARN (which is the primary resource management and scheduling tech on Hadoop). These metrics could be useful to understand  applications that are running in an hadoop environment and generate insights into migration strategies.

>### 2. Overview
The Profiler consists of a simple shell script, [profiler.sh](Profiler/profiler.sh) which extracts data from YARN, Ambari or Cloudera Manager. This script takes required configuration values from a configuration file, [profiler.conf](Profiler/profiler.conf) which needs to be updated with required values before the execution.

#### Metrics/Information extracted from a Hadoop Cluster
1. YARN Application execution metrics, Host details and scheduler information.
2. Spark History Server Metrics.
3. CDH Specific information:
    - Services, Host and Components from Cloudera Manager (CM)
    - Impala logs based on the input dates
4. HDP (or HD Insight) Specific information:
    - The blueprint, Services, Host and Components from Ambari
    - Ranger policies and Repos (incase Ranger is used)
    - NOTE: Set the HDI flag to Y or N if the distribution is Azure HD Insight.
5. Other Distributions:
    - Only YARN and Spark History Server metrics are supported at this time.



#### Profiler Script Configutation

<table>
<tbody>
<tr>
<td>&nbsp;</td>
<td>
<p><strong>Properties</strong></p>
</td>
<td>
<p><strong>Description</strong></p>
</td>
</tr>

<tr>
<td>&nbsp;</td>
<td>
<p>PROFILER_OUTPUT_PATH</p>
</td>
<td>
<p> Location where the profiler outputs are stored. If not provided, the output will be written in the default profiler folder.</p>
</td>
</tr>

<tr>
<td rowspan="8">
<p><span style="font-weight: 400;">YARN Resource manager Configs</span></p>
</td>



<td>
<p><span style="font-weight: 400;">RM_SERVER_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">YARN Resource manager URL. Comma separated URLs in case of HA&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">Use Cloudera Manager or Ambari, navigate to YARN, open Resource Manager and copy the host name from URL in your browser</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_SERVER_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Resource Manager Port&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(see instructions above)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_SECURE</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled (Y/N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_KERBERIZED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is Kerberized (Y/ N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">GOT_KEYTAB</span></p>
</td>
<td>
<p><span style="font-weight: 400;">To Automate the extract in case of a Kerberized Environment.</span></p>
<br />
<p><span style="font-weight: 400;">USE Y, if you want script to run kinit based on parameters below</span></p>
<br />
<p><span style="font-weight: 400;">USE N, if you already have a kerberos ticket active in the environment. (in this case, script will not try to do kini and you don't&nbsp; need kerberos settings below)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">KEYTAB_PATH</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Path to the Keytab file</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">KEYTAB</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Keytab file Name&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">PRINCIPAL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Keytab Principal for Kinit&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>



<tr>
<td rowspan="8">
<p><span style="font-weight: 400;">YARN Resource manager Configs</span></p>
</td>
<td>
<p><span style="font-weight: 400;">RM_SERVER_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">YARN Resource manager URL. Comma separated URLs in case of HA&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">Use Cloudera Manager or Ambari, navigate to YARN, open Resource Manager and copy the host name from URL in your browser</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_SERVER_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Resource Manager Port&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(see instructions above)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_SECURE</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled (Y/N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RM_KERBERIZED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is Kerberized (Y/ N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">GOT_KEYTAB</span></p>
</td>
<td>
<p><span style="font-weight: 400;">To Automate the extract in case of a Kerberized Environment.</span></p>
<br />
<p><span style="font-weight: 400;">USE Y, if you want script to run kinit based on parameters below</span></p>
<br />
<p><span style="font-weight: 400;">USE N, if you already have a kerberos ticket active in the environment. (in this case, script will not try to do kini and you don't&nbsp; need kerberos settings below)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">KEYTAB_PATH</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Path to the Keytab file</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">KEYTAB</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Keytab file Name&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">PRINCIPAL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Keytab Principal for Kinit&nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(use only when GOT_KEYTAB=Y)</span></p>
</td>
</tr>
<tr>
<td>
</tr>
<tr>
<td rowspan="8">
<p><span style="font-weight: 400;">Spark History Server Configs</span></p>
</td>
<td>
<p><span style="font-weight: 400;">SPARK_HS_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Spark History Server URL. &nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">Use Cloudera Manager or Ambari, navigate to Spark Service and copy the host name from URL in your browser</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">SPARK_HS_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Spark History Server Port &nbsp;</span></p>
<br />
<p><span style="font-weight: 400;">(see instructions above)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">SPARK_HS_SECURE</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled (Y/N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">SPARK_HS_KERBERIZED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is Kerberized (Y/ N)&nbsp;</span></p>
</td>
</tr>
<tr>

</tr>
<tr>

</tr>
<tr>

</tr>
<tr>

</tr>
<tr>
<td>&nbsp;</td>
<td>
<p><span style="font-weight: 400;">DISTRIBUTION</span></p>
</td>
<td>
<p><span style="font-weight: 400;">On-Prem Distribution : HDP or CDH or OTH&nbsp;</span></p>
</td>
</tr>
<td rowspan="10">
<p><span style="font-weight: 400;">Cloudera Manager and Impala&nbsp; Related Configurations if the distribution is CDH</span></p>
</td>
<td>
<p><span style="font-weight: 400;">CM_SERVER_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager URL&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_SERVER_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager Port&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_ADMIN_USER</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager Admin User</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_ADMIN_PASSWORD</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager Password&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_CLUSTER</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager Cluster Name.  You will need to convert any special characters to URL encoding - (https://www.w3schools.com/tags/ref_urlencode.ASP) &nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_API_VERSION</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Cloudera Manager API Version. Can be Obtained from CM UI. Click &ldquo;Support&rdquo; and &ldquo;API Documentation&rdquo;.&nbsp; API Version number should be available on this page (like v00)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_SECURED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled for Cloudera Manager (Y/N)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_IMPALA_NUMBER_OF_DAYS</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Number of days for initial extraction</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_IMPALA_INTERVAL_MINUTES</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Number of minutes per json file extracted, options are 1, 2, 3, 6, 10, 20, 30, 60</span></p>
</td>
</tr><tr>
<td>
<p><span style="font-weight: 400;">CM_IMPALA_PAGES</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Number of pages to be extracted per file (interval), cloudera manager limits 1000 queries per page&nbsp;</span></p>
</td>
</tr>

<tr>
<td rowspan="12">
<p><span style="font-weight: 400;">Ambari and Ranger Related Configurations if the distribution is HDP&nbsp;</span></p>
</td>

<td>
<p><span style="font-weight: 400;">IS_HDI</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is the Distribution Azure HD Insight (Y/N)&nbsp;</span></p>
</td>
</tr>
<td>
<p><span style="font-weight: 400;">AMBARI_ADMIN_USERID</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ambari Admin User id&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">AMBARI_ADMIN_PASSWORD</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ambari Admin Password&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">AMBARI_SERVER</span></p>
</td>
<td>
<p><span style="font-weight: 400;">URL for Ambari Server&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">AMBARI_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ambari Server Port&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CLUSTER_NAME</span></p>
</td>
<td>
<p><span style="font-weight: 400;">HDP Cluster name - You will need to convert any special characters to URL encoding - (https://www.w3schools.com/tags/ref_urlencode.ASP) &nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">AMBARI_SECURED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled on Ambari (Y/N)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">IS_RANGER_SETUP</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is Ranger enabled on the cluster (Y/N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RANGER_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">URL for Ranger Admin&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RANGER_PORT</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ranger Admin Port&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RANGER_SECURED</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled for Ranger URL (Y/N)</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RANGER_USER</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ranger admin User&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">RANGER_PWD</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Ranger admin Password&nbsp;</span></p>
</td>
</tr>
<tr>
</tbody>
</table>


>### 3. How to Run

**Initial Extraction :**  
It is recommended to run the first execution manualy to make sure correct configuration values.
Execute the following on the edge node or a host that can reach the YARN Resource Manager or Ambari or CM.

1. git clone -b main https://github.com/databricks-migrations/hadoop-profiler.git
2. cd Profiler/Profiler
3. Update [profiler.conf](Profiler/profiler.conf) to required settings depending on your Hadoop distribution. The code automatically determines if its an Initial or Incremental Extract.
4. Password Encryption:  
    - Open text passwords are not allowed in the configs file and passwords needs to be encrypted using Openssl.
    - Use the following command to encrypt the password value- replace `<admin password>` with the actual password
         - <font face="Courier New"> echo '"`<admin password>`"' | openssl enc -base64 -e -aes-256-cbc -nosalt -pass pass:mySecretPassKey </font>
    - <b>CAUTION:  
    a. Make sure to enclose the password with in Single and Double Quotes (example provided above)  
    b. Ignore the 'Deprecated Key' Warning (if any).  
    c. Keep your secret Key 'mySecretPassKey' safe and pass it as an arugment to the profiler. Refer to Step 4.   YOU MUST USE THE SAME SECRET KEY WHEN ENCRYPTING ANY PASSWORD  
    d. The output of the openssl command is the value you specify in the profiler.conf file  
          e.g.
          Encrypt the Cloudera Manager password using the openssl command.
          Use output generate as the CM_ADMIN_PASSWORD value.   
          You will need to do this separately for RANGER_PWD (or AMBARI_ADMIN_PASSWORD).  </b>
3. <font face="Courier New"> chmod +x profiler.sh </font>
4. <font face="Courier New"> ./profiler.sh mySecretPassKey </font>
5. Make sure the Output extracts have the data extracted.

**Daily extraction :**  
- Schedule profiler.sh to run daily for at least 2 weeks.  Please create a cron job to execute this script.   For environments with more than 10K jobs submitted per day in YARN,  consider running this script once an hour. Otherwise, run once a day.
- Frequency of Excution: YARN has a default log  aggregation and retention set as 10000 (yarn.resourcemanager.max-completed-applications)  and starts cleaning up the older application history. It is important to check this value and schedule the extracts appropriately to capture all the application.
- Note:  At any given time, if there is a need to initial extract, delete the folder "ExtractTracker" with in the Profiler directory.  

- If we cannot schedule the profiler using cron or any enterprise scheduler tools,  Refer to Section 6 on how to schedule the profiler.

>### 4. Output:

All the extracts are stored as part of the Output Folder within their respective components Sub-folders.

>### 5. How to mask data:

The profiler allows you to invoke a search and replace command to sanitize data as its extracted from CM/Ambari/Hadoop Services.  The default implementation is using the sed command.  Provided is a sed.txt file that acts as the sed command file.   The profiler assumes this file exists in its execution directory.  You can use a different implementation as long as the command you invoke can accept input from stdin and will write results to stdout. Please remember to include the "|" operator in the SEARCH_REPLACE parameter.

To use the default data masker, uncomment the SEARCH_REPLACE parameter.  Modify the sed.txt file as required.

NOTE: To ensure the data can be analyzed properly, obfuscated hostnames and IPs must be unique:
- For IP addresses, set up a replacement rule to substitute a subset of the leading numbers of the address e.g. first 2 decimals in address
- For hostnames, set up a replacement rule to substitute host domains, or prefix

<br>

>### 6. Scheduling the profiler:


If the profiler cannot be scheduled using cron or other scheduler, use the schedule_profiler.sh to trigger the profiler in the background using nohup.
Make sure to pass the secret Key  as an arugment to the profiler.


- For Example : <font face="Courier"> nohup ./schedule_profiler.sh mySecretPassKey &>/dev/null & </font>

The scheduler is a  depends on the following configurations in the config file:

<table>
<tbody>
<tr>

<td>
<p><strong>Properties</strong></p>
</td>
<td>
<p><strong>Description</strong></p>
</td>
</tr>

<tr>
<td>
<p><span style="font-weight: 400;">FREQUENCY_OF_EXECUTION</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Determines the frequency of Execution (in hours) in a day(Max 24 hours). For Example if the value is set as 5, the profiler will be executed every 5 hours. &nbsp;</span></p>
<br />
</td>
</tr>

<tr>
<td>
<p><span style="font-weight: 400;">NO_OF_DAYS</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Total number of days to run the profiler. Typically 14 days.&nbsp;</span></p>
<br />
</td>
</tr>


</tbody>
</table>

The profiler execution logs can be found in the <font face="Courier New"> /logs/profiler_extracts.log </font> file in the profiler folder

<br>
<br>


>### FAQ :  

#### 1. Does the  profiler extract any sensitive data ?


No.  The profiler has zero access to the customer data nor code.  
The profiler runs  REST API (curl) commands against YARN RM, Ambari or Cloudera Manager and collects:


### <u> Environment Information </u>
<li> Cluster Name  
<li> Software Version    
<li> Hostnames / IPs / ports
<li> IP addresses
<li> Rack IDs
<li> CPU / Memory / Disk Information
<li> Software Installation Directories
<li> Configuration Directories


### <u> All Hadoop Services </u>
<li> Service Name
<li> Software version
<li> Hostnames / IPs / ports
<li> Service status
<li> Configuration Settings
<li> Passwords are redacted / omitted by Ambari/Cloudera Manager


### <u> Ranger </u>
<li> Hostnames / IPs / ports
<li> Configuration information
<li> User names
<li> Group names
<li> Policy (permission details)


### <u> YARN </u>
<li> Hostnames / IPs / ports
<li> Job name
<li> May contain partial SQL Query Text
<li> User name
<li> Queue name
<li> Numerics - Metrics - vcores, memory, elapsed time, etc
<li> Diagnostics String  - may contain full SQL Query Text


### <u> Impala </u>
<li> Hostnames / IPs / ports
<li> Usernames
<li> Pool names
<li> Numerics - Metrics - memory, elapsed time, etc
<li> Full SQL Query Text


### <u> Spark Applications </u>
<li> Hostnames and ports
<li> Directory names to log location
<li> Numeric metrics     

<br>
<br>


#### 2. Does running the profiler has any impact on the cluster performance ?

The profiler just utilizes the REST API commands which are exposed by YARN RM  / Ambari / Cloudera Manager.  Executing the profiler once daily should not cause any performance issues.



#### 3. Does the profiler transmit any data to external URL or  collectors ?  

No. All the results are stored as part of the Output folder within the Profiler base folder. The profiler cannot transmit any data  in an automated way and has to be manually shared by the customer (either by email or by using the upload script)  



#### 4. Is the output data encrypted or stored in a custom format ?  

No. The output data is in plaintext (csv or json).  This data can be sanitized as needed by the customer



#### 5. I don't have access to Cloudera Manager / Ambari, can the profiler still collect data ?  

Yes.  Set the DISTRIBUTION=OTH in the profiler.conf file.  With this setting, the profiler will extract YARN and optionally Spark History data.



 #### 6. Does the profiler work against a Mesos environment?

No.  However, from Mesos, you can manually collect container metrics which include cores/memory, and execution time.  This can be used to derive a DBU cost.  Reach out to the SWAT team for more details.



#### 7. Does the profiler support my version of CDH, HDP, or CDP?

The profiler collection script supports CDH 5.x, CDH 6.x HDP 2.x, HDP 3.x, HDI 3.x, HDI 4.x, CDP 7.x Private Cloud (YARN/IMPALA workloads).  

In general, the REST endpoints used are consistent across Hadoop distribution versions with the exception of Cloudera Manager.   There is a setting in profiler.conf (CM_API_VERSION) which should be set with the corresponding API version.  The profiler collection script will use this version information when assembling the Cloudera Manager REST endpoint URL.



#### 8. How do I determine the frequency of execution for Incremental extracts ?

It is important to note that YARN has a default log aggregation and retention set as 10000 (yarn.resourcemanager.max-completed-applications) and starts cleaning up the older application history.Please check this value (in yarn configs - either yarn-defaults or yarn-site.xml)  and schedule the extracts appropriately to capture all the application. For Example:  If the customer is running more than 10K jobs per day, make sure to decrease the frequency to run  every 6-12 hours (instead of a day).

#### 9. How much storage is needed to run the profiler?

Typically the profiler will consume anywhere between 200-300MB of disk space after a 2 week run.  This can vary due to the activity of the hadoop cluster.  To be safe, ensure the location the profiler will run has at least 10GB of free space.
