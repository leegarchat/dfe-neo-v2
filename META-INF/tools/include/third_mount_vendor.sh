


my_print "- Монтирования vendor"
VENDOR_BLOCK=""
if ! [ -h "$(readlink /dev/block/mapper/vendor${CSLOT})" ] && [ -b "$(readlink /dev/block/mapper/vendor${CSLOT})" ]; then
    my_print "- Vendor расположен в super"
    VENDOR_BLOCK="$(readlink /dev/block/mapper/vendor${CSLOT})"
    my_print "- dm блок vendor: $(basename $VENDOR_BLOCK)"
fi
if [[ -z "$VENDOR_BLOCK" ]] ; then
    my_print "- Vendor расположен в отдельном блоке"
    VENDOR_BLOCK=$(find_block_neo -b "vendor${CSLOT}")
    my_print "- Блок vendor: $(basename $VENDOR_BLOCK)"
fi
# word13="Не удалось обноружить Vendor раздел"
[[ -z "${VENDOR_BLOCK}" ]] && abort_neo -e 25.1 -m "Vendor не найден" 

if ! $SYS_STATUS ; then
    my_print "- Размонтирования vendor"
    umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
    umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
    umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
fi 

name_vendor_block="vendor${CSLOT}"
full_path_to_vendor_folder=$TMPN/mapper/$name_vendor_block

$TOOLS/toybox mkdir -pv $full_path_to_vendor_folder
my_print "- Монтирование vendor в временную папку"
if ! mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO ; then
    mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO
fi
if ! mountpoint -q $full_path_to_vendor_folder ; then
    if $SYS_STATUS ; then
        if $install_after_ota ; then 
            exit 112
        else
            full_path_to_vendor_folder=/vendor
        fi
    else
        abort_neo -e 25.2 -m "Не получилось смонтировать vendor $name_vendor_block" 
    fi
fi

