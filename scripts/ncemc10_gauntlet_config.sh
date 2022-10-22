#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 

. ../sites/$cfgSystem/system.sh
. ../sites/$cfgSystem/$cfgTarget/nodes.sh

cfgPullSystem=NCEMC10
cfgPullSite=gauntlet

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



# #/usr/lib/systemd/system
# cfgService=(
# "common|cloud_sync"
# "common|fims"
# "common|ftd"
# "common|dts"
# "common|dbi"
# "common|events"
# "common|modbus_client"
# "common|modbus_server"
# "common|dnp3_client"
# "common|dnp3_server"
# "common|web_server"
# "common|influx"
# "common|metrics"
# "common|mongod"
# "ess_controller|ess_controller"
# "site_controller|site_controller"
# "twins|twins"
# )

# this is other files 
#     "dbName": "ncemc_01",
# just find fields and replace 
cfgFiles=(    
     "ess_controller|replace|storage.json|dbName|ncemc_01"
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

cfgSystem=NCEMC10
cfgSysId=NCEMC10
cfgTarget=gauntlet

cfgSrc=gauntlet
cfgDest=gauntlet
cfgPullSite=gauntlet
cfgTargSite=gauntlet
cfgRefSite=gauntlet
cfgPullSystem=NCEMC10
cfgTargSystem=NCEMC10
cfgRefSystem=NCEMC10


cfgNodes=${cfgNodes_gauntlet[@]}

cfgTargs=(
    "docker"
    "gauntlet"
    "lab"
)
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

