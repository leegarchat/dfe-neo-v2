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

get_current_suffix(){ # <--- Определение функции [--curent] [--uncurrent] задает CURRENT_SUFFIX|UNCURRENT_SUFFIX|CURRENT_SLOT|UNCURRENT_SLOT|OUT_MESSAGE_SUFFIX
    export CURRENT_SUFFIX=""
    export UNCURRENT_SUFFIX=""
    export CURRENT_SLOT="0"
    export UNCURRENT_SLOT="1"
    export OUT_MESSAGE_SUFFIX="A-ONLY"
    case "$1" in
        --curent) ; A_CASE="_a" ; B_CASE="_b" ;;
        --uncurent) ; B_CASE="_a" ; B_CASE="_a";;
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


    