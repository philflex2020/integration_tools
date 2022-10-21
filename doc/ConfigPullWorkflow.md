Config Pull workflow. Extract configs from site
Phil Wilshire
10_21_2022
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
It helps if the system has been set up using ssh-copy-id to allow  passwordless access to the different site systems.
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

Note that this system is expected to run on a linux container or equivalent system, with network acess to the entire site.
When using a FlexGen laptop, the container will have the /home/config directory mapped to a designated windows directory for use by the pull package.
With a "common" , "well defined" directory layout, other tools can be created to (or used) assist in the deployment process.
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


Push Operation

Once a set of configs have been "pulled" to a wekk defined directory. Those configs are also available to "Push" back on to the system.
I think some documentation trail is needed to specify who and why the old configs were restored.

This should also trigger something like an "Engineering Change Order" to maintain documentation of the site configuration.

In addition, there is no reason why the "pulled" configs could not be transferred to git with the destid as a committed branch.






Work in progress
Once a pull request has been defined the shell scripts can do the rest. I have built prototypes that need a lot more error checking / handling in them. (edited) 
I have addressed a weakness in our current json parsing system (jpack) 
with a go tool I have called fixFile.go
 
sh-4.2# more ./runit
./fixFile -dir ./ -file cs.json  -output cs_out.json -val "/home/dir3"  -path "clients.main.extension"
cat cs_out.json
./fixFile  -dir ./ -file cs_out.json  -output cs_out.json -val "[ \"local\", \"remote\" ]"  -path "clients.main.servers"
in the repo the /integration_tools/go/FixFile.go , FixFiles.go is the work I have done to provide better navigation in the json files.
I'll take a look at jq to see if it can do the same sort of work.
