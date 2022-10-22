
# this is a list of initial nodes 
# special nodes can be added in /sites/NCEMC10/<nodename>/nodes.sh to modify 
# the defaults 
# ths system always loads
#   site/repo
#   site/system
#   site/nodes 
# and then 
# /site/<nodename>/nodes.sh can overwrite or extend the system as needed.

fsystems=(
"gauntlet"
"docker"
"lab"
"randolph"
)

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

cfgNodes_lab=( 
     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleet_manager:hybridos@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.11"
         "twins_test:root@172.30.0.20"
)

cfgNodes_randolph=( 
     "ess_controller:hybridos@10.10.1.29" 
    "site_controller:hybridos@10.10.1.28" 
       "fleet_manager:hybridos@10.10.1.156" 
              "twins:hybridos@10.10.1.27"
         "powercloud:hybridos@10.10.1.11"
         "twins_test:root@172.30.0.20"
)

nodeMap[lab]=${cfgNodes_lab[@]}


echo $nodeMap[lab]

