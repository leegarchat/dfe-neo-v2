




export ALRADY_DISABLE=false
export FLASH_IN_SUPER=false
export FLASH_IN_AUTO=false
export FLASH_IN_BOOT=true


echo 12 &>$LOGNEO
DETECT_NEO_IN_BOOT=false
DETECT_NEO_IN_SUPER=false
DETECT_NEO_IN_VENDOR_BOOT=false
DFE_NEO_DETECT_IN_FSTAB=false
echo 16 &>$LOGNEO
if $(find_block_neo -c -b vendor_boot${RCSUFFIX}) ; then
    my_print "- Поиск neo_inject в vendor_boot${RCSUFFIX}"
    if cat $(find_block_neo -b vendor_boot${RCSUFFIX}) | grep mount | grep /etc/init/hw/ &>$LOGNEO ; then
        DETECT_NEO_IN_VENDOR_BOOT=true
    fi
fi
echo 178 &>$LOGNEO
if $(find_block_neo -c -b boot${RCSUFFIX}) ; then
    my_print "- Поиск neo_inject в boot${RCSUFFIX}"
    if cat $(find_block_neo -b boot${RCSUFFIX}) | grep mount | grep /etc/init/hw/ &>$LOGNEO ; then
        DETECT_NEO_IN_BOOT=true
    fi
fi
echo 181 &>$LOGNEO
my_print "- Поиск neo_inject в super"
if $TOOLS/lptools_new --slot $CSLOTSLOT --suffix $CSUFFIX --super $SUPER_BLOCK --get-info | grep "neo_inject" &>$LOGNEO ; then
    DETECT_NEO_IN_SUPER=true
fi
NEO_ALREADY_INSTALL=false
for boot in vendor_boot$CSUFFIX boot$CSUFFIX ; do
    block_boot=$(find_block_neo -b "$boot")
    path_check_boot="$TMPN/check_boot_neo/$boot"
    mkdir -pv $path_check_boot &>$LOGNEO
    cd "$path_check_boot"
    magiskboot unpack "$block_boot"
    if [[ -f "ramdisk.cpio" ]] ; then
        mkdir ramdisk_files
        cd ramdisk_files
        if ! magiskboot cpio ../ramdisk.cpio extract ; then
            magiskboot decompress ../ramdisk.cpio ../d.cpio
            rm -f ../ramdisk.cpio 
            mv ../d.cpio ../ramdisk.cpio
        fi
        for fstab in $(find ./ -name "fstab.*" ) ; do
            if grep -q "/venodr/etc/init/hw" "$fstab" || \
                    grep -q "/vendor/etc/init/hw" "$fstab" || \
                    grep -q "/system/etc/init/hw" ; then
                NEO_ALREADY_INSTALL=true
            fi
        done
    fi
    cd "$TMPN"
    rm -rf $path_check_boot
done