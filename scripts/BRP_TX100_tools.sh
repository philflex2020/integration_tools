#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=BRP_TX100
cfgTarget=docker
​
cfgNodes_docker=( 
     "ess_controller:root@172.3.27.170" 
    "site_controller:root@172.3.27.103" 
       "fleetmanager:root@172.3.27.150" 
              "twins:root@172.3.27.203"
)
​
cfgAllNodes=( 
     "ess_controller" 
    "site_controller" 
       "fleetmanager" 
              "twins"
)
​
​
#show rpms
cfgRpms=(
"common|cloud_sync"
"common|ftd"
"common|fims"
"common|dts"
"common|dbi"
"common|events"
"common|modbus_interface"
"common|dnp3_interface"
"common|web_server"
"common|influx"
"common|metrics"
"common|mongod"
"ess_controller|ess_controller"
"ess_controller|ess_controller_pm"
"site_controller|site_controller"
"site_controller|site_controller_pm"
"twins|twins"
"twins|twins_pm"
)
​
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
​
cfgMaps=(    
"ess_controller|modbus_client|bms_modbus_client.json|twins:5030"
"ess_controller|modbus_client|pcs_modbus_client.json|twins:5031"
"ess_controller|modbus_server|flexgen_ess_modbus_server.json|ess_controller:502"
"site_controller|modbus_client|flexgen_ess_01_modbus_client.json|twins:10005"
"site_controller|modbus_client|flexgen_ess_02_modbus_client.json|twins:10006"
"site_controller|modbus_client|flexgen_ess_03_modbus_client.json|twins:10007"
"site_controller|modbus_client|flexgen_ess_04_modbus_client.json|twins:10008"
"site_controller|modbus_client|flexgen_ess_05_modbus_client.json|twins:10009"
"site_controller|modbus_client|flexgen_ess_06_modbus_client.json|twins:10010"
"site_controller|modbus_client|flexgen_ess_07_modbus_client.json|twins:10011"
"site_controller|modbus_client|flexgen_ess_08_modbus_client.json|twins:10012"
"site_controller|modbus_client|flexgen_ess_09_modbus_client.json|twins:10013"
"site_controller|modbus_client|flexgen_ess_10_modbus_client.json|twins:10014"
"site_controller|modbus_client|flexgen_ess_11_modbus_client.json|twins:10015"
"site_controller|modbus_client|flexgen_ess_12_modbus_client.json|twins:10016"
"site_controller|modbus_client|flexgen_ess_13_modbus_client.json|twins:10017"
"site_controller|modbus_client|flexgen_ess_14_modbus_client.json|twins:10018"
"site_controller|modbus_client|flexgen_ess_15_modbus_client.json|twins:10019"
"site_controller|modbus_client|flexgen_ess_16_modbus_client.json|twins:10020"
"site_controller|modbus_client|flexgen_ess_17_modbus_client.json|twins:10021"
"site_controller|modbus_client|flexgen_ess_18_modbus_client.json|twins:10022"
"site_controller|modbus_client|flexgen_ess_19_modbus_client.json|twins:10023"
"site_controller|modbus_client|flexgen_ess_20_modbus_client.json|twins:10024"
"site_controller|modbus_client|flexgen_ess_21_modbus_client.json|twins:10025"
"site_controller|modbus_client|flexgen_ess_22_modbus_client.json|twins:10026"
"site_controller|modbus_client|flexgen_ess_23_modbus_client.json|twins:10027"
"site_controller|modbus_client|flexgen_ess_24_modbus_client.json|twins:10028"
"site_controller|modbus_client|flexgen_ess_25_modbus_client.json|twins:10029"
"site_controller|modbus_client|flexgen_ess_26_modbus_client.json|twins:10030"
"site_controller|modbus_client|flexgen_ess_27_modbus_client.json|twins:10031"
"site_controller|modbus_client|flexgen_ess_28_modbus_client.json|twins:10032"
"site_controller|modbus_client|flexgen_ess_29_modbus_client.json|twins:10033"
"site_controller|modbus_client|flexgen_ess_30_modbus_client.json|twins:10034"
"site_controller|modbus_client|flexgen_ess_31_modbus_client.json|twins:10035"
"site_controller|modbus_client|flexgen_ess_32_modbus_client.json|twins:10036"
"site_controller|modbus_client|flexgen_ess_33_modbus_client.json|ess_controller:502"
"site_controller|modbus_client|apc_ups_client.json|twins:10000"
"site_controller|modbus_client|sel_351_1_client.json|twins:10001"
"site_controller|modbus_client|sel_351_2_client.json|twins:10002"
"site_controller|modbus_client|sel_735_client.json|twins:10003"
"site_controller|modbus_client|sel_3530_client.json|twins:10004"
"site_controller|dnp3_server|dnp3_server.json|site_controller:20000"
"twins|modbus_server|bms_modbus_server.json|twins:5030"
"twins|modbus_server|pcs_modbus_server.json|twins:5031"
"twins|modbus_server|flexgen_ess_01_modbus_server.json|twins:10005"
"twins|modbus_server|flexgen_ess_02_modbus_server.json|twins:10006"
"twins|modbus_server|flexgen_ess_03_modbus_server.json|twins:10007"
"twins|modbus_server|flexgen_ess_04_modbus_server.json|twins:10008"
"twins|modbus_server|flexgen_ess_05_modbus_server.json|twins:10009"
"twins|modbus_server|flexgen_ess_06_modbus_server.json|twins:10010"
"twins|modbus_server|flexgen_ess_07_modbus_server.json|twins:10011"
"twins|modbus_server|flexgen_ess_08_modbus_server.json|twins:10012"
"twins|modbus_server|flexgen_ess_09_modbus_server.json|twins:10013"
"twins|modbus_server|flexgen_ess_10_modbus_server.json|twins:10014"
"twins|modbus_server|flexgen_ess_11_modbus_server.json|twins:10015"
"twins|modbus_server|flexgen_ess_12_modbus_server.json|twins:10016"
"twins|modbus_server|flexgen_ess_13_modbus_server.json|twins:10017"
"twins|modbus_server|flexgen_ess_14_modbus_server.json|twins:10018"
"twins|modbus_server|flexgen_ess_15_modbus_server.json|twins:10019"
"twins|modbus_server|flexgen_ess_16_modbus_server.json|twins:10020"
"twins|modbus_server|flexgen_ess_17_modbus_server.json|twins:10021"
"twins|modbus_server|flexgen_ess_18_modbus_server.json|twins:10022"
"twins|modbus_server|flexgen_ess_19_modbus_server.json|twins:10023"
"twins|modbus_server|flexgen_ess_20_modbus_server.json|twins:10024"
"twins|modbus_server|flexgen_ess_21_modbus_server.json|twins:10025"
"twins|modbus_server|flexgen_ess_22_modbus_server.json|twins:10026"
"twins|modbus_server|flexgen_ess_23_modbus_server.json|twins:10027"
"twins|modbus_server|flexgen_ess_24_modbus_server.json|twins:10028"
"twins|modbus_server|flexgen_ess_25_modbus_server.json|twins:10029"
"twins|modbus_server|flexgen_ess_26_modbus_server.json|twins:10030"
"twins|modbus_server|flexgen_ess_27_modbus_server.json|twins:10031"
"twins|modbus_server|flexgen_ess_28_modbus_server.json|twins:10032"
"twins|modbus_server|flexgen_ess_29_modbus_server.json|twins:10033"
"twins|modbus_server|flexgen_ess_30_modbus_server.json|twins:10034"
"twins|modbus_server|flexgen_ess_31_modbus_server.json|twins:10035"
"twins|modbus_server|flexgen_ess_32_modbus_server.json|twins:10036"
"twins|modbus_server|apc_ups_client.json|twins:10000"
"twins|modbus_server|sel_351_1_server.json|twins:10001"
"twins|modbus_server|sel_351_2_server.json|twins:10002"
"twins|modbus_server|sel_735_server.json|twins:10003"
"twins|modbus_server|sel_3530_server.json|twins:10004"
)
​
cfgVars=(
     "active_power|ess_controller|/ess_1/controls/ess_1|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_1/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_01_hs|active_power_setpoint"
     "active_power|ess_controller|/ess_2/controls/ess_2|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_2/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_02_hs|active_power_setpoint"
     "reactive_power|ess_controller|/ess_1/controls/ess_1|ReactivePowerSetpoint"
)
​
cfgSrc=docker
cfgDest=docker
cfgSysId=BRP_TX100
cfgNodes=${cfgNodes_docker[@]}
​
# pull in the rest of it
source ./deploy_tools.sh
cfgMenu