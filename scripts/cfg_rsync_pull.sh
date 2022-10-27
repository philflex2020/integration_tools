#!/usr/bash
#
# p wilshire
# 10_26_2022


# remote sync
# $1 is a serverip, it rsyncs the files from the server


if [ $# -eq 1 ] ; then
  serverip=$1
else 
  echo "please supply the server ip "
fi

uptime=`date +%F%S | sed -e 's/\//_/g'`

localdir=`pwd`
logdir="/var/log/flexgen"
logfile="cfg_rsync_pull.log"
serverdir="/home/config/rsync"

node="pull"
#mkdir -p ${stagedir}/${node}
#mkdir -p ${datadir}/${node}
mkdir -p ${logdir}


rsync -avLi  --out-format='%n' ${serverip}:${serverdir}/* ${localdir} \
                            > /tmp/${node}_${uptime}.files 2>/tmp/${node}_err.out
   #ssh $serverip "cd /home/config/rsync && git add $node && git commit -m \" $node update $uptime\" && git push"



#if [ -f  "/tmp/${node}_${uptime}_err.out" ] ; then
   echo " ${node}_${uptime}_err"    >> ${logdir}/${logfile}
   echo " pulled to ${localdir}"    >> ${logdir}/${logfile}
   cat /tmp/${node}_${uptime}.files >> ${logdir}/${logfile}
   echo " ============  "  >> ${logdir}/${logfile}
#fi

rm -f /tmp/${node}_${uptime}.files
rm -f /tmp/${node}_${uptime}_err.out

echo " =============    list of files "
cat ${logdir}/${logfile}

echo " =============    list of dirs "
ls -l  ${localdir}/

