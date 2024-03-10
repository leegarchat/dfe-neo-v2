


    
# word14="Создание neo_inject.img раздела"
my_print "- $word14" && {
    if [[ -z "$ro_hardware" ]] ; then 
        hardware_boot=$(getprop ro.hardware)
    else
        hardware_boot="$ro_hardware"
    fi
    if [[ -z "$hardware_boot" ]]; then
        hardware_boot=$(getprop ro.boot.hardware)
    fi
    
    if [[ -z "$hardware_boot" ]]; then
        hardware_boot=$(getprop ro.boot.hardware.platform)
    fi
    VENDOR_FOLDER="$full_path_to_vendor_folder"
    mkdir $TMPN/neo_inject${CSLOT}
    mkdir "$TMPN/neo_inject${CSLOT}/lost+found"
    $TOOLS/busybox cp -afc ${VENDOR_FOLDER}/etc/init/hw/* $TMPN/neo_inject${CSLOT}/
    path_original_fstab=""
    basename_fstab=""
    for file_find in "$TMPN/neo_inject${CSLOT}"/*.rc ; do
        echo "Start while2 $path_original_fstab:$basename_fstab"  &>$LOGNEO
        if $TOOLS/toybox grep "mount_all" $file_find | $TOOLS/toybox grep "\-\-late" | $TOOLS/toybox grep -v "#" &>$LOGNEO; then
        echo "Start while $path_original_fstab:$basename_fstab"  &>$LOGNEO
            if $TOOLS/toybox grep "mount_all --late" $file_find | $TOOLS/toybox grep -v "#" &>$LOGNEO; then
                if [[ -z "$path_original_fstab" ]] && [[ -z "$basename_fstab" ]] ; then
                    path_original_fstab="/etc/fstab.$hardware_boot"
                    basename_fstab=$(basename "$path_original_fstab")
                fi
                sed -i '/^    mount_all.*--late$/s/.*/    mount_all \/vendor\/etc\/init\/hw\/fstab.'$hardware_boot' --late/g' $file_find
                if $modify_early_mount ; then
                    sed -i '/^    mount_all.*--early$/s/.*/    mount_all \/vendor\/etc\/init\/hw\/fstab.'$hardware_boot' --early/g' $file_find
                fi
                last_init_rc_file_for_write=$file_find
            else    
                fstab_find="$($TOOLS/toybox grep mount_all $file_find | $TOOLS/toybox grep "\-\-late" | $TOOLS/toybox grep -v "#" | sort -u)" 
                echo $fstab_find &>$LOGNEO
                new_path_fstab="$(echo "$fstab_find" | sed "s|[^ ]*fstab[^ ]*|/vendor/etc/init/hw/fstab.$hardware_boot|")"
                $TOOLS/toybox sed -i "s|$fstab_find|$new_path_fstab|g" "$file_find"
                if $modify_early_mount ; then
                    $TOOLS/toybox sed -i "s|${fstab_find//"--late"/"--early"}|${new_path_fstab//"--late"/"--early"}|g" "$file_find"
                fi
                if [[ -z "$path_original_fstab" ]] && [[ -z "$basename_fstab" ]] ; then
                    path_original_fstab="$(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p')"
                    if (echo "$path_original_fstab" | grep -q "\\$"); then
                        basename_fstab="$(basename $(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p' | sed 's/\(\$.*\)//')$hardware_boot)"
                    else 
                        basename_fstab="$(basename $(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p'))"
                    fi
                fi
                echo "$path_original_fstab:$basename_fstab" &>$LOGNEO
                last_init_rc_file_for_write=$file_find
            fi
        echo "End while $path_original_fstab:$basename_fstab" &>$LOGNEO
        fi
        echo "End while2 $path_original_fstab:$basename_fstab" &>$LOGNEO
    done
    echo "$path_original_fstab:$basename_fstab" &>$LOGNEO
    if [[ -z "$path_original_fstab" ]] || [[ -z "$basename_fstab" ]]; then
        # word15="Устройство не поддерживается"

        abort_neo -e 36.2 -m "$word15: $path_original_fstab:$basename_fstab"
    fi

    if $safety_net_fix || $hide_not_encrypted || $add_custom_deny_list || $zygisk_turn_on || [[ -n $custom_reset_prop ]] ; then
        if $add_custom_deny_list || $zygisk_turn_on ; then
            cp $TMPN/unzip/META-INF/tools/magisk.db "$TMPN/neo_inject${CSLOT}/"
            cp $TMPN/unzip/META-INF/tools/denylist.txt "$TMPN/neo_inject${CSLOT}/"
            cp $TOOLS/sqlite3 "$TMPN/neo_inject${CSLOT}/"
            chmod 777 "$TMPN/neo_inject${CSLOT}/sqlite3"
            chmod 777 "$TMPN/neo_inject${CSLOT}/magisk.db"
            chmod 777 "$TMPN/neo_inject${CSLOT}/denylist.txt"
        fi
        cp $TOOLS/magisk "$TMPN/neo_inject${CSLOT}/"
        cp $TMPN/unzip/META-INF/tools/init.sh "$TMPN/neo_inject${CSLOT}/"
        chmod 777 "$TMPN/neo_inject${CSLOT}/init.sh"
        echo " " >> "$last_init_rc_file_for_write"
        echo -e "${add_init_target_rc_line_init}\n" >> "$last_init_rc_file_for_write"
        echo -e "${add_init_target_rc_line_early_fs}\n" >> "$last_init_rc_file_for_write"
        echo -e "${add_init_target_rc_line_postfs}\n" >> "$last_init_rc_file_for_write"
        echo -e "${add_init_target_rc_line_boot_complite}\n" >> "$last_init_rc_file_for_write"
    fi

    

    if [[ -f "${$full_path_to_vendor_folder}$(dirname ${path_original_fstab})/$basename_fstab" ]]; then
        $TOOLS/busybox cp -afc "${$full_path_to_vendor_folder}$(dirname ${path_original_fstab})/$basename_fstab" "$TMPN/neo_inject${CSLOT}/$basename_fstab"
    else
        # word16="Не удалось определить расположение fstab:"
        abort_neo -e 36.1 -m "$word16 ${$full_path_to_vendor_folder}$(dirname ${path_original_fstab})/$basename_fstab" 
    fi
    if ($TOOLS/toybox grep -q "/userdata" "${$full_path_to_vendor_folder}$(dirname ${path_original_fstab})/$basename_fstab") ; then
            $TOOLS/toybox echo "" > "$TMPN/neo_inject${CSLOT}/$basename_fstab"
            patch_fstab_neo $dfe_paterns -f "${$full_path_to_vendor_folder}$(dirname ${path_original_fstab})/$basename_fstab" -o "$TMPN/neo_inject${CSLOT}/$basename_fstab"
    else
        # word17="Не найдено /userdata в fstab"
        abort_neo -e 36.4 -m "$word17"
    fi
    if ! [[ -f "$TMPN/neo_inject${CSLOT}/$basename_fstab" ]] ; then
        # word18="В процессе монтирования что то пошло не так"
        abort_neo -e 36.6 -m "$word18"
    fi
    # if ! ( cat $TMPN/neo_inject${CSLOT}/init.target.rc | grep -q "/vendor/etc/init/hw/fstab.$hardware_boot" ) ; then
    #     abort_neo -e 36.7 -m "$word18"
    # fi
    make_img "$TMPN/neo_inject${CSLOT}" "neo_inject" "${VENDOR_FOLDER}/etc/init/hw" "${VENDOR_FOLDER}/etc" || {
        # word19="Не удалось создать раздел neo_inject.img"
        abort_neo -e 36.8 -m "$word19"
    }
    NEO_IMG="$TMPN/${LABLE}.img"

}
if ! $SYS_STATUS ; then 
    umount -fl $full_path_to_vendor_folder &>$LOGNEO
fi


if $FLASH_IN_SUPER; then
    # word20="Запись neo_inject.img в super раздел"
    my_print "- $word20" && {
        SIZE_NEO_IMG=$($TOOLS/busybox stat -c%s $NEO_IMG)
        if [ -n "$CSLOTSLOT" ] ; then 
            $TOOLS/lptools_new --super $super_block --slot 0 --suffix _a --remove "neo_inject_a" &>$LOGNEO
            $TOOLS/lptools_new --super $super_block --slot 0 --suffix _b --remove "neo_inject_b" &>$LOGNEO
            $TOOLS/lptools_new --super $super_block --slot 1 --suffix _a --remove "neo_inject_a" &>$LOGNEO
            $TOOLS/lptools_new --super $super_block --slot 1 --suffix _b --remove "neo_inject_b" &>$LOGNEO
            parametrs_lptools_final="--slot $CSLOTSLOT --suffix $CSLOT"
        else
            $TOOLS/lptools_new --super $super_block --remove "neo_inject${CSLOT}" &>$LOGNEO
            parametrs_lptools_final=""
        fi
        
        if $TOOLS/lptools_new --super $super_block $parametrs_lptools_final --create "neo_inject${CSLOT}" "$SIZE_NEO_IMG" &>$LOGNEO; then
            # my_print "- Разметка neo_inject${CSLOT} с размером $(awk 'BEGIN{printf "%.1f\n", '$SIZE_NEO_IMG'/1024/1024}')MB"
            if find_block_neo -b "neo_inject${CSLOT}"; then
                cat "$NEO_IMG" >"/dev/block/mapper/neo_inject${CSLOT}"
                mkdir -pv /tmp/neo_inject_test_mount
                mount -o,ro /dev/block/mapper/neo_inject${CSLOT} /tmp/neo_inject_test_mount &>$LOGNEO ||
                    mount -o,ro /dev/block/mapper/neo_inject${CSLOT} /tmp/neo_inject_test_mount &>$LOGNEO
                if mountpoint -q /tmp/neo_inject_test_mount; then
                    umount -fl /tmp/neo_inject_test_mount &>$LOGNEO
                    # word21="Успех!"
                    my_print "- $word21"
                    if $FLASH_IN_AUTO ; then
                        FLASH_IN_BOOT=false
                    fi
                else
                    if $FLASH_IN_AUTO ; then
                        FLASH_IN_BOOT=true
                    else
                    # word22="Не удалось корректно записать"
                        abort_neo -e 27.1 -m "$word22 neo_inject${CSLOT}"
                    fi
                fi
            else  
                if $FLASH_IN_AUTO ; then
                    FLASH_IN_BOOT=true
                else
                # word23="Не удалось найти созданный раздел"
                    abort_neo -e 27.2 -m "$word23 neo_inject${CSLOT}"
                fi
            fi
        else
            if $FLASH_IN_AUTO ; then
                FLASH_IN_BOOT=true
            else
            # word24="Не удалось создать раздел"
                abort_neo -e 27.3 -m "$word24 neo_inject${CSLOT}"
            fi
        fi
    }
fi

if $FLASH_IN_BOOT; then
    # word37="Запусиь neo_inject.img в неактивный слот: "
    case $where_to_inject in
        super)
         my_print "- $word37 ${RCSLOT}"
        ;;
        vendor_boot|boot)
         my_print "- $word37 $where_to_inject${RCSLOT}"
        ;;
    esac 
   
    cat ${NEO_IMG} >$(find_block_neo -b "${where_to_inject}${RCSLOT}")
fi


for boot_sda in vendor_boot boot; do
    if [[ "$boot_sda" == "boot" ]] && ! find_block_neo -c -b recovery${CSLOT} recovery ; then
        continue
    else
        patch_first_stage=false
        for block in $(find_block_neo -b ${boot_sda}${CSLOT}); do

            basename_block="${boot_sda}${CSLOT}"
            # word25="Патчинг загрузочного раздела"
            my_print "- $word25 ${boot_sda}${CSLOT}" && {
                work_folder="$TMPN/$basename_block"
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
                            my_print "- $word32 $(basename "$fstab")" && {
                                grep -q "/venodr/etc/init/hw" "$fstab" && {
                                    sed -i '/\/venodr\/etc\/init\/hw/d' "$fstab"
                                }
                                grep -q "/vendor/etc/init/hw" "$fstab" && {
                                    sed -i '/\/vendor\/etc\/init\/hw/d' "$fstab"
                                }
                                grep -q "/system/etc/init/hw" "$fstab" && {
                                    sed -i '/\/system\/etc\/init\/hw/d' "$fstab"
                                }
                                [[ -n "$(tail -n 1 "$fstab")" ]] && echo "" >>"$fstab"
                                if $FLASH_IN_SUPER; then
                                    if $TOOLS/toybox grep -q "slotselect" $fstab; then
                                        echo "neo_inject    /vendor/etc/init/hw ext4    ro,discard  slotselect,logical,first_stage_mount" >>$fstab
                                        patch_first_stage=true
                                    else
                                        echo "neo_inject    /vendor/etc/init/hw ext4    ro,discard  logical,first_stage_mount" >>$fstab
                                        patch_first_stage=true
                                    fi
                                else
                                    echo "${path_to_inject}${where_to_inject}${RCSLOT}    /vendor/etc/init/hw ext4    ro  first_stage_mount" >>$fstab
                                    patch_first_stage=true
                                fi

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
            if $patch_first_stage ; then 
                my_print "- $word35" && {
                    $TOOLS/magiskboot repack $block &>$LOGNEO
                    cat $work_folder/new-boot.img >$block
                }
            fi
            if $disable_verity_and_verification ; then 
                if ! $ALRADY_DISABLE; then
                    # word36="Отключение проверки целостности системы"
                    my_print "- $word36" && {
                        ALRADY_DISABLE=true
                        $TOOLS/avbctl --force disable-verification
                        $TOOLS/avbctl --force disable-verity
                    }
                fi
            fi

        done
    fi
done

mountpoint -q /data || mount /data &>$LOGNEO
mountpoint -q /data && {
    if $remove_pin; then
        # word38="Удаление записи об наличии экрана блокировки"
        my_print "- $word38"
        rm -f /data/system/locksettings*
    fi
    if $wipe_data; then
        # word39="Очистка раздела /data, за исключением /data/media"
        my_print "- $word39"
        find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
    fi
}

if ! [[ "$magisk" == false ]]; then
    my_print " "
    my_print "- $word10"
    my_print " "
    my_print " "
    [[ -z "$MAGISK_ZIP" ]] && {
        if [[ -f "$TMPN/unzip/MAGISK/${magisk}.apk" ]]; then
            MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.apk"
        elif [[ -f "$TMPN/unzip/MAGISK/${magisk}.zip" ]]; then
            MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.zip"
        fi
    }

    [[ -n "$MAGISK_ZIP" ]] && {
        mkdir -pv $TMPN/$magisk
        cd $TMPN/$magisk
        $TOOLS/busybox unzip "$MAGISK_ZIP" &>$LOGNEO
        $TOOLS/bash $TMPN/$magisk/META-INF/com/google/android/update-binary "$ZIPARG1" "$ZIPARG2" "$MAGISK_ZIP"
    }
    my_print " "
    my_print " "
fi

my_print " "
if [[ -f /tmp/recovery.log ]] ; then
    echo -e "\n\n\n\n\n\n\n\nRECOVERYLOGTHIS:\n\n"
    cat /tmp/recovery.log &>$LOGNEO
fi
# word40="Установка завершена!"
my_print "- $word40"
my_print " "