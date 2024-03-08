

if $DETECT_NEO_IN_BOOT ; then
    cat $(find_block_neo -b boot$CSUFFIX) > $(find_block_neo -b boot$RCSUFFIX)
fi
if $DETECT_NEO_IN_VENDOR_BOOT ; then
    cat $(find_block_neo -b vendor_boot$CSUFFIX) > $(find_block_neo -b vendor_boot$RCSUFFIX)
fi
if $DETECT_NEO_IN_SUPER ; then
    $TOOLS/lptools_new --slot $CSLOTSLOT --suffix $CSUFFIX --super $SUPER_BLOCK --remove "neo_inject$CSUFFIX"
fi
ramdisk_compress_format=""
for boot in $WHERE_NEO_ALREADY_INSTALL; do
    block_boot=$(find_block_neo -b "$boot")
    path_check_boot="$TMPN/check_boot_neo/$boot"
    mkdir -pv $path_check_boot &>$LOGNEO
    cd "$path_check_boot"
    magiskboot unpack "$block_boot" &>$LOGNEO
    if [[ -f "ramdisk.cpio" ]] ; then
        mkdir ramdisk_files
        cd ramdisk_files
        if ! magiskboot cpio ../ramdisk.cpio extract &>$LOGNEO ; then
            magiskboot decompress ../ramdisk.cpio ../d.cpio &>$path_check_boot/log.decompress
            rm -f ../ramdisk.cpio 
            mv ../d.cpio ../ramdisk.cpio
            ramdisk_compress_format=$(grep "Detected format:" $work_folder/log.decompress.ramdisk | sed 's/.*\[\(.*\)\].*/\1/')
        fi
        need_repack=false
        for fstab in $(find $path_check_boot/ramdisk_files/ -name "fstab.*" ) ; do
            move_fstab=false
            grep -q "/venodr/etc/init/hw" "$fstab" && {
                sed -i '/\/venodr\/etc\/init\/hw/d' "$fstab"
                move_fstab=true
            }
            grep -q "/vendor/etc/init/hw" "$fstab" && {
                sed -i '/\/vendor\/etc\/init\/hw/d' "$fstab"
                move_fstab=true
            }
            grep -q "/system/etc/init/hw" "$fstab" && {
                sed -i '/\/system\/etc\/init\/hw/d' "$fstab"
                move_fstab=true
            }
            if $move_fstab ; then
                magiskboot cpio "$path_check_boot/ramdisk.cpio" "add 777 ${fstab//$path_check_boot\/ramdisk\//} $fstab" &>$LOGNEO
                need_repack=true
            fi
        done
        if $need_repack ; then
            cd $path_check_boot
            if [[ -n "$ramdisk_compress_format" ]] ; then
                magiskboot compress="${ramdisk_compress_format}" "$path_check_boot/ramdisk.cpio" "$path_check_boot/ramdisk.compress.cpio" &>$LOGNEO
                rm -f "$path_check_boot/ramdisk.cpio"
                mv "$path_check_boot/ramdisk.compress.cpio" "$path_check_boot/ramdisk.cpio"
            fi
            magiskboot repack $block_boot
            cat $path_check_boot/new-boot.img > $block_boot
        fi
    fi
    cd "$TMPN"
    rm -rf $path_check_boot
done

my_print "- Удаление завершено"