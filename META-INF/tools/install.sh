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

    