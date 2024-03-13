
# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]

log(){
    if [[ "$1" == "-s" ]] ; then
        shift 1
        if [ -n "$LOGNEO" ]; then
            echo -e "##-----НАЧАЛО логирования------------>>" >> "$LOGNEO"
            echo "Лог вызван с строки: ${BASH_LINENO[0]}" >> "$LOGNEO"
            if [[ -n "$*" ]] ; then
                echo -e "Простой вывод команды текстового лога" >> "$LOGNEO"
            fi
            echo -e "|-->>> $@" >> "$LOGNEO"
            echo -e "##-----КОНЕЦ  логирования------------>>" >> "$LOGNEO"
        else
            echo "Error: LOGNEO variable is not defined."
        fi
    elif [[ -t 0 ]] || [ "$PPID" -eq "$$" ] ; then
        if [ -n "$LOGNEO" ]; then
            if [[ -n "$*" ]] ; then
                echo -e "\n##-----НАЧАЛО логирования------------>>" >> "$LOGNEO"
                echo "Лог вызван с строки: ${BASH_LINENO[0]}" >> "$LOGNEO"
                echo -e "______________________________" >> "$LOGNEO"
                echo -e "$@"  >> "$LOGNEO"
            else
                echo -e "\n##-----НАЧАЛО логирования------------>>"  >> "$LOGNEO"
                echo "Лог вызван с строки: ${BASH_LINENO[0]}" >> "$LOGNEO"
                echo -e "______________________________" >> "$LOGNEO"
                echo -e "" >> "$LOGNEO"
            fi
            echo -e "Перенаправление потока" >> "$LOGNEO"
            while read line; do
                echo -e "$line" >> "$LOGNEO"
            done
            echo -e "\n##-----КОНЕЦ  логирования------------>>\n\n" >> "$LOGNEO"
        else
            echo "Error: LOGNEO variable is not defined."
        fi
    fi 
}



echo "- Определение PATH с новыми бинарниками" &>>$LOGNEO && { # <--- обычный код
    binary_pull_busubox="mv cp dirname basename grep blockdev [ [[ ps stat unzip mountpoint find echo sleep sed mkdir ls ln readlink realpath cat awk wc du"
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
    export PATH="$TOOLS:$PATH"
    getprop | log
}


my_print(){ # <--- Определение функции [Аругменты $1 "Вывод сообщения"]
    case $WHERE_INSTALLING in
        kernelsu|magiskapp)
            echo -e "$@"
            echo -e "$@" >> "$LOGNEO"
            sleep 0.05
        ;;
        recovery)
            local input_message_ui="$1"
            local IFS=$'\n'
            while read -r line_print; do
                echo -e "$@" >> "$LOGNEO"
                echo -e "ui_print $line_print\nui_print" >>"/proc/self/fd/$ZIPARG2"
                sleep 0.05
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
                my_print "Отсутствует сообщение после -m"
                exit 1
            fi
            ;;
        -e)
            if [[ -n "$2" ]] ; then
                error_message="$2"
                shift 2
            else
                my_print "Отсутствует сообщение об ошибке после -e"
                exit 1
            fi
            ;;
        *)
            my_print "Неверный аргумент: $1"
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
        my_print "  !!!Exiting with error: $error_message!!!"
        
        my_print " "
        my_print " "
        
        if [[ -f /tmp/recovery.log ]] ; then
            cat /tmp/recovery.log | log "\n\n\n ЛОГ ИЗ РЕКАВАРИ"
        fi
        date_log=$(date +"%H-%M-%S-%d_%m_%y")
        if mountpoint -q /storage/emulated ; then 
            cp $NEOLOG "/storage/emulated/0/neo_file_$date_log.log"
            my_print "- logfile: /storage/emulated/0/neo_file_$date_log.log"
        elif mountpoint -q /sdcard/ ; then 
            cp $NEOLOG "/sdcard/neo_file_$date_log.log"
            my_print "- logfile: /sdcard/neo_file_$date_log.log"
        elif mountpoint -q /data/ ; then 
            cp $NEOLOG "/data/media/0/neo_file_$date_log.log"
            my_print "- logfile: /data/media/0/neo_file_$date_log.log"
        else
            cp $NEOLOG "$TPMN/../neo_file_$date_log.log"
            my_print "- logfile: $(realpath $TPMN/../neo_file_$date_log.log)"
        fi
        
        exit "$error_code"
    fi
}; export -f abort_neo

check_it(){ # <--- Определение функции [Аругментов нет]
    WHAT_CHECK="$1"
    NEED_ARGS="$2"
    if [[ "$(grep "$WHAT_CHECK=" "$CONFIG_FILE" | grep -v "#" | wc -l)" == "1" ]] ; then
        if grep -w "${WHAT_CHECK}=$NEED_ARGS" "$CONFIG_FILE" | grep -v "#" &>> "$LOGNEO" ; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}; export -f check_it

grep_cmdline() { # <--- Определение функции [Аругменты $1 что найти в cmdline]
  local REGEX="s/^$1=//p"
  { echo $(cat /proc/cmdline)$(sed -e 's/[^"]//g' -e 's/""//g' /proc/cmdline) | xargs -n 1; \
    sed -e 's/ = /=/g' -e 's/, /,/g' -e 's/"//g' /proc/bootconfig; \
  } 2>/dev/null | sed -n "$REGEX"
}; export -f grep_cmdline

get_current_suffix(){ # <--- Определение функции [--current] [--uncurrent] задает CURRENT_SUFFIX|UNCURRENT_SUFFIX|CURRENT_SLOT|UNCURRENT_SLOT|OUT_MESSAGE_SUFFIX
    export CURRENT_SUFFIX=""
    export UNCURRENT_SUFFIX=""
    export CURRENT_SLOT="0"
    export UNCURRENT_SLOT="1"
    export OUT_MESSAGE_SUFFIX="A-ONLY"
    case "$1" in
        "--current") A_CASE="_a" ; B_CASE="_b" ;;
        "--uncurrent") A_CASE="_b" ; B_CASE="_a" ;;
    esac
    CSUFFIX_tmp=$(getprop ro.boot.slot_suffix)
    if [[ -z "$CSUFFIX_tmp" ]]; then
        CSUFFIX_tmp=$(grep_cmdline androidboot.slot_suffix)
        if [[ -z "$CSUFFIX_tmp" ]]; then
            CSUFFIX_tmp=$(grep_cmdline androidboot.slot)
        fi
    fi
    case "$CSUFFIX_tmp" in
        "$A_CASE") CURRENT_SUFFIX="_a" ; UNCURRENT_SUFFIX="_b" ; CURRENT_SLOT=0 ; UNCURRENT_SLOT=1 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
        "$B_CASE") CURRENT_SUFFIX="_b" ;  UNCURRENT_SUFFIX="_a" ; CURRENT_SLOT=1 ; UNCURRENT_SLOT=0 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
    esac

}; export -f get_current_suffix

find_block_neo(){ # <--- Определение функции -с проверка поиска блока вовзращет истину или лож, -b задает что искать 
    found_blocks=()
    block_names=()
    check_status_o=false
    log -s "поиск блока, аргументы $@"
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
                log -s "Unknown parameter: $1"
                exit 1
            ;;
        esac
    done

    for block in "${block_names[@]}"; do
        if [ -h /dev/block/by-name/$block ]; then
            if ! [ -h "$(readlink /dev/block/by-name/$block)" ] && [ -b "$(readlink /dev/block/by-name/$block)" ]; then
                log -s "$(readlink /dev/block/by-name/$block)"
                found_blocks+="$(readlink /dev/block/by-name/$block) "
            fi
        elif [ -b /dev/block/mapper/$block ]; then
            if ! [ -h "$(readlink /dev/block/mapper/$block)" ] && [ -b "$(readlink /dev/block/mapper/$block)" ]; then
                log -s "$(readlink /dev/block/mapper/$block)" 
                found_blocks+="$(readlink /dev/block/mapper/$block) "
            fi
        elif [ -h /dev/block/bootdevice/by-name/$block ]; then

            if ! [ -h "$(readlink /dev/block/bootdevice/by-name/$block)" ] && [ -b "$(readlink /dev/block/bootdevice/by-name/$block)" ]; then
                log -s "$(readlink /dev/block/bootdevice/by-name/$block)"
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
            echo "${found_blocks% *}"
        fi
    fi
}; export -f find_block_neo

volume_selector(){ # <--- Определение функции  [Аругменты $1 - Выбор (+)] [Аругменты $2 - Выбор (-)]
    my_print "    $1 $word1"
    my_print "    $2 $word2"
    volume_selector_count=0
    while true; do
        while true; do
            timeout 0.5 getevent -lqc 1 2>&1 >$volume_selector_events_file &
            sleep 0.1
            volume_selector_count=$((volume_selector_count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $1 $word1"
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $2 $word2"
                return 1
            fi
            [ $volume_selector_count -gt 300 ] && break
        done
        if $volume_selector_error; then
            rm -rf $volume_selector_events_file
            abort_neo -e 2.1 -m "$word118"
        else
            volume_selector_error=true
        fi
    done
}; export -f volume_selector

unmap_all_partitions(){ # <--- Определение функции [Аругментов нет]
    for partitions in /dev/block/mapper/* ; do
        if [[ -h "$partitions" ]] && [[ -b "$(readlink -f "$partitions")" ]] ; then 
            
            partitions_name="$(basename "$partitions")"
            my_print "- $word3: $partitions_name"

            umount -fl "$partitions" &>> "$LOGNEO" && umount -fl "$partitions" &>> "$LOGNEO" && umount -fl "$partitions" &>> "$LOGNEO" && umount -fl "$partitions" &>> "$LOGNEO"
            umount -fl "$(readlink -f "$partitions")" &>> "$LOGNEO" && umount -fl "$(readlink -f "$partitions")" &>> "$LOGNEO" && umount -fl "$(readlink -f "$partitions")" &>> "$LOGNEO" && umount -fl "$(readlink -f "$partitions")" &>> "$LOGNEO"
            if [[ -n "$CURRENT_SUFFIX" ]] ; then
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --suffix "$CURRENT_SUFFIX" --unmap "$partitions_name" | log
                lptools_new --super "$SUPER_BLOCK" --slot "$UNCURRENT_SLOT" --suffix "$UNCURRENT_SUFFIX" --unmap "$partitions_name" | log
            else
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --unmap "$partitions_name" | log
            fi
        fi
    done
}; export -f unmap_all_partitions

update_partitions(){ # <--- Определение функции [Аругментов нет]

    my_print "- $word4"
    unmap_all_partitions

    good_slot_suffix=""
    if [[ -n "$CURRENT_SUFFIX" ]] ; then
        for check_suffix in _a _b ; do
            for check_slot in 0 1 ; do
                system_check_state=false
                vendor_check_state=false
                for partitions in vendor system ; do
                    continue_fail=true
                    if lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --map "${partitions}$check_suffix" &>> "$LOGNEO" ; then
                        
                        mkdir -pv "$TMPN/check_partitions/${partitions}$check_suffix" | log
                        if ! mount -r "/dev/block/mapper/${partitions}$check_suffix" "$TMPN/check_partitions/${partitions}$check_suffix" &>> "$LOGNEO" ; then
                           
                            if ! mount -r "/dev/block/mapper/${partitions}$check_suffix" "$TMPN/check_partitions/${partitions}$check_suffix" &>> "$LOGNEO" ; then
                                
                                if ! mount -r "/dev/block/mapper/${partitions}$check_suffix" "$TMPN/check_partitions/${partitions}$check_suffix" &>> "$LOGNEO" ; then
                                    
                                    continue_fail=false
                                fi
                            fi
                        fi
                        if $continue_fail && mountpoint "$TMPN/check_partitions/${partitions}$check_suffix" &>> "$LOGNEO" ; then 
                            if [[ "$partitions" == "vendor" ]] ; then
                                vendor_check_state=true
                            else
                                system_check_state=true
                            fi
                        fi
                        umount -fl "$TMPN/check_partitions/${partitions}$check_suffix" | log
                        lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --unmap "${partitions}$check_suffix" | log
                        rm -rf "$TMPN/check_partitions/${partitions}$check_suffix"
                        sleep 0.2
                    fi
                done
                
                if $system_check_state && $vendor_check_state ; then
                    good_slot_suffix+="${check_suffix}${check_slot}"
                fi
            done
        done 
        
        case "$good_slot_suffix" in
            "_a0_a1"|"_a0") 
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
                elif grep -q "source_slot: B" /tmp/recovery.log && grep -q "target_slot: A" /tmp/recovery.log ; then
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
                    my_print "- $word5"
                    if volume_selector "$word142" "$word143" ; then 
                        FINAL_ACTIVE_SLOT=0
                        FINAL_ACTIVE_SUFFIX=_a
                    else
                        FINAL_ACTIVE_SLOT=1
                        FINAL_ACTIVE_SUFFIX=_b
                    fi
                else 
                    abort_neo -e 119.1 -m "$word119"
                fi
            ;;
        esac
        unmap_all_partitions

        for partition in $(lptools_new --super $SUPER_BLOCK --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | grep -v "inject_neo" | awk '{print $1}') ; do
            partition_name=${partition/"NamePartInGroup->"/}
            if lptools_new --super "$SUPER_BLOCK" --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --map $partition_name &>> "$LOGNEO" ; then
                my_print "- $word6: $partition_name"
                sleep 0.5
            else 
                my_print "- $word7: $partition_name"
            fi
        done

        if ! [[ "$CURRENT_SUFFIX" == "$FINAL_ACTIVE_SUFFIX" ]] ; then
            SWITCH_SLOT_RECOVERY=true
            magisk resetprop ro.boot.slot_suffix $FINAL_ACTIVE_SUFFIX
            if grep androidboot.slot_suffix /proc/bootconfig ; then
                my_print "- $word8"
                edit_text="$(cat /proc/bootconfig | sed 's/androidboot.slot_suffix = "'$CURRENT_SUFFIX'"/androidboot.slot_suffix = "'$FINAL_ACTIVE_SUFFIX'"/')"
                echo -e "$edit_text" > $TMPN/bootconfig_new 
                mount $TMPN/bootconfig_new /proc/bootconfig | log
            fi
            if grep "androidboot.slot_suffix=$CURRENT_SUFFIX" /proc/cmdline || grep "androidboot.slot=$CURRENT_SUFFIX" /proc/cmdline ; then
                my_print "- $word9"
                edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot_suffix='$CURRENT_SUFFIX'/androidboot.slot_suffix='$FINAL_ACTIVE_SUFFIX'/' | sed 's/androidboot.slot='$CURRENT_SUFFIX'/androidboot.slot='$FINAL_ACTIVE_SUFFIX'/')"
                echo -e "$edit_text" > $TMPN/cmdline_new 
                mount $TMPN/cmdline_new /proc/cmdline | log
            fi
            if $BOOTCTL_STATE ; then
                my_print "- $word10: $FINAL_ACTIVE_SLOT"
                bootctl set-active-boot-slot $FINAL_ACTIVE_SLOT
            fi
        fi
    else
        unmap_all_partitions
        for partition in $(lptools_new --super $SUPER_BLOCK --slot $CURRENT_SLOT --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | grep -v "inject_neo" | awk '{print $1}') ; do
            partition_name=${partition/"NamePartInGroup->"/}
            if lptools_new --super "$SUPER_BLOCK"  --slot $CURRENT_SLOT --map $partition_name &>> "$LOGNEO" ; then
                my_print "- $word6: $partition_name"
                sleep 0.2
            else 
                my_print "- $word7: $partition_name"
            fi
        done
    fi
    get_current_suffix --current



}; export -f update_partitions

find_super_partition(){ # <--- Определение функции [Аругментов нет]
    for blocksuper in /dev/block/by-name/* /dev/block/bootdevice/by-name/* /dev/block/bootdevice/* /dev/block/* ; do
        if lptools_new --super $blocksuper --get-info &>> "$LOGNEO" ; then
            echo "$blocksuper"
            break
        fi    
    done 
}; export -f find_super_partition

select_argumetns_for_install(){ # <--- Определение функции [Аругментов нет]
    if [[ $hide_not_encrypted == "ask" ]] ; then
        my_print " "
        my_print "- $word11"
        my_print "- **$word12"
        if volume_selector "$word144" "$word145" ; then
            hide_not_encrypted=true
        else
            hide_not_encrypted=false
        fi
    fi
    if [[ $safety_net_fix == "ask" ]] ; then
        my_print " "
        my_print "- $word13"
        my_print "- **$word12"
        if volume_selector "$word144" "$word145" ; then
            safety_net_fix=true
        else
            safety_net_fix=false
        fi
    fi
    if $SYS_STATUS ; then
        wipe_data=false
    else
        if [[ $wipe_data == "ask" ]] ; then
            my_print " "
            my_print "- $word14"
            if volume_selector "$word146" "$word147" ; then
                wipe_data=true
            else
                wipe_data=false
            fi
        fi
    fi
    if [[ $remove_pin == "ask" ]] ; then
        my_print " "
        my_print "- $word15"
        if volume_selector "$word146" "$word147" ; then
            remove_pin=true
        else
            remove_pin=false
        fi
    fi
    if [[ $modify_early_mount == "ask" ]] ; then
        my_print " "
        my_print "- $word16"
        my_print "- **$word17"
        if volume_selector "$word148" "$word149" ; then
            modify_early_mount=true
        else
            modify_early_mount=false
        fi
    fi
    if [[ $disable_verity_and_verification == "ask" ]] ; then
        my_print " "
        my_print "- $word18"
        my_print "- **$word19"
        if volume_selector "$word150" "$word147" ; then
            disable_verity_and_verification=true
        else
            disable_verity_and_verification=false
        fi
    fi

    if [[ $zygisk_turn_on == "ask" ]] ; then
        my_print " "
        my_print "- $word20"
        my_print "- **$word21"
        if volume_selector "$word151" "$word152" ; then
            zygisk_turn_on=true
            my_print " "
            my_print "- $word22"
            my_print "- **$word23"
            my_print "- **$word24"
            if volume_selector "$word153" "$word154" ; then
                zygisk_turn_on_parm=always_on_boot
            else    
                zygisk_turn_on_parm=first_time_boot
            fi
        else
            zygisk_turn_on=false
        fi
    elif [[ "$zygisk_turn_on" == "first_time_boot" ]] || [[ "$zygisk_turn_on" == "always_on_boot" ]] ; then
        zygisk_turn_on_parm=$zygisk_turn_on
        zygisk_turn_on=true
    fi
    if [[ $add_custom_deny_list == "ask" ]] ; then
        my_print " "
        my_print "- $word25"
        my_print "- **$word26"
        if volume_selector "$word151" "$word152" ; then
            add_custom_deny_list=true
            my_print " "
            my_print "- $word22"
            my_print "- **$word23"
            my_print "- **$word24"
            if volume_selector "$word153" "$word154" ; then
                add_custom_deny_list_parm=first_time_boot
            else
                add_custom_deny_list_parm=always_on_boot
            fi
        else
            add_custom_deny_list=false
        fi
    elif [[ "$add_custom_deny_list" == "first_time_boot" ]] || [[ "$add_custom_deny_list" == "always_on_boot" ]] ; then
        add_custom_deny_list_parm=$add_custom_deny_list
        add_custom_deny_list=true
    fi
}; export -f select_argumetns_for_install

mount_vendor(){ # <--- Определение функции [Аругментов нет]

    my_print "- $word27"
    VENDOR_BLOCK=""
    log -s запуск функции mount_vendor
    if [[ "$SNAPSHOT_STATUS" == "unverified" ]] && $SUPER_DEVICE ; then
        log -s 'if [[ '"$SNAPSHOT_STATUS"' == "unverified" ]] && '$SUPER_DEVICE' ; then'
        if snapshotctl map &>> "$LOGNEO" ; then
            log -s snapshot map удачно
            if [[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]] ; then
                log -s '[[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]]'
                VENDOR_BLOCK="/dev/block/mapper/vendor$CURRENT_SUFFIX"
                my_print "- $word28: $(basename $(readlink $VENDOR_BLOCK))"
            else
                abort_neo -e 124.2 -m "$word120: vendor$CURRENT_SUFFIX"
            fi
        else
            abort_neo -e 124.1 -m "$word121"
        fi
    elif ! $SUPER_DEVICE; then
        log -s 'elif ! '$SUPER_DEVICE'; then'
        VENDOR_BLOCK="$(find_block_neo -b "vendor$CURRENT_SUFFIX")"
        my_print "- $word29"
        my_print "- $word30: $(basename $VENDOR_BLOCK)"
    elif $SUPER_DEVICE ; then
        log -s 'elif '$SUPER_DEVICE' ; then'
        if [[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]] ; then
            VENDOR_BLOCK="/dev/block/mapper/vendor$CURRENT_SUFFIX"
            my_print "- $word28: $(basename $(readlink $VENDOR_BLOCK))"
        else
            abort_neo -e 124.5 -m "$word120: vendor$CURRENT_SUFFIX"
        fi
    fi
    
    [[ -z "${VENDOR_BLOCK}" ]] && abort_neo -e 25.1 -m "$word122" 

    if ! $SYS_STATUS ; then
        my_print "- $word31"
        umount -fl "${VENDOR_BLOCK}" | log
        umount -fl "${VENDOR_BLOCK}" | log
        umount -fl "${VENDOR_BLOCK}" | log
    fi 

    name_vendor_block="vendor${CURRENT_SUFFIX}" 
    full_path_to_vendor_folder=$TMPN/mapper/$name_vendor_block

    mkdir -pv $full_path_to_vendor_folder | log
    my_print "- $word32"
    if ! mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>> "$LOGNEO" ; then
        mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder | log
    fi
    if ! mountpoint -q $full_path_to_vendor_folder ; then
        log -s vendor не смонтирован
        if $SYS_STATUS ; then
            log -s система запущена
            if [[ "$SNAPSHOT_STATUS" == "unverified" ]]; then 
                log -s система после обновления
                abort_neo -e 25.4 -m "$word123" 
            else
                log -s система не обновлена и используется full_path_to_vendor_folder=/vendor
                full_path_to_vendor_folder=/vendor
            fi
        else
            log -s система не запущена
            if $SWITCH_SLOT_RECOVERY ; then
                log -s слот менялся
                abort_neo -e 25.2 -m "$word124 $name_vendor_block"     
            else 
                log -s слот не менялся 
                if mount /vendor &>> "$LOGNEO" ; then
                    log -s будет использован full_path_to_vendor_folder=/vendor
                    full_path_to_vendor_folder=/vendor
                else
                    abort_neo -e 25.2 -m "$word124 $name_vendor_block" 
                fi
            fi
        fi
    fi


}; export -f mount_vendor

remove_dfe_neo(){ # <--- Определение функции [Аругментов нет]
    
    if $DETECT_NEO_IN_BOOT ; then
        log -s перезапись boot$UNCURRENT_SUFFIX $(find_block_neo -b "boot$UNCURRENT_SUFFIX")
        blockdev --setrw $(find_block_neo -b "boot$UNCURRENT_SUFFIX") &>>$LOGNEO 
        cat "$(find_block_neo -b "boot$CURRENT_SUFFIX")" > "$(find_block_neo -b "boot$UNCURRENT_SUFFIX")" 
    fi
    if $DETECT_NEO_IN_VENDOR_BOOT ; then
        log -s перезапись vendor_boot$UNCURRENT_SUFFIX $(find_block_neo -b "vendor_boot$UNCURRENT_SUFFIX")
        blockdev --setrw $(find_block_neo -b "vendor_boot$UNCURRENT_SUFFIX") &>>$LOGNEO 
        cat "$(find_block_neo -b "vendor_boot$CURRENT_SUFFIX")" > "$(find_block_neo -b "vendor_boot$UNCURRENT_SUFFIX")"
    fi
    if $DETECT_NEO_IN_SUPER && $A_ONLY_DEVICE ; then
        log -s удаление neo_inject из lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX"
        lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX" | log
        lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --remove "inject_neo$CURRENT_SUFFIX" | log
    elif $DETECT_NEO_IN_SUPER && ! $A_ONLY_DEVICE ; then
        log -s удаление neo_inject из lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX"
        lptools_new --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX" | log
        lptools_new --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX --super $SUPER_BLOCK --remove "inject_neo$CURRENT_SUFFIX" | log
    fi
    for boot in $WHERE_NEO_ALREADY_INSTALL; do
        log -s распаковка $boot
        ramdisk_compress_format=""
        block_boot=$(find_block_neo -b "$boot")
        log -s блок $boot $block_boot
        path_check_boot="$TMPN/check_boot_neo/$boot"
        
        mkdir -pv $path_check_boot | log
        cd "$path_check_boot" || exit 66
        
        magiskboot unpack -h "$block_boot" | log "Распаковка ramdisk.cpio $boot"
        if [[ -f "ramdisk.cpio" ]] ; then
            mkdir $path_check_boot/ramdisk_files | log
            cd $path_check_boot/ramdisk_files
            if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>> "$LOGNEO" ; then
                log -s ramdisk завпакован - распаковка 
                magiskboot decompress $path_check_boot/ramdisk.cpio $path_check_boot/d.cpio &>$path_check_boot/log.decompress
                rm -f $path_check_boot/ramdisk.cpio 
                mv $path_check_boot/d.cpio $path_check_boot/ramdisk.cpio
                ramdisk_compress_format=$(grep "Detected format:" $path_check_boot/log.decompress | sed 's/.*\[\(.*\)\].*/\1/')
            fi
            if [[ -n "$ramdisk_compress_format" ]] ; then
                if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>> "$LOGNEO" ; then
                    cd "$TMPN"
                    rm -rf $path_check_boot
                    continue
                fi
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
                    magiskboot cpio "$path_check_boot/ramdisk.cpio" "add 777 ${fstab//$path_check_boot\/ramdisk_files\//} $fstab" | log
                    need_repack=true
                fi
            done
            if $need_repack ; then
                cd $path_check_boot
                if [[ -n "$ramdisk_compress_format" ]] ; then
                    log -s запаковка обратно
                    magiskboot compress="${ramdisk_compress_format}" "$path_check_boot/ramdisk.cpio" "$path_check_boot/ramdisk.compress.cpio" | log
                    rm -f "$path_check_boot/ramdisk.cpio"
                    mv "$path_check_boot/ramdisk.compress.cpio" "$path_check_boot/ramdisk.cpio"
                fi
                log -s запись в  $block_boot
                magiskboot repack $block_boot | log
                blockdev --setrw $block_boot | log
                cat $path_check_boot/new-boot.img > $block_boot
            fi
        fi
        cd "$TMPN"
        rm -rf $path_check_boot
    done

    my_print "- $word33"


}; export -f remove_dfe_neo

ramdisk_first_stage_patch(){ # <--- Определение функции $1 передаються именя boot которые надо пропатчить
    for boot in $1 ; do
        ramdisk_compress_format=""
        my_print "- Патчинг first_stage $boot"
        boot_folder="$TMPN/ramdisk_patch/$boot"
        mkdir -pv "$TMPN/ramdisk_patch/$boot/ramdisk_folder" | log
        boot_block=$(find_block_neo -b $boot)
        cd $boot_folder
        my_print "- $word34 $boot"
        magiskboot unpack -h "$boot_block" | log
        cd "$boot_folder/ramdisk_folder"
        if [[ -f "$boot_folder/ramdisk.cpio" ]] ; then
            my_print "- $word34 ramdisk.cpio"
        else
            abort_neo -e 91.5 -m "Somthing wrong"
        fi
        
        if ! magiskboot cpio "$boot_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
            my_print "- $word35"
            magiskboot decompress "$boot_folder/ramdisk.cpio" "$boot_folder/ramdisk.d.cpio" &>$boot_folder/log.decompress
            rm -f "$boot_folder/ramdisk.cpio"
            mv "$boot_folder/ramdisk.d.cpio" "$boot_folder/ramdisk.cpio"
            ramdisk_compress_format=$(grep "Detected format:" $boot_folder/log.decompress | sed 's/.*\[\(.*\)\].*/\1/')
        fi
        if [[ -n "$ramdisk_compress_format" ]] ; then
            if ! magiskboot cpio "$boot_folder/ramdisk.cpio" extract ; then
                exit 152
            fi
        fi
        for fstab in $(find "$boot_folder/ramdisk_folder/" -name "$final_fstab_name"); do
            my_print "- $word36 $(basename $fstab)"
            if grep -q "/venodr/etc/init/hw" "$fstab" ; then
                sed -i '/\/venodr\/etc\/init\/hw/d' "$fstab"
            fi
            if grep -q "/vendor/etc/init/hw" "$fstab" ; then
                sed -i '/\/vendor\/etc\/init\/hw/d' "$fstab"
            fi
            if grep -q "/system/etc/init/hw" "$fstab" ; then
                sed -i '/\/system\/etc\/init\/hw/d' "$fstab"
            fi
            [[ -n "$(tail -n 1 "$fstab")" ]] && echo "" >>"$fstab"
            if $FLASH_IN_SUPER; then
                if ! $A_ONLY_DEVICE; then
                    my_print "- $word37"
                    echo "${NAME_INJECT_NEO}    /vendor/etc/init/hw ext4    ro,discard  slotselect,logical,first_stage_mount" >>$fstab
                else
                    my_print "- $word38"
                    echo "${NAME_INJECT_NEO}    /vendor/etc/init/hw ext4    ro,discard  logical,first_stage_mount" >>$fstab
                fi
            elif $FLASH_IN_BOOT; then
                my_print "- $word39 boot$UNCURRENT_SUFFIX"
                echo "/dev/block/by-name/boot$UNCURRENT_SUFFIX    /vendor/etc/init/hw ext4    ro  first_stage_mount" >>$fstab
            elif $FLASH_IN_VENDOR_BOOT; then
                my_print "- $word39 vendor_boot$UNCURRENT_SUFFIX"
                echo "/dev/block/by-name/vendor_boot$UNCURRENT_SUFFIX    /vendor/etc/init/hw ext4    ro  first_stage_mount" >>$fstab
            fi
            my_print "- $word40 $(basename $fstab) -> $boot"
            magiskboot cpio "$boot_folder/ramdisk.cpio" "add 777 ${fstab//$boot_folder\/ramdisk_folder\//} $fstab" | log
        done
        cd $boot_folder
        if [[ -n "$ramdisk_compress_format" ]] ; then
            my_print "- $word41 $ramdisk_compress_format"
            magiskboot compress="${ramdisk_compress_format}" "$boot_folder/ramdisk.cpio" "$boot_folder/ramdisk.compress.cpio" | log
            rm -f "$boot_folder/ramdisk.cpio"
            mv "$boot_folder/ramdisk.compress.cpio" "$boot_folder/ramdisk.cpio"
        fi
        my_print "- $word42 $boot"
        magiskboot repack $boot_block | log
        my_print "- $word43 new-$boot -> $boot_block"
        blockdev --setrw $boot_block | log
        cat $boot_folder/new-boot.img > $boot_block
        rm -rf "$TMPN/ramdisk_patch"
    done
    
}; export -f ramdisk_first_stage_patch

check_dfe_neo_installing(){ # <--- Определение функции [Аругментов нет]
    if ! $force_start; then
        my_print "- $word44"
        export DETECT_NEO_IN_BOOT=false
        export DETECT_NEO_IN_SUPER=false
        export DETECT_NEO_IN_VENDOR_BOOT=false
        export NEO_ALREADY_INSTALL=false
        export WHERE_NEO_ALREADY_INSTALL=""
        echo "- Поиск neo_inject в boot/vendor_boot только для a/b устройств" &>>$LOGNEO && {
            if ! $A_ONLY_DEVICE ; then 
                for boot_partition in "vendor_boot${UNCURRENT_SUFFIX}" "boot${UNCURRENT_SUFFIX}" ; do
                    echo "- Поиск neo_inject в ${boot_partition}" &>>$LOGNEO && {
                        if $(find_block_neo -c -b ${boot_partition}) ; then
                            my_print "- $word45 ${boot_partition}"
                            mkdir -pv $TMPN/mnt_boot_vendor | log
                            if mount -r $(find_block_neo -b ${boot_partition}) $TMPN/mnt_boot_vendor &>> "$LOGNEO" ; then
                                case "$boot_partition" in 
                                    vendor_boot*) 
                                        export DETECT_NEO_IN_VENDOR_BOOT=true 
                                        ;;
                                    boot*) 
                                        DETECT_NEO_IN_BOOT=true 
                                        ;;
                                esac
                                
                            fi
                        fi
                    }
                done
            fi
        }
        echo "- Поиск neo_inject в super если устройство имеет super" &>>$LOGNEO && {
            if "$SUPER_DEVICE" ; then
                my_print "- $word46"
                for neo_inject_name in neo_inject inject_neo ; do
                    if $A_ONLY_DEVICE ; then
                        if lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --get-info | grep "$neo_inject_name" &>> "$LOGNEO" ; then
                            DETECT_NEO_IN_SUPER=true
                        fi
                    elif ! $A_ONLY_DEVICE ; then 
                        if lptools_new --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX --super $SUPER_BLOCK --get-info | grep "$neo_inject_name" &>> "$LOGNEO" ; then
                            DETECT_NEO_IN_SUPER=true
                        fi
                    fi
                done
                
            fi
        }
        
        cd "$TMPN" | log
        for boot_check in "vendor_boot$CURRENT_SUFFIX" "boot$CURRENT_SUFFIX" ; do
            if find_block_neo -c -b "$boot_check" ; then
                block_boot=$(find_block_neo -b "$boot_check")
                path_check_boot="$TMPN/check_boot_neo/$boot_check"
                mkdir -pv $path_check_boot | log
                cd $path_check_boot
                magiskboot unpack -h "$block_boot" | log
                if [[ -f "$path_check_boot/ramdisk.cpio" ]] ; then
                    mkdir $path_check_boot/ramdisk_files | log
                    cd $path_check_boot/ramdisk_files
                    if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>> "$LOGNEO" ; then
                        if magiskboot decompress $path_check_boot/ramdisk.cpio $path_check_boot/d.cpio &>> "$LOGNEO" ; then
                            rm -f $path_check_boot/ramdisk.cpio | log
                            mv $path_check_boot/d.cpio $path_check_boot/ramdisk.cpio
                            if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract ; then
                                cd "$TMPN"
                                rm -rf $path_check_boot
                                continue
                            fi
                        else
                            cd "$TMPN"
                            rm -rf $path_check_boot
                            continue
                        fi
                    fi
                    for fstab in $(find $path_check_boot/ramdisk_files -name "fstab.*" ) ; do
                        if grep -q "/venodr/etc/init/hw" "$fstab" || \
                                grep -q "/vendor/etc/init/hw" "$fstab" || \
                                grep -q "/system/etc/init/hw" "$fstab" ; then
                            NEO_ALREADY_INSTALL=true
                            WHERE_NEO_ALREADY_INSTALL+=" $boot_check"
                        fi
                    done
                fi
            fi
            cd "$TMPN"
            rm -rf $path_check_boot
        done
        if $NEO_ALREADY_INSTALL ; then
            my_print "- $word47"
            if ! volume_selector "$word155" "$word156" ; then  
                remove_dfe_neo
                abort_neo -e 0 -m "DFE-NEO удален"
            fi
        fi
    fi


}; export -f check_dfe_neo_installing

setup_peremens_for_rc(){ # <--- Определение функции [Аругментов нет]

    add_init_target_rc_line_init="on init"
    add_init_target_rc_line_early_fs="on early-fs"
    add_init_target_rc_line_postfs="on post-fs-data"
    add_init_target_rc_line_boot_complite="on property:sys.boot_completed=1"

    if [[ -n $custom_reset_prop ]] ; then 

            add_init_target_rc_line_init="on init"
            add_init_target_rc_line_early_fs="on early-fs"
            add_init_target_rc_line_postfs="on post-fs-data"
            add_init_target_rc_line_boot_complite="on property:sys.boot_completed=1"


            for PARMS_RESET in $custom_reset_prop ; do  
                case $PARMS_RESET in 
                    "--init")
                        add_init=true ; add_early_fs=false ; add_post_fs_data=false ; add_boot_completed=false
                        continue
                    ;;
                    "--early-fs")
                        add_init=false ; add_early_fs=true ; add_post_fs_data=false ; add_boot_completed=false
                        continue
                    ;;
                    "--post-fs-data")
                        add_init=false ; add_early_fs=false ; add_post_fs_data=true ; add_boot_completed=false
                        continue
                    ;;
                    "--boot_completed")
                        add_init=false ; add_early_fs=false ; add_post_fs_data=false ; add_boot_completed=true
                        continue
                    ;;
                esac
                if ! $add_init && ! $add_early_fs && ! $add_post_fs_data && ! $add_boot_completed ; then
                    exit 189
                fi
                if echo "$PARMS_RESET" | grep -q "=" ; then
                    if $add_init ; then 
                        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                    elif $add_early_fs ; then 
                        add_init_target_rc_line_early_fs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_early_fs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_early_fs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                    elif $add_post_fs_data ; then 
                        add_init_target_rc_line_postfs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_postfs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_postfs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                    elif $add_boot_completed ; then 
                        add_init_target_rc_line_boot_complite+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                        add_init_target_rc_line_boot_complite+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\""
                    fi
                fi
            done
    
            
    fi
    if $safety_net_fix ; then
        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_init"
        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_init"
        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_init"

        add_init_target_rc_line_early_fs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_fs"
        add_init_target_rc_line_early_fs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_fs"
        add_init_target_rc_line_early_fs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_fs"

        add_init_target_rc_line_postfs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safatynet_postfs"

        add_init_target_rc_line_boot_complite+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_boot_complite"
        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_boot_complite"
        add_init_target_rc_line_boot_complite+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_boot_complite"
    fi
    if $hide_not_encrypted ; then
        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh hide_decrypted"
        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh hide_decrypted"
        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh hide_decrypted"
    fi
    if $zygisk_turn_on ; then
        add_init_target_rc_line_early_fs+="\n    exec_background u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh zygisk_on_$zygisk_turn_on_parm"
    fi
    if $add_custom_deny_list ; then
        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh add_deny_list_$add_custom_deny_list_parm"
    fi


}; export -f setup_peremens_for_rc

confirm_menu(){ # <--- Определение функции [Аругментов нет]
    my_print " "
    my_print " "
    my_print " "
    my_print "- $word48:"
    my_print "- $word49: $languages"
    if [[ "$where_to_inject" == "auto" ]] ; then
        my_print "- $word50:"
        my_print "- $word51"
        if $FLASH_IN_SUPER ; then
            if $A_ONLY_DEVICE ; then
                my_print ">>>> super"
            else
                my_print ">>>> super < ${CURRENT_SUFFIX} < slot"
            fi
        fi
        if $FLASH_IN_VENDOR_BOOT ; then
            my_print ">>>> vendor_boot${UNCURRENT_SUFFIX}"
        fi
        if $FLASH_IN_BOOT ; then
            my_print ">>>> boot${UNCURRENT_SUFFIX}"
        fi
    elif [[ "$where_to_inject" == "super" ]] ; then
        if $A_ONLY_DEVICE ; then
            my_print ">>>> super"
        else
            my_print ">>>> super < ${CURRENT_SUFFIX} < slot"
        fi
    else 
        my_print ">>>> ${where_to_inject}${UNCURRENT_SUFFIX}" 
    fi
    
    my_print "- $word52: $modify_early_mount"
    my_print "- SafetyNetFix: $safety_net_fix"
    my_print "- $word53: $hide_not_encrypted"
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- $word54: $zygisk_turn_on"
    else
        my_print "- $word54: $zygisk_turn_on/$zygisk_turn_on_parm"
    fi
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- $word55: $add_custom_deny_list"
    else
        my_print "- $word55: $add_custom_deny_list/$add_custom_deny_list_parm"
    fi   
    echo "- Проверка доступтности magisk" &>>$LOGNEO && {
        case $magisk in
            "EXT:"* | "ext:"* | "Ext:"*)
                magisk="$(echo ${magisk} | sed "s/ext://I")"
                if [[ -f "$(dirname "${ZIPARG3}")/${magisk}" ]]; then
                    my_print "- $word56: $magisk"
                    MAGISK_ZIP="$(dirname "${ZIPARG3}")/${magisk}"
                
                else
                    my_print "- $word57"
                    magisk=false
                fi
                ;;
            *)
                if [[ -f "$TMPN/unzip/MAGISK/${magisk}.apk" ]]; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.apk"
                    my_print "-  $word56: $magisk"
                elif [[ -f "$TMPN/unzip/MAGISK/${magisk}.zip" ]] ; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.zip"
                    my_print "-  $word56: $magisk"
                else
                    my_print "- $word57"
                    magisk=false
                fi
                ;;
        esac 
    } 
    my_print "- $word58: $wipe_data"
    my_print "- $word59: $remove_pin"
    my_print "- $word60: $dfe_paterns"
    if [[ -z "$custom_reset_prop" ]] ; then
        my_print "- custom_reset_prop: none"
    else
        my_print "- custom_reset_prop: $custom_reset_prop"
    fi
    my_print " "
    my_print " "
    if ! $force_start ; then
        my_print "- $word61"
        if ! volume_selector "$word157" "$word158" ; then 
            abort_neo -e 200 -m "Вы вышли из программы"
        fi
    fi


}; export -f confirm_menu

add_custom_rc_line_to_inirc_and_add_files(){ # <--- Определение функции передается $1 файл куда сделать запись
    if $safety_net_fix || $hide_not_encrypted || $add_custom_deny_list || $zygisk_turn_on || [[ -n $custom_reset_prop ]] ; then
        my_print "- $word62"
        if $add_custom_deny_list || $zygisk_turn_on ; then
            cp $TMPN/unzip/META-INF/tools/magisk.db "$TMPN/neo_inject$CURRENT_SUFFIX/" 
            my_print ">>>> magisk.db"
            cp $TMPN/unzip/META-INF/tools/denylist.txt "$TMPN/neo_inject$CURRENT_SUFFIX/"
            my_print ">>>> denylist.txt"
            cp $TOOLS/sqlite3 "$TMPN/neo_inject${CURRENT_SUFFIX}/"
            my_print ">>>> sqlite3 binary"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/sqlite3"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/magisk.db"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/denylist.txt"
        fi
        my_print ">>>> magisk binary"
        cp $TOOLS/magisk "$TMPN/neo_inject${CURRENT_SUFFIX}/"
        my_print ">>>> init.sh"
        cp $TMPN/unzip/META-INF/tools/init.sh "$TMPN/neo_inject${CURRENT_SUFFIX}/"
        chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/init.sh"
        echo " " >> "$1"
        my_print "- $word63 $(basename $1)"
        my_print ">>>> on init"
        echo -e "${add_init_target_rc_line_init}\n" >> "$1"
        my_print ">>>> on early-fs"
        echo -e "${add_init_target_rc_line_early_fs}\n" >> "$1"
        my_print ">>>> on post-fs"
        echo -e "${add_init_target_rc_line_postfs}\n" >> "$1"
        my_print ">>>> on boot_complite=1"
        echo -e "${add_init_target_rc_line_boot_complite}\n" >> "$1"
    fi
}; export -f add_custom_rc_line_to_inirc_and_add_files

move_fstab_from_original_vendor_and_patch(){ # <--- Определение функции [Аругментов нет]
    fstab_names_check="$basename_fstab "
    fstab_names_check+="${basename_fstab/$hardware_boot/$default_fstab_prop} "
    fstab_names_check+="${basename_fstab/$hardware_boot/$(getprop ro.product.device)} "
    fstab_names_check+="${basename_fstab/$hardware_boot/$(getprop ro.product.system.device)} "
    fstab_names_check+="${basename_fstab/$hardware_boot/$(getprop ro.product.vendor.device)} "
    fstab_names_check+="${basename_fstab/$hardware_boot/$(getprop ro.product.odm.device)}"

    my_print "- $word64"
    for original_fstab_name_for in $fstab_names_check ; do
        full_path_to_fstab_into_for="$full_path_to_vendor_folder$(dirname ${path_original_fstab})/$original_fstab_name_for"
        if [[ -f "$full_path_to_fstab_into_for" ]] && grep "/userdata" "$full_path_to_fstab_into_for" | grep "latemount" | grep -v "#" &>> "$LOGNEO" ; then
            my_print "- $word65"
            my_print "*> $original_fstab_name_for"
            my_print "- $word66"
            cp -afc "$full_path_to_fstab_into_for" "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab"
            my_print "- $word67:"
            my_print "*> neo_inject${CURRENT_SUFFIX}/$basename_fstab"
            patch_fstab_neo $dfe_paterns -f "$full_path_to_fstab_into_for" -o "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab"
            final_fstab_name="$original_fstab_name_for"
            return 0
            break
        fi
        my_print ">> $word68: $original_fstab_name_for"
    done
    return 1
    

}; export -f move_fstab_from_original_vendor_and_patch

patch_fstab_neo(){ # <--- Определение функции [-m, -r|-p, -f, -o, -v]
    removeoverlay=false
    removepattern=""
    input_fstab=""
    mountpoint=""
    output_fstab=""
    while [ $# -gt 0 ]; do
        case "$1" in
        -m) 
            removepattern="$removepattern $2--m--"
            shift 2
            while [[ "$1" != "-m" && "$1" != "-f" && "$1" != "-o" && "$1" != "-v" ]] && [ $# -gt 0 ]; do 
                case "$1" in 
                    -r|-p)
                        now_check_pattern="$1"
                        shift 1
                        if [ $# -gt 0 ] && [ "$(printf '%s' "$1" | cut -c 1)" != "-" ]; then
                            while [ $# -gt 0 ] && ( [ "$(printf '%s' "$1" | cut -c 1)" != "-" ] ); do
                                removepattern="${removepattern}-$now_check_pattern--$1-$now_check_pattern--"
                                shift 1
                            done
                        else
                            echo "No patterns provided for removal." | log
                        fi
                    ;;
                esac
            done
            ;;
        -f) 
            input_fstab="$2"
            shift 2
            ;;
        -o) 
            output_fstab="$2"
            shift 2
            ;;
        -v) 
            removeoverlay=true
            shift 1
            ;;
        *)  
            echo "Unknown parameter: $1" | log
            exit 1
            ;;
        esac
    done
    echo -n "" > "$output_fstab"
    while IFS= read -r line; do
        if $removeoverlay; then
            case $line in
                overlay*)
                    line="#$line"
                    ;;
            esac
        fi
        case $line in 
            "# "*)
                echo "comment line $line" | log
            ;;
            *)
                if [ "$(echo "$removepattern" | wc -w)" -gt 0 ]; then
                    for arrp in $removepattern ; do
                        mountpoint=${arrp%%"--m--"*}
                        patterns=${arrp##*"--m--"}
                        remove_paterns=$(echo -e ${patterns//"--p--"/"\n"} | grep "\-\-r--")
                        replace_patterns=$(echo -e ${patterns//"--r--"/"\n"} | grep "\-\-p--")
                        if [ "$(echo "$line" | awk '{print $2}')" == "$mountpoint" ]; then
                            my_print "- $word69: '$mountpoint'"
                            for replace_pattern in ${replace_patterns//"--p--"/ } ; do
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" ; then
                                    my_print "- $word70 ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$(echo "$line" | sed -E "s/,${replace_pattern%%"--to--"*}*[^[:space:]|,]*/,${replace_pattern##*"--to--"}/")
                                fi
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" && ! (echo "$line" | grep -q "${replace_pattern##*"--to--"}"); then 
                                    my_print "- $word70 ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$(echo "$line" | sed -E "s/${replace_pattern%%"--to--"*}*[^[:space:]|,]*/${replace_pattern##*"--to--"}/")
                                fi 
                            done
                            for remove_pattern in ${remove_paterns//"--r--"/ }; do
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- $word71: ${remove_pattern}"
                                    line=$(echo "$line" | sed -E "s/,${remove_pattern}*[^[:space:]|,]*//")
                                fi
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- $word71: ${remove_pattern}"
                                    line=$(echo "$line" | sed -E "s/${remove_pattern}*[^[:space:]|,]*//")
                                fi
                            done
                        fi


                    done
                fi
            ;;
        esac
        echo "$line" >>"$output_fstab"
    done <"$input_fstab"

}; export -f patch_fstab_neo

move_files_from_vendor_hw(){ # <--- Определение функции [Аругментов нет]

    echo "- Определение ro_haedware and fstab_suffix" &>>$LOGNEO && { # <--- обычный код
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
        default_fstab_prop=$(getprop ro.boot.fstab_suffix)
    }
    echo "- создание структуры папки для make_ext4fs и копирование из inithw" &>>$LOGNEO && { # <--- обычный код
        VENDOR_FOLDER="$full_path_to_vendor_folder"
        mkdir $TMPN/neo_inject${CURRENT_SUFFIX} | log
        mkdir "$TMPN/neo_inject${CURRENT_SUFFIX}/lost+found" | log
        cp -afc ${VENDOR_FOLDER}/etc/init/hw/* $TMPN/neo_inject${CURRENT_SUFFIX}/
    }
    echo "- Поиск fstab по .rc файлам" &>>$LOGNEO && { # <--- обычный код
        for file_find in "$TMPN/neo_inject${CURRENT_SUFFIX}"/*.rc ; do
            if grep "mount_all" $file_find | grep "\-\-late" | grep -v "#" &>> "$LOGNEO" ; then
                if grep "mount_all --late" $file_find | grep -v "#" &>> "$LOGNEO" ; then
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
                    fstab_find="$(grep mount_all $file_find | grep "\-\-late" | grep -v "#" | sort -u)" 
                    new_path_fstab="$(echo "$fstab_find" | sed "s|[^ ]*fstab[^ ]*|/vendor/etc/init/hw/fstab.$hardware_boot|")"
                    sed -i "s|$fstab_find|$new_path_fstab|g" "$file_find"
                    if $modify_early_mount ; then
                        sed -i "s|${fstab_find//"--late"/"--early"}|${new_path_fstab//"--late"/"--early"}|g" "$file_find"
                    fi
                    if [[ -z "$path_original_fstab" ]] && [[ -z "$basename_fstab" ]] ; then
                        path_original_fstab="$(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p')"
                        if (echo "$path_original_fstab" | grep -q "\\$"); then
                            basename_fstab="$(basename $(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p' | sed 's/\(\$.*\)//')$hardware_boot)"
                        else 
                            basename_fstab="$(basename $(echo "$fstab_find" | sed -n 's/.* \/[^/]*\(\/.*\) --late/\1/p'))"
                        fi
                    fi
                    last_init_rc_file_for_write=$file_find
                fi
            fi
        done
        if [[ -z "$path_original_fstab" ]] || [[ -z "$basename_fstab" ]]; then

            abort_neo -e 36.2 -m "$word125"
        fi
        add_custom_rc_line_to_inirc_and_add_files "$last_init_rc_file_for_write"
        if ! move_fstab_from_original_vendor_and_patch ; then
            if ! [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then 
                umount -fl "$full_path_to_vendor_folder"
            fi
            abort_neo -e 36.1 -m "$word126 /vendor/etc/[${fstab_names_check// /\|}]"
        fi
        [[ -f "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab" ]] || abort_neo -e 36.6 -m "$word127"

    }



}; export -f move_files_from_vendor_hw

check_whare_to_inject(){ # <--- Определение функции [Аругментов нет]
            
    if [[ "$where_to_inject" == "auto" ]] ; then
        if $SUPER_DEVICE ; then
            FLASH_IN_SUPER=true
        fi
        if ! $A_ONLY_DEVICE && $VENDOR_BOOT_DEVICE ; then
            FLASH_IN_VENDOR_BOOT=true
        fi
        if ! $A_ONLY_DEVICE; then
            FLASH_IN_BOOT=true
        fi
    elif [[ "$where_to_inject" == "super" ]] ; then
        if $SUPER_DEVICE ; then
            FLASH_IN_SUPER=true
        else
            abort_neo -e 71.4 -m "$word128"
        fi
    elif [[ "$where_to_inject" == "boot" ]] ; then
        if ! $A_ONLY_DEVICE; then
            FLASH_IN_BOOT=true
            echo "- не A-only wahre to inject" | log
        else
            abort_neo -e 71.3 -m "$word129"
        fi
    elif [[ "$where_to_inject" == "vendor_boot" ]] ; then
        if $VENDOR_BOOT_DEVICE && ! $A_ONLY_DEVICE; then
            FLASH_IN_VENDOR_BOOT=true
            echo "- Vendor_boot и не A-only wahre to inject" | log
        else
            abort_neo -e 71.2 -m "$word130"
        fi
    fi
    if ! $FLASH_IN_BOOT && ! $FLASH_IN_VENDOR_BOOT && ! $FLASH_IN_SUPER ; then
        abort_neo -e 71.5 -m "$word131"
    fi

}; export -f check_whare_to_inject

make_neo_inject_img(){ # <--- Определение функции
    TARGET_DIR="$1"
    LABLE="$2"
    SYSTEM_FOLDER_OWNER="$3"
    INJECT_TMP_FOLDER_ONWER="$4"
    FILE_CONTEXTS_FILE="$TMPN/${LABLE}_file_contexts"
    FS_CONFIG_FILE="$TMPN/${LABLE}_fs_config"
    for file in "$FILE_CONTEXTS_FILE" "$FS_CONFIG_FILE" ; do
        [ -f "$file" ] && rm -f "$file"
    done
    {
        find $TARGET_DIR | while read FILE
        do
            if [ -e "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" ] && [[ -n "$3" ]] ; then
                OWNER=$(stat -Z "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" | awk '/^S_Context/ {print $2}')
                if [ -z "${OWNER}" ] ; then
                    OWNER=$(stat -Z $(dirname "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}") | awk '/^S_Context/ {print $2}')
                fi
            elif [[ -e "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" ]] && [[ -n "$4" ]] ; then
                OWNER=$(stat -Z "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" | awk '/^S_Context/ {print $2}')
                if [ -z "${OWNER}" ] ; then
                    OWNER=$(stat -Z $(dirname "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}") | awk '/^S_Context/ {print $2}')
                fi
            else
                OWNER=$(stat -Z "$FILE" | awk '/^S_Context/ {print $2}')
                if [ -z "${OWNER}" ] ; then
                    OWNER=$(stat -Z $(dirname "$FILE") | awk '/^S_Context/ {print $2}')
                fi
            fi
            FILE_FORMAT=$(echo "${FILE#$TARGET_DIR}" | awk '{ gsub(/\./, "\\."); gsub(/\ /, "\\ "); gsub(/\+/, "\\+"); gsub(/\[/, "\\["); print }')
            if [ -d "${FILE}" ] ; then 
                CONTEXT_LINE="/${LABLE}${FILE_FORMAT}(/.*)? ${OWNER}"
                echo $CONTEXT_LINE >> "${FILE_CONTEXTS_FILE}"
            fi
                su_contects=false
            for check_su_contects in "magisk.db" "denylist.txt" "sqlite3" "init.sh" "magisk" ; do 
                if echo "${FILE#$TARGET_DIR}" | grep -q "$check_su_contects" ; then 
                su_contects=true 
                fi
            done
            if $su_contects ; then 
                CONTEXT_LINE="/${LABLE}${FILE_FORMAT} u:r:su:s0"
            else 
                CONTEXT_LINE="/${LABLE}${FILE_FORMAT} ${OWNER}"
            fi
            if ! [ "${LABLE}${FILE#$TARGET_DIR}" == "${LABLE}" ] ; then
                echo $CONTEXT_LINE >> "${FILE_CONTEXTS_FILE}"
            fi
            
        done
    } & {

        find $TARGET_DIR | while read FILE
        do
            if ! [ "${LABLE}${FILE#$TARGET_DIR}" == "${LABLE}" ] ; then
                if [ -e "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" ] && [ -n "$3" ]  ; then
                    PERMISSIONS_GROUPS=$(stat -c "%u %g 0%a" "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}")
                    LINKER_FILE=$(stat "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" | awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
                elif [ -e "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" ] && [ -n "$4" ]  ; then
                    PERMISSIONS_GROUPS=$(stat -c "%u %g 0%a" "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}")
                    LINKER_FILE=$(stat "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" | awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
                else
                    PERMISSIONS_GROUPS=$(stat -c "%u %g 0%a" "$FILE")
                    LINKER_FILE=$(stat "$FILE" | awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
                fi
                
                FILE_FORMAT=$(echo "${FILE#$TARGET_DIR}" | awk '{ gsub(/\ /, "\\ "); print }')
                FS_CONFIG_LINE="${LABLE}${FILE_FORMAT} ${PERMISSIONS_GROUPS} ${LINKER_FILE}"
                echo "$FS_CONFIG_LINE" >> "${FS_CONFIG_FILE}"
            fi
            
        done
    }
    wait
    PRESIZE_IMG_FODLER="$(du -sb "${TARGET_DIR}" | awk '{print int($1*10)}')"
    make_ext4fs -J -T 1230764400 -S "${FILE_CONTEXTS_FILE}" -l $PRESIZE_IMG_FODLER -C "${FS_CONFIG_FILE}" -a "${LABLE}" -L "${LABLE}" "$NEO_IMG" "${TARGET_DIR}" | log

    resize2fs -M "$NEO_IMG" | log
    resize2fs -M "$NEO_IMG" | log
    resize2fs -M "$NEO_IMG" | log
    resize2fs -M "$NEO_IMG" | log
    resize2fs -f "$NEO_IMG" "$(($(stat -c%s "$NEO_IMG")*2/512))"s | log
    if $SYS_STATUS && [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then
        echo "- Системный vendor" | log
    else
        umount -fl $full_path_to_vendor_folder | log
    fi

}; export -f make_neo_inject_img

check_size_super(){ # <--- Определение функции $1 размер neo_inject в байтах
    SIZE_NEO_IMG_FUNC="$1"
    for size_print in 2 4 8 16 32 64 128 ; do
        if (( ( $SIZE_NEO_IMG_FUNC + ( 3 * 1024 * 1024 ) ) > ( $size_print * 1024 * 1024 ) )) ; then
            continue
        fi
        if (( $FREE_SIZE_INTO_SUPER >= $size_print * 1024 * 1024 )) ; then
            my_print "- $word72"
            return 0
            break
        else
            my_print "- $word73"
            my_print "- $word74 ${size_print}mb"
            return 1
        fi
    done

}; export -f check_size_super

test_mount_neo_inject(){ # <--- Определение функции $1 путь к блоку neo_inject
    local PATH_BLOCK_NEO="$1"
    my_print "- $word75"
    mkdir -pv "$TMPN/test_neo_inject_img_mount" | log
    if mount -r "$PATH_BLOCK_NEO" "$TMPN/test_neo_inject_img_mount" ; then
        umount "$TMPN/test_neo_inject_img_mount"
        return 0
    fi
    if mount -r "$PATH_BLOCK_NEO" "$TMPN/test_neo_inject_img_mount" ; then
        umount "$TMPN/test_neo_inject_img_mount"
        return 0
    fi
    if mount -r "$PATH_BLOCK_NEO" "$TMPN/test_neo_inject_img_mount" ; then
        umount "$TMPN/test_neo_inject_img_mount"
        return 0
    fi
    if mount -r "$PATH_BLOCK_NEO" "$TMPN/test_neo_inject_img_mount" ; then
        umount "$TMPN/test_neo_inject_img_mount"
        return 0
    fi
    return 1
}; export -f test_mount_neo_inject

flash_inject_neo_to_super(){ # <--- Определение функции [Аругментов нет]
    SIZE_NEO_IMG=$(stat -c%s $NEO_IMG)
    if $A_ONLY_DEVICE ; then 
        LPTOOLS_SLOT_SUFFIX=""
    else
        LPTOOLS_SLOT_SUFFIX="--slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX"
    fi
    if [[ -e "/dev/block/mapper/neo_inject$CURRENT_SUFFI" ]] && $SYS_STATUS ; then
        NAME_INJECT_NEO=inject_neo
    fi
   
    lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --remove "neo_inject$CURRENT_SUFFIX" | log
    lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --remove "inject_neo$CURRENT_SUFFIX" | log

    
    if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
        lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --clear-cow | log
    fi
    FREE_SIZE_INTO_SUPER="$(lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --free | grep "Free space" | awk '{print $3}')"
    if ! check_size_super "$SIZE_NEO_IMG" ; then
        my_print "- $word76"
        resize2fs -M "$NEO_IMG" | log
        resize2fs -M "$NEO_IMG" | log
        resize2fs -M "$NEO_IMG" | log
        SIZE_NEO_IMG=$(stat -c%s $NEO_IMG)
        if ! check_size_super "$SIZE_NEO_IMG" ; then
            return 1
        fi
    fi
    if lptools_new --super $SUPER_BLOCK $LPTOOLS_SLOT_SUFFIX --create "${NAME_INJECT_NEO}${CURRENT_SUFFIX}" "$SIZE_NEO_IMG" &>> "$LOGNEO" ; then
        my_print "- $word77 $(awk 'BEGIN{printf "%.1f\n", '$SIZE_NEO_IMG'/1024/1024}')MB"
        if find_block_neo -c -b "${NAME_INJECT_NEO}${CURRENT_SUFFIX}"; then
            cat "$NEO_IMG" > "$(find_block_neo -b "${NAME_INJECT_NEO}${CURRENT_SUFFIX}")"
            if test_mount_neo_inject "$(find_block_neo -b "${NAME_INJECT_NEO}${CURRENT_SUFFIX}")" &>> "$LOGNEO" ; then
                my_print "- Успех записи neo_inject в super"
                FLASH_IN_BOOT=false
                FLASH_IN_VENDOR_BOOT=false
            else
                my_print "- $word78"
                return 1
            fi
        else
            my_print "- $word79"
            return 1
        fi
    else
        my_print "- $word80"
        return 1
    fi
    return 0

}; export -f flash_inject_neo_to_super

check_first_stage_fstab(){ # <--- Определение функции [Аругментов нет]
    log -s проверка бутов на first stage
    for boot in "vendor_boot$CURRENT_SUFFIX" "boot$CURRENT_SUFFIX" ; do
        log -s проверка $boot
        if ! find_block_neo -c -b $boot ; then
            log -s $boot не найден
            continue
        fi
        mkdir -pv "$TMPN/check_boot_first_stage/" | log
        boot_check_folder="$TMPN/check_boot_first_stage/$boot"
        log -s $boot_check_folder
        mkdir -pv "$boot_check_folder/ramdisk_folder" | log
        vendor_boot_block=$(find_block_neo -b $boot)
        log -s $vendor_boot_block
        cd "$boot_check_folder"
        if magiskboot unpack -h "$vendor_boot_block" &>> "$LOGNEO" ; then
            ls | log "Содержимое папки $boot_check_folder/ramdisk_folder"
            if [[ -f "$boot_check_folder/ramdisk.cpio" ]] ; then
                log -s файл ramdisk.cpio обнаружен
                cd "$boot_check_folder/ramdisk_folder"
                if ! magiskboot cpio "$boot_check_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
                    log -s не удалось распаковать cpio, возможно в нем формат сжатия
                    magiskboot decompress "$boot_check_folder/ramdisk.cpio" "$boot_check_folder/ramdisk.d.cpio" | log
                    ls | log "Содержимое папки $boot_check_folder"
                    rm -f "$boot_check_folder/ramdisk.cpio"
                    mv "$boot_check_folder/ramdisk.d.cpio" "$boot_check_folder/ramdisk.cpio"
                    ls | log "Содержимое папки $boot_check_folder"
                    
                fi
                if magiskboot cpio "$boot_check_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
                    ls | log "Содержимое папки $boot_check_folder"
                    for fstab in $(find "$boot_check_folder/ramdisk_folder/" -name "$final_fstab_name"); do
                        if grep -w "/system" $fstab | grep "first_stage_mount" &>> "$LOGNEO" ; then
                            BOOT_PATCH+="$boot "
                        fi
                    done
                fi
            fi
        fi
        rm -rf "$TMPN/check_boot_first_stage/"
    done
    if [[ -n "$BOOT_PATCH" ]] ; then
        return 0
    else
        return 1
    fi
}; export -f check_first_stage_fstab

default_post_install(){
    if $disable_verity_and_verification ; then 
        my_print "- $word81"
        ALRADY_DISABLE=true
        avbctl --force disable-verification | log
        avbctl --force disable-verity | log
    fi
    mountpoint -q /data || mount /data | log
    mountpoint -q /data && {
        if $remove_pin; then
            my_print "- $word82"
            rm -f /data/system/locksettings*
        fi
        if $wipe_data; then
            my_print "- $word83"
            find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
        fi
    }
    if ! [[ "$magisk" == false ]]; then
        my_print " "
        my_print "- $word56:"
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
            mkdir -pv $TMPN/$magisk | log
            cd $TMPN/$magisk 
            unzip "$MAGISK_ZIP" | log
            bash $TMPN/$magisk/META-INF/com/google/android/update-binary "$ZIPARG1" "$ZIPARG2" "$MAGISK_ZIP"
        }
        my_print " "
        my_print " "
    fi
    if [[ -f /tmp/recovery.log ]] ; then
        cat /tmp/recovery.log | log "\n\n\n ЛОГ ИЗ РЕКАВАРИ"
    fi
    date_log=$(date +"%H-%M-%S-%d_%m_%y")
    if mountpoint -q /sdcard/ ; then 
        cp "$TPMN/new_file.log" "/sdcard/neo_file_$date_log.log"
        my_print "- logfile: /sdcard/neo_file_$date_log.log"
    elif mountpoint -q /data/ ; then 
        cp "$TPMN/new_file.log" "/data/media/0/neo_file_$date_log.log"
        my_print "- logfile: /data/media/0/neo_file_$date_log.log"
    else
        cp "$TPMN/new_file.log" "$TPMN/../neo_file_$date_log.log"
        my_print "- logfile: $(realpath $TPMN/../neo_file_$date_log.log)"
    fi
}; export -f default_post_install

flash_inject_neo_to_vendor_boot(){
    local boot="$1"
    blockdev --setrw $(find_block_neo -b "${boot}${UNCURRENT_SUFFIX}") &>>$LOGNEO 
    cat "$NEO_IMG" > "$(find_block_neo -b "${boot}${UNCURRENT_SUFFIX}")"
    if test_mount_neo_inject "$(find_block_neo -b "${boot}${UNCURRENT_SUFFIX}")" ; then
        my_print "- $word84 ${boot}${UNCURRENT_SUFFIX}"
        return 0
    else
        return 1
    fi
}; export -f flash_inject_neo_to_vendor_boot

echo "- Определение языка" &>>$LOGNEO && { # <--- обычный код
    # lng.sh аргументы    \/--------------------\/
    for number in {1..250} ; do 
        export word${number}=""
    done
    # lng.sh аргументы    /\--------------------/\
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

echo "- Определние переменых для volume_selector" &>>$LOGNEO && { # <--- обычный код
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

echo "- Определение стандартных переменных" &>>$LOGNEO && { # <--- обычный код
    my_print "- $word85"
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
    # info аргументы      \/--------------------\/\
    export BOOT_PATCH=""
    export SUPER_THIS=""
    export SUPER_BLOCK=""
    export AONLY=""
    export SWITCH_SLOT_RECOVERY=false
    export bootctl_state=""
    export NEO_IMG="$TMPN/neo_inject.img"
    export ALRADY_DISABLE=false
    export install_after_ota=false
    export FLASH_IN_SUPER=false
    export FLASH_IN_VENDOR_BOOT=false
    export FLASH_IN_BOOT=false
    export SNAPSHOTCTL_STATE=""
    export languages=""
    export NAME_INJECT_NEO=neo_inject
    export NEO_VERSION="DFE NEO 2.5.x"
    export LOGNEO="$TMPN/outneo.log"
    export MAGISK_ZIP=""
    export where_to_inject_auto=""
    if [[ -n "$EXEMPLE_VERSION" ]] ; then
        NEO_VERSION="DFE-NEO $EXEMPLE_VERSION"
    fi
    # info аргументы      /\--------------------/\
}

echo "- Вывод базовой информации" &>>$LOGNEO && { # <--- обычный код
    # Версия программы
    my_print ""
    my_print "- $NEO_VERSION"
    my_print "- $word86 $WHERE_INSTALLING"
    my_print "- $word87"
    my_print ""
}

echo "- Чтение конфига и проверка его досутптности" &>>$LOGNEO && { # <--- обычный код
    export CONFIG_FILE=""

    if echo "$(basename "$ZIPARG3")" | grep -qi "extconfig"; then
        my_print "- $word88"
        if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
            CONFIG_FILE="$(dirname "$ZIPARG3")/NEO.config"
        else 
            my_print "- $word89"
        fi
    fi
    if [[ -z "$CONFIG_FILE" ]] && [[ -f "$TMPN/unzip/NEO.config" ]] ; then
        CONFIG_FILE="$TMPN/unzip/NEO.config"
    else
        my_print "- $word90"
        my_print "- $word91..."
        abort_neo -e "8.0" -m "$word93"
    fi
    my_print "- $word93"
    my_print "- $word94"

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
        if check_it "$what" "ask" || check_it "$what" "true" || check_it "$what" "false" ; then
            echo "$what fine" | log
        else
            PROBLEM_CONFIG+="$(grep "${what}=" "$CONFIG_FILE" | grep -v "#") "
        fi
    done
    if check_it "where_to_inject" "super" || check_it "where_to_inject" "auto" || check_it "where_to_inject" "vendor_boot" || check_it "where_to_inject" "boot" ; then
        echo "where_to_inject fine" | log
    else
        PROBLEM_CONFIG+="$(grep "where_to_inject=" "$CONFIG_FILE" | grep -v "#") "
    fi

    if check_it "force_start" "true" || check_it "force_start" "false" ; then
        echo "force_start fine" | log
    else
        PROBLEM_CONFIG+="$(grep "force_start=" "$CONFIG_FILE" | grep -v "#") "
    fi
    if [[ -n "$PROBLEM_CONFIG" ]] ; then
        my_print "- $word95:"
        for text in $PROBLEM_CONFIG ; do 
            my_print "   $text"
        done
        abort_neo -e 2.8 -m "$word132"
    fi
    source "$CONFIG_FILE" || abort_neo -e "8.2" -m "Не удалось считать файл конфигурации"
    my_print "- $word96"  
}

echo "- Проверка доступтности bootctl & snapshotctl" &>>$LOGNEO && { # <--- обычный код
    bootctl &>> "$LOGNEO"
    if [[ "$?" == "64" ]] ; then
        BOOTCTL_STATE=true
    else
        BOOTCTL_STATE=false
    fi
    snapshotctl &>> "$LOGNEO"
    if [[ "$?" == "64" ]] ; then
        SNAPSHOTCTL_STATE=true
    else
        SNAPSHOTCTL_STATE=false
    fi
}

echo "- Чтение пропов и определние слота" &>>$LOGNEO && { # <--- обычный код
    my_print "- $word97"
    get_current_suffix --current

    

    if [[ -n "$CURRENT_SUFFIX" ]] ; then
        my_print " "
        my_print "- $word98"
        my_print "- $word99: $OUT_MESSAGE_SUFFIX"
        export A_ONLY_DEVICE=false
    else
        my_print "- $word100"
        export A_ONLY_DEVICE=true
    fi
}

echo "- Поиск раздела super" &>>$LOGNEO && { # <--- обычный код
    my_print "- $word101"
    SUPER_BLOCK=$(find_super_partition)
    if [[ -z "$SUPER_BLOCK" ]] ; then
        my_print "- $word102"
        SUPER_DEVICE=false
    else
        my_print "- $word103:"
        my_print ">>> $SUPER_BLOCK"
        SUPER_DEVICE=true
    fi
}

echo "- Проверка устройства на поддердку если нет super и a_only устройство" &>>$LOGNEO && { # <--- обычный код
    if ! $SUPER_DEVICE && $A_ONLY_DEVICE ; then
        abort_neo -e "9.1" -m "$word133"
    fi
}

echo "- Поиск базовых блоков recovery|boot|vendor_boot и проверка для whare_to_inject" &>>$LOGNEO && { # <--- обычный код
    my_print "- $word104"
    if find_block_neo -c -b "recovery" "recovery_a" "recovery_b" ; then
        my_print "- $word105"
        RECOVERY_DEVICE=true
    else
        my_print "- $word106"
        RECOVERY_DEVICE=false
    fi
    my_print "- $word107"
    if find_block_neo -c -b "vendor_boot" "vendor_boot_a" "vendor_boot_b" ; then
        my_print "- $word108"
        VENDOR_BOOT_DEVICE=true
    else
        if ! $RECOVERY_DEVICE ; then 
            my_print "- $word109"
        else
            my_print "- $word110"
        fi
        VENDOR_BOOT_DEVICE=false
    fi

    check_whare_to_inject
}

echo "- Проверка запущенной системы и OTA статуса, переопределние слота на противоположный" &>>$LOGNEO && { # <--- обычный код
    if $SYS_STATUS ; then
        if ! $SNAPSHOTCTL_STATE ; then
            if ! $force_start ; then 
                my_print "- !! $word111"
                my_print "- $word112"
                if volume_selector "$word159" "$word160" ; then
                    echo "- продолжить установку" | log
                    get_current_suffix --current
                else
                    exit 82
                fi
            else
                abort_neo -e "81.1" -m "$word134" 
            fi
        fi
        if $SNAPSHOTCTL_STATE ; then
            SNAPSHOT_STATUS=$(snapshotctl dump 2>/dev/null | grep '^Update state:' | awk '{print $3}')
            if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
                echo "- Установка в текущую прошивку, обновления системы не обнаружено" | log
                get_current_suffix --current
            elif [[ "$SNAPSHOT_STATUS" == "initiated" ]] ; then
                abort_neo -e "83.1" -m "$word135"
            elif [[ "$SNAPSHOT_STATUS" == "unverified" ]] ; then
                my_print "- $word113"
                if ! $force_start ; then
                    my_print "- $word114"
                    if ! volume_selector "$word161" "$word162" ; then
                        abort_neo -e "83.2" -m "$word136"
                    fi
                fi
                get_current_suffix --uncurrent
            else
                abort_neo -e "83.4" -m "$word137"
            fi
        fi
    fi
}
flash_inject_neo(){
    if $FLASH_IN_SUPER ; then
        if ! flash_inject_neo_to_super ; then
            if $A_ONLY_DEVICE ; then
                abort_neo -e 182.2 -m "$word138"
            else
                FLASH_IN_SUPER=false
            fi
        else    
            FLASH_IN_VENDOR_BOOT=false
            FLASH_IN_BOOT=false
        fi
    fi
    if $FLASH_IN_VENDOR_BOOT ; then
        if flash_inject_neo_to_vendor_boot vendor_boot ; then
            FLASH_IN_BOOT=false  
        else 
            FLASH_IN_VENDOR_BOOT=false
        fi
    fi
    if $FLASH_IN_BOOT ; then
        if ! flash_inject_neo_to_vendor_boot boot ; then
            abort_neo -e 192.1 -m "$word139"
        fi
    fi
}
default_functions_for_install(){
    if $SUPER_DEVICE && ! $SYS_STATUS ; then
        update_partitions
        
    fi
    if $SYS_STATUS && mountpoint -q /vendor/etc/init/hw ; then
        umount -fl /vendor/etc/init/hw
    fi
    if ! $A_ONLY_DEVICE ; then
        my_print "- $word115: $OUT_MESSAGE_SUFFIX"
    fi
    check_dfe_neo_installing
    select_argumetns_for_install
    confirm_menu
    setup_peremens_for_rc
    mount_vendor
    move_files_from_vendor_hw
    if ! check_first_stage_fstab ; then
        if ! [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then 
            umount -fl "$full_path_to_vendor_folder"
        fi
        abort_neo -e 182.5 -m "$word140 $final_fstab_name"
    fi
    make_neo_inject_img "$TMPN/neo_inject$CURRENT_SUFFIX" "neo_inject" "${VENDOR_FOLDER}/etc/init/hw" "${VENDOR_FOLDER}/etc" || {
        abort_neo -e 36.8 -m "$word141"
    }
}

echo "- Старт установки" &>>$LOGNEO && {
    default_functions_for_install
    flash_inject_neo
    ramdisk_first_stage_patch $BOOT_PATCH
    default_post_install
    my_print " "
    my_print " "
    my_print "<-----$word116----->"
    my_print " "
    my_print " "
    my_print " "
    my_print "$word117"
    my_print " "
    my_print " "
    my_print " "
    my_print " "
    my_print " "
    my_print " "
    exit 0
}