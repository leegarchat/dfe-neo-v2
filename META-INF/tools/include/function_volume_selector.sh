


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
volume_selector(){
    while true; do
        volume_selector_count=0
        while true; do
            timeout 0.5 getevent -lqc 1 2>&1 >$volume_selector_events_file &
            sleep 0.1
            volume_selector_count=$((count + 1))
            if (grep -q 'KEY_VOLUMEUP *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
                return 0
            elif (grep -q 'KEY_VOLUMEDOWN *DOWN' $volume_selector_events_file); then
                rm -rf $volume_selector_events_file
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
}
