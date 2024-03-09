<<<<<<< HEAD
#!/bin/bash

export TOOLS=$TMP_TOOLS/binary/$ARCH
export LD_LIBRARY_PATH=$TMP_TOOLS/binary/$ARCH:$LD_LIBRARY_PATH

# DONT TOUCH IT!! 
remove_pin=false       # true / false
wipe_data=false        # true / false
magisk=false
where_to_inject=false
where_to_inject_auto=""
MAGISK_ZIP=""
NEO_VERSION="DFE NEO 2.5.x"
LOGNEO="$TMPN/outneo.log"

if [[ -n "$EXEMPLE_VERSION" ]] ; then
    NEO_VERSION="DFE-NEO $EXEMPLE_VERSION"
fi


if echo "$(basename "$ZIPARG3")" | $TOOLS/busybox grep -qi "extconfig"; then
    if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
            languages="$(grep "languages=" "$(dirname "$ZIPARG3")/NEO.config")"
            languages=${languages#*"="}
    else
        languages="$(grep "languages=" "$TMPN/unzip/NEO.config" )"
        languages=${languages#*"="}
    fi
else
    languages="$(grep "languages=" "$TMPN/unzip/NEO.config" )"
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





my_out_print(){
        
    ALL_WORDS="$1"
    ALL_WORDS=${ALL_WORDS// /"--SPACE--"}
    if [[ -n "$TERMINAL_SIZE" ]] ; then
        MAXLEN=$(( $TERMINAL_SIZE - 3 ))
    else
        MAXLEN=45
    fi
    case "$languages" in
        zh|hi)
            MAXLEN=$(( $MAXLEN / 2 ))
        ;;
    esac
    if [[ -n "$2" ]] && [[ "$2" == "-s" ]] ; then 
        FIRST_LINE=false
        NULL_FIRST_LINE=true
    else
        FIRST_LINE=true
        NULL_FIRST_LINE=false
    fi
    while true ; do
        if $FIRST_LINE ; then
            case "$out_words" in 
                "- "*)
                    FIRST_LINE_WORD=""
                ;;
                "-"*)
                    FIRST_LINE_WORD=" "
                ;;
                *)
                    FIRST_LINE_WORD="- "
                ;;
            esac
        else 
            if $NULL_FIRST_LINE ; then
                FIRST_LINE_WORD=""
            else
                FIRST_LINE_WORD="  "
            fi
        fi
        if (( $( echo -n "$out_words" | wc -m ) > $MAXLEN )) ; then
            if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                echo -e "ui_print ${FIRST_LINE_WORD}${out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
            else
                echo -e "${FIRST_LINE_WORD}${out_words}"
            fi
            FIRST_LINE=false
            out_words=""
        else
            bak_out_words=$out_words
            if [[ "$ALL_WORDS" == "${ALL_WORDS%%"--SPACE--"*}" ]] ; then
                if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                    echo -e "ui_print ${FIRST_LINE_WORD}$ALL_WORDS\nui_print" >>"/proc/self/fd/$ZIPARG2"
                else
                    echo -e "${FIRST_LINE_WORD}$ALL_WORDS"
                fi
                break
            fi
            
            out_words+="${ALL_WORDS%%"--SPACE--"*} "
            if (( $( echo -n "$out_words" | wc -m ) > $MAXLEN + 3 )) ; then
                if [[ -z $bak_out_words ]] ; then 
                    if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                        echo -e "ui_print ${FIRST_LINE_WORD}${out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
                    else
                        echo -e "${FIRST_LINE_WORD}${out_words}"
                    fi
                    FIRST_LINE=false
                    ALL_WORDS="${ALL_WORDS#*"--SPACE--"}"
                else
                    if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                        echo -e "ui_print ${FIRST_LINE_WORD}${bak_out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
                        else
                        echo -e "${FIRST_LINE_WORD}${bak_out_words}"
                    fi
                    FIRST_LINE=false
                fi
                out_words=""
            else
                ALL_WORDS="${ALL_WORDS#*"--SPACE--"}"
            fi
        fi
    done

}

<<<<<<< HEAD
my_print() {
<<<<<<< HEAD
<<<<<<< HEAD
    case $WHEN_INSTALLING in
        kernelsu)
            ui_print "$1"
        ;;
        magiskapp)
            echo -e "$1"
        ;;
        recovery)
            echo -e "ui_print $1\nui_print" >>"/proc/self/fd/$ZIPARG2"
        ;;
    esac
=======
    $SYS_STATUS && {
        echo -e "$@"
    } || {
        local input_message_ui="$@"
        local IFS=$'\n'
        while read -r line_print; do
            echo -e "ui_print $line_print\nui_print" >>"/proc/self/fd/$ZIPARG2"
        done <<<"$input_message_ui"
    }
>>>>>>> 320717a (Синхронизация с master)
=======
    case $WHEN_INSTALLING in
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
>>>>>>> 49c4a5d (fist_stable start on kernelsu)
}
export -f my_print

abort_neo() {
    local message="" error_message="" exit_code=0
    while [ $# -gt 0 ]; do
        case "$1" in
        -m)
            [ -n "$2" ] && {
                message="$2"
                shift 2
            } || {
                my_print "$word46"
                exit 1
            }
            ;;
        -e)
            [[ -n "$2" ]] && {
                error_message="$2"
                shift 2
            } || {
                my_print "$word47"
                exit 1
            }
            ;;
        *)
            my_print "$word48 $1"
            exit 1
            ;;
        esac
    done
    [[ -n "$message" ]] && {
        my_print " "
        my_print " "
        my_print "- $message"
    }

    local num="$error_message"
    rounded_num=$(echo "$num" | awk '{printf "%.0f\n", $1}')
    if ((rounded_num < 0)); then
        error_code=0
    elif ((rounded_num > 255)); then
        error_code=255
    else
        error_code=$rounded_num
    fi

    [[ -n "$error_message" ]] && {
        [ -n "$word42" ] && {
            my_print "  !!!$word42: $error_message!!!"
        } || {
            my_print "  !!!Exiting with error: $error_message!!!"
        }
        
        my_print " "
        my_print " "
        if [[ -f /tmp/recovery.log ]] ; then
            echo -e "\n\n\n\n\n\n\n\nRECOVERYLOGTHIS:\n\n"
            cat /tmp/recovery.log &>$LOGNEO
        fi
        exit "$error_code"
    }
}
export -f abort_neo

patch_fstab_neo() { 
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
                            echo "No patterns provided for removal." &>$LOGNEO
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
            echo "Unknown parameter: $1" &>$LOGNEO
            exit 1
            ;;
        esac
    done

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
                echo "comment line $line" &>$LOGNEO
            ;;
            *)
                if [ "$($TOOLS/toybox echo "$removepattern" | wc -w)" -gt 0 ]; then
                    for arrp in $removepattern ; do
                        mountpoint=${arrp%%"--m--"*}
                        patterns=${arrp##*"--m--"}
                        remove_paterns=$(echo -e ${patterns//"--p--"/"\n"} | grep "\-\-r--")
                        replace_patterns=$(echo -e ${patterns//"--r--"/"\n"} | grep "\-\-p--")
                        if [ "$($TOOLS/toybox echo "$line" | awk '{print $2}')" == "$mountpoint" ]; then
                            my_print "- $word43 '$mountpoint'"
                            for replace_pattern in ${replace_patterns//"--p--"/ } ; do
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" ; then
                                    my_print "- $word44 ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$($TOOLS/toybox echo "$line" | $TOOLS/toybox sed -E "s/,${replace_pattern%%"--to--"*}*[^[:space:]|,]*/,${replace_pattern##*"--to--"}/")
                                fi
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" && ! (echo "$line" | grep -q "${replace_pattern##*"--to--"}"); then 
                                    my_print "- $word44 ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$($TOOLS/toybox echo "$line" | $TOOLS/toybox sed -E "s/${replace_pattern%%"--to--"*}*[^[:space:]|,]*/${replace_pattern##*"--to--"}/")
                                fi 
                            done
                            for remove_pattern in ${remove_paterns//"--r--"/ }; do
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- $word45 ${remove_pattern}"
                                    line=$($TOOLS/toybox echo "$line" | $TOOLS/toybox sed -E "s/,${remove_pattern}*[^[:space:]|,]*//")
                                fi
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- $word45 ${remove_pattern}"
                                    line=$($TOOLS/toybox echo "$line" | $TOOLS/toybox sed -E "s/${remove_pattern}*[^[:space:]|,]*//")
                                fi
                            done
                        fi
=======
>>>>>>> 485a1d7 (.)




find_block_neo() {
    local found_blocks=()
    local block_names=()
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
                found_blocks+=("$(readlink /dev/block/by-name/$block)")
            fi
        elif [ -b /dev/block/mapper/$block ]; then
            if ! [ -h "$(readlink /dev/block/mapper/$block)" ] && [ -b "$(readlink /dev/block/mapper/$block)" ]; then
                found_blocks+=("$(readlink /dev/block/mapper/$block)")
            fi
        elif [ -h /dev/block/bootdevice/by-name/$block ]; then
            if ! [ -h "$(readlink /dev/block/bootdevice/by-name/$block)" ] && [ -b "$(readlink /dev/block/bootdevice/by-name/$block)" ]; then
                found_blocks+=("$(readlink /dev/block/bootdevice/by-name/$block)")
            fi
        fi
    done
    if [[ -z "$found_blocks" ]] ; then
     return 1 
    else
     if $check_status_o ; then
      return 0
     else
      echo "${found_blocks[@]}"
     fi
    fi
}
export -f find_block_neo

=======
# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
>>>>>>> 09d7e2e (Фиксация от 05.03 23:31)

<<<<<<< HEAD
<<<<<<< HEAD
check_config() {
    local CONFIG_NEO="$1"
    if [[ "$(grep "force_start=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]]; then
        if grep -w "force_start=false" "$CONFIG_NEO" &>$LOGNEO ; then
            check_true_false_only=false    
        elif grep -w "force_start=true" "$CONFIG_NEO" &>$LOGNEO ; then 
            check_true_false_only=true
        else
            abort_neo -e 22.1 -m "The config is configured incorrectly. Line force_start="
        fi
    else
        abort_neo -e 22.2 -m "The config is configured incorrectly. More than one line force_start="
    fi
    for text in zygisk_turn_on add_custom_deny_list; do
        if [[ "$(grep "${text}=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]]; then
            if $check_true_false_only ; then
                if grep -w "${text}=false" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=first_time_boot" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=always_on_boot" "$CONFIG_NEO" &>$LOGNEO; then
                    continue
                else
                    abort_neo -e 22.1 -m "The config is configured incorrectly. Line ${text}="
                fi
            else
                if grep -w "${text}=false" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=ask" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=first_time_boot" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=always_on_boot" "$CONFIG_NEO" &>$LOGNEO; then
                    continue
                else
                    abort_neo -e 22.1 -m "The config is configured incorrectly. Line ${text}="
                fi
            fi
        else
            abort_neo -e 22.2 -m "The config is configured incorrectly. More than one line ${text}="
        fi
    done
    for text in hide_not_encrypted safety_net_fix remove_pin wipe_data modify_early_mount disable_verity_and_verification; do
        if [[ "$(grep "${text}=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]]; then
            if $check_true_false_only ; then
                if grep -w "${text}=false" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=true" "$CONFIG_NEO" &>$LOGNEO; then
                    continue
                else
                    abort_neo -e 22.1 -m "The config is configured incorrectly. Line ${text}="
                fi
            else
                if grep -w "${text}=false" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=true" "$CONFIG_NEO" &>$LOGNEO || grep -w "${text}=ask" "$CONFIG_NEO" &>$LOGNEO; then
                    continue
                else
                    abort_neo -e 22.1 -m "The config is configured incorrectly. Line ${text}="
                fi
            fi
        else
            abort_neo -e 22.2 -m "The config is configured incorrectly. More than one line ${text}="
        fi
    done

    
    if [[ "$(grep "dfe_paterns=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]]; then
        if [[ "$(grep "dfe_paterns=" "$CONFIG_NEO")" == "dfe_paterns=" ]] || [[ "$(grep "dfe_paterns=" "$CONFIG_NEO")" == "dfe_paterns=\"\"" ]] ; then
            abort_neo -e 22.44 -m "Patterns for removal are empty. Configure NEO.config correctly"
        fi
    else
        abort_neo -e 22.61 -m "The config is configured incorrectly. More than one line dfe_paterns="
    fi

    
    if [[ "$(grep "where_to_inject=" "$CONFIG_NEO" | grep -v "#" | wc -l)" == "1" ]]; then
        if ! grep -w "where_to_inject=super" "$CONFIG_NEO" &>$LOGNEO && ! grep -w "where_to_inject=vendor_boot" "$CONFIG_NEO" &>$LOGNEO && ! grep -w "where_to_inject=auto" "$CONFIG_NEO" &>$LOGNEO && ! grep -w "where_to_inject=boot" "$CONFIG_NEO" &>$LOGNEO; then
            abort_neo -e 22.5 -m "The config is configured incorrectly. where_to_inject= expects vendor_boot or boot or super"
        fi
    else
        abort_neo -e 22.6 -m "The config is configured incorrectly. More than one line where_to_inject="
    fi

}

volume_selector() {
    # Original idea by chainfire and ianmacd @xda-developers
    local error=false
    while true; do
        local count=0
        while true; do
            timeout 0.5 $TOOLS/toolbox getevent -lqc 1 2>&1 >$TMPN/events &
            sleep 0.1
            count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $TMPN/events); then
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPN/events); then
                return 1
            fi
            [ $count -gt 100 ] && break
        done
        if $error; then
            abort_neo -e 2.1 -m "$word1"
        else
            error=true
        fi
    done
}
grep_cmdline() {
  local REGEX="s/^$1=//p"
  { echo $(cat /proc/cmdline)$(sed -e 's/[^"]//g' -e 's/""//g' /proc/cmdline) | xargs -n 1; \
    sed -e 's/ = /=/g' -e 's/, /,/g' -e 's/"//g' /proc/bootconfig; \
  } 2>/dev/null | sed -n "$REGEX"
}
update_partitions(){
    my_print "- $word49"
    BOOTCTL_SUPPORT=false
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    $TOOLS/bootctl
    boot_ct_eror=$?
    if [[ "$boot_ct_eror" == "64" ]] ; then
=======
    if $TOOLS/bootctl get-current-slot ; then
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
    if $TOOLS/bootctl get-current-slot ; then
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
    if $TOOLS/bootctl get-current-slot ; then
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
    $TOOLS/bootctl
    boot_ct_eror=$?
    if [[ "$boot_ct_eror" == "64" ]] ; then
>>>>>>> 320717a (Синхронизация с master)
        BOOTCTL_SUPPORT=true
    fi
    if $BOOTCTL_SUPPORT ; then
=======
    if $bootctl_state ; then
>>>>>>> b7021df (add check ota and flash after ota)
        SLOTCURRENT=$($TOOLS/bootctl get-current-slot)
    else
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        SLOTCURRENT="$CSLOT"
=======
        SLOTCURRENT=$CSLOT
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
        SLOTCURRENT=$CSLOT
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
        SLOTCURRENT=$CSLOT
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
        SLOTCURRENT="$CSLOT"
>>>>>>> 320717a (Синхронизация с master)
=======
        SLOTCURRENT=""
>>>>>>> d67ddcf (add later test fix A-only and others)
    fi

    if [[ -z "$SLOTCURRENT" ]] ; then
        case $CSLOT in 
            _a)
                SLOTCURRENT=0
            ;;
            _b)
                SLOTCURRENT=1
            ;;
        esac 
    fi

    if [[ -n "$SLOTCURRENT" ]] ; then 
        case "$SLOTCURRENT" in
            0) 
            SUFFIXCURRENT="_a"
            SUFFIXINCURRENT="_b"
            ;;
            1) 
            SUFFIXCURRENT="_b"
            SUFFIXINCURRENT="_a"
            ;;
        esac
    else
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        exit 14
=======
    exit 14
>>>>>>> 4f75f82 (Update update_partition and fix my_print)
=======
        exit 14
>>>>>>> c09176e (buildfix)
=======
    exit 14
>>>>>>> 320717a (Синхронизация с master)
    fi

    for part in /dev/block/mapper/* ; do
    line_to_remove=""
    if [ -b "$part" ] || ( [ -h "$part" ] && [ -b "$(readlink -f "$part")" ] ) ; then
        name_part=$(basename ${part%"$SUFFIXCURRENT"*})
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO

        $TOOLS/lptools_new --super $super_block --slot 1 --suffix _a --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 1 --suffix _b --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 0 --suffix _a --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 0 --suffix _b --unmap $(basename ${part}) &>$LOGNEO
        if [ "$name_part" == "system" ] ; then 
        name_part=system_root
        fi
        line_to_remove=$(cat /etc/fstab | grep -w "/$name_part")
        if [[ -n $line_to_remove ]] ; then
        echo "$line_to_remove" &>$LOGNEO
        sed -i "/${line_to_remove//\//\\/}/d" /etc/fstab
        fi
    fi
    done
=======
>>>>>>> 485a1d7 (.)
=======
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
>>>>>>> 679d83d (Фиксация от 09.03.24 18:02)

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

get_current_suffix(){ # <--- Определение функции [Аругментов нет]
    CSUFFIX_tmp=$(getprop ro.boot.slot_suffix)
    if [[ -z "$CSUFFIX_tmp" ]]; then
        CSUFFIX_tmp=$(grep_cmdline androidboot.slot_suffix)
        if [[ -z "$CSUFFIX_tmp" ]]; then
            CSUFFIX_tmp=$(grep_cmdline androidboot.slot)
        fi
    fi
    if [[ -n "$CSUFFIX_tmp" ]] ; then
        echo "$get_current_suffix"
    else
        echo ""
        return 0
    fi
}; export -f get_current_suffix

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

find_super_partition(){ # <--- Определение функции [Аругментов нет]
    for blocksuper in /dev/block/by-name/* /dev/block/bootdevice/by-name/* /dev/block/bootdevice/* /dev/block/* ; do
        if lptools_new --super $blocksuper --get-info &>/dev/null; then
            echo "$blocksuper"
            break
        fi    
    done 
}

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
    export CURRENT_SUFFIX="$(get_current_suffix)"

    case "$CURRENT_SUFFIX" in
        "_a") ; CURRENT_SUFFIX="_a" ; RECURCE_CURRENT_SUFFIX="_b" ; CURRENT_SLOT=0 ; RECURCE_CURRENT_SLOT=1 ;;
        "_b") ; CURRENT_SUFFIX="_b" ;  RECURCE_CURRENT_SUFFIX="_b" ; CURRENT_SLOT=1 ; RECURCE_CURRENT_SLOT=0 ;;
        *) ; CURRENT_SUFFIX="" ; RECURCE_CURRENT_SUFFIX="" ; CURRENT_SLOT=0 ; RECURCE_CURRENT_SLOT=1 ;;
    esac

    if [[ -n "$CURRENT_SUFFIX" ]] ; then
        my_print " "
        my_print "- Устройства A/B"
        my_print "- Текущий слот: $CURRENT_SUFFIX"
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


OTA_COMPLITED=false
if $SYS_STATUS ; then

    if ! $SNAPSHOTCTL_STATE;
        if ! $force_start
            my_print "- !! Ошибка в определение статуса обновления системы, бинарник не может быть выполнен"
            my_print "- Требуется уточнение пользователя, установка в текущую прошивку?"
            if volume_selector "Текущая система" "Выход" ; then
                echo "- продолжить установку" &>$NEOLOG
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
        else
            abort_neo -e "83.4" -m "Неизветсный статус обновления системы"
        fi
    fi

fi




    