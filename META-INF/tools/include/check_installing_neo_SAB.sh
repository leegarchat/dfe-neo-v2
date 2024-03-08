




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
if $TOOLS/lptools_new --slot $CSLOTSLOT --suffix $CSUFFIX --super $super_block --get-info | grep "neo_inject" &>$LOGNEO ; then
    DETECT_NEO_IN_SUPER=true
fi

if $VBOOT_THIS && 


for boot_sda in $BOOT_PATCH; do 
    if [[ "$boot_sda" == ]]
    unpack_boot $boot_sda

done
