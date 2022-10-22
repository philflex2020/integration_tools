#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=NCEMC10
cfgTarget=gauntlet

. ../sites/$cfgSystem/system.sh
. ../sites/$cfgSystem/$cfgTarget/nodes.sh

cfgNodes_gauntlet=( 
     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleet_manager:hybridos@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.11"
         "twins_test:root@172.30.0.20"
)

cfgNodes_docker=( 
     "ess_controller:root@172.30.0.21" 
    "site_controller:root@172.30.0.22" 
       "fleet_manager:root@172.30.0.23" 
              "twins:root@172.30.0.20"
         "powercloud:root@172.30.0.24"
         "twins_test:root@172.30.0.20"
)

cfgAllNodes=( 
     "ess_controller" 
    "site_controller" 
       "fleet_manager" 
              "twins"
)


cfgNodes=${cfgNodes_gauntlet[@]}

# pull in the rest of it
source ./deploy_tools.sh
cfgMenu


# #** TODO modbus_client acromag.json 10.10.1.27:1504
# #** TODO modbus_client acuvim.json 10.10.1.27:1505
# #** TODO modbus_client apcups.json 10.10.1.27:1506
# #** TODO modbus_client flexgen_ess_2_modbus_client.json 172.30.0.21:1511
# #** TODO modbus_server acromag_server.json 10.10.1.27:1504
# #** TODO modbus_server acuvim_server.json 10.10.1.27:1505
# #** TODO modbus_server apcups_server.json 10.10.1.27:1506

