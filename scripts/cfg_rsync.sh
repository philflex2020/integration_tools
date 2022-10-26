#!/bin/sh
# script to pull them all

#rsync -aLi  --out-format='%n' root@172.30.0.21:/usr/local/etc/config /home/config/rsync/ess_controller
#rsync -aLi  --out-format='%n' root@172.30.0.22:/usr/local/etc/config /home/config/rsync/site_controller
#rsync -aLi  --out-format='%n' root@172.30.0.23:/usr/local/etc/config /home/config/rsync/fleet_manager
#rsync -aLi  --out-format='%n' root@172.30.0.20:/usr/local/etc/config /home/config/rsync/twins
#rsync -aLi  --out-format='%n' root@172.30.0.21:/usr/local/etc/config /home/phil/config/rsync/ess_controller

#rsync -aLi  --out-format='%n' /usr/local/etc/config phil@192.168.1.138:/home/phil/config/rsync/ess_controller

echo ess_controller
rsync -aLi  --out-format='%n' root@172.30.0.21:/usr/local/etc/config /home/config/rsync/ess_controller > /tmp/ess.out 2>/tmp/ess_err.out

echo site_controller
rsync -aLi  --out-format='%n' root@172.30.0.22:/usr/local/etc/config /home/config/rsync/site_controller > /tmp/site.out 2>/tmp/site_err.out

echo fleet_manager skipped
#rsync -aLi  --out-format='%n' root@172.30.0.23:/usr/local/etc/config /home/config/rsync/fleet_manager> /tmp/fleet.out 2>/tmp/fleet_err.out

echo twins
rsync -aLi  --out-format='%n' root@172.30.0.20:/usr/local/etc/config /home/config/rsync/twins > /tmp/twins.out 2>/tmp/twins_err.out

#SSHPASS='yourPasswordHere' rsync --rsh="sshpass -e ssh -l username" server.example.com:/var/www/html/ /backup/

#or from a node
# scripts/cfg_push.sh
uptime=`date +%F%S | sed -e 's/\//_/g'`
node=twins
serverip="root@172.30.0.23"

rsync -aLi  --out-format='%n' /usr/local/etc/config $serverip:/home/config/rsync/$node | grep ".json" > /tmp/$node_$uptime.files 2>/tmp/$node_err.out
ssh $serverip "cd /home/config/rsync && git add $node && git commit -m \" $node update $uptime\" && git push"
#tar -cvf allfiles.tar -T /tmp/$node_$uptime.files

#or from a node
#push to a local mirror dir nd get a list of chenged files 
# tar those up and get cloudsync to deal with them
# scripts/cfg_push_local.sh
uptime=`date +%F%S | sed -e 's/\//_/g'`
node=twins
serverip="root@172.30.0.23"
datadir="/home/config/data"
stagedir="/home/rsync"
srcdir="/usr/local/etc/config"



rsync -aLi  --out-format='%n' ${srcdir} ${stagedir}/${node} | grep ".json" \
                             > /tmp/${node}_${uptime}.files 2>/tmp/${node}_${uptime}_err.out
#ssh $serverip "cd /home/config/rsync && git add $node && git commit -m \" $node update $uptime\" && git push"

#cd /usr/local/etc tar -cvzf ${datadir}/${node}_${uptime}_files.tar.gz -T /tmp/${node}_${uptime}.files



# cfg restore from git
cd /home/config/rsync
when="10 minutes ago"

commit=`git log --before="$when" -1 | grep commit | cut -d ' ' -f2`
git checkout $commit
node=twins
nodeip="root@172.30.0.20"
serverip="root@172.30.0.23"

rsync -aLi  --out-format='%n' /home/config/rsync/$node  $nodeip:/usr/local/etc/config > /tmp/$node.out 2>/tmp/$node_err.out
ssh $nodeip "cd /home/scripts && sh dbi.sh /usr/local/etc/config"

