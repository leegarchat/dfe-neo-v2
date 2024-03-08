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

source $TMP_TOOLS/include/first_add_binary_to_PATH.sh
type my_print || exit 79

my_print "- Определение функций"

source function_abort_neo
source function_volume_selector



my_print "- Определение стандартных переменных"
source first_set_default_args
source fisrt_set_languages


# Версия программы
my_print "- $NEO_VERSION"
my_print "- Скрипт запущен из $WHERE_INSTALLING"
my_print "- Чтение конфигурации"
source first_read_config


bootclt $>$LOGNEO
if [[ "$?" == "64" ]] ; then
    bootctl_state=true
else
    bootctl_state=false
fi
snapshotctl $>$LOGNEO
if [[ "$?" == "64" ]] ; then
    snapshotctl_state=true
else
    snapshotctl_state=false
fi


my_print "- Чтение пропов и определние переменных"
CSUFFIX=$(getprop ro.boot.slot_suffix)
if [ -z $CSUFFIX ]; then
    CSUFFIX=$(grep_cmdline androidboot.slot_suffix)
    if [ -z $CSUFFIX ]; then
        CSUFFIX=$(grep_cmdline androidboot.slot)
    fi
fi
case "$CSUFFIX" in
    "_a") 
    CSUFFIX="_a" 
    RCSUFFIX="_b" 
    ;;
    "_b") 
    CSUFFIX="_b" 
    RCSUFFIX="_b" 
    ;;
    *) 
    CSUFFIX="" 
    ;;
esac

if [[ -n "$CSLOT" ]] ; then
    my_print " "
    my_print "- Устройства A/B"
    my_print "- Текущий слот: $CSLOT"
    AONLY=false
else
    my_print "- Устройство A-only"
    AONLY=true
fi

my_print "- Проверка на наличие super раздела"

SUPER_BLOCK=$(find_super_partition)
if [[ -z "$SUPER_BLOCK" ]] ; then
    my_print "- Раздел super не найден"
    SUPER_THIS=false
else
    my_print "- Раздел super найден по пути:"
    my_print "   $SUPER_BLOCK"
    SUPER_THIS=true
fi

if ! $SUPER_THIS && $AONLY ; then
    abort_neo -e "9.1" -m "Текущая версия DFE-NEO не поддерживает A-only и устройства без super раздела одновременно"
fi
my_print "- Поиск recovery раздела"
if find_block_neo -c -b "recovery" "recovery_a" "recovery_b" ; then
    my_print "- Recovery раздел найден. Будет легко"
    RECOVERY_THIS=true
else
    my_print "- Recovery раздел не найден, будет сложнее"
    RECOVERY_THIS=false
fi
my_print "- Поиск vendor_boot раздела"
if find_block_neo -c -b "vendor_boot" "vendor_boot_a" "vendor_boot_b" ; then
    my_print "- Vendor_boot раздел найден. Будет легко"
    BOOT_PATCH+=" vendor_boot"
    VBOOT_THIS=true
else
    if ! $RECOVERY_THIS ; then 
        my_print "- Vendor_boot раздел не найден, будет еще сложнее"
    else
        my_print "- Vendor_boot раздел не найден, будет сложнее"
    fi
    VBOOT_THIS=false
fi
my_print "- Проверка возможности интеграции NEOv2 метода"

if $SUPER_THIS && ! $AONLY ; then
    case "$WHERE_INSTALLING" in 
        kernelsu|magiskapp)
            source install_for_system_super_a_b
        ;;
        recovery)
            my_print "- Запуск подпроцесса для A/B устройств с super"
            source install_for_recovery_super_a_b
        ;;
        *)
            abort_neo -e 10.1 -m "Скрипт запущен неправильно, как ты сюда попал?"
        ;;
    esac
elif $SUPER_THIS && $AONLY ; then
    case "$WHERE_INSTALLING" in 
        kernelsu|magiskapp)
            source install_for_system_super_a_only
        ;;
        recovery)
            source install_for_recovery_super_a_only
        ;;
        *)
            abort_neo -e 10.1 -m "Скрипт запущен неправильно, как ты сюда попал?"
        ;;
    esac 
elif ! $SUPER_THIS && ! $AONLY ; then
    case "$WHERE_INSTALLING" in 
        kernelsu|magiskapp)
            source install_for_system_a_b
        ;;
        recovery)
            source install_for_recovery_a_b
        ;;
        *)
            abort_neo -e 10.1 -m "Скрипт запущен неправильно, как ты сюда попал?"
        ;;
    esac 
fi

    

    install_after_ota=false
    if find_block_neo -c -b boot_a && find_block_neo -c -b boot_b && $SYS_STATUS ; then
        $bootctl_state && {
            snapshot_status=$($TOOLS/bootctl get-snapshot-merge-status)
        }
        $bootctl_state && {
            if ! [[ "$snapshot_status" == "$(${TOOLS}/snapshotctl dump 2>/dev/null | grep '^Update state:' | awk '{print $3}')" ]] ; then
                snapshot_status=$($TOOLS/snapshotctl dump 2>/dev/null | grep '^Update state:' | awk '{print $3}')
            fi 
            case "$snapshot_status" in
                cancelled|merging|none|snapshotted)
                    my_print "- Current snapshot state: $snapshot_status"
                    if ! [[ "$snapshot_status" == "none" ]]; then
                        my_print "- Seems like you just installed a rom update."
                        install_after_ota=true
                    fi
                ;;
            esac
        }
    fi



    SWITCH_SLOT_AFTER_OTA=false
    if ! $SYS_STATUS && [[ -n "$CSLOT" ]] ; then
        echo 1
    elif $SYS_STATUS && $install_after_ota ; then
        if $TOOLS/snapshotctl map &>$LOGNEO ; then
            my_print "- Mapping partitions after ota"
            SWITCH_SLOT_AFTER_OTA=true
        else
            exit 22
        fi
    fi 
    case "$CSLOT" in
        "_a") 
            if $SWITCH_SLOT_AFTER_OTA ; then
                CSLOT="_b" 
                CSLOTSLOT=1
                RCSLOTSLOT=0
                RCSLOT="_a"
            else
                CSLOT="_a" 
                CSLOTSLOT=0
                RCSLOTSLOT=1
                RCSLOT="_b"
            fi  
        ;;
        "_b") 
            if $SWITCH_SLOT_AFTER_OTA ; then
                CSLOT="_a" 
                CSLOTSLOT=0
                RCSLOTSLOT=1
                RCSLOT="_b"
            else
                CSLOT="_b" 
                CSLOTSLOT=1
                RCSLOTSLOT=0
                RCSLOT="_a" 
            fi  
        ;;
        *) 
        CSLOT=""
        RCSLOT=""
        ;;
    esac
    export ALRADY_DISABLE=false
    export FLASH_IN_SUPER=false
    export FLASH_IN_AUTO=false
    export FLASH_IN_BOOT=true


    
    echo 12123 &>$LOGNEO

    for boot_sda in vendor_boot boot; do
        if [[ "$boot_sda" == "boot" ]] && ! find_block_neo -c -b recovery${CSLOT} ; then
            continue
        fi

        if [[ "$boot_sda" == "boot" ]] && ! find_block_neo -c -b recovery ; then
            continue
        fi
        for block in $(find_block_neo -b ${boot_sda}${CSLOT}); do

            basename_block="${boot_sda}${CSLOT}"
            work_folder="$TMPN/${basename_block}_check_neo_status"
            row_ramdisk=false
            $TOOLS/toybox mkdir -pv $work_folder
            cd "$work_folder"
            # word27="Не удалось распаковать"
            $TOOLS/magiskboot unpack -h $block &>$work_folder/log.unpack.boot || {
                        if [[ -n "$CSLOT" ]] ; then
                            abort_neo -e "28.1" -m "$word27 boot($basename_block)" 
                        else
                            continue
                        fi
               }

            if $TOOLS/toybox grep "RAMDISK_FMT" $work_folder/log.unpack.boot | $TOOLS/toybox grep "raw" &>$LOGNEO; then
                    if $TOOLS/magiskboot decompress $work_folder/ramdisk.cpio $work_folder/ramdisk.decompress.cpio &>$work_folder/log.decompress.ramdisk ; then
                        row_ramdisk=true     
                    else
                        abort_neo -e 28.2 -m "$word29" # word29="Не получилось декмопресировать ramdisk"
                    fi  
                    $TOOLS/toybox mv $work_folder/ramdisk.decompress.cpio $work_folder/ramdisk.cpio
                    ramdisk_compress_format=$($TOOLS/toybox grep "Detected format:" $work_folder/log.decompress.ramdisk | $TOOLS/toybox sed 's/.*\[\(.*\)\].*/\1/')
            fi

            if ! [[ -f "$work_folder/ramdisk.cpio" ]] && ! [[ -f "$work_folder/log.unpack.boot" ]]; then
                cd $work_folder/../
                $TOOLS/toybox rm -rf $work_folder
                continue
            fi
            if [[ -f "$work_folder/ramdisk.cpio" ]]; then
                # word31="Распаковка ramdsik.cpio"
                mkdir $work_folder/ramdisk
                cd $work_folder/ramdisk
                "$TOOLS"/magiskboot cpio "$work_folder/ramdisk.cpio" extract &>$LOGNEO
                cd $work_folder
                for fstab in $(find "$work_folder/ramdisk/" -name "fstab.*"); do
                    if $TOOLS/toybox grep -w "/system" $fstab | $TOOLS/toybox grep "first_stage_mount" &>$LOGNEO; then
                        if grep "/venodr/etc/init/hw" "$fstab" &>$LOGNEO || \
                            grep "/vendor/etc/init/hw" "$fstab" &>$LOGNEO || \
                            grep "/system/etc/init/hw" "$fstab" &>$LOGNEO ; then
                            DFE_NEO_DETECT_IN_FSTAB=true
                        fi


                    fi
                done
            fi
            cd $work_folder/../
            $TOOLS/toybox rm -rf $work_folder
        done
    done
    if $DFE_NEO_DETECT_IN_FSTAB && ! $force_start ; then 
        if $DETECT_NEO_IN_BOOT || $DETECT_NEO_IN_SUPER || $DETECT_NEO_IN_VENDOR_BOOT ; then
            my_print " "
            my_print " "
            my_print "- $word55"
            my_print "- $word56"
            my_print "    $word57" -s
            my_print "    $word58" -s
            if ! volume_selector ; then 
                remove_dfe_neo $DETECT_NEO_IN_BOOT $DETECT_NEO_IN_SUPER
                if $DETECT_NEO_IN_VENDOR_BOOT ; then
                    cat "$(find_block_neo -b vendor_boot${CSLOT})" > "$(find_block_neo -b vendor_boot${RCSLOT})"
                fi
                if $DETECT_NEO_IN_BOOT ; then
                    cat "$(find_block_neo -b boot${CSLOT})" > "$(find_block_neo -b boot${RCSLOT})"
                fi
                my_print "- $word59"
                my_print " "
                exit 0
            fi
        fi
    fi
    if [[ $hide_not_encrypted == "ask" ]] ; then
        my_print " "
        my_print "- $word60"
        my_print "- **$word61"
        my_print "    $word63" -s
        my_print "    $word64" -s
        if volume_selector ; then
            hide_not_encrypted=true
        else
            hide_not_encrypted=false
        fi
    fi
    if [[ $safety_net_fix == "ask" ]] ; then
        my_print " "
        my_print "- $word62"
        my_print "- **$word61"
        my_print "    $word63" -s
        my_print "    $word64" -s
        if volume_selector ; then
            safety_net_fix=true
        else
            safety_net_fix=false
        fi
    fi
    if $install_after_ota ; then
        wipe_data=false
    else
        if [[ $wipe_data == "ask" ]] ; then
            my_print " "
            my_print "- $word69"
            my_print "    $word65" -s
            my_print "    $word66" -s
            if volume_selector ; then
                wipe_data=true
            else
                wipe_data=false
            fi
        fi
    fi
    if [[ $remove_pin == "ask" ]] ; then
        my_print " "
        my_print "- $word68"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            remove_pin=true
        else
            remove_pin=false
        fi
    fi
    if [[ $modify_early_mount == "ask" ]] ; then
        my_print " "
        my_print "- $word67"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            modify_early_mount=true
        else
            modify_early_mount=false
        fi
    fi
    if [[ $disable_verity_and_verification == "ask" ]] ; then
        my_print " "
        my_print "- $word92"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            disable_verity_and_verification=true
        else
            disable_verity_and_verification=false
        fi
    fi

    if [[ $zygisk_turn_on == "ask" ]] ; then
        my_print " "
        my_print "- $word84"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            zygisk_turn_on=true
            my_print " "
            my_print "- $word85"
            my_print "    $word86" -s 
            my_print "    $word87" -s
            if volume_selector ; then
                zygisk_turn_on_parm=first_time_boot
            else
                zygisk_turn_on_parm=always_on_boot
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
        my_print "- $word88"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            add_custom_deny_list=true
            my_print " "
            my_print "- $word89"
            my_print "    $word90" -s
            my_print "    $word91" -s
            if volume_selector ; then
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
    case "$where_to_inject" in
    auto*)
        where_to_inject_auto="auto:"
        FLASH_IN_AUTO=true
        where_to_inject=""
        if [[ -z "$CSLOT" ]]; then
            FLASH_IN_BOOT=false
        else 
            
            if ! find_block_neo -c -b "vendor_boot${RCSLOT}"; then
                # word5="Не удалось найти, запись будет принудительно сделана в super"
                my_print "- ${where_to_inject}${RCSLOT} $word70"
                # FLASH_IN_BOOT=false
            else 
                where_to_inject=vendor_boot
                FLASH_IN_SUPER=false
                FLASH_IN_BOOT=true
            fi
            if [[ -z "$where_to_inject" ]] ; then 
                if ! find_block_neo -c -b "boot${RCSLOT}"; then
                    # word5="Не удалось найти, запись будет принудительно сделана в super"
                    my_print "- boot${RCSLOT} and vendor_boot${RCSLOT} $word5"
                    FLASH_IN_BOOT=false
                    FLASH_IN_SUPER=true
                else
                    where_to_inject=boot
                    FLASH_IN_SUPER=false
                    FLASH_IN_BOOT=true
                fi
            fi
        
        fi 
        if [[ -z "$where_to_inject" ]] ; then
            where_to_inject=super
        fi
        ;;
    super*)
        FLASH_IN_SUPER=true
        FLASH_IN_BOOT=false
        ;;
    vendor_boot* | boot*)
        if [[ -z "$CSLOT" ]]; then
            # word4="Запись в vendor_boot или boot не доступтна для a-only. Будет принудительно сделана запись в super"
            abort_neo -e "82.1" -m "Record in Vendor_boot or Boot is not available for A-onels"
        else
            if ! find_block_neo -b "${where_to_inject}${RCSLOT}"; then
                # word5="Не удалось найти, запись будет принудительно сделана в super"
                abort_neo -e "82.1" -m "${where_to_inject}${RCSLOT} It was not possible to find"
            fi
        fi
        ;;
    *)
    # word6="Что то не так"
    abort_neo -e 24.11 -m "$word6"
    ;;
    esac
    

my_print " "



my_print "- $word71" && {
    case $magisk in
        "EXT:"* | "ext:"* | "Ext:"*)
            magisk="$(echo ${magisk} | sed "s/ext://I")"
            if [[ -f "$(dirname "${ZIPARG3}")/${magisk}" ]]; then
                my_print "- $word10 $magisk"
                MAGISK_ZIP="$(dirname "${ZIPARG3}")/${magisk}"
            
            else
                my_print "- $word72"
                magisk=false
            fi
            ;;
        *)
            if [[ -f "$TMPN/unzip/MAGISK/${magisk}.apk" ]]; then
                MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.apk"
                my_print "- $word10 $magisk"
            elif [[ -f "$TMPN/unzip/MAGISK/${magisk}.zip" ]] ; then
                MAGISK_ZIP="$TMPN/unzip/MAGISK/${magisk}.zip"
                my_print "- $word10 $magisk"
            else
                my_print "- $word72"
                magisk=false
            fi
            ;;
    esac 
    select_slot_print=""
    case $where_to_inject in 
        vendor_boot|boot)
            select_slot_print="$RCSLOT"
        ;;
    esac

    # word11="Параметр 'Куда инджектить':"
    my_print "- $word73 $languages"
    my_print "- $word74 ${where_to_inject_auto}${where_to_inject}${select_slot_print}"
    my_print "- $word75 $modify_early_mount"
    my_print "- $word76 $safety_net_fix"
    my_print "- $word77 $hide_not_encrypted"
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
    
    my_print "- $word78 $wipe_data"
    my_print "- $word79 $remove_pin"
    my_print "- $word80 $dfe_paterns"
    my_print "- custom_reset_prop: $custom_reset_prop"
    my_print " "
    my_print " "
    if ! $force_start ; then
        my_print "- $word81"
        my_print "- $word82"
        my_print "- $word83"
        if ! volume_selector ; then 
            exit 1
        fi
    fi

}

# word12="Монтирование раздела Vendor"
my_print "- $word12" && {

    if ! [ -h "$(readlink /dev/block/mapper/vendor${CSLOT})" ] && [ -b "$(readlink /dev/block/mapper/vendor${CSLOT})" ]; then
        SYSTEM_BLOCK=("$(readlink /dev/block/mapper/vendor${CSLOT})")
    fi
    if [[ -z "$SYSTEM_BLOCK" ]] ; then
        VENDOR_BLOCK=$(find_block_neo -b "vendor${CSLOT}")
    fi
    # word13="Не удалось обноружить Vendor раздел"
    [[ -z "${VENDOR_BLOCK}" ]] && abort_neo -e 25.1 -m "$word13" 
    if ! $SYS_STATUS ; then
        umount -fl "${VENDOR_BLOCK}" &>$LOGNEO
    fi 

    name_vendor_block="vendor${CSLOT}"
    full_path_to_vendor_folder=$TMPN/mapper/$name_vendor_block

    $TOOLS/toybox mkdir -pv $full_path_to_vendor_folder
    
    if ! mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO ; then
        mount -o,ro $VENDOR_BLOCK $full_path_to_vendor_folder &>$LOGNEO
    fi
    if ! mountpoint -q $full_path_to_vendor_folder ; then
        if $SYS_STATUS ; then
            if $install_after_ota ; then 
                exit 112
            else
                full_path_to_vendor_folder=/vendor
            fi
        else
            abort_neo -e 25.2 -m "Failed to mount $name_vendor_block" 
        fi
    fi
    
}
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