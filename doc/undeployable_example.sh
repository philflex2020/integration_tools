#!/bin/sh

# {
#     "clients": {
#         "main" : {
#             "directory" : "/home/vagrant/data",
#             "servers" : [ "local" ],
#             "extension" : ".tar.gz"   
#         }
#     },
#     "servers": {
#         "local": {
#             "ip" : "",
#             "directory" : "/home/vagrant/test_cloud_sync/server",
#             "timeout" : 10
#         }
#     },
#     "db_directory" : "/home/vagrant/.cloud_sync/db",
#     "retry_limit" : 1,
#     "sleep_limit_seconds" : 30,
#     "buffer_size" : 100000
# }

cloud_sync=(
'obj|clients|main|"directory":"/home/vagrant/data"|"servers":["local"]|"extension":".tar.gz"'
'obj|clients|backup|"directory":"/home/vagrant/backup"|"servers":["local"]|"extension":".tar.gz"'
'obj|servers|local|ip:""|"directory":"/home/vagrant/test_cloud_sync/server"|"timeout":10'
'obj|servers|remote1|ip:"10.3.4.5"|"directory":"/home/hybridos/test_cloud_sync/server"|"timeout":10'
'item|db_directory:"/home/hybridos/test_cloud_sync/server"'
'item|retry_limit:1'
'item|sleep_limit_seconds:30'
'item|buffer_sizs:30'
)
function txttojson()
{
echo '{'
for xx in "${cloud_sync[@]}"
do
    if  [ "${xx:0:4}" == "item" ]
    then
        echo $xx
    fi
done
echo '}'

}

txttojson
