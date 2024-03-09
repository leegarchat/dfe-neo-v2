# $WHEN_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]


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

    