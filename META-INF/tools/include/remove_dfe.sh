remove_dfe_neo(){
    boot_detect_truefalse=$1
    super_detect_truefalse=$2
    
    
    if $super_detect_truefalse ; then
        if [[ -n "$FINAL_ACTIVE_SLOT" ]] ; then 
            $TOOLS/lptools_new --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --super $super_block --remove "neo_inject$FINAL_ACTIVE_SUFFIX" &>$LOGNEO
        else
            $TOOLS/lptools_new --super $super_block --remove "neo_inject" &>$LOGNEO
        fi
        
    fi

    for boot_sda in vendor_boot boot; do
        if [[ "$boot_sda" == "boot" ]] && ! find_block_neo -c -b recovery${CSLOT} ; then
            continue
        else
            if [[ "$boot_sda" == "boot" ]] && ! find_block_neo -c -b recovery ; then
                continue
            else
                for block in $(find_block_neo -b ${boot_sda}${CSLOT}); do

                    basename_block="${boot_sda}${CSLOT}"
                    my_print "- $word50 ${boot_sda}${CSLOT}" && {
                        work_folder="$TMPN/${basename_block}_remove"
                        row_ramdisk=false

                        $TOOLS/toybox mkdir -pv $work_folder
                        cd "$work_folder"
                    }

                    # Распковка блока
                    # word26="Распаковка"
                    my_print "- $word26 $basename_block" && {
                        # word27="Не удалось распаковать"
                        $TOOLS/magiskboot unpack -h $block &>$work_folder/log.unpack.boot || {
                        if [[ -n "$CSLOT" ]] ; then
                            abort_neo -e "28.1" -m "$word27 boot($basename_block)" 
                        else
                            continue
                        fi
                        }    

                        if $TOOLS/toybox grep "RAMDISK_FMT" $work_folder/log.unpack.boot | $TOOLS/toybox grep "raw" &>$LOGNEO; then
                            # word28="Ramdisk сжат, декомпрессия..."
                            my_print "- $word28" && {
                                $TOOLS/magiskboot decompress $work_folder/ramdisk.cpio $work_folder/ramdisk.decompress.cpio &>$work_folder/log.decompress.ramdisk &&
                                    row_ramdisk=true ||
                                    abort_neo -e 28.2 -m "$word29" # word29="Не получилось декмопресировать ramdisk"
                                $TOOLS/toybox mv $work_folder/ramdisk.decompress.cpio $work_folder/ramdisk.cpio
                                ramdisk_compress_format=$($TOOLS/toybox grep "Detected format:" $work_folder/log.decompress.ramdisk | $TOOLS/toybox sed 's/.*\[\(.*\)\].*/\1/')
                            }

                        fi

                        if ! [[ -f "$work_folder/ramdisk.cpio" ]] && ! [[ -f "$work_folder/log.unpack.boot" ]]; then
                            # word30="Файл Ramdisk и файл журнала не найдены"
                            my_print "- $word30"
                            continue
                        fi
                    }
                    if [[ -f "$work_folder/ramdisk.cpio" ]]; then
                        # word31="Распаковка ramdsik.cpio"
                        my_print "- $word31" && {
                            mkdir $work_folder/ramdisk
                            cd $work_folder/ramdisk
                            "$TOOLS"/magiskboot cpio "$work_folder/ramdisk.cpio" extract &>$LOGNEO
                            cd $work_folder
                            for fstab in $(find "$work_folder/ramdisk/" -name "fstab.*"); do
                                if $TOOLS/toybox grep -w "/system" $fstab | $TOOLS/toybox grep -q "first_stage_mount"; then
                                    # word32="Патчинг fstab для first_stage"
                                    my_print "- $word51 $(basename "$fstab")" && {
                                        grep -q "/venodr/etc/init/hw" "$fstab" && {
                                            sed -i '/\/venodr\/etc\/init\/hw/d' "$fstab"
                                        }
                                        grep -q "/vendor/etc/init/hw" "$fstab" && {
                                            sed -i '/\/vendor\/etc\/init\/hw/d' "$fstab"
                                        }
                                        grep -q "/system/etc/init/hw" "$fstab" && {
                                            sed -i '/\/system\/etc\/init\/hw/d' "$fstab"
                                        }
                                        $TOOLS/magiskboot cpio "$work_folder/ramdisk.cpio" "add 777 ${fstab//$work_folder\/ramdisk\//} $fstab" &>$LOGNEO
                                    }

                                fi
                            done
                        }
                    else
                        # word33="Ramdisk.cpio файл не найден, пропуск..."
                        my_print "- $word33"
                        cd ../..
                        $TOOLS/toybox rm -rf $work_folder
                        continue
                    fi
                    if $row_ramdisk; then
                        # word34="Запаковка файлов ramdisk обратно в:"
                        my_print "- $word34 $ramdisk_compress_format"
                        "$TOOLS"/magiskboot compress="${ramdisk_compress_format}" "$work_folder/ramdisk.cpio" "$work_folder/ramdisk.compress.cpio" &>$LOGNEO || abort_neo -e 29.1 -m "$word41" # word41="Не удалось компресировать ramdisk"
                        rm -f "$work_folder/ramdisk.cpio"
                        mv "$work_folder/ramdisk.compress.cpio" "$work_folder/ramdisk.cpio"
                    fi
                    cd $work_folder
                    # word35="Ребилт и установка"
                    my_print "- $word35" && {
                        $TOOLS/magiskboot repack $block &>$LOGNEO
                        cat $work_folder/new-boot.img >$block
                    }
                done
            fi
        fi
    done 
}