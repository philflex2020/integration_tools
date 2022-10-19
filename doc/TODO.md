DONE
fixFile.go 
  needs to be integrated in progress

cfgEsslabStuff=(
    "##dbName##|labdb"
    "##Dir##|/home/docker/lab_db"
)    


cfgFiles=(    
     "ess_controller|storage.json|replace|system.client.dbName|lab"
     "ess_controller|stuff.json|template|cfgEsslabStuff"
)


design cycle #1

pull from git into a repo dir 
 Enter command :
 sgref
 please supply git repo, branch , destid
 using  repo integration_dev branch NCEMC/randolph_twins
 dest = /home/config/refs/NCEMC10/repo/2022-10-19_184509
remote: Enumerating objects: 131, done.
remote: Counting objects: 100% (131/131), done.
remote: Compressing objects: 100% (67/67), done.
remote: Total 131 (delta 75), reused 117 (delta 61), pack-reused 0
Receiving objects: 100% (131/131), 198.79 KiB | 0 bytes/s, done.
Resolving deltas: 100% (75/75), completed with 18 local objects.
From github.com:flexgen-power/integration_dev
   88bda0f..dde5922  NCEMC/randolph -> origin/NCEMC/randolph
Current branch NCEMC/randolph_twins is up to date.
Already on 'NCEMC/randolph_twins'

copying git configs from /home/config/git/integration_dev/config to /home/config/refs/NCEMC10/repo/2022-10-19_184509


use "srd" to select a repo dir

 Enter command :srd 8
 >>> current ref destids
destid dir [/home/config/refs/NCEMC10/repo] [2022-10-19_184509]
    2022-10-19_131713
    2022-10-19_131732
    2022-10-19_132025
    2022-10-19_132321
    2022-10-19_132447
    2022-10-19_133044
    2022-10-19_143617
*=> 2022-10-19_145712
     loading git data
    2022-10-19_184509
    2022-1014_0823
    2022-1014_test
    2022-1014_testgit
    2022-1014_testgit2



use "stage gauntlet"
to copy the repo dirs to a stage location 

stageCfgs  [/home/config/refs/NCEMC10/repo/2022-10-19_145712] ==> [/home/config/targ/NCEMC10/gauntlet/2022-10-19_145712]

sn 2
 Enter command :sn 2
 >>> system ips
 args = 1
 cfgTargs = [docker gauntlet lab]
    docker
=>  gauntlet
    lab
found  file [../sites/NCEMC10/system.sh]
found  file [../sites/NCEMC10/gauntlet/nodes.sh]

TODO
ssh tunnel perhaps

systemctl
timeout journalctl


df -h
/var/logs
/tmp
ps ax
top
decode fims
   lets use go for this

dbi setup/reload.
   mayb

get /controls etc 
ess /config/load
    /config/cfile
    /config/ctmpl

system config

// see fixfile
user names
db names



