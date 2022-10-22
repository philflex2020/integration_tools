#!/bin/sh
# this defined the base system
# p wilshire
# 10_09_2022
# 
cfgSystem=NCEMC10
cfgSystem=gauntlet

. ../sites/$cfgSystem/repo.sh
. ../sites/$cfgSystem/system.sh
. ../sites/$cfgSystem/nodes.sh
. ../sites/$cfgSystem/$cfgTarget/nodes.sh

# cfgPullSystem=NCEMC10
# cfgPullSite=gauntlet


# cfgSystem=NCEMC10
# cfgSysId=NCEMC10
# cfgTarget=gauntlet

# cfgSrc=gauntlet
# cfgDest=gauntlet
# cfgPullSite=gauntlet
# cfgTargSite=gauntlet
# cfgRefSite=gauntlet
# cfgPullSystem=NCEMC10
# cfgTargSystem=NCEMC10
# cfgRefSystem=NCEMC10


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

