Config Deployment tools 
p wilshire
10_09_2022


### Overview ###

The config deployment tools system provides integrators with a way to  manage distribution of config systems to a cluster of targets.

The integration_dev git repo contains the config scripts for each of the cluster subsystems.

The file layout looks like this .

Note that this is to be replaced by a dbi load for the target. 
This deplpyment tool will also perform the dbi database loading function. 

```
|-- ess_controller
|   `-- config
|       |-- bms
|       |-- dbi
|       |-- dts
|       |-- ess_controller
|       |-- events
|       |-- excel_to_json
|       |-- ftd
|       |-- gpio_controller
|       |-- metrics
|       |-- modbus_client
|       |-- modbus_client_site
|       |-- modbus_server
|       |-- ssh
|       |-- storage
|       |-- testing
|       |-- testing_orig
|       |-- tmp
|       |-- web_server
|       `-- web_ui
|-- fleet_manager
|   `-- config
|       |-- cloud_sync
|       |-- cops
|       |-- dnp3_client
|       |-- dnp3_server
|       |-- ftd
|       |-- metrics
|       |-- scheduler
|       |-- storage
|       |-- ui_config
|       |-- web_server
|       `-- web_ui
|-- powercloud
|   `-- config
|       `-- docker_fixip.txt
`-- site_controller
    `-- config
        |-- cloud_sync
        |-- cops
        |-- dbi
        |-- dnp3_client
        |-- dnp3_server
        |-- events
        |-- excel-to-json
        |-- metrics
        |-- modbus_client
        |-- modbus_loopback
        |-- scheduler
        |-- site_controller
        |-- storage
        |-- ui_config
        |-- washer
        |-- web_server
        `-- web_ui
```

## System Deployment Targets ##

There are at least three deployment target systems:-

* Docker Containers
* Gauntlet Simulator (Also sold as a product) 
* Site Installation

In addition there may be multi sites having the basic same configs with minor alterations:-
* TX100  
 * Northfork
 * Batcave
* NCEMC-10
 * Randolph
 * Merryweather 
 * ...

To compound these issues, there may be local exceptions particular to a group of sites.

NCEMC-10 Randolph may add an extra BMS module , for example.

The First job is to define the  base system (NCEMC10, SCE , TX100)

## Overall Site System Map ##

Next the Docker, Gauntlet and Site Mappings are to be defined.

These will contain usernames, nodenames and ip addresses.

```
    NCEMC-10  docker mapping

     "ess_controller:root@172.30.1.29" 
    "site_controller:root@172.30.1.28" 
       "fleetmanager:root@172.30.1.21" 
              "twins:root@172.30.1.27"
         "powercloud:root@172.30.1.20"
              "bms_1:root@10.10.1.27"
              "bms_2:root@10.10.1.27"
              "pcs_1:root@10.10.1.27"
              "pcs_2:root@10.10.1.27"

```

```
    NCEMC-10  gauntlet mappong

     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleetmanager:fleetmanager@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.20"
               "rtac:SME730@10.10.1.27"
               "bms_1:hybridos@10.10.1.27"
               "bms_2:hybridos@10.10.1.27"
               "pcs_1:hybridos@10.10.1.27"
               "pcs_2:hybridos@10.10.1.27"
```

## Component Interface Mapping ##

The system defines mapping (ip Addresses and ports) for all the modbus or dnp3 communications interfaces.
In this table each interface is given a unique name corresponding to the associated json config file.

This table is used to customise the interface configurations (ip_address and port) to match the deployment requirements.


```
    NCEMC-10  gauntlet interface mapping

"ess_controller|modbus_client|bms_1_modbus_client.json|twins:1500"
"ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501"
"ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502"
"ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503"
"ess_controller|modbus_server|ncemc_ess_modbus_server.json|site_controller:1510"
"fleetmanager|modbus_client|acromag.json|twins:1504"
"fleetmanager|dnp3_client|rtac_dnp3_client.json|twins:20001"
"fleetmanager|dnp3_client|randolph_dnp3_client.json|twins:20002"
"fleetmanager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleetmanager:20001"
"site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510"
"site_controller|modbus_client|sel_3530.json|twins:1507"
"site_controller|modbus_client|sel_735.json|twins:1508"
"site_controller|modbus_client|modbus_loopback_client.json|site_ontroller:1509"
"site_controller|modbus_server|modbus_loopback_server.json|site_controller:1510"
"site_controller|dnp3_client|rtac_dnp3_client.json|fleetmanager:20001"
"site_controller|dnp3_server|fleetmanager_dnp3_server.json|site_controller:20001"
"twins|modbus_server|bms_1_modbus_server.json|twins:1500"
"twins|modbus_server|bms_2_modbus_server.json|twins:1501"
"twins|modbus_server|pcs_1_modbus_server.json|twins:1502"
"twins|modbus_server|pcs_2_modbus_server.json|twins:1503"
"twins|modbus_server|sel_351_1_server.json|twins:1504"
"twins|modbus_server|sel_3530_server.json|twins:1507"
"twins|modbus_server|sel_735_server.json|twins:1508"
"twins|dnp3_server|randolph_rtac_dnp3_server.json|twins:20001"

```


## Config Deployment Tool ##

The task of the config deployment tool is to :-

* Adjust base configurations to accomodate local ip addresses and ports
* Provide an iniital configuration load either as files or as dbi database loads to each system in the cluster.
* Provide a means to capture/locally store  the current site configuration either from files or dbi data
* Allow an updated configuration to be deployed to one or more sites.
* Provide a means to quickly find any changes in configurations from a reference config.
* Be able to work remotely through a network connetion
* Be able to remotely restart services on target nodes to reload configs
* Be able to be work in an isolated system and resync with a master config repo when back on line.
* Provide lists of system node names, users, ip addresses and ports to assist with system deployment and configuration.


# Site Communications #

The deployment tool uses SSH to communicate with the site nodes.
The password requirement is satisfied using the "ssh-copy-id" system that facilitates direct operations on nodes without the need for passord entry. Once a deployment cycle has finished the target nodes remove the saved ids and revert to requiring passwords.



### Basic Operations ###
## Setup ## 

in the "config" node or container run this command.

source /home/config/scripts/ncemc10_gauntlet_tools.sh

this will populate the local environment with the deployment tool commands.


## cfgHelp ##
The deployment tool has this initial functionality:

sh-4.2# cfgHelp

```
 showNodes                   -- shows the system nodes
 pullConfigs node destid     -- pull configs to a specified dest
 showConfigs node destid     -- show configs from specified dest
 diffConfigs node dest orig  -- check configs in dest against origs
 pushConfigs node destid     -- push configs to a specified dest
 showPorts node              -- show ports require  for a given node
 
 ```

## showNodes ##

This provides a list of nodes in the system.

```
ess_controller:hybridos@10.10.1.29
site_controller:hybridos@10.10.1.28
fleetmanager:hybridos@10.10.1.156
twins:hybridos@10.10.1.27
powercloud:hybridos@10.10.1.20
twins_test:root@172.30.0.20
```
## showPorts (node) ##

This provides a list of ports required for a system component (node) 

# TODO :: add tcp/udp designation #

```
sh-4.2# showPorts twins
1500 1501 1502 1503 1504 20001 20002 1507 1508
```
## showConfigs node ##

# TODO add node option

This shows the ip mappings for the intefaces for the whole system or a particular node

```
sh-4.2# showConfigs twins 10_09_2022_orig
ess_controller|modbus_client|bms_1_modbus_client.json|twins:1500
ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501
ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502
ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503
ess_controller|modbus_server|ncemc_ess_modbus_server.json|site_controller:1510
fleetmanager|modbus_client|acromag.json|twins:1504
fleetmanager|dnp3_client|rtac_dnp3_client.json|twins:20001
fleetmanager|dnp3_client|randolph_dnp3_client.json|twins:20002
fleetmanager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleetmanager:20001
site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510
site_controller|modbus_client|sel_3530.json|twins:1507
site_controller|modbus_client|sel_735.json|twins:1508
site_controller|modbus_client|modbus_loopback_client.json|site_controller:1509
site_controller|modbus_server|modbus_loopback_server.json|site_controller:1510
site_controller|dnp3_client|rtac_dnp3_client.json|fleetmanager:20001
site_controller|dnp3_server|fleetmanager_dnp3_server.json|site_controller:20001
twins|modbus_server|bms_1_modbus_server.json|twins:1500
twins|modbus_server|bms_2_modbus_server.json|twins:1501
twins|modbus_server|pcs_1_modbus_server.json|twins:1502
twins|modbus_server|pcs_2_modbus_server.json|twins:1503
twins|modbus_server|sel_351_1_server.json|twins:1504
twins|modbus_server|sel_3530_server.json|twins:1507
twins|modbus_server|sel_735_server.json|twins:1508
twins|dnp3_server|randolph_rtac_dnp3_server.json|twins:20001
```

## pullConfigs (node , dest) ##

This pulls the configs for a chosen node to a designated root directory

```

sh-4.2# pullConfigs twins 10_09_2022_orig
randolph_rtac_dnp3_server.json                                                        100%   14KB 183.2KB/s   00:00
pcs_1_modbus_echo.json                                                                100% 1628    34.2KB/s   00:00
bms_1_modbus_server.json                                                              100%   89KB 790.8KB/s   00:00
sel_735_server.json                                                                   100% 3907    81.2KB/s   00:00
acuvim_server.json                                                                    100% 4120    97.0KB/s   00:00
apc_ups_server.json                                                                   100% 9944   208.1KB/s   00:00
bms_2_modbus_server.json                                                              100%   89KB   1.1MB/s   00:00
pcs_1_modbus_server.json                                                              100% 7855   154.7KB/s   00:00
bms_2_modbus_echo.json                                                                100%   18KB 387.4KB/s   00:00
bms_1_modbus_echo.json                                                                100%   18KB 372.9KB/s   00:00
pcs_2_modbus_server.json                                                              100% 7855   165.3KB/s   00:00
sel_351_1_server.json                                                                 100% 4789   100.0KB/s   00:00
sel_3530_server.json                                                                  100% 4675    86.4KB/s   00:00
pcs_2_modbus_echo.json                                                                100% 1628    32.1KB/s   00:00
.gitkeep                                                                              100%    0     0.0KB/s   00:00
twins.json                                                                            100%   50KB   1.1MB/s   00:00
component.txt
configs pulled to /home/config/pull/10_09_2022_orig/twins

```

Here is the result of the pull request

```
tree -L 3  /home/config/pull/10_09_2022_orig/twins
/home/config/pull/10_09_2022_orig/twins
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
    |   |-- sel_3530_echo.json
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
    |   |-- sel_3530_server.json
    |   `-- sel_735_server.json
    `-- twins
        `-- twins.json

6 directories, 37 files
```

Where the node uses dbi as a config store the `dbi` directory will contain the documents extracted from the dbi dtabase.
( TODO )

## pushConfigs (node , dest) ##

NOTE still under development

This pushes the configs for a chosen node from designated root directory.

The configs are modified , as needed , for the users, ip addreses and ports required for the system. (TODO) 
The echo tool is used to build server and echo files from modbus or dnp3 client config files (TODO)
The local node dbi database will also be updated (TODO)


## diffConfigs node dir1  dir2 ##

This tool runs a diff operation to check if any changes have been made to a node configuration based on pullCfg directories 

Use this to see the config pull directories 

```
ls /home/config/pull/
10_08_2022  10_08_2022_1  10_08_2022_final  10_08_2022_orig  10_08_2022_test  10_09_2022_orig
```

This is a check for overnight changes

```
diffConfigs twins 10_08_2022_final 10_09_2022_orig
```

This shows changes made in a day to one system.

```
diffConfigs site_controller 10_09_2022_orig 10_08_2022_orig
 /config/dnp3_client/rtac_dnp3_client.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/dnp3_client/rtac_dnp3_client.json  2022-10-08 10:32:49.336205000 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/dnp3_client/rtac_dnp3_client.json  2022-10-09 13:14:58.448561200 +0000
@@ -50,7 +50,8 @@
                 {
                     "id": "voltage_l1",
                     "offset": 4,
-                    "name": "Voltage Phasor A"
+                    "name": "Voltage Phasor A",
+                    "echo_id": "/components/twins_sel_3530/v1"
                 },
                 {
                     "id": "voltage_l2",
@@ -65,7 +66,8 @@
                 {
                     "id": "current_l1",
                     "offset": 7,
-                    "name": "Current Phasor magnitude phase A"
+                    "name": "Current Phasor magnitude phase A",
+                    "echo_id": "/components/twins_sel_3530/i"
                 },
                 {
                     "id": "current_l2",
@@ -100,28 +102,33 @@
                 {
                     "id": "frequency",
                     "offset": 14,
-                    "name": "Frequency"
+                    "name": "Frequency",
+                    "echo_id": "/components/twins_sel_3530/f1"
                 },
                 {
                     "id": "power_factor",
                     "offset": 15,
                                        "scale": 100,
-                    "name": "Power Factor"
+                    "name": "Power Factor",
+                    "echo_id": "/components/twins_sel_3530/pf"
                 },
                 {
                     "id": "active_power",
                     "offset": 16,
-                    "name": "Real Power"
+                    "name": "Real Power",
+                    "echo_id": "/components/twins_sel_3530/p"
                 },
                 {
                     "id": "reactive_power",
                     "offset": 17,
-                    "name": "Reactive Power"
+                    "name": "Reactive Power",
+                    "echo_id": "/components/twins_sel_3530/q"
                 },
                 {
                     "id": "apparent_power",
                     "offset": 18,
-                    "name": "Apparent Power"
+                    "name": "Apparent Power",
+                    "echo_id": "/components/twins_sel_3530/s"
                 },
                 {
                     "id": "kwh_delivered",
 /config/metrics/mdo_metrics.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/metrics/mdo_metrics.json   2022-10-08 10:32:54.144494400 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/metrics/mdo_metrics.json   2022-10-09 13:15:02.783114400 +0000

[[ diffs missing from this output]]

 /config/metrics/metrics.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/metrics/metrics.json       2022-10-08 10:32:54.255022400 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/metrics/metrics.json       2022-10-09 13:15:02.901276400 +0000
@@ -207,6 +207,50 @@
       ]
     },
     {
+      "uri":"/metrics/active_power",
+      "naked":"true",
+      "metrics":[
+        {
+          "id":"lt_limit",
+          "inputs":[
+            {"uri":"/features/active_power","id":"manual_ess_kW_cmd"},
+            {"uri":"/features/standalone_power","id":"poi_limits_min_kW"}
+          ],
+          "operation":"compare",
+          "param":{
+            "operation":"lt"
+          }
+        },
+        {
+          "id":"is_min_limited",
+          "inputs":[
+            {"uri":"/metrics/active_power","id":"lt_limit"},
+            {"uri":"/features/standalone_power","id":"poi_limits_enable"}
+          ],
+          "operation":"compareand"
+        },
+        {
+          "id":"gt_limit",
+          "inputs":[
+            {"uri":"/features/active_power","id":"manual_ess_kW_cmd"},
+            {"uri":"/features/standalone_power","id":"poi_limits_max_kW"}
+          ],
+          "operation":"compare",
+          "param":{
+            "operation":"gt"
+          }
+        },
+        {
+          "id":"is_max_limited",
+          "inputs":[
+            {"uri":"/metrics/active_power","id":"gt_limit"},
+            {"uri":"/features/standalone_power","id":"poi_limits_enable"}
+          ],
+          "operation":"compareand"
+        }
+      ]
+    },
+    {
       "uri":"/metrics/site",
       "naked":"true",
       "metrics":[
@@ -236,18 +280,6 @@
             "operation":"eq",
             "reference":true
           }
-        },
-        {
-          "id":"reactive_power_ltd",
-          "inputs":[
-            {"uri":"/metrics/reactive_power","id":"is_charge_limited"},
-            {"uri":"/metrics/reactive_power","id":"is_discharge_limited"}
-          ],
-          "operation":"compareor",
-          "param":{
-            "operation":"eq",
-            "reference":true
-          }
         }
       ]
     },
@@ -537,56 +569,14 @@
         }
       ]
     },
-         {
-      "uri":"/components/sel_3530_rtac",
-      "naked":"true",
-      "metrics":[
-                   {
-          "id":"735_comm_inverted",
-          "inputs":[
-            {"uri":"/components/sel_3530_rtac","id":"735_dnp_comm"}
-          ],
-          "operation":"select",
-          "param":{
-            "trueCase":false,
-            "falseCase":true
-          },
-          "initialValue":false
-                   },
-                   {
-          "id":"735_phasor_inverted",
-          "inputs":[
-            {"uri":"/components/sel_3530_rtac","id":"735_synchrophasor_comm"}
-          ],
-          "operation":"select",
-          "param":{
-            "trueCase":false,
-            "falseCase":true
-          },
-          "initialValue":false
-               },
-               {
-          "id":"external_rtac_inverted",
-          "inputs":[
-            {"uri":"/components/sel_3530_rtac","id":"external_rtac_comm"}
-          ],
-          "operation":"select",
-          "param":{
-            "trueCase":false,
-            "falseCase":true
-          },
-          "initialValue":false
-                   }
-      ]
-    },
     {
-      "uri":"/components/virtual_sel_735",
+      "uri":"/components/virtual_3530_rtac",
       "naked":"true",
       "metrics":[
         {
           "id":"breaker_status",
           "inputs":[
-            {"uri":"/components/sel_735","id":"voltage_l1"}
+            {"uri":"/components/sel_3530_rtac","id":"voltage_l1"}
           ],
           "operation":"compareor",
           "param":{
 /config/modbus_client/acuvim.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/modbus_client/acuvim.json  2022-10-08 10:32:51.095438500 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/modbus_client/acuvim.json  2022-10-09 13:14:59.954512000 +0000
@@ -2,7 +2,7 @@
        "connection":
        {
                "name": "m_bess_aux_acuvim",
-               "ip_address": "10.101.87.54",
+               "ip_address": "10.10.1.27",
                "port": 502
        },
        "components":
@@ -25,25 +25,29 @@
                                                        "id":"frequency",
                                                        "offset":16384,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/f1"
                                                },
                                                {
                                                        "id":"voltage_l1",
                                                        "offset":16386,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/v1"
                                                },
                                                {
                                                        "id":"voltage_l2",
                                                        "offset":16388,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/v2"
                                                },
                                                {
                                                        "id":"voltage_l3",
                                                        "offset":16390,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/v3"
                                                },
                                                {
                                                        "id":"voltage_ln_rms",
@@ -79,7 +83,8 @@
                                                        "id":"current_l1",
                                                        "offset":16402,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/i"
                                                },
                                                {
                                                        "id":"current_l2",
@@ -131,7 +136,8 @@
                                                        "offset":16418,
                                                        "size":2,
                                                        "scale":1000,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/p"
                                                },
                                                {
                                                        "id":"reactive_power_l1",
@@ -159,7 +165,8 @@
                                                        "offset":16426,
                                                        "size":2,
                                                        "scale":1000,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/q"
                                                },
                                                {
                                                        "id":"apparent_power_l1",
@@ -187,7 +194,8 @@
                                                        "offset":16434,
                                                        "size":2,
                                                        "scale":1000,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/s"
                                                },
                                                {
                                                        "id":"power_factor_l1",
@@ -211,7 +219,8 @@
                                                        "id":"power_factor",
                                                        "offset":16442,
                                                        "size":2,
-                                                       "float":true
+                                                       "float":true,
+                                                       "echo_id": "/components/twins_bess_aux/pf"
                                                },
                                                {
                                                        "id":"active_power_demand",
 /config/site_controller/assets.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/site_controller/assets.json        2022-10-08 10:32:49.855697700 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/site_controller/assets.json        2022-10-09 13:14:58.968445400 +0000
@@ -7,7 +7,7 @@
       "asset_instances":[
         {
           "id":"feed_1",
-          "name":"POI",
+          "name":"SEL 3530 RTAC",
           "value_open":2,
           "value_close":1,
           "value_reset":7,
@@ -16,7 +16,7 @@
           "demand_control":"Uncontrolled",
           "components":[
             {
-              "component_id":"virtual_sel_735",
+              "component_id":"virtual_3530_rtac",
               "variables": {
                 "breaker_status":{
                   "name":"Breaker Status (SEL 735)",
@@ -28,244 +28,14 @@
               }
             },
             {
-              "component_id":"sel_735",
-              "variables":{
-                "grid_voltage_l1":{
-                  "name":"Grid AC Voltage L1 (SEL 735)",
-                  "register_id":"voltage_l1",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "grid_voltage_l2":{
-                  "name":"Grid AC Voltage L2 (SEL 735)",
-                  "register_id":"voltage_l2",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "grid_voltage_l3":{
-                  "name":"Grid AC Voltage L3 (SEL 735)",
-                  "register_id":"voltage_l3",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "grid_frequency":{
-                  "name":"Frequency (SEL 735)",
-                  "register_id":"frequency",
-                  "scaler":1,
-                  "unit":"Hz",
-                  "twins_id":"f1"
-                },
-                "current_l1":{
-                  "name":"L1 AC Current (SEL 735)",
-                  "register_id":"current_l1",
-                  "scaler":1,
-                  "unit":"A",
-                  "twins_id":"i"
-                },
-                "current_l2":{
-                  "name":"L2 AC Current (SEL 735)",
-                  "register_id":"current_l2",
-                  "scaler":1,
-                  "unit":"A",
-                  "twins_id":"i"
-                },
-                "current_l3":{
-                  "name":"L3 AC Current (SEL 735)",
-                  "register_id":"current_l3",
-                  "scaler":1,
-                  "unit":"A",
-                  "twins_id":"i"
-                },
-                "voltage_l1_n":{
-                  "name":"L1-N AC Voltage (SEL 735)",
-                  "register_id":"voltage_l1",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l2_n":{
-                  "name":"L2-N AC Voltage (SEL 735)",
-                  "register_id":"voltage_l2",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l3_n":{
-                  "name":"L3-N AC Voltage (SEL 735)",
-                  "register_id":"voltage_l3",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l1_l2":{
-                  "name":"L1-L2 AC Voltage (SEL 735)",
-                  "register_id":"voltage_l1_l2",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l2_l3":{
-                  "name":"L2-L3 AC Voltage (SEL 735)",
-                  "register_id":"voltage_l2_l3",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l3_l1":{
-                  "name":"L3-L1 AC Voltage (SEL 735)",
-                  "register_id":"voltage_l3_l1",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "active_power":{
-                  "name":"AC Active Power (SEL 735)",
-                  "register_id":"active_power",
-                  "scaler":1000,
-                  "unit":"W",
-                  "twins_id":"p",
-                  "signed":true
-                },
-                "reactive_power":{
-                  "name":"AC Reactive Power (SEL 735)",
-                  "register_id":"reactive_power",
-                  "scaler":1000,
-                  "unit":"VAR",
-                  "twins_id":"q"
-                },
-                "apparent_power":{
-                  "name":"AC Apparent Power (SEL 735)",
-                  "register_id":"apparent_power",
-                  "scaler":1000,
-                  "unit":"VA",
-                  "twins_id":"s"
-                },
-                "power_factor":{
-                  "name":"Power Factor (SEL 735)",
-                  "register_id":"power_factor",
-                  "scaler":1
-                },
-                "kwh_delivered":{
-                  "name":"Active Energy Delivered (735)",
-                  "register_id":"kwh_delivered",
-                  "scaler":1000,
-                  "unit":"Wh",
-                  "twins_id":"p"
-                },
-                "kwh_received":{
-                  "name":"Active Energy Received (735)",
-                  "register_id":"kwh_received",
-                  "scaler":1000,
-                  "unit":"Wh",
-                  "twins_id":"p"
-                }
-              },
-              "ui_controls":{
-                "maint_mode":{
-                  "name":"Maintenance Mode",
-                  "type":"Bool"
-                },
-                "breaker_close":{
-                  "name":"Breaker Close",
-                  "register_id":"breaker_control",
-                  "twins_id":"ctrlword1"
-                },
-                "breaker_open":{
-                  "name":"Breaker Open",
-                  "register_id":"breaker_control",
-                  "twins_id":"ctrlword1"
-                }
-              }
-            }
-          ]
-        },
-        {
-          "id":"feed_2",
-          "name":"Virtual BESS Meter",
-          "demand_control":"Uncontrolled",
-          "components":[
-            {
-              "component_id":"feed_gross_ess",
-              "variables":{
-                "active_power":{
-                  "name":"Gross Total Active Power",
-                  "register_id":"active_power",
-                  "scaler":1,
-                  "unit":"kW"
-                },
-                "reactive_power":{
-                  "name":"Gross Total Reactive Power",
-                  "register_id":"reactive_power",
-                  "scaler":1,
-                  "unit":"kVAR"
-                }
-              }
-            }
-          ]
-        },
-        {
-          "id":"feed_3",
-          "name":"BESS Aux",
-          "demand_control":"Uncontrolled",
-          "components":[
-            {
-              "component_id":"m_bess_aux_acuvim",
-              "variables":{
-                "active_power":{
-                  "name":"AC Active Power",
-                  "register_id":"active_power",
-                  "scaler":1,
-                  "unit":"kW",
-                  "twins_id":"p"
-                },
-                "reactive_power":{
-                  "name":"AC Reactive Power",
-                  "register_id":"reactive_power",
-                  "scaler":1,
-                  "unit":"kVAR",
-                  "twins_id":"q"
-                },
-                "voltage_l1_l2":{
-                  "name":"L1-N AC Voltage",
-                  "register_id":"voltage_l1",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l2_l3":{
-                  "name":"L2-N AC Voltage",
-                  "register_id":"voltage_l2",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                },
-                "voltage_l3_l1":{
-                  "name":"L3-N AC Voltage",
-                  "register_id":"voltage_l3",
-                  "scaler":1,
-                  "unit":"V",
-                  "twins_id":"v1"
-                }
-              }
-            }
-          ]
-        },
-        {
-          "id":"feed_4",
-          "name":"SEL 3530 RTAC",
-          "demand_control":"Uncontrolled",
-          "components":[
-            {
               "component_id":"sel_3530_rtac",
-              "variables":{
+              "variables":
+              {
                 "active_power_command_charge":{
-                  "name":"Active Power Charge Limit",
-                  "register_id":"charge_limit_kw",
-                  "scaler":1,
-                  "unit":"kW"
+                "name":"Active Power Charge Limit",
+                "register_id":"charge_limit_kw",
+                "scaler":1,
+                "unit":"kW"
                 },
                 "reactive_power_command_charge":{
                   "name":"Reactive Power Charge Limit",
@@ -285,19 +55,19 @@
                   "scaler":1,
                   "unit":"kVAR"
                 },
-                "voltage_l1":{
+                "grid_voltage_l1":{
                   "register_id":"voltage_l1",
                   "scaler":1,
                   "unit":"V",
                   "name":"Voltage Phasor A"
                 },
-                "voltage_l2":{
+                "grid_voltage_l2":{
                   "register_id":"voltage_l2",
                   "scaler":1,
                   "unit":"V",
                   "name":"Voltage Phasor B"
                 },
-                "voltage_l3":{
+                "grid_voltage_l3":{
                   "register_id":"voltage_l3",
                   "scaler":1,
                   "unit":"V",
@@ -345,7 +115,7 @@
                   "unit":"V",
                   "name":"Voltage Phasor CA"
                 },
-                "frequency":{
+                "grid_frequency":{
                   "register_id":"frequency",
                   "scaler":1,
                   "unit":"Hz",
@@ -464,31 +234,25 @@
                   "ui_type":"fault"
                 },
                 "local_estop_signal":{
-                  "register_id":"local_estop_inverted",
+                  "register_id":"local_estop_signal",
                   "type":"Bool",
                   "name":"Local E-stop signal",
                   "ui_type":"fault"
                 },
-                "651R_comm_comm":{
-                  "register_id":"651R_comm_inverted",
-                  "type":"Bool",
-                  "name":"651R Comm Status",
-                  "ui_type":"fault"
-                },
                 "external_rtac_comm":{
-                  "register_id":"external_rtac_inverted",
+                  "register_id":"external_rtac_comm",
                   "type":"Bool",
                   "name":"External RTAC Comm status",
                   "ui_type":"fault"
                 },
                 "735_dnp_comm":{
-                  "register_id":"735_comm_inverted",
+                  "register_id":"735_dnp_comm",
                   "type":"Bool",
                   "name":"735 DNP Comm status",
                   "ui_type":"fault"
                 },
                 "735_synchrophasor_comm":{
-                  "register_id":"735_phasor_inverted",
+                  "register_id":"735_synchrophasor_comm",
                   "type":"Bool",
                   "name":"735 synchrophasor Comm status",
                   "ui_type":"fault"
@@ -517,6 +281,94 @@
                   "name":"RMB Spare 4",
                   "ui_type":"none"
                 }
+              },
+              "ui_controls":
+              {
+                "maint_mode":{
+                  "name":"Maintenance Mode",
+                  "type":"Bool"
+                },
+                "breaker_close":{
+                  "name":"Breaker Close",
+                  "register_id":"breaker_control",
+                  "twins_id":"ctrlword1"
+                },
+                "breaker_open":{
+                  "name":"Breaker Open",
+                  "register_id":"breaker_control",
+                  "twins_id":"ctrlword1"
+                }
+              }
+            }
+          ]
+        },
+        {
+          "id":"feed_2",
+          "name":"Virtual BESS Meter",
+          "demand_control":"Uncontrolled",
+          "components":[
+            {
+              "component_id":"feed_gross_ess",
+              "variables":{
+                "active_power":{
+                  "name":"Gross Total Active Power",
+                  "register_id":"active_power",
+                  "scaler":1,
+                  "unit":"kW"
+                },
+                "reactive_power":{
+                  "name":"Gross Total Reactive Power",
+                  "register_id":"reactive_power",
+                  "scaler":1,
+                  "unit":"kVAR"
+                }
+              }
+            }
+          ]
+        },
+        {
+          "id":"feed_3",
+          "name":"BESS Aux",
+          "demand_control":"Uncontrolled",
+          "components":[
+            {
+              "component_id":"m_bess_aux_acuvim",
+              "variables":{
+                "active_power":{
+                  "name":"AC Active Power",
+                  "register_id":"active_power",
+                  "scaler":1,
+                  "unit":"kW",
+                  "twins_id":"p"
+                },
+                "reactive_power":{
+                  "name":"AC Reactive Power",
+                  "register_id":"reactive_power",
+                  "scaler":1,
+                  "unit":"kVAR",
+                  "twins_id":"q"
+                },
+                "voltage_l1_l2":{
+                  "name":"L1-N AC Voltage",
+                  "register_id":"voltage_l1",
+                  "scaler":1,
+                  "unit":"V",
+                  "twins_id":"v1"
+                },
+                "voltage_l2_l3":{
+                  "name":"L2-N AC Voltage",
+                  "register_id":"voltage_l2",
+                  "scaler":1,
+                  "unit":"V",
+                  "twins_id":"v1"
+                },
+                "voltage_l3_l1":{
+                  "name":"L3-N AC Voltage",
+                  "register_id":"voltage_l3",
+                  "scaler":1,
+                  "unit":"V",
+                  "twins_id":"v1"
+                }
               }
             }
           ]
 /config/site_controller/variables.json - diffs ==========
--- /home/config/pull/10_08_2022_orig/site_controller/config/site_controller/variables.json     2022-10-08 10:32:50.024755800 +0000
+++ /home/config/pull/10_09_2022_orig/site_controller/config/site_controller/variables.json     2022-10-09 13:14:59.090840900 +0000
@@ -651,7 +651,7 @@
                 "disable_flag":
                 {
                     "name": "Disable Site",
-                    "ui_type": "control",
+                    "ui_type": "status",
                     "type": "enum_slider",
                     "var_type": "Bool",
                     "value": false,
```
