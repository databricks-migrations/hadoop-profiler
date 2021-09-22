# Profiler For hadoop 

### This Batch Script will Extract  the following metrics from a Hadoop Cluster :

### 1. YARN Application execution, Host , metrics and Scheduler Information

### 2. If the Distribution is HDP, then  extract
####     -  the blueprint, Service, hosts and host components from Ambari
####     -  Ranger policies and Repos if Ranger is Used

### 3. If the Distribution is CDH, then  extract
####     -  the Services, host and components from CM  
####     -  Impala logs based on the input dates 

<h2><span style="font-weight: 400;">Configuration:</span></h2>
<ul>
<li style="font-weight: 400;" aria-level="1"><span style="font-weight: 400;">The following changes need to be applied to the configuration file.&nbsp;</span></li>
</ul>
<p>&nbsp;</p>
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
<p><span style="font-weight: 400;">INITIAL_EXEC</span></p>
</td>
<td>
<p><span style="font-weight: 400;">For initial Execution (Y/N) .&nbsp;</span></p>
<p><span style="font-weight: 400;">Y -&gt; Includes Ambari or CM extracts, Ranger, YARN Host, Scheduler and metrics.&nbsp;</span></p>
<p><span style="font-weight: 400;">N -&gt;&nbsp; Extracts only the RM Applications.&nbsp;</span></p>
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
<p><span style="font-weight: 400;">IS_SECURE</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Is https enabled (Y/N)&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">IS_KERBERIZED</span></p>
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
<td>&nbsp;</td>
<td>
<p><span style="font-weight: 400;">DISTRIBUTION</span></p>
</td>
<td>
<p><span style="font-weight: 400;">On-Prem Distribution : HDP or CDP&nbsp;</span></p>
</td>
</tr>
<tr>
<td rowspan="12">
<p><span style="font-weight: 400;">Ambari and Ranger Related Configurations if the distribution is HDP&nbsp;</span></p>
</td>
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
<p><span style="font-weight: 400;">HDP Cluster name&nbsp;</span></p>
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
<td rowspan="10">
<p><span style="font-weight: 400;">Cloudera Manager and Impala&nbsp; Related Configurations if the distribution is CDP</span></p>
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
<p><span style="font-weight: 400;">Cloudera Manager Cluster Name&nbsp;</span></p>
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
<p><span style="font-weight: 400;">CM_IMPALA_URL</span></p>
</td>
<td>
<p><span style="font-weight: 400;">URL for Impala. Same as Cloudera manager URL&nbsp;</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_IMPALA_EXTRACT_DATES</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Range of dates separated by spaces&nbsp;</span></p>
<p><span style="font-weight: 400;">Example: </span><span style="font-weight: 400;">"2021-08-25 2021-08-26 2021-08-27"</span></p>
</td>
</tr>
<tr>
<td>
<p><span style="font-weight: 400;">CM_IMPALA_SERVICE</span></p>
</td>
<td>
<p><span style="font-weight: 400;">Service name for Impala. Can be obtained from CM.&nbsp;</span></p>
</td>
</tr>
</tbody>
</table>
