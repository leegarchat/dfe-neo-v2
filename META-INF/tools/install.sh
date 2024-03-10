<<<<<<< HEAD
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
=======

>>>>>>> 94cf7ee (Первая рабочая сборка для A-only recovery)
# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
>>>>>>> 09d7e2e (Фиксация от 05.03 23:31)

<<<<<<< HEAD
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
    binary_pull_busubox="mv cp dirname basename grep [ [[ stat sleep mountpoint sed echo mkdir ls ln readlink realpath cat awk wc du"
=======
echo "- Определение PATH с новыми бинарниками" &>>$NEOLOG && { # <--- обычный код
<<<<<<< HEAD
    binary_pull_busubox="mv cp dirname basename grep [ [[ stat sleep unzip mountpoint sed echo find mkdir ls ln readlink realpath cat awk wc du"
>>>>>>> 94cf7ee (Первая рабочая сборка для A-only recovery)
=======
    binary_pull_busubox="mv cp dirname basename grep [ [[ stat unzip mountpoint sed mkdir ls ln readlink realpath cat awk wc du"
>>>>>>> d6f84c8 (try_fix bootloop)
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
    export PATH="$TOOLS:$PATH"
}

my_print(){ # <--- Определение функции [Аругменты $1 "Вывод сообщения"]
    case $WHERE_INSTALLING in
        kernelsu|magiskapp)
            echo -e "$1" &>>$LOGNEO
            echo -e "$1"
        ;;
        recovery)
            local input_message_ui="$1"
            local IFS=$'\n'
            while read -r line_print; do
                echo -e "$line_print" &>>$LOGNEO
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
        # if [[ -f /tmp/recovery.log ]] ; then
        #     echo -e "\n\n\n\n\n\n\n\nRECOVERYLOGTHIS:\n\n" >>$LOGNEO
        #     cat /tmp/recovery.log >>$LOGNEO
        # fi
        exit "$error_code"
    fi
}; export -f abort_neo

check_it(){ # <--- Определение функции [Аругментов нет]
    WHAT_CHECK="$1"
    NEED_ARGS="$2"
    if [[ "$(grep "$WHAT_CHECK=" "$CONFIG_FILE" | grep -v "#" | wc -l)" == "1" ]] ; then
        if grep -w "${WHAT_CHECK}=$NEED_ARGS" "$CONFIG_FILE" | grep -v "#" &>>$LOGNEO ; then
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
    if [[ -n "$CSUFFIX_tmp" ]] ; then
        echo "$get_current_suffix"
    fi
    case "$CSUFFIX_tmp" in
        "$A_CASE") CURRENT_SUFFIX="_a" ; UNCURRENT_SUFFIX="_b" ; CURRENT_SLOT=0 ; UNCURRENT_SLOT=1 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
        "$B_CASE") CURRENT_SUFFIX="_b" ;  UNCURRENT_SUFFIX="_b" ; CURRENT_SLOT=1 ; UNCURRENT_SLOT=0 ; OUT_MESSAGE_SUFFIX="$CURRENT_SUFFIX" ;;
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
                echo "Unknown parameter: $1" &>>$LOGNEO
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
            echo "${found_blocks% *}"
        fi
    fi
}; export -f find_block_neo

volume_selector(){ # <--- Определение функции  [Аругменты $1 - Выбор (+)] [Аругменты $2 - Выбор (-)]
    my_print "    $1 [Громкость вверх (+)]"
    my_print "    $2 [Громкость вниз (-)]"
    volume_selector_count=0
    while true; do
        while true; do
            timeout 0.5 getevent -lqc 1 2>&1 >$volume_selector_events_file &
            sleep 0.1
            volume_selector_count=$((volume_selector_count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $1 [Громкость вверх (+)]"
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                my_print "**> $2  [Громкость вниз (-)]"
                return 1
            fi
            [ $volume_selector_count -gt 300 ] && break
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
            umount -fl "$partitions" &>>$LOGNEO && umount -fl "$partitions" &>>$LOGNEO && umount -fl "$partitions" &>>$LOGNEO && umount -fl "$partitions" &>>$LOGNEO
            umount -fl "$(readlink -f "$partitions")" &>>$LOGNEO && umount -fl "$(readlink -f "$partitions")" &>>$LOGNEO && umount -fl "$(readlink -f "$partitions")" &>>$LOGNEO && umount -fl "$(readlink -f "$partitions")" &>>$LOGNEO
            if [[ -n "$CURRENT_SUFFIX" ]] ; then
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --suffix "$CURRENT_SUFFIX" --unmap "$partitions_name" &>>$NEOLOG
                lptools_new --super "$SUPER_BLOCK" --slot "$UNCURRENT_SLOT" --suffix "$UNCURRENT_SUFFIX" --unmap "$partitions_name" &>>$NEOLOG
            else
                lptools_new --super "$SUPER_BLOCK" --slot "$CURRENT_SLOT" --unmap "$partitions_name" &>>$NEOLOG
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
                    if lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --map "system$check_suffix" &>>$NEOLOG ; then
                        mkdir -pv "$TMPN/check_partitions/system$check_suffix" &>>$NEOLO
                        if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                            if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                                if ! mount -r "/dev/block/mapper/system$check_suffix" "$TMPN/check_partitions/system$check_suffix" ; then
                                    continue_fail=true
                                fi
                            fi
                        fi
                        if ! $continue_fail && mountpoint "$TMPN/check_partitions/system$check_suffix" &>>$LOGNEO ; then export ${partitions}_check_state=true ; fi
                        umount -fl "$TMPN/check_partitions/system$check_suffix" &>>$NEOLOG
                        lptools_new --super "$SUPER_BLOCK" --suffix "$check_suffix" --slot "$check_slot" --unmap "system$check_suffix" &>>$NEOLOG
                        rm -rf "$TMPN/check_partitions/system$check_suffix"
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
            if lptools_new --super "$SUPER_BLOCK" --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --map $partition_name &>>$NEOLOG ; then
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
                mount $TMPN/bootconfig_new /proc/bootconfig &>>$LOGNEO
            fi
            if grep "androidboot.slot_suffix=$CURRENT_SUFFIX" /proc/cmdline || grep "androidboot.slot=$CURRENT_SUFFIX" /proc/cmdline ; then
                edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot_suffix='$CURRENT_SUFFIX'/androidboot.slot_suffix='$FINAL_ACTIVE_SUFFIX'/' | sed 's/androidboot.slot='$CURRENT_SUFFIX'/androidboot.slot='$FINAL_ACTIVE_SUFFIX'/')"
                echo -e "$edit_text" > $TMPN/cmdline_new 
                mount $TMPN/cmdline_new /proc/cmdline &>>$LOGNEO
            fi
            if $BOOTCTL_STATE ; then
                bootctl set-active-boot-slot $FINAL_ACTIVE_SLOT
            fi
        fi
    else
        unmap_all_partitions
        for partition in $(lptools_new --super $SUPER_BLOCK --slot $CURRENT_SLOT --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | awk '{print $1}') ; do
            partition_name=${partition/"NamePartInGroup->"/}
            if lptools_new --super "$SUPER_BLOCK"  --slot $CURRENT_SLOT --map $partition_name &>>$NEOLOG ; then
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
        if volume_selector "Да 'установить'" "Нет 'не устанавливать'" ; then
            hide_not_encrypted=true
        else
            hide_not_encrypted=false
        fi
    fi
    if [[ $safety_net_fix == "ask" ]] ; then
        my_print " "
        my_print "- Установить встроенный safety net fix?"
        my_print "- **Будет работать только если установлен Magisk или KSU или Selinux в режиме Permissive"
        if volume_selector "Да 'установить'" "Нет 'не устанавливать'" ; then
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
            my_print "- Сделать wipe data? удалит все данные прошивки, внутренняя память не будет тронута"
            if volume_selector "Да 'удалить'" "Нет 'не трогать!'" ; then
                wipe_data=true
            else
                wipe_data=false
            fi
        fi
    fi
    if [[ $remove_pin == "ask" ]] ; then
        my_print " "
        my_print "- Удалить данные экрана блокировки?"
        if volume_selector "Да 'Удалить'" "Нет 'не трогать!'" ; then
            remove_pin=true
        else
            remove_pin=false
        fi
    fi
    if [[ $modify_early_mount == "ask" ]] ; then
        my_print " "
        my_print "- Подключать измененный fstab во время раннего монтирования разделов?"
        my_print "- ** Нужно в основном если вы использовали дополнительные ключи dfe_paterns для системных разделов или использовали ключ -v для удаления оверлеев"
        if volume_selector "Да 'Подключить'" "Нет 'Нет нужды'" ; then
            modify_early_mount=true
        else
            modify_early_mount=false
        fi
    fi
    if [[ $disable_verity_and_verification == "ask" ]] ; then
        my_print " "
        my_print "- Удалить проверку целостности системы?"
        my_print "- ** Эта опция патчит vbmeta и system_vbmeta тем самым отключает проверку целостности системы, включите эту опцию если получили bootloop или если знаете зачем она нужна, в ином случае просто не трогайте"
        if volume_selector "Да 'отключить'" "Нет 'не трогать'" ; then
            disable_verity_and_verification=true
        else
            disable_verity_and_verification=false
        fi
    fi

    if [[ $zygisk_turn_on == "ask" ]] ; then
        my_print " "
        my_print "- Принудительно включить zygisk во время включения?"
        my_print "- ** Опция будет работать только если включен maghisk"
        if volume_selector "Да 'включить'" "Нет 'не надо'" ; then
            zygisk_turn_on=true
            my_print " "
            my_print "- Какой режим принудительного запуска использовать?"
            my_print "- ** Постоянный, это значит что будет включаться каждый раз при запуске системы"
            my_print "- ** Одноразовый, это значит что запуститься будет включен только при первом запуске системы, в дальнейшом будет игнорироваться принудительный запуск"
            if volume_selector "'Постоянно'" "'Одноразово'" ; then
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
        my_print "- Принудительно делать запись в denylist во время включения?"
        my_print "- ** Опция будет работать только если включен zygisk"
        if volume_selector "Да 'включить'" "Нет 'не надо'" ; then
            add_custom_deny_list=true
            my_print " "
            my_print "- Какой режим принудительного запуска использовать?"
            my_print "- ** Постоянный, это значит что будет включаться каждый раз при запуске системы"
            my_print "- ** Одноразовый, это значит что запуститься будет включен только при первом запуске системы, в дальнейшом будет игнорироваться принудительный запуск"
            if volume_selector "'Постоянно'" "'Одноразово'" ; then
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

    my_print "- Монтирования vendor"
    VENDOR_BLOCK=""
    if [[ "$SNAPSHOT_STATUS" == "unverified" ]] && $SUPER_DEVICE ; then
        if snapshotctl map &>>$NEOLOG ; then
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
        umount -fl "${VENDOR_BLOCK}" &>>$LOGNEO
        umount -fl "${VENDOR_BLOCK}" &>>$LOGNEO
        umount -fl "${VENDOR_BLOCK}" &>>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>>$LOGNEO
        umount -fl "$(readlink "$VENDOR_BLOCK")" &>>$LOGNEO
    fi 

    name_vendor_block="vendor${CSLOT}"
    full_path_to_vendor_folder=$TMPN/mapper/$name_vendor_block

    mkdir -pv $full_path_to_vendor_folder
    my_print "- Монтирование vendor в временную папку"
    if ! mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>>$LOGNEO ; then
        mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>>$LOGNEO
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

remove_dfe_neo(){ # <--- Определение функции [Аругментов нет]
    
    if $DETECT_NEO_IN_BOOT ; then
        cat "$(find_block_neo -b "boot$CURRENT_SUFFIX")" > "$(find_block_neo -b "boot$UNCURRENT_SUFFIX")" 
    fi
    if $DETECT_NEO_IN_VENDOR_BOOT ; then
        cat "$(find_block_neo -b "vendor_boot$CURRENT_SUFFIX")" > "$(find_block_neo -b "vendor_boot$UNCURRENT_SUFFIX")"
    fi
    if $DETECT_NEO_IN_SUPER && $A_ONLY_DEVICE ; then
        lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX" 
    elif $DETECT_NEO_IN_SUPER && ! $A_ONLY_DEVICE ; then
        lptools_new --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX --super $SUPER_BLOCK --remove "neo_inject$CURRENT_SUFFIX"
    fi
    for boot in $WHERE_NEO_ALREADY_INSTALL; do
        ramdisk_compress_format=""
        block_boot=$(find_block_neo -b "$boot")
        path_check_boot="$TMPN/check_boot_neo/$boot"
        mkdir -pv $path_check_boot &>>$LOGNEO
        cd "$path_check_boot" || exit 66
        magiskboot unpack -h "$block_boot" &>>$LOGNEO
        if [[ -f "ramdisk.cpio" ]] ; then
            mkdir $path_check_boot/ramdisk_files
            cd $path_check_boot/ramdisk_files
            if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>>$LOGNEO ; then
                magiskboot decompress $path_check_boot/ramdisk.cpio $path_check_boot/d.cpio &>$path_check_boot/log.decompress
                rm -f $path_check_boot/ramdisk.cpio 
                mv $path_check_boot/d.cpio $path_check_boot/ramdisk.cpio
                ramdisk_compress_format=$(grep "Detected format:" $path_check_boot/log.decompress.ramdisk | sed 's/.*\[\(.*\)\].*/\1/')
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
                    magiskboot cpio "$path_check_boot/ramdisk.cpio" "add 777 ${fstab//$path_check_boot\/ramdisk_files\//} $fstab" &>>$LOGNEO
                    need_repack=true
                fi
            done
            if $need_repack ; then
                cd $path_check_boot
                if [[ -n "$ramdisk_compress_format" ]] ; then
                    magiskboot compress="${ramdisk_compress_format}" "$path_check_boot/ramdisk.cpio" "$path_check_boot/ramdisk.compress.cpio" &>>$LOGNEO
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

ramdisk_first_stage_patch(){ # <--- Определение функции $1 передаються именя boot которые надо пропатчить
    for boot in $1 ; do
        my_print "- Патчинг first_stage $boot"
        boot_folder="$TMPN/ramdisk_patch/$boot"
        mkdir -pv "$TMPN/ramdisk_patch/$boot/ramdisk_folder" &>>$LOGN
        boot_block=$(find_block_neo -b $boot)
        cd $boot_folder
        magiskboot unpack -h "$boot_block"
        cd "$boot_folder/ramdisk_folder"
        if ! magiskboot cpio "$boot_folder/ramdisk.cpio" extract &>>$LOGNEO ; then
            my_print "- Ramdisk зжать... Декомпресия"
            magiskboot decompress "$boot_folder/ramdisk.cpio" "$boot_folder/ramdisk.d.cpio" &>$boot_folder/log.decompress
            rm -f "$boot_folder/ramdisk.cpio"
            mv "$boot_folder/ramdisk.d.cpio" "$boot_check_folder/ramdisk.cpio"
            ramdisk_compress_format=$(grep "Detected format:" $boot_folder/log.decompress.ramdisk | sed 's/.*\[\(.*\)\].*/\1/')
        fi
        for fstab in $(find "$boot_folder/ramdisk_folder/" -name "$final_fstab_name"); do
            my_print "- Патчинг $(basename $fstab)"
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
                    echo "neo_inject    /vendor/etc/init/hw ext4    ro,discard  slotselect,logical,first_stage_mount" >>$fstab
                else
                    echo "neo_inject    /vendor/etc/init/hw ext4    ro,discard  logical,first_stage_mount" >>$fstab
                fi
            elif $FLASH_IN_BOOT; then
                echo "/dev/block/by-name/boot$UNCURRENT_SUFFIX    /vendor/etc/init/hw ext4    ro  first_stage_mount" >>$fstab
            elif $FLASH_IN_VENDOR_BOOT; then
                echo "/dev/block/by-name/vendor_boot$UNCURRENT_SUFFIX    /vendor/etc/init/hw ext4    ro  first_stage_mount" >>$fstab
            fi
            magiskboot cpio "$boot_folder/ramdisk.cpio" "add 777 ${fstab//$boot_folder\/ramdisk_folder\//} $fstab" &>>$LOGNEO
        done
        cd $boot_folder
        if [[ -n "$ramdisk_compress_format" ]] ; then
            my_print "- Запаковка ramdisk обратно в $ramdisk_compress_format"
            magiskboot compress="${ramdisk_compress_format}" "$boot_folder/ramdisk.cpio" "$boot_folder/ramdisk.compress.cpio" &>>$LOGNEO
            rm -f "$boot_folder/ramdisk.cpio"
            mv "$boot_folder/ramdisk.compress.cpio" "$boot_folder/ramdisk.cpio"
        fi
        magiskboot repack $boot_block
        my_print "- Запись new-$boot в $boot_block"
        cat $boot_folder/new-boot.img > $boot_block
        rm -rf "$TMPN/ramdisk_patch"
    done
    
}; export -f ramdisk_first_stage_patch

check_dfe_neo_installing(){ # <--- Определение функции [Аругментов нет]
    if ! $force_start; then
        export DETECT_NEO_IN_BOOT=false
        export DETECT_NEO_IN_SUPER=false
        export DETECT_NEO_IN_VENDOR_BOOT=false
        export NEO_ALREADY_INSTALL=false
        export WHERE_NEO_ALREADY_INSTALL=""
        echo "- Поиск neo_inject в boot/vendor_boot только для a/b устройств" &>>$NEOLOG && {
            if ! $A_ONLY_DEVICE ; then 
                for boot_partition in "vendor_boot${UNCURRENT_SUFFIX}" "boot${UNCURRENT_SUFFIX}" ; do
                    echo "- Поиск neo_inject в ${boot_partition}${UNCURRENT_SUFFIX}" &>>$NEOLOG && {
                        if $(find_block_neo -c -b ${boot_partition}${UNCURRENT_SUFFIX}) ; then
                            my_print "- Поиск neo_inject в ${boot_partition}${UNCURRENT_SUFFIX}"
                            if cat $(find_block_neo -b ${boot_partition}${UNCURRENT_SUFFIX}) | grep mount | grep /etc/init/hw/ &>>$LOGNEO ; then
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
        echo "- Поиск neo_inject в super если устройство имеет super" &>>$NEOLOG && {
            if "$SUPER_DEVICE" ; then
                my_print "- Поиск neo_inject в super"
                if $A_ONLY_DEVICE ; then
                    if lptools_new --slot $CURRENT_SLOT --super $SUPER_BLOCK --get-info | grep "neo_inject" &>>$LOGNEO ; then
                        DETECT_NEO_IN_SUPER=true
                    fi
                elif ! $A_ONLY_DEVICE ; then 
                    if lptools_new --slot $CURRENT_SLOT --suffix $CURRENT_SUFFIX --super $SUPER_BLOCK --get-info | grep "neo_inject" &>>$LOGNEO ; then
                        DETECT_NEO_IN_SUPER=true
                    fi
                fi
                
            fi
        }
        
        cd "$TMPN" &>>$LOGNEO
        for boot_check in "vendor_boot$CURRENT_SUFFIX" "boot$CURRENT_SUFFIX" ; do
            if find_block_neo -c -b "$boot_check" ; then
                block_boot=$(find_block_neo -b "$boot_check")
                path_check_boot="$TMPN/check_boot_neo/$boot_check"
                mkdir -pv $path_check_boot
                cd $path_check_boot &>>$LOGNEO
                magiskboot unpack -h "$block_boot" &>>$LOGNEO
                if [[ -f "$path_check_boot/ramdisk.cpio" ]] ; then
                    mkdir $path_check_boot/ramdisk_files
                    cd $path_check_boot/ramdisk_files
                    if ! magiskboot cpio $path_check_boot/ramdisk.cpio extract &>>$LOGNEO ; then
                        if magiskboot decompress $path_check_boot/ramdisk.cpio $path_check_boot/d.cpio &>>$LOGNEO ; then
                            rm -f $path_check_boot/ramdisk.cpio &>>$LOGNEO
                            mv $path_check_boot/d.cpio $path_check_boot/ramdisk.cpio
                        else
                            continue
                            cd "$TMPN"
                            rm -rf $path_check_boot
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
            my_print "- Обнаружен установленный DFE-NEO, удалить или установить снова?"
            if ! volume_selector "Переустановить" "Удалить" ; then  
                remove_dfe_neo
                exit 0
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
    my_print "- Итог конфигурации:"
    my_print "- Язык $languages"
    if [[ "$where_to_inject" == "auto" ]] ; then
        my_print "- Место для inject.img:"
        my_print "- Прошивка образа будет по порядку в один из"
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
    
    my_print "- Монтировать fstab в early_mount: $modify_early_mount"
    my_print "- SafetyNetFix: $safety_net_fix"
    my_print "- Скрыть не зашифрованность: $hide_not_encrypted"
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- zygisk on boot: $zygisk_turn_on"
    else
        my_print "- zygisk on boot: $zygisk_turn_on/$zygisk_turn_on_parm"
    fi
    if [[ -z "$zygisk_turn_on_parm" ]] ; then 
        my_print "- Custom denylist: $add_custom_deny_list"
    else
        my_print "- Custom denylist: $add_custom_deny_list/$add_custom_deny_list_parm"
    fi   
    echo "- Проверка доступтности magisk" &>>$LOGNEO && {
        case $magisk in
            "EXT:"* | "ext:"* | "Ext:"*)
                magisk="$(echo ${magisk} | sed "s/ext://I")"
                if [[ -f "$(dirname "${ZIPARG3}")/${magisk}" ]]; then
                    my_print "- Установка Magisk: $magisk"
                    MAGISK_ZIP="$(dirname "${ZIPARG3}")/${magisk}"
                
                else
                    my_print "- Magisk: Не устанавливать"
                    magisk=false
                fi
                ;;
            *)
                if [[ -f "$TMPN/unzip/MAGISK/${magisk}.apk" ]]; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.apk"
                    my_print "- Установка Magisk: $magisk"
                elif [[ -f "$TMPN/unzip/MAGISK/${magisk}.zip" ]] ; then
                    MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.zip"
                    my_print "- Установка Magisk: $magisk"
                else
                    my_print "- Magisk: Не устанавливать"
                    magisk=false
                fi
                ;;
        esac 
    } 
    my_print "- Очистка данных: $wipe_data"
    my_print "- Удалить данные блокировки: $remove_pin"
    my_print "- Патерны патчинга fstab: $dfe_paterns"
    my_print "- custom_reset_prop: $custom_reset_prop"
    my_print " "
    my_print " "
    if ! $force_start ; then
        my_print "- Продолжить установку с текущими параметрами?"
        if ! volume_selector "Да" "Выход" ; then 
            exit 1
        fi
    fi


}; export -f confirm_menu

add_custom_rc_line_to_inirc_and_add_files(){ # <--- Определение функции передается $1 файл куда сделать запись
    if $safety_net_fix || $hide_not_encrypted || $add_custom_deny_list || $zygisk_turn_on || [[ -n $custom_reset_prop ]] ; then
        if $add_custom_deny_list || $zygisk_turn_on ; then
            cp $TMPN/unzip/META-INF/tools/magisk.db "$TMPN/neo_inject$CURRENT_SUFFIX/" 
            cp $TMPN/unzip/META-INF/tools/denylist.txt "$TMPN/neo_inject$CURRENT_SUFFIX/"
            cp $TOOLS/sqlite3 "$TMPN/neo_inject${CURRENT_SUFFIX}/"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/sqlite3"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/magisk.db"
            chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/denylist.txt"
        fi
        cp $TOOLS/magisk "$TMPN/neo_inject${CURRENT_SUFFIX}/"
        cp $TMPN/unzip/META-INF/tools/init.sh "$TMPN/neo_inject${CURRENT_SUFFIX}/"
        chmod 777 "$TMPN/neo_inject${CURRENT_SUFFIX}/init.sh"
        echo " " >> "$1"
        echo -e "${add_init_target_rc_line_init}\n" >> "$1"
        echo -e "${add_init_target_rc_line_early_fs}\n" >> "$1"
        echo -e "${add_init_target_rc_line_postfs}\n" >> "$1"
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


    for original_fstab_name_for in $fstab_names_check ; do
        full_path_to_fstab_into_for="$full_path_to_vendor_folder$(dirname ${path_original_fstab})/$original_fstab_name_for"
        if [[ -f "$full_path_to_fstab_into_for" ]] && grep "/userdata" "$full_path_to_fstab_into_for" | grep "latemount" | grep -v "#" &>>$LOGNEO ; then
            cp -afc "$full_path_to_fstab_into_for" "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab"
            patch_fstab_neo $dfe_paterns -f "$full_path_to_fstab_into_for" -o "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab"
            final_fstab_name="$original_fstab_name_for"
            return 0
            break
        fi
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
                            echo "No patterns provided for removal." &>>$LOGNEO
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
            echo "Unknown parameter: $1" &>>$LOGNEO
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
                echo "comment line $line" &>>$LOGNEO
            ;;
            *)
                if [ "$(echo "$removepattern" | wc -w)" -gt 0 ]; then
                    for arrp in $removepattern ; do
                        mountpoint=${arrp%%"--m--"*}
                        patterns=${arrp##*"--m--"}
                        remove_paterns=$(echo -e ${patterns//"--p--"/"\n"} | grep "\-\-r--")
                        replace_patterns=$(echo -e ${patterns//"--r--"/"\n"} | grep "\-\-p--")
                        if [ "$(echo "$line" | awk '{print $2}')" == "$mountpoint" ]; then
                            my_print "- Обнаружена точка монтирования: '$mountpoint'"
                            for replace_pattern in ${replace_patterns//"--p--"/ } ; do
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" ; then
                                    my_print "- Замена выполнена ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$(echo "$line" | sed -E "s/,${replace_pattern%%"--to--"*}*[^[:space:]|,]*/,${replace_pattern##*"--to--"}/")
                                fi
                                if echo "$line" | grep -q "${replace_pattern%%"--to--"*}" && ! (echo "$line" | grep -q "${replace_pattern##*"--to--"}"); then 
                                    my_print "- Замена выполнена ${replace_pattern%%"--to--"*}->${replace_pattern##*"--to--"}"
                                    line=$(echo "$line" | sed -E "s/${replace_pattern%%"--to--"*}*[^[:space:]|,]*/${replace_pattern##*"--to--"}/")
                                fi 
                            done
                            for remove_pattern in ${remove_paterns//"--r--"/ }; do
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- Флаг удален: ${remove_pattern}"
                                    line=$(echo "$line" | sed -E "s/,${remove_pattern}*[^[:space:]|,]*//")
                                fi
                                if echo "$line" | grep -q "${remove_pattern}" ; then 
                                    my_print "- Флаг удален: ${remove_pattern}"
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
        mkdir $TMPN/neo_inject${CURRENT_SUFFIX}
        mkdir "$TMPN/neo_inject${CURRENT_SUFFIX}/lost+found"
        cp -afc ${VENDOR_FOLDER}/etc/init/hw/* $TMPN/neo_inject${CURRENT_SUFFIX}/
    }
    echo "- Поиск fstab по .rc файлам" &>>$LOGNEO && { # <--- обычный код
        for file_find in "$TMPN/neo_inject${CURRENT_SUFFIX}"/*.rc ; do
            if grep "mount_all" $file_find | grep "\-\-late" | grep -v "#" &>>$LOGNEO; then
                if grep "mount_all --late" $file_find | grep -v "#" &>>$LOGNEO; then
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

            abort_neo -e 36.2 -m "Устройство не поддерживается"
        fi
        add_custom_rc_line_to_inirc_and_add_files "$last_init_rc_file_for_write"
        if ! move_fstab_from_original_vendor_and_patch ; then
            if ! [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then 
                umount -fl "$full_path_to_vendor_folder"
            fi
            abort_neo -e 36.1 -m "Ни один из fstab не найден в /vendor/etc/[${fstab_names_check// /\|}]"
        fi
        [[ -f "$TMPN/neo_inject${CURRENT_SUFFIX}/$basename_fstab" ]] || abort_neo -e 36.6 -m "В процессе патчинга что то пошло не так"

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
            abort_neo -e 71.4 -m "Устройство не имеет super раздела, используйте другой параметр where_to_inject"
        fi
    elif [[ "$where_to_inject" == "boot" ]] ; then
        if ! $A_ONLY_DEVICE; then
            FLASH_IN_BOOT=true
            echo "- не A-only wahre to inject" &>>$LOGNEO
        else
            abort_neo -e 71.3 -m "Устройство должно быть A-B. Используйте where_to_inject с другим параметром super или auto"
        fi
    elif [[ "$where_to_inject" == "vendor_boot" ]] ; then
        if $VENDOR_BOOT_DEVICE && ! $A_ONLY_DEVICE; then
            FLASH_IN_VENDOR_BOOT=true
            echo "- Vendor_boot и не A-only wahre to inject" &>>$LOGNEO
        else
            abort_neo -e 71.2 -m "Устройство не имеет vendor_boot блока или устройство A-only. Используйте where_to_inject с другим параметром"
        fi
    fi
    if ! $FLASH_IN_BOOT && ! $FLASH_IN_VENDOR_BOOT && ! $FLASH_IN_SUPER ; then
        abort_neo -e 71.5 -m "Устройство вообще не поддерживается"
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
    make_ext4fs -J -T 1230764400 \
            -S "${FILE_CONTEXTS_FILE}" \
            -l "$(du -sb "${TARGET_DIR}" | awk '{print int($1*10)}')" \
            -C "${FS_CONFIG_FILE}" -a "${LABLE}" -L "${LABLE}" \
            "$NEO_IMG" "${TARGET_DIR}"

    resize2fs -M "$NEO_IMG" &>>$LOGN
    resize2fs -M "$NEO_IMG" &>>$LOGN
    resize2fs -M "$NEO_IMG" &>>$LOGN
    resize2fs -M "$NEO_IMG" &>>$LOGN
    # resize2fs -f "$NEO_IMG" "$(($(stat -c%s "$NEO_IMG")*2/512))"s &>>$LOGN
    if $SYS_STATUS && [[ "$full_path_to_vendor_folder" == "/vendor" ]] ; then
        echo "- Системный vendor" &>>$LOGNEO
    else
        umount -fl $full_path_to_vendor_folder &>>$LOGNEO
    fi

}; export -f make_neo_inject_img

check_size_super(){ # <--- Определение функции $1 размер neo_inject в байтах
    SIZE_NEO_IMG_FUNC="$1"
    for size_print in 2 4 8 16 32 64 128 ; do
        if (( ( $SIZE_NEO_IMG_FUNC + ( 3 * 1024 * 1024 ) ) > ( $size_print * 1024 * 1024 ) )) ; then
            continue
        fi
        if (( $FREE_SIZE_INTO_SUPER >= $size_print * 1024 * 1024 )) ; then
            my_print "- В super достаточно места для записи neo_inject.img"
            return 0
            break
        else
            my_print "- В super не достаточно места для записи neo_inject.img"
            my_print "- Нужно ${size_print}mb"
            return 1
        fi
    done

}; export -f check_size_super

test_mount_neo_inject(){ # <--- Определение функции $1 путь к блоку neo_inject
    local PATH_BLOCK_NEO="$1"

    mkdir -pv "$TMPN/test_neo_inject_img_mount"
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
    $TOOLS/lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --remove "neo_inject$CURRENT_SUFFIX"
    if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
        lptools_new --super "$SUPER_BLOCK" $LPTOOLS_SLOT_SUFFIX --clear-cow
    fi
    FREE_SIZE_INTO_SUPER="$(lptools_new --super "$SUPER_BLOCK" --free | grep "Free space" | awk '{print $3}')"
    if ! check_size_super "$SIZE_NEO_IMG" ; then
        my_print "- Попытка сжать neo_inject.img"
        resize2fs -M "$NEO_IMG" &>>$LOGN
        resize2fs -M "$NEO_IMG" &>>$LOGN
        resize2fs -M "$NEO_IMG" &>>$LOGN
        SIZE_NEO_IMG=$(stat -c%s $NEO_IMG)
        if ! check_size_super "$SIZE_NEO_IMG" ; then
            return 1
        fi
    fi
    if lptools_new --super $SUPER_BLOCK $LPTOOLS_SLOT_SUFFIX --create "neo_inject${CURRENT_SUFFIX}" "$SIZE_NEO_IMG" &>>$LOGNEO; then
        my_print "- Разметка neo_inject с размером $(awk 'BEGIN{printf "%.1f\n", '$SIZE_NEO_IMG'/1024/1024}')MB"
        if find_block_neo -b "neo_inject${CURRENT_SUFFIX}"; then
            cat "$NEO_IMG" >"$(find_block_neo -b "neo_inject${CURRENT_SUFFIX}")"
            if test_mount_neo_inject "$(find_block_neo -b "neo_inject${CURRENT_SUFFIX}")" &>>$LOGN ; then
                my_print "- Успех записи neo_inject в super"
                FLASH_IN_BOOT=false
                FLASH_IN_VENDOR_BOOT=false
            else
                my_print "- Не удалось смонтировать созданный раздел"
                return 1
            fi
        else
            my_print "- Не удалость найти созданный раздел"
            return 1
        fi
    else
        my_print "- Не удалость создать раздел"
        return 1
    fi
    return 0

}; export -f flash_inject_neo_to_super

check_first_stage_fstab(){ # <--- Определение функции [Аругментов нет]
    for boot in "vendor_boot$CURRENT_SUFFIX" "boot$CURRENT_SUFFIX" ; do
        if ! find_block_neo -c -b $boot ; then
            continue
        fi
        mkdir "$TMPN/check_boot_first_stage/" &>>$NEOLOG
        boot_check_folder="$TMPN/check_boot_first_stage/$boot"
        mkdir -pv "$boot_check_folder/ramdisk_folder" &>>$NEOLOG
        vendor_boot_block=$(find_block_neo -b $boot)
        cd "$boot_check_folder"
        if magiskboot unpack -h "$vendor_boot_block" ; then
            if [[ -f "$boot_check_folder/ramdisk.cpio" ]] ; then
                cd "$boot_check_folder/ramdisk_folder"
                if ! magiskboot cpio "$boot_check_folder/ramdisk.cpio" extract ; then
                    magiskboot decompress "$boot_check_folder/ramdisk.cpio" "$boot_check_folder/ramdisk.d.cpio"
                    rm -f "$boot_check_folder/ramdisk.cpio"
                    mv "$boot_check_folder/ramdisk.d.cpio" "$boot_check_folder/ramdisk.cpio"
                fi
                if magiskboot cpio "$boot_check_folder/ramdisk.cpio" extract ; then
                    for fstab in $(find "$boot_check_folder/ramdisk_folder/" -name "$final_fstab_name"); do
                        if grep -w "/system" $fstab | grep -q "first_stage_mount"; then
                            BOOT_PATCH+="$boot$CURRENT_SUFFIX "
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
        my_print "- Отключение проверки целостности системы"
        ALRADY_DISABLE=true
        $TOOLS/avbctl --force disable-verification
        $TOOLS/avbctl --force disable-verity
    fi
    mountpoint -q /data || mount /data &>>$LOGNEO
    mountpoint -q /data && {
        if $remove_pin; then
            my_print "- Удаление записи о наличии экрана блокировки"
            rm -f /data/system/locksettings*
        fi
        if $wipe_data; then
            my_print "- Очистка раздела /data, за исключением /data/media"
            find /data -maxdepth 1 -mindepth 1 -not -name "media" -exec rm -rf {} \;
        fi
    }
    if ! [[ "$magisk" == false ]]; then
        my_print " "
        my_print "- Установка Magisk:"
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
            unzip "$MAGISK_ZIP" &>>$LOGNEO
            bash $TMPN/$magisk/META-INF/com/google/android/update-binary "$ZIPARG1" "$ZIPARG2" "$MAGISK_ZIP"
        }
        my_print " "
        my_print " "
    fi
    if [[ -f /tmp/recovery.log ]] ; then
        echo -e "\n\n\n\n\n\n\n\nRECOVERYLOGTHIS:\n\n" >>$LOGNEO
        cat /tmp/recovery.log >>$LOGNEO
    fi
}; export -f default_post_install

flash_inject_neo_to_vendor_boot(){
    local boot="$1"
    cat "$NEO_IMG" > "$(find_block_neo -b "${boot}${UNCURRENT_SUFFIX}")"
    if test_mount_neo_inject "$(find_block_neo -b "${boot}${UNCURRENT_SUFFIX}")" ; then
        my_print "- Успех записи neo_inject в ${boot}${UNCURRENT_SUFFIX}"
        return 0
    else
        return 1
    fi
}; export -f flash_inject_neo_to_vendor_boot

echo "- Определение языка" &>>$LOGNEO && { # <--- обычный код
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
    export BOOT_PATCH=""
    export SUPER_THIS=""
    export SUPER_BLOCK=""
    export AONLY=""
    export bootctl_state=""
    export NEO_IMG="$TMPN/neo_inject.img"
    export ALRADY_DISABLE=false
    export install_after_ota=false
    export FLASH_IN_SUPER=false
    export FLASH_IN_VENDOR_BOOT=false
    export FLASH_IN_BOOT=false
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

echo "- Вывод базовой информации" &>>$LOGNEO && { # <--- обычный код
    # Версия программы
    my_print "- $NEO_VERSION"
    my_print "- Скрипт запущен из $WHERE_INSTALLING"
    my_print "- Чтение конфигурации"
}

echo "- Чтение конфига и проверка его досутптности" &>>$LOGNEO && { # <--- обычный код
    export CONFIG_FILE=""

    if echo "$(basename "$ZIPARG3")" | grep -qi "extconfig"; then
        my_print "- В название архива присутсвует extconfig. Будет попытка считать конфиг из той же папки где распаложен установочный архив"
        if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
            CONFIG_FILE="$(dirname "$ZIPARG3")/NEO.config"
        else 
            my_print "- Внешний конфиг не найден. Будет произведено чтение из встроенного"
        fi
    fi
    if [[ -z "$CONFIG_FILE" ]] && [[ -f "$TMPN/unzip/NEO.config" ]] ; then
        CONFIG_FILE="$TMPN/unzip/NEO.config"
    else
        my_print "- Встроенный конфиг не обнаружен"
        my_print "- Выход..."
        abort_neo -e "8.0" -m "Не найден встроенный конфиг"
    fi
    my_print "- Конфиг обнаружен"
    my_print "- Проверка аргументов на соответсвие"

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
            echo "$what fine" &> $LOGNEO
        else
            PROBLEM_CONFIG+="$(grep "${what}=" "$CONFIG_FILE" | grep -v "#") "
        fi
    done
    if check_it "where_to_inject" "super" || check_it "where_to_inject" "auto" || check_it "where_to_inject" "vendor_boot" || check_it "where_to_inject" "boot" ; then
        echo "where_to_inject fine" &> $LOGNEO
    else
        PROBLEM_CONFIG+="$(grep "where_to_inject=" "$CONFIG_FILE" | grep -v "#") "
    fi

    if check_it "force_start" "true" || check_it "force_start" "false" ; then
        echo "force_start fine" &> $LOGNEO
    else
        PROBLEM_CONFIG+="$(grep "force_start=" "$CONFIG_FILE" | grep -v "#") "
    fi
    if [[ -n "$PROBLEM_CONFIG" ]] ; then
        my_print "- Обнаружены проблемы:"
        for text in $PROBLEM_CONFIG ; do 
            my_print "   $text"
        done
        abort_neo -e 2.8 -m "Проблема с конифгом"
    fi
    source "$CONFIG_FILE" || abort_neo -e "8.2" -m "Не удалось считать файл конфигурации"
    my_print "- Все впорядке!"  
}

echo "- Проверка доступтности bootctl & snapshotctl" &>>$LOGNEO && { # <--- обычный код
    bootctl $>$LOGNEO
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

echo "- Чтение пропов и определние слота" &>>$LOGNEO && { # <--- обычный код
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

echo "- Поиск раздела super" &>>$LOGNEO && { # <--- обычный код
    my_print "- Проверка на наличие super раздела"
    SUPER_BLOCK=$(find_super_partition)
    if [[ -z "$SUPER_BLOCK" ]] ; then
        my_print "- Раздел super не найден"
        SUPER_DEVICE=false
    else
        my_print "- Раздел super найден по пути:"
        my_print ">>> $SUPER_BLOCK"
        SUPER_DEVICE=true
    fi
}

echo "- Проверка устройства на поддердку если нет super и a_only устройство" &>>$LOGNEO && { # <--- обычный код
    if ! $SUPER_DEVICE && $A_ONLY_DEVICE ; then
        abort_neo -e "9.1" -m "Текущая версия DFE-NEO не поддерживает A-only и устройства без super раздела одновременно"
    fi
}

echo "- Поиск базовых блоков recovery|boot|vendor_boot и проверка для whare_to_inject" &>>$LOGNEO && { # <--- обычный код
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
        VENDOR_BOOT_DEVICE=true
    else
        if ! $RECOVERY_DEVICE ; then 
            my_print "- Vendor_boot раздел не найден, будет еще сложнее"
        else
            my_print "- Vendor_boot раздел не найден, будет сложнее"
        fi
        VENDOR_BOOT_DEVICE=false
    fi

    check_whare_to_inject
}

echo "- Проверка запущенной системы и OTA статуса, переопределние слота на противоположный" &>>$LOGNEO && { # <--- обычный код
    if $SYS_STATUS ; then
        if ! $SNAPSHOTCTL_STATE ; then
            if ! $force_start ; then 
                my_print "- !! Ошибка в определение статуса обновления системы, бинарник не может быть выполнен"
                my_print "- Требуется уточнение пользователя, установка в текущую прошивку?"
                if volume_selector "Текущая система" "Выход" ; then
                    echo "- продолжить установку" &>>$NEOLOG
                    get_current_suffix --current
                else
                    exit 82
                fi
            else
                abort_neo -e "81.1" -m "Ошибка в проверке статуса обновления системы, с функцией force_start=true продолжить нельзя" 
            fi
        fi
        if $SNAPSHOTCTL_STATE ; then
            SNAPSHOT_STATUS=$(snapshotctl dump 2>/dev/null | grep '^Update state:' | awk '{print $3}')
            if [[ "$SNAPSHOT_STATUS" == "none" ]] ; then
                echo "- Установка в текущую прошивку, обновления системы не обнаружено" &>>$NEOLOG
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

default_functions_for_install(){
    if $SUPER_DEVICE ; then
        update_partitions
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
        abort_neo -e 182.5 -m "Не удалось натйи $final_fstab_name в ramdisk boot/vendor_boot"
    fi
    make_neo_inject_img "$TMPN/neo_inject$CURRENT_SUFFIX" "neo_inject" "${VENDOR_FOLDER}/etc/init/hw" "${VENDOR_FOLDER}/etc" || {
        abort_neo -e 36.8 -m "Не удалось создать раздел neo_inject.img"
    }
}

echo "- Старт установки" &>>$LOGNEO && {
    default_functions_for_install
    if $FLASH_IN_SUPER ; then
        if ! flash_inject_neo_to_super ; then
            if $A_ONLY_DEVICE ; then
                abort_neo -e 182.2 -m "Не удалось записать образ в super, для A-only это критично. Выход"
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
            abort_neo -e 192.1 -m "Не удалось записать inject_neo никуда"
        fi
    fi
    ramdisk_first_stage_patch $BOOT_PATCH
    default_post_install
    exit 0
}