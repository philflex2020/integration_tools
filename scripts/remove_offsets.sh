cat ./fixoffsets.sh
#!/bin/bash

device_id=0

while IFS= read -r line
do
  nline="$line"
  if [[ "$line" = *"device_id"* ]] ; then
    foo=`echo  "$line" | cut -d ':' -f2 | cut -d ',' -f1`
    #if  [[ $foo -gt 10 ]] ; then
    # echo $foo
    #fi

  elif  [[ $foo -gt 10 ]] && [[ "$line" = *"offset"* ]] ; then
    ofoo=`echo  "$line" | cut -d ':' -f2 | cut -d ',' -f1`
    ofom=`expr $ofoo % 1000`
    nline=`echo "$line" | sed -e "s/$ofoo/$ofom/1"`
    #echo "$line  offset : $ofoo : $ofom"
    #echo "nline >> $nline"
  fi
  echo "$nline"
done < bms_orig.json