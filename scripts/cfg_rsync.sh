#!/bin/sh
# script to pull them all

rsync -aLi  --out-format='%n' root@172.30.0.21:/usr/local/etc/config /home/config/rsync/ess_controller
rsync -aLi  --out-format='%n' root@172.30.0.22:/usr/local/etc/config /home/config/rsync/site_controller
rsync -aLi  --out-format='%n' root@172.30.0.23:/usr/local/etc/config /home/config/rsync/fleet_manager
rsync -aLi  --out-format='%n' root@172.30.0.20:/usr/local/etc/config /home/config/rsync/twins
#rsync -aLi  --out-format='%n' root@172.30.0.21:/usr/local/etc/config /home/phil/config/rsync/ess_controller

#rsync -aLi  --out-format='%n' /usr/local/etc/config phil@192.168.1.138:/home/phil/config/rsync/ess_controller