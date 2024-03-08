




source update_partitions
CSUFFIX=$(getprop ro.boot.slot_suffix)
if [[ -z "$CSUFFIX" ]]; then
    CSUFFIX=$(grep_cmdline androidboot.slot_suffix)
    if [[ -z "$CSUFFIX" ]]; then
        CSUFFIX=$(grep_cmdline androidboot.slot)
    fi
fi
case "$CSUFFIX" in
    "_a") 
    CSLOTSLOT=0
    RCSLOTSLOT=1
    CSUFFIX="_a" 
    RCSUFFIX="_b" 
    ;;
    "_b") 
    CSLOTSLOT=1
    RCSLOTSLOT=0
    CSUFFIX="_b" 
    RCSUFFIX="_a" 
    ;;
    *) 
    abort_neo "- Что то пошло не так"
    ;;
esac

my_print "- Загрузочный слот перераспределен"
my_print "- Загрузочный слот: $CSUFFIX"

source check_installing_neo