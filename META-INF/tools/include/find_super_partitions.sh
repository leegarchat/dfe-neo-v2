


for blocksuper in /dev/block/by-name/* /dev/block/bootdevice/by-name/* /dev/block/bootdevice/* /dev/block/* ; do
    if lptools_new --super $blocksuper --get-info &>/dev/null; then
        echo "$blocksuper"
        break
    fi    
done 