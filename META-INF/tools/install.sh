
# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]

log(){
    if ! [[ -t 0 ]] && ! [[ "$1" == "-s" ]] ; then
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
    elif [[ "$1" == "-s" ]] ; then
    shift 1
        if [ -n "$LOGNEO" ]; then
            echo -e "##-----НАЧАЛО логирования------------>>" >> "$LOGNEO"
            echo "Лог вызван с строки: ${BASH_LINENO[0]}" >> "$LOGNEO"
            if [[ -n "$*" ]] ; then
                echo -e "Простой вывод команды текстового лога" >> "$LOGNEO"
            fi
            echo -e "|-->>> $*" >> "$LOGNEO"
            echo -e "##-----КОНЕЦ  логирования------------>>" >> "$LOGNEO"
        else
            echo "Error: LOGNEO variable is not defined."
        fi
        
    fi 
}

echo "- Определение PATH с новыми бинарниками" &>>$LOGNEO && { # <--- обычный код
    binary_pull_busubox="mv cp dirname basename grep blockdev [ [[ ps stat unzip mountpoint find echo sleep sed mkdir ls ln readlink realpath cat awk wc du df"
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
    getprop | log getprop
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
    return_message=""
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
        -r)
            if [[ -n "$2" ]] ; then
                return_message="$2"
                rounded_num=$(echo "$return_message" | awk '{printf "%.0f\n", $1}')
                shift 2
            else
                my_print "Отсутствует сообщение об ошибке после -e"
                exit 1
            fi
            ;;
        -e)
            if [[ -n "$2" ]] ; then
                error_message="$2"
                rounded_num=$(echo "$error_message" | awk '{printf "%.0f\n", $1}')
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

    if ((rounded_num < 0)); then
        error_code=0
    elif ((rounded_num > 255)); then
        error_code=255
    else
        error_code=$rounded_num
    fi

    if [[ -n "$error_message" ]] ; then
        if ! [[ "$error_code" == 0 ]] ; then
            my_print "  !!!Exiting with error: $error_message!!!"
        fi
        my_print " "
        my_print " "
        
        if [[ -f /tmp/recovery.log ]] ; then
            cat /tmp/recovery.log | log "\n\n\n ЛОГ ИЗ РЕКАВАРИ"
        fi
        date_log=$(date +"%d_%m_%y-%H-%M-%S")
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
        umount_vendor
        exit "$error_code"
    elif [[ -n "$return_message" ]] ; then
        my_print "- $word169: $return_message"
        my_print ""
        return $error_code
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
    log -s "поиск блока, аргументы $*"
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
    umount -fl /vendor
    umount -fl /system_root
    umount -fl /system_ext
    umount -fl /product
    umount -fl /odm
    for partitions in /dev/block/mapper/* ; do
        if [[ -h "$partitions" ]] && [[ -b "$(readlink -f "$partitions")" ]] ; then 
            partitions_name="$(basename "$partitions")"
            if ! [[ "$partitions_name" == userdata ]] ; then
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
                        umount -fl "$TMPN/check_partitions/${partitions}$check_suffix" | log "umount -fl "$TMPN/check_partitions/${partitions}$check_suffix""
                        lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --unmap "${partitions}$check_suffix" | log "lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --unmap "${partitions}$check_suffix""
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
                if ! $FORCE_START ; then 
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
                mount $TMPN/bootconfig_new /proc/bootconfig | log "mount $TMPN/bootconfig_new /proc/bootconfig"
            fi
            if grep "androidboot.slot_suffix=$CURRENT_SUFFIX" /proc/cmdline || grep "androidboot.slot=$CURRENT_SUFFIX" /proc/cmdline ; then
                my_print "- $word9"
                edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot_suffix='$CURRENT_SUFFIX'/androidboot.slot_suffix='$FINAL_ACTIVE_SUFFIX'/' | sed 's/androidboot.slot='$CURRENT_SUFFIX'/androidboot.slot='$FINAL_ACTIVE_SUFFIX'/')"
                echo -e "$edit_text" > $TMPN/cmdline_new 
                mount $TMPN/cmdline_new /proc/cmdline | log "mount $TMPN/cmdline_new /proc/cmdline"
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
    
    if [[ $HIDE_NOT_ENCRYPTED == "ask" ]] ; then
        my_print " "
        my_print "- $word11"
        my_print "- **$word12"
        if volume_selector "$word144" "$word145" ; then
            HIDE_NOT_ENCRYPTED=true
        else
            HIDE_NOT_ENCRYPTED=false
        fi
    fi
    if [[ $SAFETY_NET_FIX_PATCH == "ask" ]] ; then
        my_print " "
        my_print "- $word13"
        my_print "- **$word12"
        if volume_selector "$word144" "$word145" ; then
            SAFETY_NET_FIX_PATCH=true
        else
            SAFETY_NET_FIX_PATCH=false
        fi
    fi
    if $SYS_STATUS ; then
        WIPE_DATA_AFTER_INSTALL=false
    else
        if [[ $WIPE_DATA_AFTER_INSTALL == "ask" ]] ; then
            my_print " "
            my_print "- $word14"
            if volume_selector "$word146" "$word147" ; then
                WIPE_DATA_AFTER_INSTALL=true
            else
                WIPE_DATA_AFTER_INSTALL=false
            fi
        fi
    fi
    if [[ $REMOVE_LOCKSCREEN_INFO == "ask" ]] ; then
        my_print " "
        my_print "- $word15"
        if volume_selector "$word146" "$word147" ; then
            REMOVE_LOCKSCREEN_INFO=true
        else
            REMOVE_LOCKSCREEN_INFO=false
        fi
    fi
    if [[ $MOUNT_FSTAB_EARLY_TOO == "ask" ]] ; then
        my_print " "
        my_print "- $word16"
        my_print "- **$word17"
        if volume_selector "$word148" "$word149" ; then
            MOUNT_FSTAB_EARLY_TOO=true
        else
            MOUNT_FSTAB_EARLY_TOO=false
        fi
    fi
    if [[ $DISABLE_VERITY_VBMETA_PATCH == "ask" ]] ; then
        my_print " "
        my_print "- $word18"
        my_print "- **$word19"
        if volume_selector "$word150" "$word147" ; then
            DISABLE_VERITY_VBMETA_PATCH=true
        else
            DISABLE_VERITY_VBMETA_PATCH=false
        fi
    fi

    if [[ $ZYGISK_TURN_ON_IN_BOOT == "ask" ]] ; then
        my_print " "
        my_print "- $word20"
        my_print "- **$word21"
        if volume_selector "$word151" "$word152" ; then
            ZYGISK_TURN_ON_IN_BOOT=true
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
            ZYGISK_TURN_ON_IN_BOOT=false
        fi
    elif [[ "$ZYGISK_TURN_ON_IN_BOOT" == "first_time_boot" ]] || [[ "$ZYGISK_TURN_ON_IN_BOOT" == "always_on_boot" ]] ; then
        zygisk_turn_on_parm=$ZYGISK_TURN_ON_IN_BOOT
        ZYGISK_TURN_ON_IN_BOOT=true
    fi
    if [[ $INJECT_CUSTOM_DENYLIST_IN_BOOT == "ask" ]] ; then
        my_print " "
        my_print "- $word25"
        my_print "- **$word26"
        if volume_selector "$word151" "$word152" ; then
            INJECT_CUSTOM_DENYLIST_IN_BOOT=true
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
            INJECT_CUSTOM_DENYLIST_IN_BOOT=false
        fi
    elif [[ "$INJECT_CUSTOM_DENYLIST_IN_BOOT" == "first_time_boot" ]] || [[ "$INJECT_CUSTOM_DENYLIST_IN_BOOT" == "always_on_boot" ]] ; then
        add_custom_deny_list_parm=$INJECT_CUSTOM_DENYLIST_IN_BOOT
        INJECT_CUSTOM_DENYLIST_IN_BOOT=true
    fi
}; export -f select_argumetns_for_install

mount_vendor(){ # <--- Определение функции [Аругментов нет]
    my_print "- $word27"
    VENDOR_BLOCK=""
    log -s запуск функции mount_vendor
    if [[ "$SNAPSHOT_STATUS" == "unverified" ]] && $SUPER_DEVICE ; then
        if snapshotctl map &>> "$LOGNEO" ; then
            if [[ -h "/dev/block/mapper/vendor$CURRENT_SUFFIX" ]] ; then
                VENDOR_BLOCK="/dev/block/mapper/vendor$CURRENT_SUFFIX"
                my_print "- $word28: $(basename $(readlink $VENDOR_BLOCK))"
            else
                abort_neo -e 124.2 -m "$word120: vendor$CURRENT_SUFFIX"
            fi
        else
            abort_neo -e 124.1 -m "$word121"
        fi
    elif ! $SUPER_DEVICE; then
        VENDOR_BLOCK="$(find_block_neo -b "vendor$CURRENT_SUFFIX")"
        my_print "- $word29"
        my_print "- $word30: $(basename $VENDOR_BLOCK)"
    elif $SUPER_DEVICE ; then
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
        for f in $(mount | grep $(readlink $VENDOR_BLOCK) | awk '{print $3}') $(mount | grep $VENDOR_BLOCK | awk '{print $3}') $VENDOR_BLOCK ; do
            umount -fl "${f}" | log "umount -fl "${f}""
            umount -fl "${f}" | log "umount -fl "${f}""
            umount -fl "${f}" | log "umount -fl "${f}""
        done
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
    for boot in $WHERE_NEO_ALREADY_INSTALL_NEOv1 ; do

        name_boot_patch_neov1=$boot
        install_boot_neov1=$(find_block_neo -b "$boot")
        mkdir -pv "$TMPN/neov1_$name_boot_patch_neov1"
        boot_dir_neov1="$TMPN/neov1_$name_boot_patch_neov1"
        cd $boot_dir_neov1
        magiskboot unpack $install_boot_neov1
        if ! [[ -f $boot_dir_neov1/ramdisk.cpio ]] ; then
            abort_neo -r 195.1 -m "$word170"
        fi
        compress_ramdisk_neov1=""
        if ! magiskboot cpio $boot_dir_neov1/ramdisk.cpio ; then
            magiskboot decompress $boot_dir_neov1/ramdisk.cpio $boot_dir_neov1/ramdisk2.cpio > $boot_dir_neov1/log.decompress
            rm -f $boot_dir_neov1/ramdisk.cpio
            mv $boot_dir_neov1/ramdisk2.cpio $boot_dir_neov1/ramdisk.cpio
            compress_ramdisk_neov1=$(grep "Detected format:" $boot_dir_neov1/log.decompress | sed 's/.*\[\(.*\)\].*/\1/')
            if ! magiskboot cpio $boot_dir_neov1/ramdisk.cpio ; then
                abort_neo -r 195.2 -m "$word171"
            fi 
        fi
        remove_files="overlay.d/sbin/neov1bin/sqlite3 "
        remove_files+="overlay.d/sbin/neov1bin/denylist.txt "
        remove_files+="overlay.d/sbin/neov1bin/magisk.db "
        remove_files+="overlay.d/sbin/neov1bin/magisk "
        remove_files+="overlay.d/sbin/neov1bin/init.sh "
        remove_files+="overlay.d/sbin/neov1bin "
        remove_files+="overlay.d/init_neov1.rc "

        for file in $remove_files ; do
            if magiskboot cpio ramdisk.cpio "exists $file" ; then 
                magiskboot cpio ramdisk.cpio "rm -r $file"
            fi
        done
        cd $boot_dir_neov1
        if [[ -n "$compress_ramdisk_neov1" ]] ; then
            magiskboot compress="${compress_ramdisk_neov1}" "$boot_dir_neov1/ramdisk.cpio" "$boot_dir_neov1/ramdisk.compress.cpio" | log
            rm -f "$boot_dir_neov1/ramdisk.cpio"
            mv "$boot_dir_neov1/ramdisk.compress.cpio" "$boot_dir_neov1/ramdisk.cpio"
        fi
        magiskboot repack $install_boot_neov1
        cat new-boot.img > $install_boot_neov1


    done
    for boot in $WHERE_NEO_ALREADY_INSTALL; do
        log -s распаковка $boot
        ramdisk_compress_format=""
        block_boot=$(find_block_neo -b "$boot")
        log -s блок $boot $block_boot
        path_check_boot="$TMPN/check_boot_neo/$boot"
        
        mkdir -pv $path_check_boot | log
        cd "$path_check_boot"
        
        magiskboot unpack -h "$block_boot" | log "Распаковка ramdisk.cpio $boot"
        if [[ -f "ramdisk.cpio" ]] ; then
            mkdir -pv  $path_check_boot/ramdisk_files | log
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
                    magiskboot cpio "$path_check_boot/ramdisk.cpio" "add 777 ${fstab//$path_check_boot\/ramdisk_files\//} $fstab" | log "magiskboot cpio $path_check_boot/ramdisk.cpio add 777 ${fstab//$path_check_boot\/ramdisk_files\//} $fstab"
                    need_repack=true
                fi
            done
            if $need_repack ; then
                cd $path_check_boot
                if [[ -n "$ramdisk_compress_format" ]] ; then
                    log -s запаковка обратно
                    magiskboot compress="${ramdisk_compress_format}" "$path_check_boot/ramdisk.cpio" "$path_check_boot/ramdisk.compress.cpio" | log "magiskboot compress=${ramdisk_compress_format} $path_check_boot/ramdisk.cpio $path_check_boot/ramdisk.compress.cpio"
                    rm -f "$path_check_boot/ramdisk.cpio"
                    mv "$path_check_boot/ramdisk.compress.cpio" "$path_check_boot/ramdisk.cpio"
                fi
                log -s запись в  $block_boot
                magiskboot repack $block_boot | log "magiskboot repack $block_boot"
                blockdev --setrw $block_boot | log "blockdev --setrw $block_boot"
                cat $path_check_boot/new-boot.img > $block_boot
            fi
        fi
        cd "$TMPN"
        rm -rf $path_check_boot
    done
    if $LEGACY_ALREADY_INSTALL ; then
        mount_vendor
        mount -o rw,remount $full_path_to_vendor_folder
        for file in sqlite3 magisk magisk.db init.sh denylist.txt ; do
            rm -f $full_path_to_vendor_folder/etc/init/hw/$file
        done
        for file in $full_path_to_vendor_folder/etc/fstab* ; do
            if [[ -f $(dirname $file)/backup.$(basename $file) ]] ; then
                rm -f $file
                mv $(dirname $file)/backup.$(basename $file) $file
            fi
        done
        for file in "$full_path_to_vendor_folder"/etc/init/hw/*.rc ; do
            if grep -q "# DFE-NEO-INITS_LINES" "$file"; then
                sed -i '/# DFE-NEO-INITS_LINES/d' "$file"
            fi
        done
        
    fi
    my_print "- $word33"


}; export -f remove_dfe_neo

check_dfe_neo_installing(){ # <--- Определение функции [Аругментов нет]
    if ! $FORCE_START; then
        my_print "- $word44"
        export DETECT_NEO_IN_BOOT=false
        export LEGACY_ALREADY_INSTALL=false
        export DETECT_NEO_IN_SUPER=false
        export DETECT_NEO_IN_VENDOR_BOOT=false
        export NEO_ALREADY_INSTALL=false
        export NEOV1_ALREADY_INSTALL=false
        export WHERE_NEO_ALREADY_INSTALL_NEOv1=""
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
        
        cd "$TMPN" 
        for boot_check in "vendor_boot$CURRENT_SUFFIX" "boot$CURRENT_SUFFIX" "ramdisk$CURRENT_SUFFIX" "recovery_ramdisk$CURRENT_SUFFIX" "init_boot$CURRENT_SUFFIX" "ramdisk" "recovery_ramdisk" "kern-a" ; do
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
                            if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>> "$LOGNEO" ; then
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
                    if [[ -f $path_check_boot/ramdisk_files/overlay.d/init_neov1.rc ]] && [[ -d $path_check_boot/ramdisk_files/overlay.d/sbin/neov1bin ]] ; then
                        NEO_ALREADY_INSTALL=true
                        NEOV1_ALREADY_INSTALL=true
                        WHERE_NEO_ALREADY_INSTALL_NEOv1+=" $boot_check"
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
        if $NEOV1_DFE && ! $NEOV2_DFE && ! $DFE_LEGACY ; then
            pass
        else
            mount_vendor
            for file in $full_path_to_vendor_folder/etc/fstab* ; do
                if [[ -f $(dirname $file)/backup.$(basename $file) ]] ; then
                    NEO_ALREADY_INSTALL=true
                    LEGACY_ALREADY_INSTALL=true 
                    umount_vendor
                    break
                fi
            done
        fi
        if $NEO_ALREADY_INSTALL ; then
            my_print " "
            my_print " "
            my_print "- $word163:"
        fi
        if $NEOV1_ALREADY_INSTALL ; then
            my_print "- $word164:"
        fi
        if [[ -n "$WHERE_NEO_ALREADY_INSTALL_NEOv1" ]] ; then
            for whare_patch_ramdisk_neov1 in $WHERE_NEO_ALREADY_INSTALL_NEOv1 ; do
                my_print "    $whare_patch_ramdisk_neov1"
            done
        fi
        if $LEGACY_ALREADY_INSTALL ; then 
            my_print "- $word165"
        fi
        if $DETECT_NEO_IN_BOOT || $DETECT_NEO_IN_SUPER || $DETECT_NEO_IN_VENDOR_BOOT ; then
            my_print "- $word166:"
        fi
        if $DETECT_NEO_IN_SUPER ; then
            my_print "    super"
        fi
        if $DETECT_NEO_IN_BOOT ; then
            my_print "    boot${UNCURRENT_SUFFIX}"
        fi
        if $DETECT_NEO_IN_VENDOR_BOOT ; then
            my_print "    vendor_boot${UNCURRENT_SUFFIX}"
        fi
        if [[ -n "$WHERE_NEO_ALREADY_INSTALL" ]] ; then
            my_print "- $word167:"
            for whare_patch_ramdisk_neov2 in $WHERE_NEO_ALREADY_INSTALL ; do
                my_print "    $whare_patch_ramdisk_neov2"
            done
        fi
        if $NEO_ALREADY_INSTALL ; then
            if $NEOV1_DFE && ! $NEOV2_DFE && ! $DFE_LEGACY && ! [[ "$INSTALL_MAGISK" == false ]] ; then
                my_print "- $word168"
            else
                my_print "- $word47"
            fi
        
            if ! volume_selector "$word155" "$word156" ; then  
                remove_dfe_neo
                abort_neo -e 0 -m "DFE-NEO Removed succes"
            fi
        fi
    fi


}; export -f check_dfe_neo_installing

setup_peremens_for_rc(){ # <--- Определение функции [Аругментов нет]

    add_init_target_rc_line_init="on init # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_early_fs="on early-fs # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_postfs="on post-fs-data # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_boot_complite="on property:sys.boot_completed=1 # DFE-NEO-INITS_LINES"

    add_init_target_rc_line_init_neov1="on init # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_init_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh fstab_patch"
    add_init_target_rc_line_early_fs_neov1="on early-fs # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_postfs_neov1="on post-fs-data # DFE-NEO-INITS_LINES"
    add_init_target_rc_line_boot_complite_neov1="on property:sys.boot_completed=1 # DFE-NEO-INITS_LINES"

    if [[ -n $CUSTOM_SETPROP ]] ; then 

            for PARMS_RESET in $CUSTOM_SETPROP ; do  
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
                        add_init_target_rc_line_init_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                    elif $add_early_fs ; then 
                        add_init_target_rc_line_early_fs_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_early_fs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_early_fs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_early_fs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                    elif $add_post_fs_data ; then 
                        add_init_target_rc_line_postfs_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_postfs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_postfs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_postfs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                    elif $add_boot_completed ; then 
                        add_init_target_rc_line_boot_complite_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_boot_complite+="\n    exec - system system -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                        add_init_target_rc_line_boot_complite+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh custom_reset_prop \"${PARMS_RESET%%=*}\" \"${PARMS_RESET#*=}\" # DFE-NEO-INITS_LINES"
                    fi
                fi
            done
    
            
    fi
    if $SAFETY_NET_FIX_PATCH ; then
        add_init_target_rc_line_init_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh safetynet_init # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_init # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_init # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_init # DFE-NEO-INITS_LINES"

        add_init_target_rc_line_early_fs_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh safetynet_fs # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_early_fs+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_fs # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_early_fs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_fs # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_early_fs+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_fs # DFE-NEO-INITS_LINES"
        
        add_init_target_rc_line_postfs_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh safatynet_postfs # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_postfs+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safatynet_postfs # DFE-NEO-INITS_LINES"

        add_init_target_rc_line_boot_complite_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh safetynet_boot_complite # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_boot_complite+="\n    exec - system system -- /vendor/etc/init/hw/init.sh safetynet_boot_complite # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh safetynet_boot_complite # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_boot_complite+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh safetynet_boot_complite # DFE-NEO-INITS_LINES"
    fi
    if $HIDE_NOT_ENCRYPTED ; then
        add_init_target_rc_line_init_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh hide_decrypted # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec - system system -- /vendor/etc/init/hw/init.sh hide_decrypted # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh hide_decrypted # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_init+="\n    exec u:r:su:s0 root root -- /vendor/etc/init/hw/init.sh hide_decrypted # DFE-NEO-INITS_LINES"
    fi
    if $ZYGISK_TURN_ON_IN_BOOT ; then
        add_init_target_rc_line_early_fs_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh zygisk_on_$zygisk_turn_on_parm # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_early_fs+="\n    exec_background u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh zygisk_on_$zygisk_turn_on_parm # DFE-NEO-INITS_LINES"
    fi
    if $INJECT_CUSTOM_DENYLIST_IN_BOOT ; then
        add_init_target_rc_line_boot_complite_neov1+="\n    exec u:r:magisk:s0 root root -- \${MAGISKTMP}/neov1bin/init.sh add_deny_list_$add_custom_deny_list_parm # DFE-NEO-INITS_LINES"
        add_init_target_rc_line_boot_complite+="\n    exec u:r:magisk:s0 root root -- /vendor/bin/sh /vendor/etc/init/hw/init.sh add_deny_list_$add_custom_deny_list_parm # DFE-NEO-INITS_LINES"
    fi


}; export -f setup_peremens_for_rc

confirm_menu(){ # <--- Определение функции [Аругментов нет]
    my_print " "
    my_print " "
    my_print " "
    my_print "- $word48:"
    my_print "- $word49: $LANGUAGE"
    my_print "- $word172:"
    for mathod_now in $order_method_auto ; do
        case "$mathod_now" in
            neov1)
                my_print "- $word173"
            ;;
            neov2)
                my_print "- $word174"
                if [[ "$WHERE_TO_INJECT" == "auto" ]] ; then
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
                elif [[ "$WHERE_TO_INJECT" == "super" ]] ; then
                    if $A_ONLY_DEVICE ; then
                        my_print ">>>> super"
                    else
                        my_print ">>>> super < ${CURRENT_SUFFIX} < slot"
                    fi
                else 
                    my_print ">>>> ${WHERE_TO_INJECT}${UNCURRENT_SUFFIX}" 
                fi
            ;;
            legacy)
                my_print "- $word175" 
            ;;
        esac
    done

    my_print "- $word52: $MOUNT_FSTAB_EARLY_TOO"
    my_print "- SafetyNetFix: $SAFETY_NET_FIX_PATCH"
    my_print "- $word53: $HIDE_NOT_ENCRYPTED"
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- $word54: $ZYGISK_TURN_ON_IN_BOOT"
    else
        my_print "- $word54: $ZYGISK_TURN_ON_IN_BOOT/$zygisk_turn_on_parm"
    fi
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- $word55: $INJECT_CUSTOM_DENYLIST_IN_BOOT"
    else
        my_print "- $word55: $INJECT_CUSTOM_DENYLIST_IN_BOOT/$add_custom_deny_list_parm"
    fi   
    echo "- Проверка доступтности magisk" &>>$LOGNEO && {
        case $INSTALL_MAGISK in
            "EXT:"* | "ext:"* | "Ext:"*)
                INSTALL_MAGISK="$(echo ${INSTALL_MAGISK} | sed "s/ext://I")"
                if [[ -f "$(dirname "${ZIPARG3}")/${INSTALL_MAGISK}" ]]; then
                    my_print "- $word56: $INSTALL_MAGISK"
                    MAGISK_ZIP="$(dirname "${ZIPARG3}")/${INSTALL_MAGISK}"
                
                else
                    my_print "- $word57"
                    INSTALL_MAGISK=false
                fi
                ;;
            *)
                if [[ -f "$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.apk" ]]; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.apk"
                    my_print "-  $word56: $INSTALL_MAGISK"
                elif [[ -f "$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.zip" ]] ; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.zip"
                    my_print "-  $word56: $INSTALL_MAGISK"
                else
                    my_print "- $word57"
                    INSTALL_MAGISK=false
                fi
                ;;
        esac 
    } 
    my_print "- $word58: $WIPE_DATA_AFTER_INSTALL"
    my_print "- $word59: $REMOVE_LOCKSCREEN_INFO"
    my_print "- $word60: $FSTAB_PATCH_PATERNS"
    if [[ -z "$CUSTOM_SETPROP" ]] ; then
        my_print "- CUSTOM_SETPROP: none"
    else
        my_print "- CUSTOM_SETPROP: $CUSTOM_SETPROP"
    fi
    my_print " "
    my_print " "
    if ! $FORCE_START ; then
        my_print "- $word61"
        if ! volume_selector "$word157" "$word158" ; then 
            abort_neo -e 200 -m "Вы вышли из программы"
        fi
    fi


}; export -f confirm_menu

add_custom_rc_line_to_inirc_and_add_files(){ # <--- Определение функции передается $1 файл куда сделать запись
    if $SAFETY_NET_FIX_PATCH || $HIDE_NOT_ENCRYPTED || $INJECT_CUSTOM_DENYLIST_IN_BOOT || $ZYGISK_TURN_ON_IN_BOOT || [[ -n $CUSTOM_SETPROP ]] ; then
        my_print "- $word62"
        if $INJECT_CUSTOM_DENYLIST_IN_BOOT || $ZYGISK_TURN_ON_IN_BOOT ; then
            cp $TMPN/unzip/META-INF/tools/magisk.db "$2/" 
            my_print ">>>> magisk.db"
            cp $TMPN/unzip/META-INF/tools/denylist.txt "$2/"
            my_print ">>>> denylist.txt"
            cp $TOOLS/sqlite3 "$2/"
            my_print ">>>> sqlite3 binary"
            chmod 777 "$2/sqlite3"
            chmod 777 "$2/magisk.db"
            chmod 777 "$2/denylist.txt"
        fi
        my_print ">>>> magisk binary"
        cp $TOOLS/magisk "$2/"
        my_print ">>>> init.sh"
        cp $TMPN/unzip/META-INF/tools/init.sh "$2/"
        chmod 777 "$2/init.sh"
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
            if [[ "$output_fstab" == "fstab\*" ]] ; then
                exit 192
            fi
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

move_fstab_from_original_vendor_and_patch(){ # <--- Определение функции [Аругментов нет]
    original_fstab_name_for="$(basename "$1")"
    full_path_to_fstab_into_for="$1"
    my_print ">> $word68: $original_fstab_name_for"
    
    if [[ -f "$full_path_to_fstab_into_for" ]] && grep "/userdata" "$full_path_to_fstab_into_for" | grep "latemount" | grep -v "#" &>> "$LOGNEO" ; then
        my_print "- $word66"
        if [[ -f "$TMPN/neo_inject${CURRENT_SUFFIX}/$original_fstab_name_for" ]] ; then
            return 20
        else
            my_print "- $word67:"
            my_print "*> neo_inject${CURRENT_SUFFIX}/$original_fstab_name_for"
            cp -afc "$full_path_to_fstab_into_for" "$TMPN/neo_inject${CURRENT_SUFFIX}/$original_fstab_name_for"
            patch_fstab_neo $FSTAB_PATCH_PATERNS -f "$full_path_to_fstab_into_for" -o "$TMPN/neo_inject${CURRENT_SUFFIX}/$original_fstab_name_for"
            return 10
        fi
    fi
        
    return 30
    

}; export -f move_fstab_from_original_vendor_and_patch

move_files_from_vendor_hw(){ # <--- Определение функции [Аругментов нет]

    echo "- Определение ro_haedware and fstab_suffix" &>>$LOGNEO && { # <--- обычный код
        if [[ "$FSTAB_EXTENSION" == "auto" ]] ; then
            FSTAB_EXTENSION=""
        fi
        if [[ -z "$FSTAB_EXTENSION" ]] ; then 
            hardware_boot=$(getprop ro.hardware)
        else
            hardware_boot="$FSTAB_EXTENSION"
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
        mkdir -pv $TMPN/neo_inject${CURRENT_SUFFIX} | log
        mkdir -pv "$TMPN/neo_inject${CURRENT_SUFFIX}/lost+found" | log
        cp -afc ${VENDOR_FOLDER}/etc/init/hw/* $TMPN/neo_inject${CURRENT_SUFFIX}/
    }
    
    echo "- Поиск fstab по .rc файлам" &>>$LOGNEO && { # <--- обычный код
        fstab_names_check=""
        for file_find in "$TMPN/neo_inject${CURRENT_SUFFIX}"/*.rc ; do
            if grep "mount_all" $file_find | grep "\-\-late" | grep -v "#" &>> "$LOGNEO" ; then

                fstab_lines_all=$(grep mount_all $file_find | grep "\-\-late" | grep -v "#" | sort -u)
                if [[ "$default_fstab_prop" == default ]] ; then
                    default_fstab_prefixx="fstab.$hardware_boot fstab.$default_fstab_prop fstab.$(getprop ro.product.device)"
                else
                    default_fstab_prefixx="fstab.$hardware_boot fstab.$default_fstab_prop fstab.$(getprop ro.product.device) fstab.default"
                fi
                while IFS= read -r while_line_fstab; do
                    if echo "$while_line_fstab" | grep "mount_all --late" | grep -v "#" &>> "$LOGNEO" ; then
                        echo 11 | log
                        for fstab_needed_patch in $default_fstab_prefixx; do
                            echo 12 | log
                            if ! echo "$fstab_names_check" | grep $fstab_needed_patch &>>$LOGNEO ; then
                                fstab_names_check+="$fstab_needed_patch "
                            fi
                            move_fstab_from_original_vendor_and_patch "$full_path_to_vendor_folder/etc/$fstab_needed_patch"
                            return_error="$?"
                            case "$return_error" in
                            10|20)
                                if [[ "$return_error" == "10" ]] ; then
                                    final_fstab_name+="$fstab_needed_patch "
                                fi
                                sed -i '/^    mount_all --late$/s/.*/    mount_all \/vendor\/etc\/init\/hw\/fstab.'$hardware_boot' --late/g' "$file_find"
                                $MOUNT_FSTAB_EARLY_TOO && sed -i '/^    mount_all --early$/s/.*/    mount_all \/vendor\/etc\/init\/hw\/fstab.'$hardware_boot' --early/g' $file_find
                                last_init_rc_file_for_write=$file_find
                            ;;
                            esac
                        done
                        
                    else
                        fstab_base_name__SS=$(basename "$(echo "$while_line_fstab" | awk '{print $2}')")
                        if echo "$fstab_base_name__SS" | grep "\\$" &>>$LOGNEO ; then
                            echo 14 | log
                            fstab_base_name__SS=""
                            for file in $default_fstab_prefixx ; do
                                if [[ -f $full_path_to_vendor_folder/etc/$file ]] ; then
                                    fstab_base_name__SS="$file"
                                    break
                                fi
                            done
                            [[ -z "$fstab_base_name__SS" ]] && exit 81
                        fi
                        echo 17 | log
                        if ! echo "$fstab_names_check" | grep $fstab_base_name__SS &>>$LOGNEO ; then
                            fstab_names_check+="$fstab_base_name__SS "
                        fi
                        new_path_fstab="$(echo "$while_line_fstab" | sed "s|[^ ]*fstab[^ ]*|/vendor/etc/init/hw/$fstab_base_name__SS|")"
                        move_fstab_from_original_vendor_and_patch "$full_path_to_vendor_folder/etc/$fstab_base_name__SS"
                        return_error="$?"
                        case "$return_error" in
                            10|20)
                                if [[ "$return_error" == "10" ]] ; then
                                    final_fstab_name+="$fstab_base_name__SS " 
                                fi
                                sed -i "s|$while_line_fstab|$new_path_fstab|g" "$file_find"
                                last_init_rc_file_for_write=$file_find
                                if $MOUNT_FSTAB_EARLY_TOO ; then
                                    sed -i "s|${while_line_fstab//"--late"/"--early"}|${new_path_fstab//"--late"/"--early"}|g" "$file_find"
                                fi
                            ;;
                        esac
                        
                    fi  
                done <<< "$fstab_lines_all"
            fi
        done
        if [[ -z "$final_fstab_name" ]] || [[ "$final_fstab_name" == "" ]] ; then
            abort_neo -r 36.1 -m "$word126 /vendor/etc/[${fstab_names_check// /\|}]"
        fi
        add_custom_rc_line_to_inirc_and_add_files "$last_init_rc_file_for_write" "$TMPN/neo_inject${CURRENT_SUFFIX}" 
    }

}; export -f move_files_from_vendor_hw

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
                    if ! magiskboot cpio "$boot_check_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
                        continue
                    fi
                    
                fi
                    find_args=""
                    ls | log "Содержимое папки $boot_check_folder"
                    for needed_add_find_arg in $final_fstab_name ; do
                        if [[ -z "$find_args" ]] ; then 
                            find_args="-name $needed_add_find_arg"
                        else
                            find_args+=" -or -name $needed_add_find_arg"
                        fi
                    done
                    for fstab in $(find "$boot_check_folder/ramdisk_folder/" $find_args); do
                        if grep -w "/system" $fstab | grep "first_stage_mount" &>> "$LOGNEO" ; then
                            BOOT_PATCH+="$boot "
                        fi
                    done
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
            abort_neo -r 91.5 -m "Somthing wrong"
        fi
        
        if ! magiskboot cpio "$boot_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
            my_print "- $word35"
            magiskboot decompress "$boot_folder/ramdisk.cpio" "$boot_folder/ramdisk.d.cpio" &>$boot_folder/log.decompress
            rm -f "$boot_folder/ramdisk.cpio"
            mv "$boot_folder/ramdisk.d.cpio" "$boot_folder/ramdisk.cpio"
            ramdisk_compress_format=$(grep "Detected format:" $boot_folder/log.decompress | sed 's/.*\[\(.*\)\].*/\1/')
        fi
        if [[ -n "$ramdisk_compress_format" ]] ; then
            if ! magiskboot cpio "$boot_folder/ramdisk.cpio" extract &>> "$LOGNEO" ; then
                abort_neo -r 91.6 -m "Somthing wrong"
            fi
        fi
        find_args=""
        for needed_add_find_arg in $final_fstab_name ; do
            if [[ -z "$find_args" ]] ; then 
                find_args="-name $needed_add_find_arg"
            else
                find_args+=" -or -name $needed_add_find_arg"
            fi
        done
        for fstab in $(find "$boot_folder/ramdisk_folder/" $find_args); do
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

check_whare_to_inject(){ # <--- Определение функции [Аругментов нет]      
    if [[ "$WHERE_TO_INJECT" == "auto" ]] ; then
        if $SUPER_DEVICE ; then
            FLASH_IN_SUPER=true
        fi
        if ! $A_ONLY_DEVICE && $VENDOR_BOOT_DEVICE ; then
            FLASH_IN_VENDOR_BOOT=true
        fi
        if ! $A_ONLY_DEVICE; then
            FLASH_IN_BOOT=true
        fi
    elif [[ "$WHERE_TO_INJECT" == "super" ]] ; then
        if $SUPER_DEVICE ; then
            FLASH_IN_SUPER=true
        else
            abort_neo -e 71.4 -m "$word128"
        fi
    elif [[ "$WHERE_TO_INJECT" == "boot" ]] ; then
        if ! $A_ONLY_DEVICE; then
            FLASH_IN_BOOT=true
            echo "- не A-only wahre to inject" | log
        else
            abort_neo -e 71.3 -m "$word129"
        fi
    elif [[ "$WHERE_TO_INJECT" == "vendor_boot" ]] ; then
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
    
    if [[ "$2" == "neo_inject" ]] ; then
        MAKEING_IMG_NAME="$NEO_IMG"
    else
        MAKEING_IMG_NAME="$TMPN/$2.img"
    fi
    make_ext4fs -J -T 1230764400 -S "${FILE_CONTEXTS_FILE}" -l $PRESIZE_IMG_FODLER -C "${FS_CONFIG_FILE}" -a "${LABLE}" -L "${LABLE}" "$MAKEING_IMG_NAME" "${TARGET_DIR}" | log

    resize2fs -M -f "$MAKEING_IMG_NAME" | log
    resize2fs -M -f "$MAKEING_IMG_NAME" | log
    resize2fs -M -f "$MAKEING_IMG_NAME" | log
    resize2fs -M -f "$MAKEING_IMG_NAME" | log
    if [[ "$2" == "neo_inject" ]] ; then
        resize2fs -f "$MAKEING_IMG_NAME" "$(($(stat -c%s "$MAKEING_IMG_NAME")*2/512))"s | log
    fi
    if $SYS_STATUS && [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then
        echo "- Системный vendor" | log
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
    if [[ -e "/dev/block/mapper/neo_inject$CURRENT_SUFFIX" ]] && $SYS_STATUS ; then
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
        resize2fs -M -f "$NEO_IMG" | log
        resize2fs -M -f "$NEO_IMG" | log
        resize2fs -M -f "$NEO_IMG" | log
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
                my_print "- $word84 super"
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

default_post_install(){ # <--- Определение функции
    if $DISABLE_VERITY_VBMETA_PATCH ; then 
        my_print "- $word81"
        ALRADY_DISABLE=true
        avbctl --force disable-verification | log
        avbctl --force disable-verity | log
    fi
    mountpoint -q /data || mount /data | log
    mountpoint -q /data && {
        if $REMOVE_LOCKSCREEN_INFO; then
            my_print "- $word82"
            rm -f /data/system/locksettings*
        fi
        if $WIPE_DATA_AFTER_INSTALL; then
            my_print "- $word83"
            find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
        fi
    }
    if ! [[ "$INSTALL_MAGISK" == false ]]; then
        my_print " "
        my_print "- $word56:"
        my_print " "
        my_print " "
        [[ -z "$MAGISK_ZIP" ]] && {
            if [[ -f "$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.apk" ]]; then
                MAGISK_ZIP="$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.apk"
            elif [[ -f "$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.zip" ]]; then
                MAGISK_ZIP="$TMPN/unzip/MAGISK/${INSTALL_MAGISK}.zip"
            fi
        }

        [[ -n "$MAGISK_ZIP" ]] && {

            if ! $A_ONLY_DEVICE && $SNAPSHOTCTL_STATE && ! [[ $SNAPSHOT_STATUS == "none" ]] ; then
                mkdir -pv $TMPN/backup_boot/ | log 
                cat "$(find_block_neo "boot$UNCURRENT_SUFFIX")" > $TMPN/backup_boot/boot$UNCURRENT_SUFFIX.img
                blockdev --setrw "$(find_block_neo "boot$UNCURRENT_SUFFIX")" | log blockdev-log "boot$UNCURRENT_SUFFIX"
                blockdev --setrw "$(find_block_neo "boot$CURRENT_SUFFIX")" | log blockdev-log "boot$CURRENT_SUFFIX"
                cat "$(find_block_neo "boot$CURRENT_SUFFIX")" > "$(find_block_neo "boot$UNCURRENT_SUFFIX")"
            fi
            mkdir -pv $TMPN/$INSTALL_MAGISK | log
            cd $TMPN/$INSTALL_MAGISK 
            unzip "$MAGISK_ZIP" | log
            bash $TMPN/$INSTALL_MAGISK/META-INF/com/google/android/update-binary "$ZIPARG1" "$ZIPARG2" "$MAGISK_ZIP"
            if ! $A_ONLY_DEVICE && $SNAPSHOTCTL_STATE && ! [[ $SNAPSHOT_STATUS == "none" ]] ; then
                blockdev --setrw "$(find_block_neo "boot$UNCURRENT_SUFFIX")" | log blockdev-log "boot$UNCURRENT_SUFFIX"
                blockdev --setrw "$(find_block_neo "boot$CURRENT_SUFFIX")" | log blockdev-log "boot$CURRENT_SUFFIX"
                cat "$(find_block_neo "boot$UNCURRENT_SUFFIX")" > "$(find_block_neo "boot$CURRENT_SUFFIX")" 
                cat $TMPN/backup_boot/boot$UNCURRENT_SUFFIX.img > "$(find_block_neo "boot$UNCURRENT_SUFFIX")"
            fi
        }
        my_print " "
        my_print " "
    fi
    if [[ -f /tmp/recovery.log ]] ; then
        cat /tmp/recovery.log | log "\n\n\n ЛОГ ИЗ РЕКАВАРИ"
    fi
    date_log=$(date +"%d_%m_%y-%H-%M-%S")
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
}; export -f default_post_install

flash_inject_neo_to_vendor_boot(){ # <--- Определение функции
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

check_support_dfe_methodts(){ # <--- Определение функции
    if $NEOV2_DFE || $NEOV1_DFE || $LEGACY_DFE ; then
        for check_argumets_dfe_method in $order_method_auto ; do
            return 0
        done
        return 1
    else
        return 1
    fi
}

echo "- Определение языка" &>>$LOGNEO && { # <--- обычный код
    # lng.sh аргументы    \/--------------------\/
    for number in {1..250} ; do 
        export word${number}=""
    done
    # lng.sh аргументы    /\--------------------/\
    if echo "$(basename "$ZIPARG3")" | busybox grep -qi "extconfig"; then
        if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
                LANGUAGE="$(grep "LANGUAGE=" "$(dirname "$ZIPARG3")/NEO.config")"
                LANGUAGE=${LANGUAGE#*"="}
        else
            LANGUAGE="$(grep "LANGUAGE=" "$TMPN/unzip/NEO.config")"
            LANGUAGE=${LANGUAGE#*"="}
        fi
    else
        LANGUAGE="$(grep "LANGUAGE=" "$TMPN/unzip/NEO.config")"
        LANGUAGE=${LANGUAGE#*"="}
    fi
    if ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$LANGUAGE/$LANGUAGE.sh" ]] ; then
        my_print "- $LANGUAGE.sh language file not found. English will be used"
        LANGUAGE=en
        ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$LANGUAGE/$LANGUAGE.sh" ]] && {
            abort_neo -e "23.27" -m "English language file not found, WHAT THE FUCK????"
        }
    fi
    sed -i 's/\r$//' "$TMPN/unzip/META-INF/tools/languages/$LANGUAGE/$LANGUAGE.sh"
    source "$TMPN/unzip/META-INF/tools/languages/$LANGUAGE/$LANGUAGE.sh" || abort_neo -e "23.31" -m "Failed to read language file"
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
    export LANGUAGE=""
    export FORCE_START=""
    export FSTAB_EXTENSION=""
    export DISABLE_VERITY_VBMETA_PATCH=""
    export HIDE_NOT_ENCRYPTED=""
    export CUSTOM_SETPROP=""
    export INJECT_CUSTOM_DENYLIST_IN_BOOT=""
    export ZYGISK_TURN_ON_IN_BOOT=""
    export LEGACY_DFE=false
    export NEOV1_DFE=false
    export NEOV2_DFE=false
    export SAFETY_NET_FIX_PATCH=""
    export REMOVE_LOCKSCREEN_INFO=""
    export WIPE_DATA_AFTER_INSTALL=""
    export MOUNT_FSTAB_EARLY_TOO=""
    export FSTAB_PATCH_PATERNS=""
    export WHERE_TO_INJECT=""
    export INSTALL_MAGISK=""
    # NEO.config аргументы /\--------------------/\
    # info аргументы      \/--------------------\/\
    export DFE_LEGACY=false
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
    true_false_ask="DISABLE_VERITY_VBMETA_PATCH "
    true_false_ask+="HIDE_NOT_ENCRYPTED "
    true_false_ask+="SAFETY_NET_FIX_PATCH "
    true_false_ask+="REMOVE_LOCKSCREEN_INFO "
    true_false_ask+="WIPE_DATA_AFTER_INSTALL "
    true_false_ask+="MOUNT_FSTAB_EARLY_TOO "

    for what in "ZYGISK_TURN_ON_IN_BOOT" "INJECT_CUSTOM_DENYLIST_IN_BOOT" ; do
        if check_it "$what" "ask" || check_it "$what" "false" || check_it "$what" "first_time_boot" || check_it "$what" "always_on_boot" ; then
            echo "$what fine" | log
        else
            PROBLEM_CONFIG+="$(grep "${what}=" "$CONFIG_FILE" | grep -v "#") "
        fi
    done
    for what in $true_false_ask ; do 
        if check_it "$what" "ask" || check_it "$what" "true" || check_it "$what" "false" ; then
            echo "$what fine" | log
        else
            PROBLEM_CONFIG+="$(grep "${what}=" "$CONFIG_FILE" | grep -v "#") "
        fi
    done
    if check_it "WHERE_TO_INJECT" "super" || check_it "WHERE_TO_INJECT" "auto" || check_it "WHERE_TO_INJECT" "vendor_boot" || check_it "WHERE_TO_INJECT" "boot" ; then
        echo "WHERE_TO_INJECT fine" | log
    else
        PROBLEM_CONFIG+="$(grep "WHERE_TO_INJECT=" "$CONFIG_FILE" | grep -v "#") "
    fi
    if check_it "DFE_METHOD" "auto-1" || \
                    check_it "DFE_METHOD" "auto-2" || \
                    check_it "DFE_METHOD" "auto-3" || \
                    check_it "DFE_METHOD" "auto-4" || \
                    check_it "DFE_METHOD" "auto-5" || \
                    check_it "DFE_METHOD" "auto-6" || \
                    check_it "DFE_METHOD" "neov2"  || \
                    check_it "DFE_METHOD" "neov1"  || \
                    check_it "DFE_METHOD" "legacy"
    then
        echo "DFE_METHOD fine" | log
    else
        PROBLEM_CONFIG+="$(grep "DFE_METHOD=" "$CONFIG_FILE" | grep -v "#") "
    fi

    if check_it "FORCE_START" "true" || check_it "FORCE_START" "false" ; then
        echo "FORCE_START fine" | log
    else
        PROBLEM_CONFIG+="$(grep "FORCE_START=" "$CONFIG_FILE" | grep -v "#") "
    fi
    if [[ -n "$PROBLEM_CONFIG" ]] ; then
        my_print "- $word95:"
        for text in $PROBLEM_CONFIG ; do 
            my_print "   $text"
        done
        abort_neo -e 2.8 -m "$word132"
    fi
    sed -i 's/\r$//' "$CONFIG_FILE"
    source "$CONFIG_FILE" || abort_neo -e "8.2" -m "Не удалось считать файл конфигурации"
    set +e
    my_print "- $word96"  
}

echo "- Определние метода DFE" &>>$LOGNEO && { # <--- обычный код

    case "$DFE_METHOD" in 
        auto-1)
            order_method_auto="legacy neov2 neov1"
            NEOV2_DFE=true ; NEOV1_DFE=true ; LEGACY_DFE=true
        ;;
        auto-2)
            order_method_auto="neov2 legacy neov1"
            NEOV2_DFE=true ; NEOV1_DFE=true ; LEGACY_DFE=true
        ;;
        auto-3)
            order_method_auto="neov2 neov1"
            NEOV2_DFE=true ; NEOV1_DFE=true
        ;;
        auto-4)
            order_method_auto="neov2 legacy"
            NEOV2_DFE=true ; LEGACY_DFE=true
        ;;
        auto-5)
            order_method_auto="legacy neov2"
            NEOV2_DFE=true ; LEGACY_DFE=true
        ;;
        auto-6)
            order_method_auto="legacy neov1"
            NEOV1_DFE=true ; LEGACY_DFE=true
        ;;
        legacy)
            order_method_auto="legacy"
            LEGACY_DFE=true
        ;;
        neov1)
            order_method_auto="neov1"
            NEOV1_DFE=true
        ;;
        neov2)
            order_method_auto="neov2"
            NEOV2_DFE=true
        ;;
    esac
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
        if snapshotctl dump | grep '^Update state:' &>> "$LOGNEO" ; then 
            SNAPSHOTCTL_STATE=true
        else 
            SNAPSHOTCTL_STATE=false
        fi
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

echo "- Проверка устройства на поддержку если нет super и a_only устройство" &>>$LOGNEO && { # <--- обычный код
    if ! $SUPER_DEVICE && $A_ONLY_DEVICE ; then
        NEOV2_DFE=false
        order_method_auto="${order_method_auto/neov2/}"
        check_support_dfe_methodts || abort_neo -e 140.1 -m "$word176"
        # abort_neo -e "9.1" -m "$word133"
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
    if $NEOV2_DFE ; then
        check_whare_to_inject
    fi
}

echo "- Проверка запущенной системы и OTA статуса, переопределние слота на противоположный" &>>$LOGNEO && { # <--- обычный код
    if $SYS_STATUS ; then
        if ! $SNAPSHOTCTL_STATE ; then
            if ! $FORCE_START ; then 
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
            if ! [[ "$SNAPSHOT_STATUS" == "none" ]]; then
                LEGACY_DFE=false
                order_method_auto=${order_method_auto/legacy/}
                check_support_dfe_methodts || abort_neo -e 140.2 -m "$word177"
            fi
            if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
                echo "- Установка в текущую прошивку, обновления системы не обнаружено" | log
                get_current_suffix --current
            elif [[ "$SNAPSHOT_STATUS" == "initiated" ]] ; then
                abort_neo -e "83.1" -m "$word135"
            elif [[ "$SNAPSHOT_STATUS" == "unverified" ]] ; then
                my_print "- $word113"
                if ! $FORCE_START ; then
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
                abort_neo -r 182.2 -m "$word138"
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
            abort_neo -r 192.1 -m "$word139"
        fi
    fi
}

first_installing_detect_current_slot(){
    if $SUPER_DEVICE && ! $SYS_STATUS ; then
        update_partitions
        
    fi
    if $SYS_STATUS && mountpoint -q /vendor/etc/init/hw ; then
        umount -fl /vendor/etc/init/hw
        for fstab_umount in /systemm/etc/*fstab* /vendor/etc/*fstab* /*fstab* /odm/etc/*fstba* ; do
            if [[ -f $fstab_umount ]] ; then
                umount -fl $fstab_umount
            fi
        done
    
    fi
    if ! $A_ONLY_DEVICE ; then
        my_print "- $word115: $OUT_MESSAGE_SUFFIX"
    fi
}

second_select_args_and_setup_rc_and_map_vendor(){
    my_print " "
    select_argumetns_for_install
    my_print " "
    confirm_menu
    my_print " " 
    setup_peremens_for_rc
    my_print " "
    
}

check_rw(){
    if touch "$1/test_file" ; then
        rm -f "$1/test_file"
        return 0
    else
        [[ -f "$1/test_file" ]] && {
           rm -f "$1/test_file" 
        }
        return 1
    fi
}
check_free_size(){
    if (( $(df "$1" | wc -l) == 2 )) ; then
        check_free_data=$(df "$1" | tail -n1 | awk '{print int($4)}')
    elif (( $(df "$1" | wc -l) == 3 )) ; then
        check_free_data=$(df "$1" | tail -n1 | awk '{print int($3)}')
    fi
    if (( $check_free_data * 1024 > "$2" )) ; then
        return 0
    else
        return 1
    fi
}

try_expand_image(){
    if $SUPER_DEVICE ; then
        block_check="/dev/block/mapper/$1"
        if $A_ONLY_DEVICE ; then
            lptools_args_try_expand_image="--super $SUPER_BLOCK"
        else
            lptools_args_try_expand_image="--super $SUPER_BLOCK --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX"
        fi
    else
        block_check="$(find_block_neo -b "$1")"
    fi
    
    if tune2fs -l $block_check &>>$LOGNEO ; then
        umount_vendor
        if tune2fs -l $block_check | grep "Filesystem features" | grep -q "shared_blocks"  ; then
            if $SUPER_DEVICE ; then
                if lptools_new $lptools_args_try_expand_image --resize "$1" $(awk 'BEGIN{print int('$(blockdev --getsize64 $block_check)'*1.3)}') &>>$LOGNEO ; then
                    if ! e2fsck -y -E unshare_blocks $block_check &>>$LOGNEO ; then 
                        abort_neo -r 192.79 -m "$word178"
                    fi
                else
                    cat $block_check > "$TMPN/$1.img"
                    resize2fs -f $TMPN/$1.img $(awk 'BEGIN{print int('$(stat -c%s $TMPN/$1.img)'*1.3)/512}')s | log
                    if e2fsck -y -E unshare_blocks $TMPN/$1.img &>>$LOGNEO ; then 
                        resize2fs -M -f $TMPN/$1.img 
                        resize2fs -M -f $TMPN/$1.img 
                        resize2fs -M -f $TMPN/$1.img 
                        resize2fs -M -f $TMPN/$1.img 
                        resize2fs -f $TMPN/$1.img $(awk 'BEGIN{print int(('$(stat -c%s $TMPN/$1.img)'+52428800)/512)}')s 
                        if lptools_new $lptools_args_try_expand_image --resize "$1" "$(stat -c%s $TMPN/$1.img)" &>>$LOGNEO ; then
                            cat $TMPN/$1.img > $block_check
                            rm -f "$TMPN/$1.img"
                            return 0
                        else
                            rm -f "$TMPN/$1.img"
                            abort_neo -r 192.77 -m "$word179"
                        fi
                    else
                        rm -f "$TMPN/$1.img"
                        abort_neo -r 192.7 -m "$word178"
                    fi
                fi
            else
                if resize2fs -f $TMPN/$1.img $(awk 'BEGIN{print int('$(blockdev --getsize64 $block_check)'*1.3/512)}')s &>>$LOGNEO ; then
                    if ! e2fsck -y -E unshare_blocks $block_check &>>$LOGNEO ; then 
                        abort_neo -r 192.78 -m "$word178"
                    fi
                else
                    cat $block_check > "$TMPN/$1.img"
                    if e2fsck -y -E unshare_blocks $TMPN/$1.img &>>$LOGNEO ; then 
                        resize2fs -M -f $TMPN/$1.img | log
                        resize2fs -M -f $TMPN/$1.img | log
                        resize2fs -M -f $TMPN/$1.img | log
                        resize2fs -M -f $TMPN/$1.img | log
                        resize2fs -f $TMPN/$1.img $(awk 'BEGIN{print int(('$(stat -c%s $TMPN/$1.img)'+52428800)/512)}')s | log
                        if (( "$(blockdev --getsize64 $block_check)" >= "$(stat -c%s $TMPN/$1.img)" )) ; then
                            cat $TMPN/$1.img > $block_check
                            rm -f "$TMPN/$1.img"
                            return 0
                        else
                            rm -f "$TMPN/$1.img"
                            abort_neo -r 192.81 -m "$word180"
                        fi
                    else
                        rm -f "$TMPN/$1.img"
                        abort_neo -r 192.7 -m "$word178"
                    fi

                fi
            fi
        else
            if $SUPER_DEVICE ; then
                size_img_block_dev="$(( $(tune2fs -l $block_check | grep 'Block count:' | awk '{print $3}') * $(tune2fs -l $block_check | grep 'Block size:' | awk '{print $3}') ))"
                if ! resize2fs -f $block_check $(awk 'BEGIN{print int(('$size_img_block_dev'+41943040)/512)}')s &>>$LOGNEO ; then
                    if lptools_new $lptools_args_try_expand_image --resize "$1" $(awk 'BEGIN{print int('$(blockdev --getsize64 $block_check)'+52428800)}') &>>$LOGNEO ; then 
                        if ! resize2fs -f $block_check $(awk 'BEGIN{print int(('$(blockdev --getsize64 $block_check)'+52428800)/512)}')s &>>$LOGNEO ; then
                            abort_neo -r 192.121 -m "$word180"
                        fi 
                        return 0
                    else
                        abort_neo -r 192.124 -m "$word180"
                    fi
                fi
                if e2fsck -fy $block_check &>>$LOGNEO ; then
                    return 0
                else
                    if lptools_new $lptools_args_try_expand_image --resize "$1" "$(($(tune2fs -l $block_check | grep 'Block count:' | awk '{print $3}') * $(tune2fs -l $block_check | grep 'Block size:' | awk '{print $3}')))" &>>$LOGNEO ; then 
                        e2fsck -fy $block_check | log
                    else
                        resize2fs -M -f $block_check | log
                        lptools_new $lptools_args_try_expand_image --resize "$1" "$(($(tune2fs -l $block_check | grep 'Block count:' | awk '{print $3}') * $(tune2fs -l $block_check | grep 'Block size:' | awk '{print $3}')))" | log
                        abort_neo -r 192.146 -m "$word180"
                    fi
                fi
            else
                if ! resize2fs -f $block_check $(awk 'BEGIN{print int(('$(blockdev --getsize64 $block_check)'+52428800)/512)}')s | log ; then
                    abort_neo -r 192.126 -m "$word180"
                fi
            fi
        fi
    else
        case $1 in 
            *$CURRENT_SUFFIX) 
                name_final_partitions="${1%"$CURRENT_SUFFIX"*}"
            ;;
            *)
                name_final_partitions="${1}"
            ;;
        esac
        make_neo_inject_img "$full_path_to_vendor_folder" "${name_final_partitions}"
        umount_vendor
        resize2fs -f $TMPN/$name_final_partitions.img $(awk 'BEGIN{print int(('$(stat -c%s $TMPN/$name_final_partitions.img)'+52428800)/512)}')s | log
        if $SUPER_DEVICE ; then
            if lptools_new $lptools_args_try_expand_image --resize "$1" $(stat -c%s $TMPN/$name_final_partitions.img) &>>$LOGNEO ; then
                cat $TMPN/$name_final_partitions.img > $block_check
                return 0
            else
                abort_neo -r 192.3 -m "$word181"
            fi
        else
            if (( "$(blockdev --getsize64 $block_check)" >= "$(stat -c%s $TMPN/$name_final_partitions1.img)" )) ; then
                cat $TMPN/$name_final_partitions.img > $block_check
                return 0
            else 
                abort_neo -r 192.32 -m "$word181"
            fi 
        fi    
        
    fi
    # elif dump.erofs $block_check &>>$LOGNEO ; then
    #     block_fs=erofs
    # else
    #     block_fs=f2fs
    # fi
    return 0
    
    
    
    

}

umount_vendor(){
    if $SYS_STATUS && [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then
        echo ""
    else 
        umount "$full_path_to_vendor_folder"
        umount /vendor
    fi
}

install_neov2_method(){ # <- Функйия по установке NEOv2 методота, возвращает 0/1 в случае успеха или проавала
    mount_vendor
    move_files_from_vendor_hw || return 1
    if ! check_first_stage_fstab ; then
        abort_neo -r 182.5 -m "$word140 $final_fstab_name"
    fi
    make_neo_inject_img "$TMPN/neo_inject$CURRENT_SUFFIX" "neo_inject" "${VENDOR_FOLDER}/etc/init/hw" "${VENDOR_FOLDER}/etc" || {
        abort_neo -r 36.8 -m "$word141"
    }
    flash_inject_neo || return 1
    ramdisk_first_stage_patch $BOOT_PATCH || return 1
}
install_legacy_method(){
    eed_remove_legacy_method_before=false
    mount_vendor
    mkdir -pv $TMPN/fstabs_files/ 
    if $LEGACY_ALREADY_INSTALL ; then
        my_print "$word182"
        mount -o rw,remount $full_path_to_vendor_folder
        for file in sqlite3 magisk magisk.db init.sh denylist.txt ; do
            rm -f $full_path_to_vendor_folder/etc/init/hw/$file
        done
        for file in $full_path_to_vendor_folder/etc/fstab* ; do
            if [[ -f $(dirname $file)/backup.$(basename $file) ]] ; then
                rm -f $file
                mv $(dirname $file)/backup.$(basename $file) $file
            fi
        done
        for file in "$full_path_to_vendor_folder"/etc/init/hw/*.rc ; do
            if grep -q "# DFE-NEO-INITS_LINES" "$file"; then
                sed -i '/# DFE-NEO-INITS_LINES/d' "$file"
            fi
        done
        
    fi
    for fstab_legacy in "$full_path_to_vendor_folder"/etc/fstab* ; do
        patch_fstab_neo $FSTAB_PATCH_PATERNS -f "$fstab_legacy" -o "$TMPN/fstabs_files/$(basename $fstab_legacy)"     
    done
    mount -o rw,remount "$full_path_to_vendor_folder"
    if ! check_free_size "$full_path_to_vendor_folder" 47185920 || ! check_rw "$full_path_to_vendor_folder" ; then
        my_print "- $word183"
        my_print "- $word184"
        if ! $SYS_STATUS ; then
            try_expand_image "vendor$CURRENT_SUFFIX" || return 1
        else
            abort_neo -r 192.5 -m "$word185"
        fi
    fi
    umount_vendor
    mount_vendor
    mount -o rw,remount "$full_path_to_vendor_folder"
    for fstab_legacy in $TMPN/fstabs_files/* ; do
        cp "$full_path_to_vendor_folder/etc/$(basename $fstab_legacy)" "$full_path_to_vendor_folder/etc/backup.$(basename $fstab_legacy)"
        cat $fstab_legacy > $full_path_to_vendor_folder/etc/$(basename $fstab_legacy)
    done
    for file_rc in $full_path_to_vendor_folder/etc/init/hw/*.rc ; do 
        if cat $file_rc | grep "mount_all" | grep -v "#" | grep "\-\-late" ; then
            add_custom_rc_line_to_inirc_and_add_files "$file_rc" "$full_path_to_vendor_folder/etc/init/hw" 
            break
        fi
    done
    umount_vendor
    return 0
}
patch_boot_neov1(){
    for boot in $@ ; do
        if find_block_neo -c -b "$boot" ; then
            install_boot_neov1=$(find_block_neo -b "$boot")
            name_boot_patch_neov1=$boot
            break
        fi
    done
    my_print "- $word186: $name_boot_patch_neov1"
    my_print "- $word187"
    mkdir -pv "$TMPN/neov1_$name_boot_patch_neov1" | log
    boot_dir_neov1="$TMPN/neov1_$name_boot_patch_neov1"
    cd $boot_dir_neov1
    magiskboot unpack $install_boot_neov1 | log
    if ! [[ -f $boot_dir_neov1/ramdisk.cpio ]] ; then
        abort_neo -r 195.1 -m "$word188"
    fi
    compress_ramdisk_neov1=""
    if ! magiskboot cpio $boot_dir_neov1/ramdisk.cpio ; then
        magiskboot decompress $boot_dir_neov1/ramdisk.cpio $boot_dir_neov1/ramdisk2.cpio > $boot_dir_neov1/log.decompress
        rm -f $boot_dir_neov1/ramdisk.cpio | log
        mv $boot_dir_neov1/ramdisk2.cpio $boot_dir_neov1/ramdisk.cpio
        compress_ramdisk_neov1=$(grep "Detected format:" $boot_dir_neov1/log.decompress | sed 's/.*\[\(.*\)\].*/\1/')
        if ! magiskboot cpio $boot_dir_neov1/ramdisk.cpio &>>$LOGNEO ; then
            abort_neo -r 195.2 -m "$word171"
        fi 
    fi
    for file in "overlay.d" "overlay.d/sbin" "overlay.d/sbin/neov1bin" ; do
        if ! magiskboot cpio ramdisk.cpio "exists $file" &>>$LOGNEO ; then 
            magiskboot cpio ramdisk.cpio "mkdir 0777 $file" | log
        fi
    done
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/magisk.db $TMPN/unzip/META-INF/tools/magisk.db" | log
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/denylist.txt $TMPN/unzip/META-INF/tools/denylist.txt" | log
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/sqlite3 $TOOLS/sqlite3" | log
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/magisk $TOOLS/magisk" | log
    sed -i 's|^FSTAB_PATCH_PATERNS=.*|FSTAB_PATCH_PATERNS="'"$FSTAB_PATCH_PATERNS"'"|' "$TMPN/unzip/META-INF/tools/init.sh" | log
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/init.sh $TMPN/unzip/META-INF/tools/init.sh" | log
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/sbin/neov1bin/bash $TOOLS/bash" | log 
    echo -e "${add_init_target_rc_line_init_neov1}\n" >> "$TMPN/init_neov1.rc"
    echo -e "${add_init_target_rc_line_early_fs_neov1}\n" >> "$TMPN/init_neov1.rc"
    echo -e "${add_init_target_rc_line_postfs_neov1}\n" >> "$TMPN/init_neov1.rc"
    echo -e "${add_init_target_rc_line_boot_complite_neov1}\n" >> "$TMPN/init_neov1.rc"
    magiskboot cpio ramdisk.cpio "add 0777 overlay.d/init_neov1.rc $TMPN/init_neov1.rc" | log
    cd $boot_dir_neov1
    if [[ -n "$compress_ramdisk_neov1" ]] ; then
        my_print "- $word41 $compress_ramdisk_neov1"
        magiskboot compress="${compress_ramdisk_neov1}" "$boot_dir_neov1/ramdisk.cpio" "$boot_dir_neov1/ramdisk.compress.cpio" | log
        rm -f "$boot_dir_neov1/ramdisk.cpio" | log
        mv "$boot_dir_neov1/ramdisk.compress.cpio" "$boot_dir_neov1/ramdisk.cpio"
    fi
    magiskboot repack $install_boot_neov1 | log
    cat new-boot.img > $install_boot_neov1
}
install_neov1_method(){
    get_current_suffix --current
    case $OUT_MESSAGE_SUFFIX in 
        _a|_b) 
            if ! [[ "$INSTALL_MAGISK" == false ]] ; then
                patch_boot_neov1 "ramdisk$CURRENT_SUFFIX recovery_ramdisk$CURRENT_SUFFIX init_boot$CURRENT_SUFFIX boot$CURRENT_SUFFIX ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a" || return 1 
            else
                patch_boot_neov1 "ramdisk$CURRENT_SUFFIX recovery_ramdisk$CURRENT_SUFFIX init_boot$CURRENT_SUFFIX boot$CURRENT_SUFFIX ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a" || return 1 
                patch_boot_neov1 "ramdisk$UNCURRENT_SUFFIX recovery_ramdisk$UNCURRENT_SUFFIX init_boot$UNCURRENT_SUFFIX boot$UNCURRENT_SUFFIX ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a" || return 1
            fi
        ;;
        *) 
            patch_boot_neov1 "ramdisk$CURRENT_SUFFIX recovery_ramdisk$CURRENT_SUFFIX init_boot$CURRENT_SUFFIX boot$CURRENT_SUFFIX ramdisk recovery_ramdisk kern-a android_boot kernel bootimg init_boot boot lnx boot_a" || return 1
        ;;
    esac  
}

echo "- Старт установки" &>>$LOGNEO && {
    my_print "$NEOV1_DFE:$NEOV2_DFE:$DFE_LEGACY:$INSTALL_MAGISK"
    if $NEOV1_DFE && ! $NEOV2_DFE && ! $DFE_LEGACY && ! [[ "$INSTALL_MAGISK" == false ]] ; then
        get_current_suffix --current
    else
        first_installing_detect_current_slot
        my_print " "
    fi
    check_dfe_neo_installing
    my_print " "
    second_select_args_and_setup_rc_and_map_vendor
    my_print " "
    complited_installed_dfe=false
    for mathod_now in $order_method_auto ; do
        case "$mathod_now" in
            neov1)
                my_print "У\n- $word189"
                if install_neov1_method ; then
                    my_print " "
                    my_print " "
                    my_print "- $word190"
                    complited_installed_dfe=true
                    break
                fi 
            ;;
            neov2)
                my_print "\n- $word191"
                if install_neov2_method ; then
                    my_print " "
                    my_print " "
                    my_print "- $word192"
                    complited_installed_dfe=true
                    break
                fi 
            ;;
            legacy)
                my_print "\n- $word193"
                if install_legacy_method ; then
                    my_print " "
                    my_print " "
                    my_print "- $word194"
                    complited_installed_dfe=true
                    break
                fi 
            ;;
        esac
    done
    if ! $complited_installed_dfe ; then
        if $SYS_STATUS && [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then 
            echo ""
        else
            umount -fl "$full_path_to_vendor_folder"
        fi
        abort_neo -e 193 -m "$word195"
    fi
    
    
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