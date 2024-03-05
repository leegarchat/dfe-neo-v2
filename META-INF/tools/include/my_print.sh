
# $WHERE_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $ZIPARG2 - Константа, объявлена в update-binary. Второй аргумент передаваймы при установке zip в recovery outfd 

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



