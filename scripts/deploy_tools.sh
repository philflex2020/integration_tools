#!/bin/sh
# these will be in a different file 
# cfgNodes=( 
#      "ess_controller:hybridos@10.10.1.29" 
#     "site_controller:hybridos@10.10.1.28" 
#        "fleetmanager:hybridos@10.10.1.156" 
#               "twins:hybridos@10.10.1.27"
#          "powercloud:hybridos@10.10.1.20"
#          "twins_test:root@172.30.0.20"
# )

# cfgMaps=(    
# "ess_controller|modbus_client|bms_1_modbus_client.json|twins:1500"
# "ess_controller|modbus_client|bms_2_modbus_client.json|twins:1501"
# "ess_controller|modbus_client|pcs_1_modbus_client.json|twins:1502"
# "ess_controller|modbus_client|pcs_2_modbus_client.json|twins:1503"
# "ess_controller|modbus_server|ncemc_ess_modbus_server.json|site_controller:1510"
# "fleetmanager|modbus_client|acromag.json|twins:1504"
# "fleetmanager|dnp3_client|rtac_dnp3_client.json|twins:20001"
# "fleetmanager|dnp3_client|randolph_dnp3_client.json|twins:20002"
# "fleetmanager|dnp3_server|ncemc_fleetmanager_dnp3_server.json|fleetmanager:20001"
# "site_controller|modbus_client|flexgen_ess_1_modbus_client.json|ess_controller:1510"
# "site_controller|modbus_client|sel_3530.json|twins:1507"
# "site_controller|modbus_client|sel_735.json|twins:1508"
# "site_controller|modbus_client|modbus_loopback_client.json|site_ontroller:1509"
# "site_controller|modbus_server|modbus_loopback_server.json|site_controller:1510"
# "site_controller|dnp3_client|rtac_dnp3_client.json|fleetmanager:20001"
# "site_controller|dnp3_server|fleetmanager_dnp3_server.json|site_controller:20001"
# "twins|modbus_server|bms_1_modbus_server.json|twins:1500"
# "twins|modbus_server|bms_2_modbus_server.json|twins:1501"
# "twins|modbus_server|pcs_1_modbus_server.json|twins:1502"
# "twins|modbus_server|pcs_2_modbus_server.json|twins:1503"
# "twins|modbus_server|sel_351_1_server.json|twins:1504"
# "twins|modbus_server|sel_3530_server.json|twins:1507"
# "twins|modbus_server|sel_735_server.json|twins:1508"
# "twins|dnp3_server|randolph_rtac_dnp3_server.json|twins:20001"
# )

#** TODO modbus_client acromag.json 10.10.1.27:1504
#** TODO modbus_client acuvim.json 10.10.1.27:1505
#** TODO modbus_client apcups.json 10.10.1.27:1506
#** TODO modbus_client flexgen_ess_2_modbus_client.json 172.30.0.21:1511
#** TODO modbus_server acromag_server.json 10.10.1.27:1504
#** TODO modbus_server acuvim_server.json 10.10.1.27:1505
#** TODO modbus_server apcups_server.json 10.10.1.27:1506

# getPulldir 
# home/config/$system/$target/$date/$node 

function getPull()
{
  #cfgDest=gauntlet
  #cfgSysId=NCEMC10
  dest=/home/config/pull/$cfgSysId/$cfgDest
  if [ $# -ge 2 ] 
  then
    dest=/home/config/pull/$cfgSysId/$cfgDest/$2/$1
  fi
  echo $dest
}

# $1 node name
function nodeIp()
{
    for i in ${cfgNodes[@]} 
    do 
    name=`echo $i | cut -d ':' -f1`
    if [ "$name" == "$1" ] 
    then
      ip=`echo $i | cut -d '@' -f2`
      echo $ip
      return
    fi
    done
}

# $1 node name
function nodeUser()
{
    for i in ${cfgNodes[@]} 
    do 
    name=`echo $i | cut -d ':' -f1`
    if [ "$name" == "$1" ] 
    then
      u=`echo $i | cut -d ':' -f2`
      user=`echo $u | cut -d '@' -f1`
      echo $user
      return
    fi
    done
}

function nodeSSH()
{
    for i in ${cfgNodes[@]} 
    do 
    name=`echo $i | cut -d ':' -f1`
    if [ "$name" == "$1" ] 
    then
      ip=`echo $i | cut -d ':' -f2`
      echo $ip
      return
    fi
    done
}

function nodeMaps()
{
    for i in ${cfgMaps[@]} 
    do 
    name=`echo $i | cut -d '|' -f1`
    #echo $name
    if [ "$name" == "$1" ] 
    then
      #ip=`echo $i | cut -d ':' -f2`
      echo $i
      #return
    fi
    done
}

# $1 node name $2 dest id
function pullConfigs()
{
    if [ $# -lt 2 ] 
    then
      echo " pulling all configs into $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "pullConfigs $cn $1"
         pullConfigs "$cn" "$1"
      done
      return
    fi
    ddd=`date +%F%T`

    dest=`getPull $1 $2`
    echo " pulling configs for [$1] into [$2] dest = [$dest]"
    #dest=/home/config/pull/$2/$1
    mkdir -p $dest
    ip=`nodeSSH $1`
    if [ "$ip" != "" ]
    then
      scp -r $ip:/usr/local/etc/config $dest
      echo "configs pulled to $dest"
      return
    fi
    echo "node $1 unknown"

}

# $1 node name $2 dest id
function pullDbi()
{
  # $1 node
  ip=`nodeSSH $1`
  if [ "$ip" != "" ]
  then
    docs=`ssh $ip /usr/local/bin/fims_send -m get -r /me -u /dbi/$1/show_documents`
    ddocs=`echo $docs |cut -d '[' -f2 | cut -d ']' -f1`
    echo $ddocs > /tmp/$1_ddocs
    sed -i "s/,/\n/g" /tmp/$1_ddocs
    clist=()
    while read d 
    do
      dd=`echo $d |cut -d '"' -f2 `
      echo $dd 
      clist+=($dd)
      #dfile=`ssh $ip /usr/local/bin/fims_send -m get -r /me -u /dbi/$1/$dd`
      #echo $dfile
      #sleep 1
    done < /tmp/$1_ddocs
    echo clist 
    echo "${clist[@]}"
    for c in "${clist[@]}"
    do
      echo " item $c"
      dfile=`ssh $ip /usr/local/bin/fims_send -m get -r /me -u /dbi/$1/$c`
      echo $dfile
      #sleep 1
    done
    return
  fi
      
}

# $1 node name $2 dest id
function pullrConfigs()
{
    ddd=`date +%F%T`
    dest=getPull $1 $2
    #dest=/home/config/pull/$2/$1
    mkdir -p $dest
    ip=`nodeSSH $1`
    user=`nodeUser $1`
    if [ "$ip" != "" ]
    then
      mkdir -p $dest
      src=$ip:/home/$user/config
      rsync -av $src  $dest
      echo "configs rsync'd from $src to $dest"
      return
    fi
    echo "node $1 unknown"

}
# $1 node name $2 dest id
function pushConfigs()
{
    src=getPull $1 $2
    dest=/home/hybridos
    mkdir -p $dest
    ip=`nodeSSH $1`
    if [ "$ip" != "" ]
    then
      scp -rv $src $ip:$dest/test
      echo "configs pushed to $ip:$dest"
      return
    fi
    echo "node $1 unknown"

}

# $1 node name $2 dest id $3 orig id
function showConfigs()
{
    ddd=`date +%F%T`
    if [ $# -lt 2 ] 
    then
      echo " Show all configs from  $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "showConfigs $cn $1"
         showConfigs $cn $1
      done
      return
    fi
    dest=getPull $1 $2
    orig=getPull $1 $3

    #dest=/home/config/pull/$2/$1
    #orig=/home/config/pull/$3/$1
    files=`find $dest -name "*.json" `
    for f in $files 
    do
      file=${f#$dest}
      echo $2/$1$file
    done

}

# cannot do this until we get jq in the config repo
# $1 node name $2 dest id $3 orig id
# make sure the configs pass a basic json test
function testConfigs()
{
    ddd=`date +%F%T`
    #dest=/home/config/pull/$2/$1
    #orig=/home/config/pull/$3/$1
    dest=getPull $1 $2
    orig=getPull $1 $3
    files=`find $dest -name "*.json" `
    for f in $files 
    do
      file=${f#$dest}
      echo $file
    done

}

# $1 node name $2 dest id $3 orig id
function diffConfigs()
{
    ddd=`date +%F%T`
    #dest=/home/config/pull/$2/$1
    #orig=/home/config/pull/$3/$1
    dest=`getPull $1 $2`
    orig=`getPull $1 $3`

    files=`find $dest -name "*.json" `
    for f in $files 
    do
      file=${f#$dest}
      xdiff=`diff -u ${orig}${file} ${dest}${file} > ${dest}${file}.diff`
      if [ -s ${dest}${file}.diff ]
      then
        echo " $file - diffs =========="
        cat ${dest}${file}.diff
      else
        #echo " $file - no diffs =========="
        rm -f ${dest}${file}.diff
      fi
    done

}

function showNodes()
{
    for i in ${cfgNodes[@]} 
    do 
    echo $i

    done
}

function showConfigMaps()
{
    for i in ${cfgMaps[@]} 
    do 
    echo $i

    done
}

# Show ports for a selected system
#"ess_controller|modbus_client|bms_1_modbus_client.json|twins:1500"
# showPorts twins
function showPorts()
{
    plist=()
    for i in ${cfgMaps[@]} 
    do 
      #echo $i
      port=`echo $i | cut -d '|' -f4`
      pnode=`echo $port | cut -d ':' -f1 `
      pport=`echo $port | cut -d ':' -f2 `
      if [ "$pnode" == "$1" ]
      then 
        foo=`echo "${plist[@]}" | grep $pport`
        if [ "$foo" == "" ]
        then
            plist+=($pport)
       fi
      fi 
    done
    echo "${plist[@]}"
}

cfgDtime=""

function showDestIds()
{
    if [ $# -ge 1 ]
    then
      cfgDtime=$1
    fi

    dest=`getPull`

    dirs=(`ls -1 $dest `)
    for d in ${dirs[@]}
    do
      if [ "$d" == "$cfgDtime" ]
      then
         echo "*=> $d"
      else
         echo "    $d"
      fi
    done
}

function cfgHelp()
{
    echo
    echo " System Config Management Tool"
    echo " System: $cfgSystem      <- PullSource: $cfgTarget "
    echo "                         -> PullDir: $cfgDtime "
    echo "                         -> PushDest: $cfgDest "
    echo
    echo " (sd) showIds                     -- show the available destids "    
    echo " (sn) showNodes                   -- shows the system nodes"    
    echo " (sp) showPorts node              -- show ports require  for a given node"
    echo " (source) src                     -- set pull source (gauntlet/docker/site)"

    echo " (scm) showConfigMaps              -- show modbus and dnp3 files"
    echo " showConfigs [node] destid         -- show modbus and dnp3 files"
    echo 
    echo " (pull) pullConfigs destid        -- pull configs to a specified dest"
    echo " (pulln) pullConfigs node destid  -- pull configs to a specified dest"
    echo " (fips) fixIps [node] destid       -- fixIps for this destination"
    echo    
    echo " showConfigs [node] destid         -- show configs from specified dest"
    echo " diffConfigs node dest orig        -- check configs in dest against origs "

    echo " pushConfigs [node] destid         -- push configs to a specified dest (in Progress)"
}


function cfgMenu()
{
  dend=0
  cfgHelp
  echo " (q) Quit Menu "
  while [ $dend -eq 0 ]
  do
    node=''
    read -p " Enter command :" cmd node
    #echo "you entered [$cmd]"
    case "$cmd" in
      "q") dend=1
      ;;

      "sn") 
      echo " >>> system ips"
      showNodes
      ;;

      "sd") 
      echo " >>> current destids"
      showDestIds $node
      ;;
      "scm") 
      echo " >>> config maps"
      showConfigMaps
      ;;

      "source")
      case "$node" in
        "d"|"docker")
        echo " >>> docker system ips selected "
        cfgNodes=${cfgNodes_docker[@]}
        ;;
        "g"|"gauntlet")
        echo " >>> gauntlet system ips selected "
        cfgNodes=${cfgNodes_gauntlet[@]}
        ;;
        "s"|"site")
        echo "source [$node] not defined"
        ;;
        *)
        echo "source [$node] not recognised"
        ;;
        esac 
      ;; 

      "sp") 
      if [ "$node" != "" ]
      then
        echo "ports used for $node" 
        showPorts $node
      else
        echo " no node given"
      fi
      ;;

      "pull") 
      if [ "$node" != "" ]
      then
        echo " >>> pull configs into dest [$node]"
        cfgDtime="$node"
        pullConfigs "$node"     
      else
        echo " no dest id given"
      fi
      ;;
      "pulln") 
      if [ "$node" != "" ]
      then
        echo " >>> pull configs from [$node] into [$cfgDest]"
        #cfgDest="$node"
        pullConfigs "$node" "$cfgDtime"    
      else
        echo " no node given"
      fi
      ;;

      "h") cfgHelp
      echo " (q) Quit Menu "
      ;;

      *) 
      echo " >>>> Unknown cmd [$cmd]"
      ;;

    esac
    #read -p " continue :" cmd
  done

}

# fixIps file  field  newdata
function fixFile()
{
  if [ $# -lt 3 ]
  then
    echo " needs a file, field and new data"
    return
  fi
  file=$1
  field=$2
  newdata=$3
  xxx=`echo "$field" | grep ','`
  if [ "$xxx" != "" ]
  then
    newdata=${newdata}, 
  fi
  echo " file [$file]"
  echo " field [$field]"
  echo " newdata [$newdata]"
  sed -i "s/$field/$newdata/1" $file
  return

}

# fixIps node pullDir
function fixIps()
{
  if [ $# -lt 2 ]  
  then
    echo " Fix all ip addresses from   $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "fixIps $cn $1"
         fixIps $cn $1
      done
      return
    fi
  if [ $# -ge 2 ]; then
    plist=(`nodeMaps $1`)
    #echo "${plist[@]}"
    for pitem in "${plist[@]}"
    do
      #echo " >>> pitem $pitem"
      #echo "TEST extract data  " 
      pfile=`echo $pitem | cut -d '|' -f 3`
      ppnode=`echo $pitem | cut -d '|' -f 4`
      pnode=`echo $ppnode | cut -d ':' -f1`
      port=`echo $ppnode | cut -d ':' -f2` 
      ppip=`nodeSSH $pnode`
      pip=`echo $ppip | cut -d '@' -f2`
      dest=`getPull $1 $2`
      cfgsrcArr=(`find $dest -name $pfile`) 
      echo "file = $pfile pnode = $pnode port = $port pip = $pip src = [${cfgsrc[0]}]"
      newip=$pip
      newport=$port
      for cfgsrc in "${cfgsrcArr[@]}" 
      do
        #echo "file FOUND " 
        # we change the file in place, as long as it is not checked in we'll be OK
        # have to find the exact line with "ip_address"

        ipADDRArr=`grep \"ip_address\" $cfgsrc`
        ipADDR=$ipADDRArr
        trim="        "
        #trimc=`echo "$ipADDR" | tr -cd ' ' | wc -c`
        newip="$trim\"ip_address\": \"$pip\""

        fixFile $cfgsrc "$ipADDR" "$newip"

        pORTArr=`grep \"port\" $cfgsrc`
        newport="$trim\"port\": $port"
        echo ">>>> pORTArr  [$pORTArr]"
        echo ">>>> newport  [$newport]"

        xxx=`echo "$pORTArr" | grep ','`
        fixFile $cfgsrc "$pORTArr" "$newport"
        done
    done 
    return
    #CFGSRC="/home/docker/git/dnp3_interface/brp/angleton/dnp3_client.json"
    #CFGADDR=$3
    #newip=`echo $CFGADDR | cut -d ':' -f1`
    #newport=`echo $CFGADDR | cut -d ':' -f2`
    #CFGSRC=`find /home/config -name $2`
    newip=$pip
    newport=$port
  fi  
}

# # ncemc10 interface ip remapping gauntlet
# # ess_controller 10.10.1.29
# modbus_client bms_1_modbus_client.json 10.10.1.27:1500
# modbus_client bms_2_modbus_client.json 10.10.1.27:1501
# modbus_client pcs_1_modbus_client.json 10.10.1.27:1502
# modbus_client pcs_2_modbus_client.json 10.10.1.27:1503
# modbus_server ncemc_ess_modbus_server.json 10.10.1.28:1510
# # fleetmanager 10.10.1.156
# modbus_client acromag.json 10.10.1.27:1504
# dnp3_client   rtac_dnp3_client.json 10.10.1.27:20001
# dnp3_client   randolph_dnp3_client.json 10.10.1.27:20002
# dnp3_server   ncemc_fleetmanager_dnp3_server.json 10.10.1.156:20001
# # powercloud 172.30.0.24
# # site_controller 10.10.1.28
# #** TODO modbus_client acromag.json 10.10.1.27:1504
# #** TODO modbus_client acuvim.json 10.10.1.27:1505
# #** TODO modbus_client apcups.json 10.10.1.27:1506
# modbus_client flexgen_ess_1_modbus_client.json 10.10.1.29:1510
# #** TODO modbus_client flexgen_ess_2_modbus_client.json 172.30.0.21:1511
# modbus_client sel_3530.json 10.10.1.27:1507
# modbus_client sel_735.json 10.10.1.27:1508
# modbus_client modbus_loopback_client.json 10.10.1.29:1509
# modbus_server modbus_loopback_server.json 10.10.1.29:1510
# dnp3_client   rtac_dnp3_client.json 10.10.1.156:20001
# dnp3_server   fleetmanager_dnp3_server.json 10.10.1.156:20001
# #twins  10.10.1.27
# modbus_server bms_1_modbus_server.json 10.10.1.27:1500
# modbus_server bms_2_modbus_server.json 10.10.1.27:1501
# modbus_server pcs_1_modbus_server.json 10.10.1.27:1502
# modbus_server pcs_2_modbus_server.json 10.10.1.27:1503
# modbus_server sel_351_1_server.json 10.10.1.27:1504
# modbus_server sel_3530_server.json 10.10.1.29:1507
# modbus_server sel_735_server.json 10.10.1.29:1508
# dnp3_server   randolph_rtac_dnp3_server.json 10.10.1.29:20001
# #** TODO modbus_server acromag_server.json 10.10.1.27:1504
# #** TODO modbus_server acuvim_server.json 10.10.1.27:1505
# #** TODO modbus_server apcups_server.json 10.10.1.27:1506
