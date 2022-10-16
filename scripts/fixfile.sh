
# file name field , new data
function fixFileRecord()
{
  if [ $# -lt 3 ]
  then
    echo " needs a file, field and new data"
    return
  fi
  file=$1
  field=$2
  newdata=$3
  fdata=$(<$file)
  part1=`awk -F"stalled" "/$field/{print $2}" fdata
  part2=`awk -F"$field" '/ip_address/{print $2}' $file`

#   xxx=`echo "$field" | grep ','`
#   if [ "$xxx" != "" ]
#   then
#     newdata=${newdata}, 
#   fi
#   echo " file [$file]"
#   echo " field [$field]"
#   echo " newdata [$newdata]"
#   sed -i "s/$field/$newdata/1" $file
   return

}

fixFileRecord ./test.json "ip_adress" "127.0.0.1"
