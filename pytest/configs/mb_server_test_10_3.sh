#!/bin/sh
# 
/usr/local/bin/fims_echo -u /comptest/comp1 -b '{
      "01":0
}'&
/
/usr/local/bin/fims_echo -u /components/comp2 -b '{
      "24_decode_id":0,
      "25":0

}'&
/usr/local/bin/fims_echo -u /components/xyz_ip_device_id -b '{
      "26":0

}'&
/usr/local/bin/fims_echo -u /components/comp1 -b '{
      "02":0,
      "03":0,
      "10":0,
      "13":0,
      "04":0
}'&
