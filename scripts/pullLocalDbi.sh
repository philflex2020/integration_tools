#!/bin/sh
# p wilshire
# pull the dbi files and save them in a /home/hybridos/config/dbi folder

dbiDir=/home/hybridos/config/dbi_pull

cfgCols=()

function getCollections()
{
  docs=`/usr/local/bin/fims_send -m get -r /me -u /dbi/show_collections`
  ddocs=`echo $docs |cut -d '[' -f2 | cut -d ']' -f1`

  cfgCols=(`echo $ddocs | sed -e "s/,/ /g" `)

}
# $1 node name

function pullLocalDbi()
{
  mkdir -p $dbiDir/$1
  # $1 node
  docs=`/usr/local/bin/fims_send -m get -r /me -u /dbi/$1/show_documents`
  ddocs=`echo $docs |cut -d '[' -f2 | cut -d ']' -f1`
  echo $ddocs > /tmp/$1_ddocs
  sed -i "s/,/\n/g" /tmp/$1_ddocs
  clist=()
  while read d
  do
    dd=`echo $d |cut -d '"' -f2 `
    #echo $dd
    clist+=($dd)
    #dfile=`ssh $ip /usr/local/bin/fims_send -m get -r /me -u /dbi/$1/$dd`
    #echo $dfile
    #sleep 1
  done < /tmp/$1_ddocs
  #echo clist
  #echo "${clist[@]}"
  for c in "${clist[@]}"
  do
    #echo " item $c"
    dfile=`/usr/local/bin/fims_send -m get -r /me -u /dbi/$1/$c`
    echo $dfile > $dbiDir/$1/$c.json
    #sleep 1
  done
}

getCollections 

for col in ${cfgCols[@]}
do
  cc=`echo $col| cut -d \" -f2`
  pullLocalDbi $cc
done


#pullLocalDbi ess_controller
#pullLocalDbi ui_config


