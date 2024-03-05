

# $LOGNEO - Константа, объявлена в update-binary. Путь к лог файлу
abort_neo(){
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
}
export -f abort_neo