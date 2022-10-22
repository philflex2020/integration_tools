#!/bin/sh
# this defined the base system
# p wilshire
# 10_14_2022
# 
cfgTarget=lab


cfgSrc=$cfgTarget
cfgDest=$cfgTarget
cfgNodes=${cfgNodeMapArr[$cfgTarget]}
cfgTargSite=$cfgTarget
cfgPullDest=$cfgTarget

# #** TODO modbus_client acromag.json 10.10.1.27:1504
# #** TODO modbus_client acuvim.json 10.10.1.27:1505
# #** TODO modbus_client apcups.json 10.10.1.27:1506
# #** TODO modbus_client flexgen_ess_2_modbus_client.json 172.30.0.21:1511
# #** TODO modbus_server acromag_server.json 10.10.1.27:1504
# #** TODO modbus_server acuvim_server.json 10.10.1.27:1505
# #** TODO modbus_server apcups_server.json 10.10.1.27:1506

