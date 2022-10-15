#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=NCEMC10
cfgTarget=gauntlet

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


#show rpms
cfgRpms=(
"common|cloud_sync|/usr/local/bin/cloud_sync"
"common|ftd|/usr/local/bin/ftd"
"common|fims|/usr/local/bin/fims_server"
"common|dts|/usr/local/bin/dts"
"common|dbi|/usr/local/bin/dbi"
"common|events|/usr/local/bin/events"
"common|modbus_interface|/usr/local/bin/modbus_client"
"common|dnp3_interface|/usr/local/bin/dnp3_clinet"
"common|web_server|/usr/local/bin/web_ui"
"common|influx|/usr/bin/influx"
"common|metrics|/usr/local/bin/metrics"
"common|mongod|/usr/bin/mongod"
"common|ssh|/usr/bin/ssh"
"common|sshd|/usr/sbin/sshd"
"ess_controller|ess_controller|/usr/local/bin/ess_controler"
"ess_controller|ess_controller_pm"
"site_controller|site_controller|/usr/local/bin/site_controller"
"site_controller|site_controller_pm"
"twins|twins|/usr/local/bin/twins"
"twins|twins_pm"
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

# this is other files 
#     "dbName": "ncemc_01",
# just find fields and replace 
cfgFiles=(    
     "ess_controller|replace|storage.json|dbName|ncemc_01"
)

# this is for ip addresses 
cfgMaps=(    
"ess_controller|modbus_client|bms_1_modbus_client.json|fleet_manager:1500"
"ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501"
"ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502"
"ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503"
"ess_controller|modbus_server|ncemc_flexgen_ess_modbus_server.json|ess_controller:1510"
"fleet_managermodbus_client|acromag.json|twins:1504"
"fleet_managerdnp3_client|rtac_dnp3_client.json|twins:20001"
"fleet_managerdnp3_client|randolph_dnp3_client.json|twins:20002"
"fleet_managerdnp3_server|ncemc_fleetmanager_dnp3_server.json|fleet_manager:20001"
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

cfgVars=(
     "active_power|ess_controller|/ess_1/controls/ess_1|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_1/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_01_hs|active_power_setpoint"
     "active_power|ess_controller|/ess_2/controls/ess_2|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_2/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_02_hs|active_power_setpoint"
     "reactive_power|ess_controller|/ess_1/controls/ess_1|ReactivePowerSetpoint"
     "test_set|ess_controller|/ess_2/test/test_active_power|'{\"active_power\":3344}'|set"
     "test_get|ess_controller|/ess_2/test/test_active_power|active_power"

)

cfgSrc=gauntlet
cfgDest=gauntlet
cfgSysId=NCEMC10
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

