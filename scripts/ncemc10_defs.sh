#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
#cfgSystem_ncemc_NCEMC10
#cfgTarget=gauntlet

cfgNodes_gauntlet=( 
     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleetmanager:hybridos@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.11"
         "twins_test:root@172.30.0.20"
)

cfgNodes_docker=( 
     "ess_controller:root@172.30.0.21" 
    "site_controller:root@172.30.0.22" 
       "fleetmanager:root@172.30.0.23" 
              "twins:root@172.30.0.20"
         "powercloud:root@172.30.0.24"
         "twins_test:root@172.30.0.20"
              "bms_1:root@172.30.0.20"
              "bms_2:root@172.30.0.20"
              "pcs_1:root@172.30.0.20"
              "pcs_2:root@172.30.0.20"
)

cfgNodes_randolph=( 
     "ess_controller:hybridos@192.168.112.0.11" 
    "site_controller:hybridos@192.168.112.22" 
       "fleetmanager:hybridos@192.168.112.23" 
              "twins:hybridos@192.168.112.20"
         "powercloud:hybridos@192.168.112.24"
     "bms_1:hybridos@192.168.114.0.12" 
     "bms_2:hybridos@192.168.114.0.13" 
     "pcs_1:hybridos@192.168.112.0.12" 
     "pcs_2:hybridos@192.168.112.0.13" 
)

cfgAllNodes=( 
     "ess_controller" 
    "site_controller" 
       "fleetmanager" 
              "twins"
)


cfgMaps=(    
"ess_controller|modbus_client|bms_1_modbus_client.json|fleetmanager:1500"
"ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501"
"ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502"
"ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503"
"ess_controller|modbus_server|ncemc_flexgen_ess_modbus_server.json|ess_controller:1510"
"fleetmanager|modbus_client|acromag.json|twins:1504"
"fleetmanager|dnp3_client|rtac_dnp3_client.json|twins:20001"
"fleetmanager|dnp3_client|randolph_dnp3_client.json|twins:20002"
"fleetmanager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleetmanager:20001"
"site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510"
"site_controller|modbus_client|sel_3530.json|twins:1507"
"site_controller|modbus_client|sel_735.json|twins:1508"
"xxsite_controller|modbus_client|modbus_loopback_client.json|site_ontroller:1509"
"xxsite_controller|modbus_server|modbus_loopback_server.json|site_controller:1510"
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

cfgVars=(
     "active_power|ess_controller|/ess_1/controls/ess_1|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_1/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_01_hs|active_power_setpoint"
     "active_power|ess_controller|/ess_2/controls/ess_2|ActivePowerSetpoint"
     "active_power|ess_controller|/ess_2/components/pcs_registers_fast|active_power"
     "active_power|site_controller|/components/flexgen_ess_02_hs|active_power_setpoint"
     "reactive_power|ess_controller|/ess_1/controls/ess_1|ReactivePowerSetpoint"
)
#declare -A cfgNCEMC10

#cfgNCEMC10[name]="NCEMC10"
cfgNCEMC10_vars="${cfgVars[@]}"
cfgNCEMC10_maps="${cfgMaps[@]}"
cfgNCEMC10_nodes="${cfgAllNodes[@]}"

#cfgMaps["NCEMC10"]["vars"]


#echo ${cfgMaps[@]}

cfgMaps="${cfgNCEMC10_maps[@]}"

echo ${cfgMaps[@]}







