
# $LOGNEO - Константа, объявлена в update-binary. Путь к лог файлу

CONFIG_NEO="$1"
check_it(){
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
}
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
        PROBLEM_CONFIG+="$(grep "${true_false_ask}=" "$CONFIG_NEO" | grep -v "#")"
    fi
done
if check_it "where_to_inject" "super" || check_it "where_to_inject" "vendor_boot" || check_it "where_to_inject" "boot" ; then
    echo "where_to_inject fine" &> $LOGNEO
else
    PROBLEM_CONFIG+="$(grep "where_to_inject=" "$CONFIG_NEO" | grep -v "#")"
fi

if check_it "force_start" "true" || check_it "force_start" "false" ; then
    echo "force_start fine" &> $LOGNEO
else
    PROBLEM_CONFIG+="$(grep "force_start=" "$CONFIG_NEO" | grep -v "#")"
fi

if [[ -n "$PROBLEM_CONFIG" ]] ; then
    my_print "- Обнаружены проблемы:"
    for text in "$PROBLEM_CONFIG" ; do 
        my_print "   $text"
    done
    return 1
fi
