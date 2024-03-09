# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]

echo "- Определение PATH с новыми бинарниками" &>$NEOLOG && { # <--- обычный код
    binary_pull_busubox="mv cp dirname basename grep [ [[ sleep mountpoint sed echo mkdir ls ln readlink realpath cat awk wc"
    binary_pull_busubox+=""
    binary_pull_toybox="file"
    # Добавление из busybox
    for name_sub_bin in $binary_pull_busubox ; do
        ln -s "${TOOLS}/busybox" "${TOOLS}/${name_sub_bin}"
    done
    for name_sub_bin in $binary_pull_toybox ; do
        ln -s "${TOOLS}/toybox" "${TOOLS}/${name_sub_bin}"
    done
    # Добавление из toolbox
    ln -s "${TOOLS}/toolbox" "${TOOLS}/getprop"
    ln -s "${TOOLS}/toolbox" "${TOOLS}/setprop"
    ln -s "${TOOLS}/toolbox" "${TOOLS}/getevent"
    # Добавление из magisk
    ln -s "${TOOLS}/magisk" "${TOOLS}/resetprop"

    # Экспортирование PATH с новыми бинарниками!! mount использовать системный
    export "$TOOLS:$PATH"
}

my_print(){ # <--- Определение функции [Аругменты $1 "Вывод сообщения"]
    case $WHERE_INSTALLING in
        kernelsu|magiskapp)
            echo -e "$1"
        ;;
        recovery)
            local input_message_ui="$1"
            local IFS=$'\n'
            while read -r line_print; do
                echo -e "ui_print $line_print\nui_print" >>"/proc/self/fd/$ZIPARG2"
            done <<<"$input_message_ui"
        ;;
    esac
}; export -f my_print

abort_neo(){ # <--- Определение функции [ -e "код ошибки {1}|{1.1}"] [ -m "Сообщение ошибки"]
    message="" 
    error_message="" 
    exit_code=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -m)
            if [[ -n "$2" ]] ; then 
                message="$2"
                shift 2
            else 
                my_print "$word46"
                exit 1
            fi
            ;;
        -e)
            if [[ -n "$2" ]] ; then
                error_message="$2"
                shift 2
            else
                my_print "$word47"
                exit 1
            fi
            ;;
        *)
            my_print "$word48 $1"
            exit 1
            ;;
        esac
    done
    if [[ -n "$message" ]] ; then
        my_print " "
        my_print " "
        my_print "- $message"
    fi

    num="$error_message"
    rounded_num=$(echo "$num" | awk '{printf "%.0f\n", $1}')
    if ((rounded_num < 0)); then
        error_code=0
    elif ((rounded_num > 255)); then
        error_code=255
    else
        error_code=$rounded_num
    fi

    if [[ -n "$error_message" ]] ; then
        if [ -n "$word42" ] ; then 
            my_print "  !!!$word42: $error_message!!!"
        else 
            my_print "  !!!Exiting with error: $error_message!!!"
        fi
        
        my_print " "
        my_print " "
        if [[ -f /tmp/recovery.log ]] ; then
            echo -e "\n\n\n\n\n\n\n\nRECOVERYLOGTHIS:\n\n"
            cat /tmp/recovery.log &>$LOGNEO
        fi
        exit "$error_code"
    fi
}; export -f abort_neo

check_it(){ # <--- Определение функции [Аругментов нет]
    WHAT_CHECK="$1"
    NEED_ARGS="$2"
    if [[ "$(grep "$WHAT_CHECK=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]] ; then
        if grep -w "${WHAT_CHECK}=$NEED_ARGS" "$CONFIG_NEO" | grep -v "#" &>$LOGNEO ; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}; export -f check_it

get_current_suffix(){ # <--- Определение функции [--current] [--uncurrent] задает CURRENT_SUFFIX|UNCURRENT_SUFFIX|CURRENT_SLOT|UNCURRENT_SLOT|OUT_MESSAGE_SUFFIX
    export CURRENT_SUFFIX=""
    export UNCURRENT_SUFFIX=""
    export CURRENT_SLOT="0"
    export UNCURRENT_SLOT="1"
    export OUT_MESSAGE_SUFFIX="A-ONLY"
    case "$1" in
        --current) ; A_CASE="_a" ; B_CASE="_b" ;;
        --uncurrent) ; A_CASE="_b" ; B_CASE="_a" ;;
    esac
    CSUFFIX_tmp=$(getprop ro.boot.slot_suffix)
    if [[ -z "$CSUFFIX_tmp" ]]; then
        CSUFFIX_tmp=$(grep_cmdline androidboot.slot_suffix)
        if [[ -z "$CSUFFIX_tmp" ]]; then
            CSUFFIX_tmp=$(grep_cmdline androidboot.slot)
        fi
    fi
    if [[ -n "$CSUFFIX_tmp" ]] ; then
        echo "$get_current_suffix"
    fi
    case "$CSUFFIX_tmp" in
        "$A_CASE") ; CURRENT_SUFFIX="_a" ; UNCURRENT_SUFFIX="_b" ; CURRENT_SLOT=0 ; UNCURRENT_SLOT=1 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
        "$B_CASE") ; CURRENT_SUFFIX="_b" ;  UNCURRENT_SUFFIX="_b" ; CURRENT_SLOT=1 ; UNCURRENT_SLOT=0 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
    esac

}; export -f get_current_suffix

find_block_neo(){ # <--- Определение функции -с проверка поиска блока вовзращет истину или лож, -b задает что искать 
    found_blocks=()
    block_names=()
    check_status_o=false
    while [ $# -gt 0 ]; do
        case "$1" in
            -c)
                check_status_o=true
                shift 1
            ;;
            -b)
                shift 1
                if [[ $# -gt 0 && ${1:0:1} != "-" ]]; then
                    while [[ $# -gt 0 && ${1:0:1} != "-" ]]; do
                        block_names+=("$1")
                        shift 1
                    done
                fi
            ;;
            *)
                echo "Unknown parameter: $1" &>$LOGNEO
                exit 1
            ;;
        esac
    done

    for block in "${block_names[@]}"; do
        # my_print "- Searching for block $block"
        if [ -h /dev/block/by-name/$block ]; then
            if ! [ -h "$(readlink /dev/block/by-name/$block)" ] && [ -b "$(readlink /dev/block/by-name/$block)" ]; then
                found_blocks+="$(readlink /dev/block/by-name/$block) "
            fi
            elif [ -b /dev/block/mapper/$block ]; then
            if ! [ -h "$(readlink /dev/block/mapper/$block)" ] && [ -b "$(readlink /dev/block/mapper/$block)" ]; then
                found_blocks+="$(readlink /dev/block/mapper/$block) "
            fi
            elif [ -h /dev/block/bootdevice/by-name/$block ]; then
            if ! [ -h "$(readlink /dev/block/bootdevice/by-name/$block)" ] && [ -b "$(readlink /dev/block/bootdevice/by-name/$block)" ]; then
                found_blocks+="$(readlink /dev/block/bootdevice/by-name/$block) "
            fi
        fi
    done
    if [[ -z "$found_blocks" ]] ; then
        return 1
    else
        if $check_status_o ; then
            return 0
        else
            echo "${found_blocks}"
        fi
    fi
}; export -f find_block_neo

volume_selector(){ # <--- Определение функции  [Аругменты $1 - Выбор (+)] [Аругменты $2 - Выбор (-)]
    my_print "    $1 [Громкость вверх (+)]"
    my_print "    $2 [Громкость вниз (-)]"
    while true; do
        volume_selector_count=0
        while true; do
            timeout 0.5 getevent -lqc 1 2>&1 >$volume_selector_events_file &
            sleep 0.1
            volume_selector_count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $1 [Громкость вверх (+)]"
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $2  [Громкость вниз (-)]"
                return 1
            fi
            [ $volume_selector_count -gt 100 ] && break
        done
        if $volume_selector_error; then
            rm -rf $volume_selector_events_file
            abort_neo -e 2.1 -m "Нажатие не распознано"
        else
            volume_selector_error=true
        fi
    done
}; export -f volume_selector

unmap_all_partitions(){ # <--- Определение функции [Аругментов нет]
    for partitions in /dev/block/mapper/* ; do
        if [[ -h "$partitions" ]] && [[ -b "$(readlink -f "$partitions")" ]] ; then 
            partitions_name="$(basename "$partitions")"
            umount -fl "$partitions" &>$LOGNEO && umount -fl "$partitions" &>$LOGNEO && umount -fl "$partitions" &>$LOGNEO && umount -fl "$partitions" &>$LOGNEO
            if [[ -n "$CURRENT_SUFFIX" ]] ; then
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --suffix "$CURRENT_SUFFIX" --unmap "$partitions_name" &>$NEOLO
                lptools_new --super "$SUPER_BLOCK" --slot "$UNCURRENT_SLOT" --suffix "$UNCURRENT_SUFFIX" --unmap "$partitions_name" &>$NEOLO
            else
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --unmap "$partitions_name" &>$NEOLO
            fi
        fi
    done
}; export -f unmap_all_partitions

update_partitions(){ # <--- Определение функции [Аругментов нет]

    my_print "- Обновление разделов"
    unmap_all_partitions

    good_slot_suffix=""
    if [[ -n "$CURRENT_SUFFIX" ]] ; then
        for check_suffix in _a _b ; do
            for check_slot in 0 1 ; do
                system_check_state=false
                vendor_check_state=false
                for partitions in vendor system ; do
                    continue_fail=false
                    if lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --map "system$check_suffix" &>$NEOLOG ; then
                        mkdir -pv "$TMPN/check_partitions/system$check_suffix" &>$NEOLO
                        if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                            if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                                if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                                    continue_fail=true
                                fi
                            fi
                        fi
                        if ! $continue_fail && mountpoint "$TMPN/check_partitions/system$check_suffix" &>$LOGNEO ; then export ${partitions}_check_state=true ; fi
                        umount -fl "$TMPN/check_partitions/system$check_suffix" &>$NEOLOG
                        lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --unmap "system$check_suffix" &>$NEOLOG
                        rm -rf "$TMPN/check_partitions/system$check_suffix"
                    fi
                done
                if $system_check_state && $vendor_check_state ; then
                    good_slot_suffix+="${check_suffix}${check_slot}"
                fi
            done
        done 
        case "$good_slot_suffix" in
            "_a0_b1"|"_a0") 
                FINAL_ACTIVE_SLOT=0
                FINAL_ACTIVE_SUFFIX=_a
            ;;
            "_b0_b1"|"_b1") 
                FINAL_ACTIVE_SLOT=1
                FINAL_ACTIVE_SUFFIX=_b
            ;;
            "_a0_b1")
                if grep -q "source_slot: A" /tmp/recovery.log && grep -q "target_slot: B" /tmp/recovery.log ; then
                    FINAL_ACTIVE_SLOT=1
                    FINAL_ACTIVE_SUFFIX=_b
                elif grep -q "target_slot: B" /tmp/recovery.log && grep -q "source_slot: A" /tmp/recovery.log ; then
                    FINAL_ACTIVE_SLOT=0
                    FINAL_ACTIVE_SUFFIX=_a
                else
                    FINAL_ACTIVE_SLOT=$CURRENT_SLOT
                    FINAL_ACTIVE_SUFFIX=$CURRENT_SUFFIX
                fi
            ;;
            *)
                my_print " !!!!!!!!! " 
                if ! $force_start ; then 
                    my_print "- Скрипт не смог определить загрузочный слот. Выберите загрузочный слот самостоятельно"
                    if volume_selector "Выбрать слот _a" "Выбрать слот _b" ; then 
                        FINAL_ACTIVE_SLOT=0
                        FINAL_ACTIVE_SUFFIX=_a
                    else
                        FINAL_ACTIVE_SLOT=1
                        FINAL_ACTIVE_SUFFIX=_b
                    fi
                else 
                    abort_neo -e 119.1 -m "Скрипт не смог определить загрузочный слот. В режиме force_start=true установка не доступтна"
                fi
            ;;
        esac
        unmap_all_partitions

        for partition in $(lptools_new --super $SUPER_BLOCK --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | awk '{print $1}') ; do
            partition_name=${partition/"NamePartInGroup->"/}
            if lptools_new --super "$SUPER_BLOCK" --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --map $partition_name &>$NEOLOG ; then
                my_print "- Разметка раздела: $partition_name"
                sleep 0.5
            else 
                my_print "- Не удалось разметить: $partition_name"
            fi
        done

        if ! [[ "$CURRENT_SUFFIX" == "$FINAL_ACTIVE_SUFFIX" ]] ; then
            magisk resetprop ro.boot.slot_suffix $FINAL_ACTIVE_SUFFIX
            if grep androidboot.slot_suffix /proc/bootconfig ; then
                edit_text="$(cat /proc/bootconfig | sed 's/androidboot.slot_suffix = "'$CURRENT_SUFFIX'"/androidboot.slot_suffix = "'$FINAL_ACTIVE_SUFFIX'"/')"
                echo -e "$edit_text" > $TMPN/bootconfig_new 
                mount $TMPN/bootconfig_new /proc/bootconfig &>$LOGNEO
            fi
            if grep "androidboot.slot_suffix=$CURRENT_SUFFIX" /proc/cmdline || grep "androidboot.slot=$CURRENT_SUFFIX" /proc/cmdline ; then
                edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot_suffix='$CURRENT_SUFFIX'/androidboot.slot_suffix='$FINAL_ACTIVE_SUFFIX'/' | sed 's/androidboot.slot='$CURRENT_SUFFIX'/androidboot.slot='$FINAL_ACTIVE_SUFFIX'/')"
                echo -e "$edit_text" > $TMPN/cmdline_new 
                mount $TMPN/cmdline_new /proc/cmdline &>$LOGNEO
            fi
            if $BOOTCTL_STATE ; then
                bootctl set-active-boot-slot $FINAL_ACTIVE_SLOT
            fi
        fi
    else
        unmap_all_partitions
        for partition in $(lptools_new --super $SUPER_BLOCK --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | awk '{print $1}') ; do
            partition_name=${partition/"NamePartInGroup->"/}
            if lptools_new --super "$SUPER_BLOCK" --map $partition_name &>$NEOLOG ; then
                my_print "- Разметка раздела: $partition_name"
                sleep 0.5
            else 
                my_print "- Не удалось разметить: $partition_name"
            fi
        done
    fi
    get_current_suffix --current



}; export -f update_partitions

find_super_partition(){ # <--- Определение функции [Аругментов нет]
    for blocksuper in /dev/block/by-name/* /dev/block/bootdevice/by-name/* /dev/block/bootdevice/* /dev/block/* ; do
        if lptools_new --super $blocksuper --get-info &>/dev/null; then
            echo "$blocksuper"
            break
        fi    
    done 
}; export -f find_super_partition

select_argumetns_for_install(){ # <--- Определение функции [Аругментов нет]
    if [[ $hide_not_encrypted == "ask" ]] ; then
        my_print " "
        my_print "- Установить патч, который скроет отсутствие шифрования?"
        my_print "- **Будет работать только если установлен Magisk или KSU или Selinux в режиме Permissive"
        my_print "    Да 'установить' - Громкость вверх (+)" -s
        my_print "    Нет 'не устанавливать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'установить' - Громкость вверх (+)"
            hide_not_encrypted=true
        else
            my_print "**> Нет 'не устанавливать' - Громкость вниз (-)"
            hide_not_encrypted=false
        fi
    fi
    if [[ $safety_net_fix == "ask" ]] ; then
        my_print " "
        my_print "- Установить встроенный safety net fix?"
        my_print "- **Будет работать только если установлен Magisk или KSU или Selinux в режиме Permissive"
        my_print "    Да 'установить' - Громкость вверх (+)" -s
        my_print "    Нет 'не устанавливать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'установить' - Громкость вверх (+)"
            safety_net_fix=true
        else
            my_print "**> Нет 'не устанавливать' - Громкость вниз (-)"
            safety_net_fix=false
        fi
    fi
    if $SYS_STATUS ; then
        wipe_data=false
    else
        if [[ $wipe_data == "ask" ]] ; then
            my_print " "
            my_print "- Сделать wipe data? удалит все данные прошивки, внутренняя память не будет тронута"
            my_print "    Да 'удалить' - Громкость вверх (+)" -s
            my_print "    Нет 'не трогать!' - Громкость вниз (-)" -s
            if volume_selector ; then
                my_print "**> Да 'удалить' - Громкость вверх (+)"
                wipe_data=true
            else
                my_print "**> Нет 'не трогать!' - Громкость вниз (-)"
                wipe_data=false
            fi
        fi
    fi
    if [[ $remove_pin == "ask" ]] ; then
        my_print " "
        my_print "- Удалить данные экрана блокировки?"
        my_print "    Да 'удалить' - Громкость вверх (+)" -s
        my_print "    Нет 'не трогать!' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'удалить' - Громкость вверх (+)"
            remove_pin=true
        else
            my_print "**> Нет 'не трогать!' - Громкость вниз (-)"
            remove_pin=false
        fi
    fi
    if [[ $modify_early_mount == "ask" ]] ; then
        my_print " "
        my_print "- Подключать измененный fstab во время раннего монтирования разделов?"
        my_print "- ** Нужно в основном если вы использовали дополнительные ключи dfe_paterns для системных разделов или использовали ключ -v для удаления оверлеев"
        my_print "    Да 'Подключить' - Громкость вверх (+)" -s
        my_print "    Нет 'Нет нужды' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'Подключить' - Громкость вверх (+)"
            modify_early_mount=true
        else
            my_print "**> Нет 'Нет нужды' - Громкость вниз (-)"
            modify_early_mount=false
        fi
    fi
    if [[ $disable_verity_and_verification == "ask" ]] ; then
        my_print " "
        my_print "- Удалить проверку целостности системы?"
        my_print "- ** Эта опция патчит vbmeta и system_vbmeta тем самым отключает проверку целостности системы, включите эту опцию если получили bootloop или если знаете зачем она нужна, в ином случае просто не трогайте"
        my_print "    Да 'отключить' - Громкость вверх (+)" -s
        my_print "    Нет 'не трогать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'отключить' - Громкость вверх (+)"
            disable_verity_and_verification=true
        else
            my_print "**> Нет 'не трогать' - Громкость вниз (-)"
            disable_verity_and_verification=false
        fi
    fi

    if [[ $zygisk_turn_on == "ask" ]] ; then
        my_print " "
        my_print "- Принудительно включить zygisk во время включения?"
        my_print "- ** Опция будет работать только если включен maghisk"
        my_print "    Да 'включить' - Громкость вверх (+)" -s
        my_print "    Нет 'не надо' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'включить' - Громкость вверх (+)"
            zygisk_turn_on=true
            my_print " "
            my_print "- Какой режим принудительного запуска использовать?"
            my_print "- ** Постоянный, это значит что будет включаться каждый раз при запуске системы"
            my_print "- ** Одноразовый, это значит что запуститься будет включен только при первом запуске системы, в дальнейшом будет игнорироваться принудительный запуск"
            my_print "    'Постоянно' - Громкость вверх (+)" -s
            my_print "    'Одноразово' - Громкость вниз (-)" -s
            if volume_selector ; then
                my_print "**> 'Постоянно' - Громкость вверх (+)"
                zygisk_turn_on_parm=always_on_boot
            else    
                my_print "**> 'Одноразово' - Громкость вниз (-)"
                zygisk_turn_on_parm=first_time_boot
            fi
        else
            my_print "**> Нет 'не надо' - Громкость вниз (-)"
            zygisk_turn_on=false
        fi
    elif [[ "$zygisk_turn_on" == "first_time_boot" ]] || [[ "$zygisk_turn_on" == "always_on_boot" ]] ; then
        zygisk_turn_on_parm=$zygisk_turn_on
        zygisk_turn_on=true
    fi
    if [[ $add_custom_deny_list == "ask" ]] ; then
        my_print " "
        my_print "- Принудительно делать запись в denylist во время включения?"
        my_print "- ** Опция будет работать только если включен zygisk"
        my_print "    Да 'включить' - Громкость вверх (+)" -s
        my_print "    Нет 'не надо' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'включить' - Громкость вверх (+)"
            add_custom_deny_list=true
            my_print " "
            my_print "- Какой режим принудительного запуска использовать?"
            my_print "- ** Постоянный, это значит что будет включаться каждый раз при запуске системы"
            my_print "- ** Одноразовый, это значит что запуститься будет включен только при первом запуске системы, в дальнейшом будет игнорироваться принудительный запуск"
            my_print "    'Постоянно' - Громкость вверх (+)" -s
            my_print "    'Одноразово' - Громкость вниз (-)" -s
            if volume_selector ; then
                my_print "**> 'Постоянно' - Громкость вверх (+)"
                add_custom_deny_list_parm=first_time_boot
            else
                my_print "**> 'Одноразово' - Громкость вниз (-)"
                add_custom_deny_list_parm=always_on_boot
            fi
        else
            my_print "**> Нет 'не надо' - Громкость вниз (-)"
            add_custom_deny_list=false
        fi
    elif [[ "$add_custom_deny_list" == "first_time_boot" ]] || [[ "$add_custom_deny_list" == "always_on_boot" ]] ; then
        add_custom_deny_list_parm=$add_custom_deny_list
        add_custom_deny_list=true
    fi
}; export -f select_argumetns_for_install

mount_vendor(){ # <--- Определение функции [Аругментов нет]

    my_print "- Монтирования vendor"
    VENDOR_BLOCK=""
    if [[ "$SNAPSHOT_STATUS" == "unverified" ]] && $SUPER_DEVICE ; then
        if snapshotctl map &>$NEOLOG ; then
            if [[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]] ; then
                VENDOR_BLOCK="/dev/block/mapper/vendor$CURRENT_SUFFIX"
                my_print "- dm блок vendor: $(basename $(readlink $VENDOR_BLOCK))"
            else
                abort_neo -e 124.2 -m "С разметкой что то пошло не так, vendor$CURRENT_SUFFIX не найден"
            fi
        else
            abort_neo -e 124.1 -m "Не удалось разметить разделы после OTA"
        fi
    elif ! $SUPER_DEVICE; then
        VENDOR_BLOCK="$(find_block_neo -b "vendor$CURRENT_SUFFIX")"
        my_print "- Vendor расположен в отдельном блоке "
        my_print "- Блок vendor: $(basename $(readlink $VENDOR_BLOCK))"
    elif $SUPER_DEVICE ; then
        if [[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]] ; then
            VENDOR_BLOCK="/dev/block/mapper/vendor$CURRENT_SUFFIX"
            my_print "- dm блок vendor: $(basename $(readlink $VENDOR_BLOCK))"
        else
            abort_neo -e 124.5 -m "С разметкой что то пошло не так, vendor$CURRENT_SUFFIX не найден"
        fi
    fi
    
    [[ -z "${VENDOR_BLOCK}" ]] && abort_neo -e 25.1 -m "Vendor не найден" 

    if ! $SYS_STATUS ; then
        my_print "- Размонтирования vendor"
        umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
        umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
        umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>$LOGNEO
    fi 

    name_vendor_block="vendor${CSLOT}"
    full_path_to_vendor_folder=$TMPN/mapper/$name_vendor_block

    mkdir -pv $full_path_to_vendor_folder
    my_print "- Монтирование vendor в временную папку"
    if ! mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO ; then
        mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO
    fi
    if ! mountpoint -q $full_path_to_vendor_folder ; then
        if $SYS_STATUS ; then
            if [[ "$SNAPSHOT_STATUS" == "unverified" ]]; then 
                abort_neo -e 25.4 -m "Не получилось смонтировать vendor, вариантов установки после ота больше нет" 
            else
                full_path_to_vendor_folder=/vendor
            fi
        else
            abort_neo -e 25.2 -m "Не получилось смонтировать vendor $name_vendor_block" 
        fi
    fi


}; export -f mount_vendor

remove_dfe_neo(){
    
    if $DETECT_NEO_IN_BOOT ; then
        cat $(find_block_neo -b boot$CSUFFIX) > $(find_block_neo -b boot$RCSUFFIX)
    fi
    if $DETECT_NEO_IN_VENDOR_BOOT ; then
        cat $(find_block_neo -b vendor_boot$CSUFFIX) > $(find_block_neo -b vendor_boot$RCSUFFIX)
    fi
    if $DETECT_NEO_IN_SUPER && $A_ONLY_DEVICE ; then
        lptools_new --slot $CSLOTSLOT --super $SUPER_BLOCK --remove "neo_inject$CSUFFIX"
    elif $DETECT_NEO_IN_SUPER && ! $A_ONLY_DEVICE ; then
        lptools_new --slot $CSLOTSLOT --suffix $CSUFFIX --super $SUPER_BLOCK --remove "neo_inject$CSUFFIX"
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


}; export -f remove_dfe_neo

check_dfe_neo_installing(){
    if ! $force_start; then
        export DETECT_NEO_IN_BOOT=false
        export DETECT_NEO_IN_SUPER=false
        export DETECT_NEO_IN_VENDOR_BOOT=false
        export NEO_ALREADY_INSTALL=false
        export WHERE_NEO_ALREADY_INSTALL=""
        echo "- Поиск neo_inject в boot/vendor_boot только для a/b устройств" &>$NEOLOG {
            if ! $A_ONLY_DEVICE ; then
                for boot_partition in "vendor_boot${RCSUFFIX}" "boot${RCSUFFIX}" ; do
                    echo "- Поиск neo_inject в ${boot_partition}${RCSUFFIX}" &>$NEOLOG {
                        if $(find_block_neo -c -b ${boot_partition}${RCSUFFIX}) ; then
                            my_print "- Поиск neo_inject в ${boot_partition}${RCSUFFIX}"
                            if cat $(find_block_neo -b ${boot_partition}${RCSUFFIX}) | grep mount | grep /etc/init/hw/ &>$LOGNEO ; then
                                case "$boot_partition" in 
                                    vendor_boot*) ; export DETECT_NEO_IN_VENDOR_BOOT=true ;;
                                    boot*) ; DETECT_NEO_IN_BOOT=true ;;
                                esac
                                
                            fi
                        fi
                    }
                done
            fi
        }
        echo "- Поиск neo_inject в super если устройство имеет super" &>$NEOLOG {
            if "$SUPER_DEVICE" ; then
                my_print "- Поиск neo_inject в super"
                if $A_ONLY_DEVICE ; then
                    if $TOOLS/lptools_new --slot $CSLOTSLOT --super $SUPER_BLOCK --get-info | grep "neo_inject" &>$LOGNEO ; then
                        DETECT_NEO_IN_SUPER=true
                    fi
                elif ! $A_ONLY_DEVICE ; then
                    if $TOOLS/lptools_new --slot $CSLOTSLOT --suffix $CSUFFIX --super $SUPER_BLOCK --get-info | grep "neo_inject" &>$LOGNEO ; then
                        DETECT_NEO_IN_SUPER=true
                    fi
                fi
                
            fi
        }
        

        for boot in vendor_boot$CSUFFIX boot$CSUFFIX ; do
            block_boot=$(find_block_neo -b "$boot")
            path_check_boot="$TMPN/check_boot_neo/$boot"
            mkdir -pv $path_check_boot &>$LOGNEO
            cd "$path_check_boot"
            magiskboot unpack "$block_boot" &>$LOGNEO
            if [[ -f "ramdisk.cpio" ]] ; then
                mkdir ramdisk_files
                cd ramdisk_files
                if ! magiskboot cpio ../ramdisk.cpio extract &>$LOGNEO ; then
                    if magiskboot decompress ../ramdisk.cpio ../d.cpio &>$LOGNEO ; then
                        rm -f ../ramdisk.cpio &>$LOGNEO
                        mv ../d.cpio ../ramdisk.cpio
                    else
                        continue
                        cd "$TMPN"
                        rm -rf $path_check_boot
                    fi
                fi
                for fstab in $(find ./ -name "fstab.*" ) ; do
                    if grep -q "/venodr/etc/init/hw" "$fstab" || \
                            grep -q "/vendor/etc/init/hw" "$fstab" || \
                            grep -q "/system/etc/init/hw" ; then
                        NEO_ALREADY_INSTALL=true
                        WHERE_NEO_ALREADY_INSTALL+=" $boot"
                    fi
                done
            fi
            cd "$TMPN"
            rm -rf $path_check_boot
        done
        if $NEO_ALREADY_INSTALL ; then
            my_print "- Обнаружен установленный DFE-NEO, удалить или установить снова?"
            my_print "    Переустановить - громкость вверх (+)"
            my_print "    Удалить - громкость вверх (-)"
            if ! volume_selector ; then
                my_print "**> Переустановить - громкость вверх (+)"
            else
                my_print "**> Удалить - громкость вверх (-)"   
                first_remove_neo_recovery_super_a_b
                exit 0
            fi
        fi
    fi


}; export -f check_neo_installing


move_files_from_vendor_hw(){ # <--- Определение функции [Аругментов нет]

    # full_path_to_vendor_folder Путь к папке с вендором




}; export -f move_files_from_vendor_hw

echo "- Определение языка" &>$LOGNEO && { # <--- обычный код
    if echo "$(basename "$ZIPARG3")" | busybox grep -qi "extconfig"; then
        if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
                languages="$(grep "languages=" "$(dirname "$ZIPARG3")/NEO.config")"
                languages=${languages#*"="}
        else
            languages="$(grep "languages=" "$TMPN/unzip/NEO.config")"
            languages=${languages#*"="}
        fi
    else
        languages="$(grep "languages=" "$TMPN/unzip/NEO.config")"
        languages=${languages#*"="}
    fi
    if ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" ]] ; then
        my_print "- $languages.sh language file not found. English will be used"
        languages=en
        ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" ]] && {
            abort_neo -e "23.27" -m "English language file not found, WHAT THE FUCK????"
        }
    fi
    sed -i 's/\r$//' "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh"
    source "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" || abort_neo -e "23.31" -m "Failed to read language file"
}

echo "- Определние переменых для volume_selector" &>$LOGNEO && { # <--- обычный код
    export volume_selector_error=false
    export volume_selector_events_file=volume_selector_events
    if touch $volume_selector_events_file ; then
        for dir in /dev /tmp /data/local /data; do
            if touch $dir/volume_selector_events ; then
                volume_selector_events_file=$dir/volume_selector_events
                break
            fi
        done
    fi
    rm -rf $volume_selector_events_file
}

echo "- Определение стандартных переменных" &>$LOGNEO && { # <--- обычный код
    my_print "- Определение стандартных переменных"
    # NEO.config аргументы \/--------------------\/
    export languages=""
    export force_start=""
    export ro_hardware=""
    export disable_verity_and_verification=""
    export hide_not_encrypted=""
    export custom_reset_prop=""
    export add_custom_deny_list=""
    export zygisk_turn_on=""
    export safety_net_fix=""
    export remove_pin=""
    export wipe_data=""
    export modify_early_mount=""
    export dfe_paterns=""
    export where_to_inject=""
    export magisk=""
    # NEO.config аргументы /\--------------------/\
    # lng.sh аргументы    \/--------------------\/
    for number in {1..250} ; do 
        export word${number}=""
    done
    # lng.sh аргументы    /\--------------------/\
    # info аргументы      \/--------------------\/\
    export BOOT_PATCH="boot"
    export SUPER_THIS=""
    export SUPER_BLOCK=""
    export AONLY=""
    export bootctl_state=""
    export CSUFFIX=""
    export RCSUFFIX=""
    export ALRADY_DISABLE=false
    export install_after_ota=false
    export FLASH_IN_SUPER=false
    export FLASH_IN_AUTO=false
    export FLASH_IN_BOOT=true
    export snapshotctl_state=""
    export languages=""
    export NEO_VERSION="DFE NEO 2.5.x"
    export LOGNEO="$TMPN/outneo.log"
    export MAGISK_ZIP=""
    export where_to_inject_auto=""
    if [[ -n "$EXEMPLE_VERSION" ]] ; then
        NEO_VERSION="DFE-NEO $EXEMPLE_VERSION"
    fi
    # info аргументы      /\--------------------/\
}

echo "- Вывод базовой информации" &>$LOGNEO && { # <--- обычный код
    # Версия программы
    my_print "- $NEO_VERSION"
    my_print "- Скрипт запущен из $WHERE_INSTALLING"
    my_print "- Чтение конфигурации"
}

echo "- Чтение конфига и проверка его досутптности" &>$LOGNEO && { # <--- обычный код
    export CONFIG_FILE=""

    if echo "$(basename "$ZIPARG3")" | grep -qi "extconfig"; then
        my_print "- В название архива присутсвует extconfig. Будет попытка считать конфиг из той же папки где распаложен установочный архив"
        if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
            CONFIG_FILE="$(dirname "$ZIPARG3")/NEO.config"
        else 
            my_print "- Внешний конфиг не найден. Будет произведено чтение из встроенного"
        fi
    fi
    if [[ -z "$CONFIG_FILE" ]] && [[ -f "$TMPN/unzip/NEO.config" ]]
        CONFIG_FILE="$TMPN/unzip/NEO.config"
    else
        my_print "- Встроенный конфиг не обнаружен"
        my_print "- Выход..."
        abort_neo -e "8.0" -m "Не найден встроенный конфиг"
    fi
    my_print "- Конфиг обнаружен"
    my_print "- Проверка аргументов на соответсвие"

    source first_check_config "$CONFIG_FILE" || abort_neo -e "8.1" -m "Конфиг настроен не корреткно"
    PROBLEM_CONFIG=""
    true_false_ask="disable_verity_and_verification "
    true_false_ask+="hide_not_encrypted "
    true_false_ask+="add_custom_deny_list "
    true_false_ask+="zygisk_turn_on "
    true_false_ask+="safety_net_fix "
    true_false_ask+="remove_pin "
    true_false_ask+="wipe_data "
    true_false_ask+="modify_early_mount "

    for what in $true_false_ask ; do 
        if check_it "$true_false_ask" "ask" || check_it "$true_false_ask" "true" || check_it "$true_false_ask" "false" ; then
            echo "$true_false_ask fine" &> $LOGNEO
        else
            PROBLEM_CONFIG+="$(grep "${true_false_ask}=" "$CONFIG_FILE" | grep -v "#")"
        fi
    done
    if check_it "where_to_inject" "super" || check_it "where_to_inject" "vendor_boot" || check_it "where_to_inject" "boot" ; then
        echo "where_to_inject fine" &> $LOGNEO
    else
        PROBLEM_CONFIG+="$(grep "where_to_inject=" "$CONFIG_FILE" | grep -v "#")"
    fi

    if check_it "force_start" "true" || check_it "force_start" "false" ; then
        echo "force_start fine" &> $LOGNEO
    else
        PROBLEM_CONFIG+="$(grep "force_start=" "$CONFIG_FILE" | grep -v "#")"
    fi
    if [[ -n "$PROBLEM_CONFIG" ]] ; then
        my_print "- Обнаружены проблемы:"
        for text in "$PROBLEM_CONFIG" ; do 
            my_print "   $text"
        done
        abort_neo -e 2.8 -m "Проблема с конифгом"
    fi
    source "$CONFIG_FILE" || abort_neo -e "8.2" -m "Не удалось считать файл конфигурации"
    my_print "- Все впорядке!"  
}

echo "- Проверка доступтности bootctl & snapshotctl" &>$LOGNEO && { # <--- обычный код
    bootclt $>$LOGNEO
    if [[ "$?" == "64" ]] ; then
        BOOTCTL_STATE=true
    else
        BOOTCTL_STATE=false
    fi
    snapshotctl $>$LOGNEO
    if [[ "$?" == "64" ]] ; then
        SNAPSHOTCTL_STATE=true
    else
        SNAPSHOTCTL_STATE=false
    fi
}

echo "- Чтение пропов и определние слота" &>$LOGNEO && { # <--- обычный код
    my_print "- Чтение пропов и определние переменных"
    get_current_suffix --current

    

    if [[ -n "$CURRENT_SUFFIX" ]] ; then
        my_print " "
        my_print "- Устройства A/B"
        my_print "- Текущий слот: $OUT_MESSAGE_SUFFIX"
        export A_ONLY_DEVICE=false
    else
        my_print "- Устройство A-only"
        export A_ONLY_DEVICE=true
    fi
}

echo "- Поиск раздела super" &>$LOGNEO && { # <--- обычный код
    my_print "- Проверка на наличие super раздела"
    SUPER_BLOCK=$(find_super_partition)
    if [[ -z "$SUPER_BLOCK" ]] ; then
        my_print "- Раздел super не найден"
        SUPER_DEVICE=false
    else
        my_print "- Раздел super найден по пути:"
        my_print "   $SUPER_BLOCK"
        SUPER_DEVICE=true
    fi
}

echo "- Проверка устройства на поддердку если нет super и a_only устройство" &>$LOGNEO && { # <--- обычный код
    if ! $SUPER_DEVICE && $A_ONLY_DEVICE ; then
        abort_neo -e "9.1" -m "Текущая версия DFE-NEO не поддерживает A-only и устройства без super раздела одновременно"
    fi
}

echo "- Поиск базовых блоков recovery|boot|vendor_boot" &>$LOGNEO && { # <--- обычный код
    my_print "- Поиск recovery раздела"
    if find_block_neo -c -b "recovery" "recovery_a" "recovery_b" ; then
        my_print "- Recovery раздел найден. Будет легко"
        RECOVERY_DEVICE=true
    else
        my_print "- Recovery раздел не найден, будет сложнее"
        RECOVERY_DEVICE=false
    fi
    my_print "- Поиск vendor_boot раздела"
    if find_block_neo -c -b "vendor_boot" "vendor_boot_a" "vendor_boot_b" ; then
        my_print "- Vendor_boot раздел найден. Будет легко"
        BOOT_PATCH+=" vendor_boot"
        VENDOR_BOOT_DEVICE=true
    else
        if ! $RECOVERY_THIS ; then 
            my_print "- Vendor_boot раздел не найден, будет еще сложнее"
        else
            my_print "- Vendor_boot раздел не найден, будет сложнее"
        fi
        VENDOR_BOOT_DEVICE=false
    fi
}

echo "- Проверка запущенной системы и OTA статуса, переопределние слота на противоположный" &>$LOGNEO && { # <--- обычный код
    if $SYS_STATUS ; then
        if ! $SNAPSHOTCTL_STATE;
            if ! $force_start
                my_print "- !! Ошибка в определение статуса обновления системы, бинарник не может быть выполнен"
                my_print "- Требуется уточнение пользователя, установка в текущую прошивку?"
                if volume_selector "Текущая система" "Выход" ; then
                    echo "- продолжить установку" &>$NEOLOG
                    get_current_suffix --current
                else
                    exit 82
                fi
            else
                abort_neo -e "81.1" -m "Ошибка в проверке статуса обновления системы, с функцией force_start=true продолжить нельзя" 
            fi
        fi
        if $SNAPSHOTCTL_STATE ; then
            SNAPSHOT_STATUS=$($TOOLS/snapshotctl dump 2>/dev/null | grep '^Update state:' | awk '{print $3}')
            if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
                echo "- Установка в текущую прошивку, обновления системы не обнаружено" &>$NEOLOG
                get_current_suffix --current
            elif [[ "$SNAPSHOT_STATUS" == "initiated" ]] ; then
                abort_neo -e "83.1" -m "Прошивка в состояние обновления, дождитесь установки обновления!"
            elif [[ "$SNAPSHOT_STATUS" == "unverified" ]] ; then
                my_print "- Обнаружено завершение установки обновления, утсановка DFE-NEO будет произведена в новую прошивку"
                if ! $force_start ; then
                    my_print "- Но прежде чем начать мне нужно, что обновление установлено полностью, првоерить это я пока не могу"
                    if ! volume_selector "Установлена полностью" "Еще не установлена" ; then
                        abort_neo -e "83.2" -m "Дождитесь полной установки прошивки прежде чем запускать скрипт"
                    fi
                fi
                get_current_suffix --uncurrent
            else
                abort_neo -e "83.4" -m "Неизветсный статус обновления системы"
            fi
        fi
        my_print "- Установка в слот: $OUT_MESSAGE_SUFFIX"
    fi
}

if ! $SYS_STATUS && $A_ONLY_DEVICE && $SUPER_DEVICE ; then
    update_partitions
    select_argumetns_for_install
    mount_vendor
    move_files_from_vendor_hw

fi