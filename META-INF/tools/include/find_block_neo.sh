
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
