#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=NCEMC10
cfgTarget=gauntlet

cfgNodes=( 
     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleetmanager:hybridos@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.20"
         "twins_test:root@172.30.0.20"
)

#/usr/lib/systemd/system
cfgService=(
"common|cloud_sync"
"common|ftd"
"common|dts"
"common|dbi"
"common|events"
"common|modbus_client"
"common|modbus_server"
"common|dnp3_client"
"common|dnp3_server"
"common|web_server"
"common|influx"
"common|metrics"
"common|mongod"
"ess_controller|ess_controller"
"site_controller|site_controller"
"twins|twins"
)

cfgMaps=(    
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
)
# pull in the rest of it
source ./deploy_tools.sh

# #** TODO modbus_client acromag.json 10.10.1.27:1504
# #** TODO modbus_client acuvim.json 10.10.1.27:1505
# #** TODO modbus_client apcups.json 10.10.1.27:1506
# #** TODO modbus_client flexgen_ess_2_modbus_client.json 172.30.0.21:1511
# #** TODO modbus_server acromag_server.json 10.10.1.27:1504
# #** TODO modbus_server acuvim_server.json 10.10.1.27:1505
# #** TODO modbus_server apcups_server.json 10.10.1.27:1506

