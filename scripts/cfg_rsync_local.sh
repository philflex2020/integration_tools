#!/usr/bash
#
# p wilshire
# 10_26_2022

# $1 is the node or system name 

# remote sync
# $2 is a serverip, it rsyncs the files to the server
# local sync
# creates a list of chnaged files and then tars them up ready for cloud_sync to deploy the tarball
# $2 is the server  if we dont give a server the operation is local 

if [ $# -eq 1 ] ; then
  node=$1
else 
 node=site_controller
fi

if [ $# -eq 2 ] ; then
  serverip=$2
else 
  serverip="local"
  #serverip="root@172.30.0.23"
fi

uptime=`date +%F%S | sed -e 's/\//_/g'`

datadir="/home/data"
stagedir="/home/rsync"
srcdir="/usr/local/etc/config"
logdir="/var/log/flexgen"
logfile="cfg_rsync_local.log"
serverdir="/home/config/rsync"


mkdir -p ${stagedir}/${node}
mkdir -p ${datadir}/${node}
mkdir -p ${logdir}



if [ "$serverip" == local ]; then

   rsync -aLi  --out-format='%n' ${srcdir} ${stagedir}/${node} | grep -e ".json" -e ".xlsx" \
                             > /tmp/${node}_${uptime}.files 2>/tmp/${node}_${uptime}_err.out

   # if nothing changed we get no files.
   if [  -s "/tmp/${node}_${uptime}.files" ] ; then
      cd /usr/local/etc && /usr/bin/tar -czf ${datadir}/${node}_${uptime}_files.tar.gz -T /tmp/${node}_${uptime}.files
   fi

else

   rsync -aLi  --out-format='%n' ${srcdir} ${serverip}:${serverdir}/$node | grep -e ".json" -e ".xlsx"\
                            > /tmp/$node_$uptime.files 2>/tmp/$node_err.out
   #ssh $serverip "cd /home/config/rsync && git add $node && git commit -m \" $node update $uptime\" && git push"

fi

if [ ! -s "/tmp/${node}_${uptime}_err.out" ] ; then
   echo " ${node}_${uptime}_err"  >> ${logfile}
   cat /tmp/${node}_${uptime}_err.out >> ${logfile}
fi

rm -f /tmp/${node}_${uptime}.files
rm -f /tmp/${node}_${uptime}_err.out

#ls -l  ${datadir}/

