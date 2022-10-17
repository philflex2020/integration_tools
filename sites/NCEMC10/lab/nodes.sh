#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=NCEMC10
cfgTarget=lab

cfgNodes_lab=( 
     "ess_controller:hybridos@10.10.1.150|/home/hybridos" 
    "site_controller:hybridos@10.10.1.151|/home/hybridos" 
       "fleet_manager:hybridos@10.10.1.156|/home/hybridos" 
              "twins:hybridos@10.10.1.152|/home/hybridos"
         "powercloud:hybridos@10.10.1.11|/home/hybridos"
         "twins_test:root@172.30.0.20|/home/hybridos"
)


cfgAllNodes=( 
     "ess_controller" 
    "site_controller" 
              "twins"
)


#/usr/lib/systemd/system
cfgService=(
"common|cloud_sync"
"common|fims"
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
"ess_controller|modbus_client|bms_1_modbus_client.json|fleet_manager:1500"
"ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501"
"ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502"
"ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503"
"ess_controller|modbus_server|ncemc_flexgen_ess_modbus_server.json|ess_controller:1510"
"fleet_manager|modbus_client|acromag.json|twins:1504"
"fleet_manager|dnp3_client|rtac_dnp3_client.json|twins:20001"
"fleet_manager|dnp3_client|randolph_dnp3_client.json|twins:20002"
"fleet_manager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleet_manager:20001"
"site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510"
"site_controller|modbus_client|sel_3530.json|twins:1507"
"site_controller|modbus_client|sel_735.json|twins:1508"
"xxsite_controller|modbus_client|modbus_loopback_client.json|site_ontroller:1509"
"xxsite_controller|modbus_server|modbus_loopback_server.json|site_controller:1510"
"site_controller|dnp3_client|rtac_dnp3_client.json|fleet_manager:20001"
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

cfgFiles=(    
     "ess_controller|replace|storage.json|dbName|gauntlet"
)

cfgSrc=lab
cfgDest=lab
cfgSysId=NCEMC10
cfgNodes=${cfgNodes_lab[@]}
