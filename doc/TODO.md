P wilshire
10.20.2022
change of priority to pull tool

decided that this needs a web frontend to gain traction


10.21.2022

request for workflow for pull..

Note .........

I have a personal goal, to make the transition between different deployment targets automatic.
We should retain a golden set of configs on a git repo. 
We should have tools to translate those configs , as needed, for different deployment targets.

site 
local docker testing
gauntlet
lab

If this operation is not made automatic and seamless we will have test configs bleeding into customer sites , or , even worse we will try and deploy untested configs onto a customer site and try and debug them there.

We are suffering from this failure on an almost daily basis.
We have not solved the problem in over two years.

The task is not difficult....

1/ adjust ip addresses and port designations
2/ modify config directories for logs / databases etc/.
3/ change usernames for sysctl startup scripts.
    the same tool (say dts ) is deployed on each node in a system. 
    different nodes have different configs . We will try to use an ess_controller dts config on a powercloud system.


4/ adjust modbus addressing to cope with different device-ids.
   major vendor that maps different battery modules to differnt device-IDS and keeps the modbus register offsets the same for each module.
   In our simulation environment we need to take the device-id * 1000 an add it to the variable offsets  for each module. Our simulation systems have to have unique variable offsets.
   so the offsets need to be adjusted to run in a simulator and then restored to run on site.

so this 

   "components": [
        {
            "id": "bms_1_info",
            "frequency": 1000,
            "offset_time": 20,
            "device_id": 1,
            "registers": [
                {
                    "type": "Holding Registers",
                    "starting_offset": 298,
                    "number_of_registers": 90,
                    "map": [
                        {
                            "id": "year",
                            "offset": 298,
becomes this
   "components": [
        {
            "id": "bms_1_info",
            "frequency": 1000,
            "offset_time": 20,
            "device_id": 1,
            "registers": [
                {
                    "type": "Holding Registers",
                    "starting_offset": 01298,
                    "number_of_registers": 90,
                    "map": [
                        {
                            "id": "year",
                            "offset": 01298,



End Note....


Config Pull workflow. Extract from site

Objective 1 to copy current live configs from a site to a well defined location.
Objective 2 to allow diff tool to  look for changes in configs.



1/ Select a System ( BRPTX100 , BRPTX10 etc )
2/ Select a site where the system is running:  docker, lab, gauntlet  or a customer site.
3/ Select a pull id ( basically a Date)
4/ pull the config dir from all ( or selected ) site nodes.

This will populate a local directory with an exact copy of all the configs used on the selected nodes on the selected site.

With the shell script version 
you set up the environemnt with  a source file "ncemc10_gauntlet_config.sh"
quit the menu 
then the 
"pullConfigs"  
 command will do the job.  

The initial set up has defined the ip addresses for all the sites and then creates a "pull" directory 
and "scps" /home/hybridos/config into /home/config/pull/NCEMC10/ 

It helps if the system has been set up using ssh-copy-id to allow  passordless access to the different site systems.

The directory structure overview is as follows:

/home/config/pull/NCEMC10/gauntlet/2022-10-14_134555/
                      ess_controller  
                      fleetmanager  
                      site_controller  
                      twins


The pull tool defines a framework for the directory layout to be used by all.
This allows the deploy tool to restore those configs regardless of who "pulled" them.

for example

(tree /home/config/pull/NCEMC10/gauntlet/2022-10-14_134555/twins/)

/home/config/pull/NCEMC10/gauntlet/2022-10-14_134555/twins/
`-- config
    |-- component.txt
    |-- dnp3_server
    |   `-- randolph_rtac_dnp3_server.json
    |-- echo
    |   |-- acuvim_echo.json
    |   |-- apc_ups_echo.json
    |   |-- bms_1_modbus_echo.json
    |   |-- bms_2_modbus_echo.json
    |   |-- pcs_1_modbus_echo.json
    |   |-- pcs_2_modbus_echo.json
    |   |-- sel_351_1_echo.json
    |   |-- sel_3530_rtac_echo.json
    |   `-- sel_735_echo.json
    |-- modbus_client
    |   |-- bms_1_modbus_client.json
    |   |-- bms_1_modbus_echo.json
    |   |-- bms_1_modbus_server.json
    |   |-- bms_2_modbus_client.json
    |   |-- bms_2_modbus_echo.json
    |   |-- bms_2_modbus_server.json
    |   |-- pcs_1_modbus_client.json
    |   |-- pcs_1_modbus_echo.json
    |   |-- pcs_1_modbus_server.json
    |   |-- pcs_2_modbus_client.json
    |   |-- pcs_2_modbus_echo.json
    |   `-- pcs_2_modbus_server.json
    |-- modbus_server
    |   |-- acuvim_server.json
    |   |-- apc_ups_server.json
    |   |-- bms_1_modbus_echo.json
    |   |-- bms_1_modbus_server.json
    |   |-- bms_2_modbus_echo.json
    |   |-- bms_2_modbus_server.json
    |   |-- pcs_1_modbus_echo.json
    |   |-- pcs_1_modbus_server.json
    |   |-- pcs_2_modbus_echo.json
    |   |-- pcs_2_modbus_server.json
    |   |-- sel_351_1_server.json
    |   |-- sel_3530_rtac_server.json
    |   `-- sel_735_server.json
    `-- twins
        `-- twins.json



Note that this system is expected to run on a linux container or equivalent system, with netork acess to the entire site.

When using a FlexGen laptop the container will have the /home/config directory mapped to a designated directory for 
use by the pull package.


With a "common" , "well defined" directory layout, other tools can be created to assist in the deployment process.
For example 'diff' can be used , if needed, across the whole system to search for any changes between different snapshots of the system.

A simple search tool can be used to look for text expressions in the config files.
This can be invluable when looking for the origin of an alarm, or for a particular variable name for example.


A web frontend would be invaluable in selecting Systems / Targets / and pull destinations for use by the extebded tools.

Here is the diff tool being used on real site snapshots

```
cat /home/config/pull/NCEMC10/gauntlet/2022-10-14_143952/ess_controller/config/web_ui/assets.json.diff
--- /home/config/refs/NCEMC10/repo/2022-1014_0823/ess_controller/config/web_ui/assets.json      2022-10-11 00:31:25.1847
79200 +0000
+++ /home/config/pull/NCEMC10/gauntlet/2022-10-14_143952/ess_controller/config/web_ui/assets.json       2022-10-14 14:40
:21.748058800 +0000
@@ -80,6 +80,7 @@
       "info": {
         "asset": "BMS",
         "assetKey": "bms",
+        "itemName": "Rack",
         "baseURI": "/bms",
         "extension": "/bms_",
         "hasSummary": false,
@@ -304,6 +305,7 @@
       "info": {
         "asset": "PCS",
         "assetKey": "pcs",
+        "itemName": "Modules",
         "baseURI": "/pcs",
         "extension": "/pcs_",
         "hasSummary": false,








We have systems 
   NCEMC10
   BRP10
   BRP100   etc 

   The system will define basic characteristics of the design.
   Number of fleet_manager , site_controller, powercloud , ess_controller (and twins) systems.

   In addition there are Modbus / Dnp3 peripherals associated with the site.

   There are two basic maps for the system one defines the network connecting the system components.




   The other defines the interface modules , modbus and dnp3 connecting the components together.


Typical interface mappings

here is the text  representation of the interface list 
this will change depending on the site being used for either deployment or testing.


"ess_controller|modbus_client|bms_1_modbus_client.json|bms_1:502"
"ess_controller|modbus_client|bms_2_modbus_client.json|bms_2:502"
"ess_controller|modbus_client|pcs_1_modbus_client.json|pcs_1:502"
"ess_controller|modbus_client|pcs_2_modbus_client.json|pcs_2:502"
"ess_controller|modbus_server|ncemc_flexgen_ess_modbus_server.json|ess_controller:1510"

"fleet_manager|modbus_client|acromag.json|acromag:502"
"fleet_manager|dnp3_client|rtac_dnp3_client.json|twins:20001"
"fleet_manager|dnp3_client|randolph_dnp3_client.json|twins:20002"
"fleet_manager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleet_manager:20001"

"site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510"
"site_controller|modbus_client|sel_3530.json|sel_3530:502"
"site_controller|modbus_client|sel_735.json|sel_735:502"
"site_controller|dnp3_client|rtac_dnp3_client.json|fleet_manager:20001"
"site_controller|dnp3_server|fleetmanager_dnp3_server.json|site_controller:20001"


If we are running with the twins simulator, then some of the peripheral interfaces are directed to that simulator.


"twins|modbus_server|bms_1_modbus_server.json|twins:1500"
"twins|modbus_server|bms_2_modbus_server.json|twins:1501"
"twins|modbus_server|pcs_1_modbus_server.json|twins:1502"
"twins|modbus_server|pcs_2_modbus_server.json|twins:1503"
"twins|modbus_server|sel_351_1_server.json|twins:1504"
"twins|modbus_server|sel_3530_server.json|twins:1507"
"twins|modbus_server|sel_735_server.json|twins:1508"
"twins|dnp3_server|randolph_rtac_dnp3_server.json|twins:20001"





DONE

fixFile.go 
fixFiles.go loads templates up


  needs to be integrated into script  process.




cfgEsslabStuff=(
    "##dbName##|labdb"
    "##Dir##|/home/docker/lab_db"
)    


cfgFiles=(    
     "ess_controller|storage.json|replace|system.client.dbName|lab"
     "ess_controller|stuff.json|template|cfgEsslabStuff"
)


design cycle #1

pull from git into a repo dir 
 Enter command :
 sgref
 please supply git repo, branch , destid
 using  repo integration_dev branch NCEMC/randolph_twins
 dest = /home/config/refs/NCEMC10/repo/2022-10-19_184509
remote: Enumerating objects: 131, done.
remote: Counting objects: 100% (131/131), done.
remote: Compressing objects: 100% (67/67), done.
remote: Total 131 (delta 75), reused 117 (delta 61), pack-reused 0
Receiving objects: 100% (131/131), 198.79 KiB | 0 bytes/s, done.
Resolving deltas: 100% (75/75), completed with 18 local objects.
From github.com:flexgen-power/integration_dev
   88bda0f..dde5922  NCEMC/randolph -> origin/NCEMC/randolph
Current branch NCEMC/randolph_twins is up to date.
Already on 'NCEMC/randolph_twins'

copying git configs from /home/config/git/integration_dev/config to /home/config/refs/NCEMC10/repo/2022-10-19_184509


use "srd" to select a repo dir

 Enter command :srd 8
 >>> current ref destids
destid dir [/home/config/refs/NCEMC10/repo] [2022-10-19_184509]
    2022-10-19_131713
    2022-10-19_131732
    2022-10-19_132025
    2022-10-19_132321
    2022-10-19_132447
    2022-10-19_133044
    2022-10-19_143617
*=> 2022-10-19_145712
     loading git data
    2022-10-19_184509
    2022-1014_0823
    2022-1014_test
    2022-1014_testgit
    2022-1014_testgit2



use "stage gauntlet"
to copy the repo dirs to a stage location 

stageCfgs  [/home/config/refs/NCEMC10/repo/2022-10-19_145712] ==> [/home/config/targ/NCEMC10/gauntlet/2022-10-19_145712]

make sure the correct target node is set up

sn 2
 Enter command :sn 2
 >>> system ips
 args = 1
 cfgTargs = [docker gauntlet lab]
    docker
=>  gauntlet
    lab
found  file [../sites/NCEMC10/system.sh]
found  file [../sites/NCEMC10/gauntlet/nodes.sh]
 new cfgTargSite=>gauntlet

 ip map for current target   => gauntlet

   ess_controller:hybridos@10.10.1.29|/home/hybridos
   site_controller:hybridos@10.10.1.28|/home/hybridos
   fleet_manager:hybridos@10.10.1.156|/home/hybridos
   twins:hybridos@10.10.1.27|/home/hybridos
   powercloud:hybridos@10.10.1.11|/home/hybridos
   twins_test:root@172.30.0.20|/home/config

   ===============



Now we have to fixIPs and fixFiles



TODO
ssh tunnel perhaps

systemctl
timeout journalctl


df -h
/var/logs
/tmp
ps ax
top
decode fims
   lets use go for this

dbi setup/reload.
   mayb

get /controls etc 
ess /config/load
    /config/cfile
    /config/ctmpl

system config

// see fixfile
user names
db names



