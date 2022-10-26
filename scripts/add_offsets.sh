#!/bin/bash
# add offsets

function cfgAddOffsets {
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
        ofoo=`expr $ofoo % 1000`
        ofadd=`expr $devid \* 1000`
        ofom=`expr $ofoo + $ofadd`
        nline=`echo "$line" | sed -e "s/$ofoo/$ofom/1"`
        #echo "$line  offset : $ofoo : $ofom : ofadd $ofadd "
        #echo "nline >> $nline"
        #exit 0
    fi
    echo "$nline"
    done < $1
    #bms_fix.json
}

bms_fix=`cfgAddOffsets bms_fix.json`
echo "$bms_fix" >bmd_fix_fixed.json
