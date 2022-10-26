#!/bin/bash
# remove_offsets
function cfgRemoveOffsets()
{

devid=0

while IFS= read -r line || [ -n "$line" ]
do
  nline="$line"
  if [[ "$line" = *"device_id"* ]] ; then
    devid=`echo  "$line" | cut -d ':' -f2 | cut -d ',' -f1`
    #if  [[ $foo -gt 10 ]] ; then
    # echo $foo
    #fi

  elif  [[ $devid -gt 10 ]] && [[ "$line" = *"offset"* ]] ; then
    ofoo=`echo  "$line" | cut -d ':' -f2 | cut -d ',' -f1`
    ofom=`expr $ofoo % 1000`
    nline=`echo "$line" | sed -e "s/$ofoo/$ofom/1"`
    #echo "$line  offset : $ofoo : $ofom"
    #echo "nline >> $nline"
  fi
  echo "$nline"
done < $1
}
bms_orig=`cfgRemoveOffsets bms_orig.json`
echo "$bms_orig" > bms_orig_fixed.json