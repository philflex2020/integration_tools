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
# reason for being ....
# One thing that was wiped out of the ess gauntlet configs were the IPs and ports for the ess_controller  clients and servers. So far I've put 10.10.1.27 in the IP of both bms and pcs modbus clients then set ncemc_flexgen_ess_modbus_server to 0.0.0.0. 
# Does anyone remember if this is right? Were than any funny port remaps?
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
cfgR="\e[31m"
cfgGR="\e[32m"
cfgY="\e[33m"
cfgB="\e[34m"
cfgW="\e[97m"
cfgE="\e[0m"


# new layout 
##  systems
##    NCEMC10
## (sites)  gauntlet
##          docker
##          repo
##            destid
##               node
function getPullDir()
{
  dest=/home/config/pull/$cfgPullSystem/$cfgPullSite
  if [ $# -ge 1 ] 
  then
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$1
  fi
  if [ $# -ge 2 ] 
  then
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$2/$1
  fi
  
  echo $dest
}

# new layout 
##  systems
##    NCEMC10
## (sites)  gauntlet
##          docker
##          repo
##            destid
##               node
function getAnyDir()
{
  dest=/home/config/pull/$cfgPullSystem/$cfgPullSite
  # look for pull in $1
  if [ $# -ge 1 ] 
  then
    case $1 in
    "pull:"*)
    p1=$1
    p1v=${p1#"pull:"}
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$p1v
    ;;
    "targ:"*)
    p1=$1
    p1v=${p1#"targ:"}
    dest=/home/config/targ/$cfgTargSystem/$cfgTargSite/$p1v
    ;;
    "refs:"*)
    p1=$1
    p1v=${p1#"refs:"}
    dest=/home/config/refs/$cfgRefSystem/$cfgRefSite/$p1v
    ;;
    *)
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$1
    ;;
    esac
  fi
  if [ $# -ge 2 ] 
  then
    case $2 in
    "pull:"*)
    p2=$2
    p2v=${p2#"pull:"}
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$p2v/$1
    ;;
    "targ:"*)
    p2=$2
    p2v=${p2#"targ:"}
    dest=/home/config/targ/$cfgTargSystem/$cfgTargSite/$p2v/$1
    ;;
    "refs:"*)
    p2=$2
    p2v=${p2#"refs:"}
    dest=/home/config/refs/$cfgRefSystem/$cfgRefSite/$p2v/$1
    ;;
    *)
    dest=/home/config/pull/$cfgPullSystem/$cfgPullSite/$2/$1
    ;;
    
    esac
  fi
  
  mkdir -p $dest
  echo $dest
}

# getPull
function getRefDir()
{
  dest=/home/config/refs/$cfgRefSystem/$cfgRefSite
  # add a node 
  if [ $# -ge 1 ] 
  then
    dest=/home/config/refs/$cfgRefSystem/$cfgRefSite/$1
  fi
  # add  node and a dir
  if [ $# -ge 2 ] 
  then
    dest=/home/config/refs/$cfgRefSystem/$cfgRefSite/$2/$1
  fi
  
  echo $dest
}

function getTargDir()
{
  dest=/home/config/targ/$cfgTargSystem/$cfgTargSite
  # add a node 
  if [ $# -ge 1 ] 
  then
    dest=/home/config/targ/$cfgTargSystem/$cfgTargSite/$1
  fi
  # add  node and a dir
  if [ $# -ge 2 ] 
  then
    dest=/home/config/targ/$cfgTargSystem/$cfgTargSite/$2/$1
  fi
  echo $dest
}


# getPull
function getSrcDir()
{
  dest=/home/config/pull/$cfgSrcSysId/$cfgSrcSite
  if [ $# -ge 1 ] 
  then
    dest=/home/config/pull/$cfgSrcSysId/$cfgSrcSite/$1
  fi
  if [ $# -ge 2 ] 
  then
    dest=/home/config/pull/$cfgSrcSysId/$cfgSrcSite/$2/$1
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

## get the ssh login information
## note that this works to allow a ssh "jump"
# ssh -t hybridos@10.10.1.29 ssh hybridos@10.10.1.28
# but it wot work for scp
#

function nodeSSH()
{
    for i in ${cfgNodes[@]} 
    do 
    name=`echo $i | cut -d ':' -f1`
    if [ "$name" == "$1" ] 
    then
      ip=`echo $i | cut -d ':' -f2`
      ip=`echo $ip | cut -d '|' -f1`
      echo $ip
      return
    fi
    done
}


function destSSH()
{
    for i in ${cfgNodes[@]} 
    do 
    name=`echo $i | cut -d ':' -f1`
    if [ "$name" == "$1" ] 
    then
      ip=`echo $i | cut -d ':' -f2`
      dest=`echo $ip | cut -d '|' -f2`
      echo $dest
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
#ssh hybridos@10.10.1.29 "timeout 5 /usr/local/bin/fims_listen > /home/hybridos/fims_out.txt"         
function logFims()
{
    if [ $# -lt 2 ] 
    then
      echo " collecting fims into $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "pullFims $cn $1"
         pullFims "$cn" "$1"
      done
      return
    fi
    ddd=`date +%F%T`

    #dest=`getPull $1 $2`
    #echo " pulling fims for [$1] into [$2] dest = [$dest]"
    #dest=/home/config/pull/$2/$1
    #mkdir -p $dest/fims_pull
    ip=`nodeSSH $1`
    if [ "$ip" != "" ]
    then
      ssh $ip  "mkdir -p /home/hybridos/fims_data && timeout 5 /usr/local/bin/fims_listen > /home/hybridos/fims_data/fims_out.txt&"         
      echo "fims collection started waiting 5 seconds"
      #return
    else
      echo "node $1 unknown"
    fi

}

function pullFims()
{
    if [ $# -lt 2 ] 
    then
      echo " collecting all fims into $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "pullFims $cn $1"
         pullFims "$cn" "$1"
      done
      return
    fi
    ddd=`date +%F%T`
    #getPull
    dest=`getPullDir $1 $2`
    dest=${dest}/fims_data
    echo " pulling fims for [$1] into [$2] dest = [$dest]"
    #dest=/home/config/pull/$2/$1
    mkdir -p $dest
    ip=`nodeSSH $1`
    if [ "$ip" != "" ]
    then
      fdata=`ssh $ip  "cat /home/hybridos/fims_data/fims_out.txt"`
      echo $fdata > $dest/fims_data.txt

      #return
    else
      echo "node $1 unknown"
    fi

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
    #ddd=`date +%F%T`

    #getPull
    dest=`getPullDir $1 $2`
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
    #getPull
    dest=`getPullDir $1 $2`
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
  # if [ $# -lt 2 ] 
  # then
  #   echo " pushing all configs from $1"
  #   for cn in ${cfgAllNodes[@]}
  #   do
  #     echo "pushConfigs $cn $1"
  #     pushConfigs "$cn" "$1"
  #   done
  #   return
  # fi
  #getPull
  # etRefDir
  if [ $# -lt 2 ]
  then
    refdt=$cfgTargDtime
  else
    refdt=$2
  fi 
  # TOTO pickone showone
  # we stage configs in TargDir
  src=`getTargDir $1 $refdt`
  # getTargDir perhaps
  # TODODODODO  get from node config
  dest=/home/hybridos
  ##mkdir -p $dest
  ip=`nodeSSH $1`
  dest=`destSSH $1`

  if [ "$ip" != "" ]
  then
    echo "pushing configs from $src to $ip:$dest"
    scp -r $src $ip:$dest/test
    echo "configs pushed to $ip:$dest"
    return
  fi
  echo "node $1 unknown"
}

# $1 node name $2 dest id $3 orig id
function showPullConfigs()
{
    ddd=`date +%F%T`
    if [ $# -lt 2 ] 
    then
      echo " Show all configs from  $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "showPullConfigs $cn $1"
         showPullConfigs $cn $1
      done
      return
    fi
    dest=`getPullDir $1 $2`
    #orig=`getPullDir $1 $3`

    #dest=/home/config/pull/$2/$1
    #orig=/home/config/pull/$3/$1
    files=`find $dest -name "*.json" `
    for f in $files 
    do
      file=${f#$dest}
      echo $2/$1$file
    done

}

# $1 node name $2 dest id $3 orig id
function showRefConfigs()
{
    ddd=`date +%F%T`
    if [ $# -lt 2 ] 
    then
      echo " Show all configs from  $1"
      for cn in ${cfgAllNodes[@]}
      do
         echo "showPullConfigs $cn $1"
         showPullConfigs $cn $1
      done
      return
    fi
    dest=`getRefDir $1 $2`
    #orig=`getPullDir $1 $3`

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
    dest=`getPullDir $1 $2`
    orig=`getPullDir $1 $3`
    files=`find $dest -name "*.json" `
    for f in $files 
    do
      file=${f#$dest}
      echo $file
    done

}

# $1 node name refs:$2 dest id pull:$3 orig id
function diffConfigs()
{
    #ddd=`date +%F%T`
    #dest=/home/config/pull/$2/$1
    #orig=/home/config/pull/$3/$1
    #getAnyDir decodes pull: def:from $x 
    
    orig=$diffADir
    dest=$diffBDir

    if [ "$orig" == "" ]
    then
       echo "select diff A dir with difa"
    fi
    if [ "$dest" == "" ]
    then
       echo "select diff B dir with difb"
    fi
    if [ "$orig" == "" ] || [ "$dest" == "" ]
    then
      return 
    fi
    
    #dest=`getAnyDir $1 $2`
    #orig=`getAnyDir $1 $3`

    files=`find $dest -name "*.json" `
    for f in $files 
    do
      dfile=${f#$dest}
      ofile=${f#$orig}
      if [ -f "${orig}${dfile}" ]
      then 
        xdiff=`diff -u ${orig}${dfile} ${dest}${dfile} > ${dest}${dfile}.diff`
        if [ -s ${dest}${dfile}.diff ]
        then
          echo " $dfile - diffs =========="
          cat ${dest}${dfile}.diff
        else
          #echo " $file - no diffs =========="
          rm -f ${dest}${dfile}.diff
        fi
      #else
      #    echo " no $ofile - found =========="
      fi
    done
}

function loadNodes()
{
  fnodes="../sites/$cfgTargSystem/$cfgTargSite/nodes.sh"
  ftarg="../sites/$cfgTargSystem/system.sh"
  if [ -f  "$ftarg" ]
  then
    echo "found  file [$ftarg] "
    . "$ftarg"
  else
    echo "no file found [$ftarg]"
  fi
  if [ -f  "$fnodes" ]
  then
    echo "found  file [$fnodes] "
    . "$fnodes"
  else
    echo "no file found [$fnodes]"
  fi
}

# $1 sel(0 to bypass)  $2 list  $3 curr sel  
function pickOne()
{
  uKey=0
  cKey=$1
  #cKey=$((${cKey} + 1))
  eKey=$#
  eKey=$((${eKey} - 1))
  targs=("$@")

  #echo " args = $#"
  #echo "cKey = $cKey"
  #echo "targs = [$2]"
  #echo "def targ = ${targs[$eKey]}"
  curr=${targs[$eKey]}
  for i in ${targs[@]} 
  do
    #echo "uKey [$uKey] cKey [$cKey] i [$i]"
    if [ "$uKey" == "$cKey" ] && [ $uKey -gt 0 ]
    then
      #echo "curr was  = [$curr]"
      curr="$i"
      echo $curr
      return
      #nodes.sh
    fi
    uKey=$((${uKey} + 1))
  done
  echo $curr
  return
}

function showPick ()
{
  uKey=1
  cKey=$((${cKey} + 1))
  targs=("$@")
  eKey=$#
  eKey=$((${eKey} - 1))
  curr=${targs[$eKey]}
  
  for i in ${targs[@]} 
  do
    if [ $uKey -gt 0 ] && [ $uKey -lt $# ]
    then 
      if [ "$curr" == "$i" ]
      then
        echo "=>  $i"
      else
        echo "    $i"
      fi
    fi
    uKey=$((${uKey} + 1))
  done
}

function showNodes()
{
  uKey=1
  cKey=0
  echo " args = $#"
  echo " cfgTargs = [${cfgTargs[@]}]"
  curr=$cfgTargSite
  if [ $# -ge 2 ]
  then
    curr=`pickOne $1 ${cfgTargs[@]} "$2"`
    showPick ${cfgTargs[@]} $curr
    #return
  elif [ $# -ge 1 ]
  then
    curr=`pickOne $1 ${cfgTargs[@]} "docker"`
    showPick ${cfgTargs[@]} $curr
    #return
  fi
  if [ "$cfgTargSite" != "$curr" ]
  then
    echo " note cfgTargSite=>$cfgTargSite  curr=>$curr "
    cfgTargSite="$curr"
    echo "loading new target definitions"
    loadNodes
    echo " new cfgTargSite=>$cfgTargSite "
      #nodes.sh
  fi
    # echo " available targets :"
  # echo
  # for i in ${cfgTargs[@]} 
  # do 
  #   if [ "$cfgTargSite" == "$i" ]
  #   then
  #      echo "=>  $i"
  #   else
  #      echo "    $i"
  #   fi
  # done
  echo
  echo " ip map for current target   => $cfgTargSite "
  echo
  for i in ${cfgNodes[@]} 
  do 
    echo "   $i"
  done
  echo
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
# ust needs a var name   
function runVar()
{
  if [ $# -eq 0 ]
  then
    vlist=()
    for i in ${cfgVars[@]} 
    do 
      #echo $i
      var=`echo $i | cut -d '|' -f1`
      #echo "var = $var"
      vadd=`echo ${vlist[@]} | grep $var`
      #echo "vadd = $vadd"

      if [ "$vadd" == "" ]
      then
        echo "==> $var"
        vlist+=($var)
      fi
    done
    return 
  fi

  for i in ${cfgVars[@]} 
  do 
    #echo $i
    var=`echo $i | cut -d '|' -f1`
    node=`echo $i | cut -d '|' -f2 `
    uri=`echo $i | cut -d '|' -f3 `
    fvar=`echo $i | cut -d '|' -f4 `
    fset=`echo $i | cut -d '|' -f5 `
    if [ "$fset" == "" ]
    then
      fset="get"
    fi

    if [ "$var" == "$1" ]
    then
      ip=`nodeSSH $node`
      if [ "$ip" != "" ]
      then
        if [ "$fset" == "get" ]
        then
          echo -n " $node get $uri/$fvar"
          vval=`ssh $ip "/usr/local/bin/fims_send -m $fset -r/xxx -u $uri/$fvar"`
        fi
        if [ "$fset" == "set" ]
        then   
           echo -n " $node set $uri $fvar"
           vval=`ssh $ip "/usr/local/bin/fims_send -m $fset -r/xxx -u $uri $fvar"`
        fi
        echo "  $vval"
      fi
    fi
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
## showDestids
function showPullDestIds()
{
    cDtime="$cfgPullDtime"
    cKey=0
    if [ $# -ge 2 ]
    then
      cKey=$2 
    fi
    if [ $# -ge 1 ]
    then
      cfgPullSite=$1
    fi
    
    uKey=1

    dest=`getPullDir `
    echo "destid dir [$dest] [$cfgPullDtime]"
    dirs=(`ls -1 $dest `)

    if [ "$cKey" == "new" ]
    then 
      cfgDtime=`date +%F_%T | sed -e 's/://g'`
      cfgPullDtime="$cfgDtime"
      dirs+=($cfgPullDtime)
    fi

    for d in ${dirs[@]}
    do
      if [ "$uKey" == "$cKey" ]
      then
        cDtime=$d
        cfgPullDtime=$d
      fi
      uKey=$((${uKey} + 1))
    done

    for d in ${dirs[@]}
    do
      if [ "$d" == "$cfgPullDtime" ]
      then
         echo "*=> $d"
      else
         echo "    $d"
      fi
    done
}

function showRefDestIds()
{
    cDtime="$cfgRefDtime"
    cKey=0
    if [ $# -ge 1 ]
    then
      cKey=$1 
      #cDtime=$1
      #cfgRefDtime=$1
    fi

    uKey=1
    dest=`getRefDir `
    echo "destid dir [$dest] [$cDtime]"
    dirs=(`ls -1 $dest `)
    if [ "$cKey" == "new" ]
    then 
      cfgDtime=`date +%F_%T | sed -e 's/://g'`
      cfgRefDtime="$cfgDtime"
      dirs+=($cfgRefDtime)
    fi

    for d in ${dirs[@]}
    do
      if [ "$uKey" == "$cKey" ]
      then
        cDtime=$d
        cfgRefDtime=$d
      fi
      uKey=$((${uKey} + 1))
    done
    for d in ${dirs[@]}
    do
      if [ "$d" == "$cfgRefDtime" ]
      then
         echo "*=> $d"
         gid=`getAnyDir refs:$d`
         if [ -f "$gid/git_data.sh" ]
         then
           echo "     loading git data"
           source "$gid/git_data.sh"
         fi
      else
         echo "    $d"
      fi
    done
}

function showTargDestIds()
{
    cDtime="$cfgTargDtime"
    cKey=0
    if [ $# -ge 1 ]
    then
      cKey=$1 
      #cDtime=$1
      #cfgRefDtime=$1
    fi

    uKey=1
    dest=`getTargDir `
    echo "destid dir [$dest] [$cDtime]"
    dirs=(`ls -1 $dest `)
    if [ "$cKey" == "new" ]
    then 
      cfgDtime=`date +%F_%T | sed -e 's/://g'`
      cfgTargDtime="$cfgDtime"
      dirs+=($cfgTargDtime)
    fi

    for d in ${dirs[@]}
    do
      if [ "$uKey" == "$cKey" ]
      then
        cDtime=$d
        cfgTargDtime=$d
      fi
      uKey=$((${uKey} + 1))
    done
    for d in ${dirs[@]}
    do
      if [ "$d" == "$cfgTargDtime" ]
      then
         echo "*=> $d"
         gid=`getAnyDir targ:$d`
      else
         echo "    $d"
      fi
    done
}

# Show ports for a selected system
#"ess_controller|modbus_client|bms_1_modbus_client.json|twins:1500"
# showRpms [twins] default to all
function showRpms()
{
  if [ $# -lt 1 ] 
  then
    echo " showing all rpms for "
    for cn in ${cfgAllNodes[@]}
    do
        echo "showRpms $cn "
        showRpms "$cn"
    done
    return
  fi
  ip=`nodeSSH $1`
  vval=(`ssh $ip "rpm -qa"`)
  #TODO record these somewhere
  # echo "  ${vval[@]}"
  
  for i in ${cfgRpms[@]} 
  do 
    #echo $i

    pnode=`echo $i | cut -d '|' -f1`
    name=`echo $i | cut -d '|' -f2 `
    efile=`echo $i | cut -d '|' -f3 `
    if [ "$pnode" == "$1" ] || [ "$pnode" == "common" ]
    then 

      echo -n  "name [$name] "
      for j in ${vval[@]}
      do
        rf=`echo $j |grep $name`
        if [ "$rf" != "" ]
        then
          echo -n " $j"
        fi
      done
      echo 
    fi

  #   if [ "$pnode" == "$1" ] || [ "$pnode" == "common" ]
  #   then 
  #     ip=`nodeSSH $1`
  #     if [ "$ip" != "" ] && [ "$efile" != ""]
  #     then
  #       echo -n ">>>>>> [$pnode] [$name] [$efile] "
  #       vval=`ssh $ip "rpm -q --whatprovides \"$efile\""`
  #       echo "  $vval"
  #     fi
  #     if [ "$ip" != "" ] 
  #     then 
  #       echo -n " $node $name "
  #       vval=`ssh $ip "rpm -qa $name"`
  #       echo "  $vval"

  #     fi
  #  fi
  done
}

cfgR=""
cfgGR=""
cfgB="" 
#0x27[34m
cfgW=""
cfgE="" 
#ESC[39m

cfgDtime=`date +%F_%T | sed -e 's/://g'`

cfgRefDtime="$cfgDtime"
cfgTargDtime="$cfgDtime"
cfgPullDtime="$cfgDtime"

# cfgRefBranch="integration_dev:NCEMC10_features/hotfix"
# cfgGITREPO="integration_dev"
# cfgGITBRANCH="NCEMC/randolph_twins"

# cfgRefSystem=$cfgSystem
# cfgTargSystem="$cfgSystem"
# cfgPullSystem="$cfgSystem"

# cfgRefSite="repo"
#cfgTargSite="docker"
#cfgTargSystem="NCEMC10"
#cfgPullSite=gauntlet
loadNodes
#fnodes="../sites/$cfgTargSystem/$cfgTargSite/nodes.sh"
function cfgHelpSites()
{
    if [ "$cfgTargSite" == "" ]
    then
      cfgTargSite="unknown cfgTargSite"
    fi
    if [ "$cfgPullSite" == "" ]
    then
      cfgPullSite="unknown cfgPullSite"
    fi

    #echo "     (sys)                       (site)               (dest)  "
    echo -n " Ref Source: "
    echo -n " System:${cfgB}${cfgRefSystem}${cfgE} "
    echo -n " Site:${cfgB}${cfgRefSite}${cfgE}     " 
    #"<- PullSource: ${cfgB}$cfgTarget${cfgE} "
    echo  " destId:${cfgB}$cfgRefDtime${cfgE} "

    echo -n " Target Push:"
    echo -n " System:${cfgB}${cfgTargSystem}${cfgE} "
    echo -n " Site:${cfgB}${cfgTargSite}${cfgE}     " 
    echo    " destId:${cfgB}$cfgTargDtime${cfgE} "
    #"<- PullSource: ${cfgB}$cfgTarget${cfgE} "
    #echo
    echo -n " Pull Dest:  "
    echo -n " System:${cfgB}${cfgPullSystem}${cfgE} "
    echo -n " Site:${cfgB}${cfgPullSite}${cfgE}     " 
    #"<- PullSource: ${cfgB}$cfgTarget${cfgE} "
    echo " destId:${cfgB}$cfgPullDtime${cfgE} "
    echo 
    echo " Git Repo:${cfgB}$cfgGITREPO${cfgE} Branch:${cfgB}$cfgGITBRANCH${cfgE} "

}

function cfgHelp()
{ 
    echo
    echo "           ${cfgB}System Config Management Tool${cfgE}"
    echo
    cfgHelpSites
    #echo "                         -> PushDest: ${cfgB}$cfgSite${cfgE} "
    echo
    echo " (rpms) showRpms                   -- show the System rpms "    
    echo " (srd) showRefIds                  -- set/show the available ref destids "    
    echo " (std) showTargIds                 -- set/show the available Tsrget (stage) destids "    
    echo " (spd) showPullIds                 -- set/show the available pull destids "    
    echo " (sn) showNodes                    -- shows the system target nodes"    
    echo " (sp) showPorts node               -- show ports require  for a given node"
    echo " (scm) showConfigMaps              -- show modbus and dnp3 files"
    echo " ===>  pull configs from git "
    echo " (sgref) setGitRef [repo] [branch] destid -- setup a refs destid from git "
    echo " (stage) StageCfgs [target] [destid] -- stage configs for a target from repos "
    
    #echo " (sys) src[Ref/Targ/Pull] id       -- set system (NCEMC/TX100 etc)"
    #echo " (site) site[Ref/Targ/Pull] id     -- set site (gauntlet/docker/randolph)"
    #echo " (dest) src[Ref/Targ/Pull] id      -- set destid (2022_10_13_1122)"

    #echo " showPullConfigs [node] destid     -- show modbus and dnp3 files"
    #echo " showRefConfigs [node] destid      -- show modbus and dnp3 files"
    echo 
    echo " (sv) runVar name                 -- show selected var (in Progress)"
    
    echo 
    echo " (pull) pullConfigs destid         -- pull configs to a specified dest"
    echo " (pulln) pullConfigs node destid   -- pull configs to a specified dest"
    echo " (fips) fixIps [node] destid       -- fixIps for this destination"
    echo    
    echo " (lf) logFims [node] destid        -- start a 5 second log of fims"
    echo " (pf) pullFims [node] destid       -- pull the fimsLog"
    echo 
    echo    
    echo " showConfigs [node] destid         -- show configs from specified dest"
    echo " (difa|difb) pull site number      -- setup diff dirs A and B"
    echo " (dfc) diffConfigs node [pull:|refs:]dest [pull:|refs:]orig   -- check configs in dest against origs "
    echo
    echo " (fs) findString [destid] string   -- find files containing a string (no spaces please)"

    echo " (push) pushConfigs [node] destid   -- push configs to a specified dest (in Progress)"
}

function getDiffDest()
{
  node=$1
  data=$2
  data1=$3  
  who=$4


  case "$node" in
      "p"|"pull")

        tempDestId=$cfgPullDtime
        showPullDestIds $data $data1
        difDestId=$cfgPullDtime
        difRef="pull"
        #populates $cfgPullDtime
        cfgPullDtime=$tempDestId
    ;;
    "r"|"ref")

        tempDestId=$cfgRefDtime
        showRefDestIds $data $data1
        difDestId=$cfgRefDtime
        difRef="refs"
        #populates $cfgPullDtime
        cfgRefDtime=$tempDestId
    ;;
    "t"|"targ")

        tempDestId=$cfgTargDtime
        showTargDestIds $data $data1
        difDestId=$cfgTargDtime
        difRef="targ"
        #populates $cfgPullDtime
        cfgTrgDtime=$tempDestId
    ;;
    
  esac
  diffDest=`getAnyDir "$difRef:$difDestId"`
  echo " anydir [$difRef:$difDestId] dif for  $who dir is [$diffDest]"
}

function cfgMenu()
{
  dend=0
  cfgHelp
  echo " (q) Quit Menu "
  while [ $dend -eq 0 ]
  do
    node=''
    data=''
    read -p " Enter command :" cmd node data data1
    #echo "you entered [$cmd]"
    case "$cmd" in
      "q") dend=1
      ;;

      "sn") 
      echo " >>> select system (use a number)"
      showNodes $node $data
      ;;

      "sys") 
      echo " >>> set system  $node to $data"
      case "${node:0:1}" in 
        "T"|"t")
          #cfgTargSystem="$data"
          #. ../sites/$cfgTargSystem/$cfgTargSite/nodes.sh
          #. ../sites/$cfgTargSystem/nodes.sh
          echo  " systems = ${fsystems[@]} "

          ## we have to do more work here
          # cgNodes = nodes for system site combo
          # esch avaiable system will have a config dir with possible sites
          #cfgNodes=${cfgNodes_gauntlet[@]}
          # cfgnodes = system_

        ;;
        "R"|"r")
          cfgRefSystem="$data"
        ;;
        "P"|"p")
          cfgPullSystem="$data"
        ;;

      esac
      cfgHelpSites
      ;;

      "sgref")
      if [ "$node" == "help" ]
      then
        echo "example >> sgref integration_dev NCEMC/randolph_twins refs:2022-1014_testgit"
      else
        setGitRef $node $data $data1
      fi
      ;;

      "site") 
      # TODO recset cfgNodes etc
      echo " >>> set site  $node to $data"
      case "${node:0:1}" in 
        "T"|"t")
          cfgTargSite="$data"
          loadNodes
        ;;

        "R"|"r")
          cfgRefSite="$data"
        ;;
        "P"|"p")
          cfgPullSite="$data"
        ;;
      esac
      cfgHelpSites
      ;;

      "dest") 
      echo " >>> set dest  $node to $data"
      case "${node:0:1}" in 
        "T"|"t")
          cfgTargDtime="$data"
        ;;
        "R"|"r")
          cfgRefDtime="$data"
        ;;
        "P"|"p")
          cfgPullDtime="$data"
        ;;
      esac
      cfgHelpSites
      ;;

      "rpms") 
      #echo " >>> system rpms"
      showRpms $node
      ;;

      "dfc") 
      #echo " >>> diffConfigs"
      diffConfigs $node $data $data1
      ;;

      "sv") 
      echo " >>> values for [$node]"
      runVar $node
      ;;

      "spd") 
      echo " >>> current pull destids"
      showPullDestIds $node $data
      #populates $cfgPullDtime
      ;;

      "difa") 
      diffDest=""
      if [ "$node" == "" ]
      then 
        echo " >>> current difa dir [$diffADir]"
      else      
        echo " >>> setup difa dir"
        getDiffDest $node $data $data1 "diffA"
        diffADir=$diffDest
      fi
      ;;

      "difb") 
      diffDest=""
      if [ "$node" == "" ]
      then 
        echo " >>> current difb dir [$diffBDir]"
      else      
        echo " >>> setup difb dir"
        getDiffDest $node $data $data1 "diffB"
        diffBDir=$diffDest
      fi
      ;;

      "srd") 
      echo " >>> current ref destids"
      showRefDestIds $node
      ;;
      "std") 
      echo " >>> current ref destids"
      showTargDestIds $node
      ;;
      
      "fs") 
      echo "# looking for a string"
      findString $node $data
      ;;
      "fips") 
      echo "# fixIps $node"
      fixIps $node $data
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
        echo "using dest id $cfgPullDtime"
        pullConfigs $cfgPullDtime
      fi
      ;;
      "stage")
        StageCfgs $node $data
      ;;
      "push") 
      if [ "$node" != "" ]
      then
        echo " >>> push configs to  target [$node]"
        cfgDtime="$node"
        pushConfigs "$node"     
      else
        echo "using dest id $cfgRefDtime"
        pushConfigs $cfgRefDtime
      fi
      ;;

      "lf") 
      if [ "$node" != "" ]
      then
        echo " >>> start 5 second fims log [$node]"
        if [ "$data" != "" ]
        then
          cfgDtime="$data"
        fi        
        logFims "$node" "$data"     
      else
        echo " no dest id given"
      fi
      ;;

      "pf") 
      if [ "$node" != "" ]
      then
        echo " >>> collect 5 second fims log [$node]"
        if [ "$data" != "" ]
        then
          cfgDtime="$data"
        fi
        pullFims "$node" "$data"     
      else
        echo " no dest id given"
      fi
      ;;

      "pulln") 
      if [ "$node" != "" ]
      then
        echo " >>> pull configs from [$node] into [$cfgSite]"
        #cfgSite="$node"
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

//  we copy a repo set of configs to a stage dir for a given target , or the default target
function StageCfgs()
{
  if [ $# -gt 0 ]
  then
    cfgTargSite="$1"
  fi
  ddd="refs:$cfgRefDtime"
  src=`getAnyDir $ddd`

  ddd="targ:$cfgRefDtime"
  dest=`getAnyDir $ddd`

  echo "stageCfgs  [$src] ==> [$dest]"
  mkdir -p $dest
  if [ -d "$src" ]
  then
    cp -a $src/* $dest/
  else
    echo " unable to find ref dir [$src]"    
  fi

}
  # fixFiles too
# man they are all over the place...
# https://github.com/flexgen-power/cloud_sync/dev/config/config.json
# https://github.com/flexgen-power/config_powercloud/dev/ftd/ftd.json
# https://github.com/flexgen-power/config_powercloud/dev/dts/dts.json
# /usr/local/etc/config/go_logging/cloud_sync/cloud_sync_verbose.json
# mcp stuff
# https://github.com/flexgen-power/config_powercloud/dev/mcp/mcp_dts.json
# /usr/local/etc/config/../config_powercloud/cloud_sync/cloud_sync.json what the heck

#cfgFiles=(    
#      fleet_manager|ftd|archive|/home/hybridos/powercloud/fleetman01/data
#      ess_controller|ftd|storage.json|dbName|docker
#)
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
  dname=`dirname $file`
  fname=`basename $file`

  if [ -e /usr/local/bin/fixFile ]
  then
   /usr/local/bin/fixFile -dir "$dname" -key "$field" -val "$newdata" -file "$fname"  
  else
    xxx=`echo "$field" | grep ','`
    if [ "$xxx" != "" ]
    then
      newdata=${newdata}, 
    fi
    echo " file [$file]"
    echo " field [$field]"
    echo " newdata [$newdata]"

    sed -i "s/$field/$newdata/1" $file
  fi
  return

}
# checkout git to a ref dir
#
#  git_repo
#  Git branch
#  destid
#   setGitRef integration_dev NCEMC/randolph_twins refs:2022-1014_test
#GITBRANCH  = $(shell git branch | grep \* | cut -d ' ' -f2)
#GITCOMMIT  = $(shell git log --pretty=format:'%h' -n 1)
#GITVERSION = $(shell git rev-list --count $(GITCOMMIT))
#GITTAG     = $(shell git describe --match v* --abbrev=0 --tags HEAD --always)
function setGitRef()
{
  if [ $# -lt 2 ]  
  then
    echo " please supply git repo, branch , destid"
    gitrepo="$cfgGITREPO"
    gitbranch="$cfgGITBRANCH"
  else
   gitrepo="$1"
   gitbranch="$2"

  fi
  echo "using  repo $gitrepo branch $gitbranch"
  pwd=`pwd`
  ##date
  cfgRefDtime=`date +%F_%T | sed -e 's/://g'`
  ##dd=`date +%F%T`
  ddd="refs:$cfgRefDtime"
  if [ $# -ge 3 ]
  then
    ddd=$3
  fi  
  dest=`getAnyDir $ddd`
  gdest=/home/config/git
  mkdir -p $dest
  mkdir -p $gdest
  
  echo " dest = $dest"
  cd $gdest
  #cd ../../
  edir=$gdest/$gitrepo

  #cd $edir
  if [ -d $gdest/$gitrepo ]
  then 
    cd $gdest/$gitrepo
    git pull -r

  else
    cd $gdest
    git clone git@github.com:flexgen-power/$gitrepo
    cd $gitrepo
  fi
  git checkout $gitbranch

  cfgGITBRANCH=`git branch | grep \* | cut -d ' ' -f2`
  cfgGITCOMMIT=`git log --pretty=format:'%h' -n 1`
  cfgGITVERSION=`git rev-list --count ${cfgGITCOMMIT}`
  cfgGITTAG=`git describe --match v* --abbrev=0 --tags HEAD --always`
  echo "cfgGITREPO=\"$gitrepo\""                    > config/git_data.sh
  echo "cfgGITBRANCH=\"${cfgGITBRANCH}\""   >> config/git_data.sh
  echo "cfgGITCOMMIT=\"${cfgGITCOMMIT}\""   >> config/git_data.sh
  echo "cfgGITVERSION=\"${cfgGITVERSION}\"" >> config/git_data.sh
  echo "cfgGITTAG=\"${cfgGITTAG}\""         >> config/git_data.sh
  cd $pwd
  echo "copying git configs from $edir/config to $dest " 
  cp -a $edir/config/* $dest  
}

function cfgSetIp()
{
  fname=$1
  ipaddress=$2
  port=$3
  contents="$(jq '.connection.ip_address |= "$ipaddress" | .connection.port |= $port ' $fname)" && echo "${contents}" > $fname
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
      dest=`getAnyDir $1 $2`
      cfgsrcArr=(`find $dest -name $pfile`) 
      echo "file = $pfile pnode = $pnode port = $port pip = $pip src = [${cfgsrcArr[0]}]"
      echo " dest [$dest]"
      newip=$pip
      newport=$port
      for cfgsrc in "${cfgsrcArr[@]}" 
      do
        cfgSetIP $cfgsrc $newip $newport
        # #echo "file FOUND " 
        # # we change the file in place, as long as it is not checked in we'll be OK
        # # have to find the exact line with "ip_address"
        # # but what if its not on a line on its own
        # # we need to crawl through the file to find the string to replace
        # ipADDRArr=`grep \"ip_address\" $cfgsrc`
        # ipADDR=$ipADDRArr
        # trim="        "
        # #trimc=`echo "$ipADDR" | tr -cd ' ' | wc -c`
        # newip="$trim\"ip_address\": \"$pip\""

        # fixFile $cfgsrc "$ipADDR" "$newip"

        # pORTArr=`grep \"port\" $cfgsrc`
        # newport="$trim\"port\": $port"
        # echo ">>>> pORTArr  [$pORTArr]"
        # echo ">>>> newport  [$newport]"

        # xxx=`echo "$pORTArr" | grep ','`
        # fixFile $cfgsrc "$pORTArr" "$newport"
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

# fs [refid] string
function findString()
{
  dtime="$cfgDtime"
  if [ $# -lt 1 ]  
  then
    echo "#we need a string to find"
    return
  fi
  if [ $# -lt 2 ]  
  then
    string="$1"
  else 
    string="$2"
    dtime="$1"
    cfgDtime="$1"
  fi
  dest=`getPullDir "$dtime"`
  echo "#using dest $dest  string [$string]"
  findArr=(`find $dest -name "*.json" | xargs grep -Rl $string `) 
  for f in ${findArr[@]}
  do
    echo "$f"
  done
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
