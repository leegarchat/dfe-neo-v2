#!/system/bin/sh


TMP_BINARY=$(dirname "$0")
BBBIN=""
FSTAB_PATCH_PATERNS=EXEMPLE

for file in magisk sqlite3 magisk.db bash busybox ; do
    [ -f "$TMP_BINARY/$file" ] && {
        chmod 777 "$TMP_BINARY/$file"
        [ "$file" = "busybox" ] && {
            if "$TMP_BINARY/$file" ; then
                BBBIN="$TMP_BINARY/$file"
            fi
        }
    }
done
case "$TMP_BINARY" in
    /vendor/etc/*)
        echo ""
    ;;
    *)
        if [ -z "$BASH_VERSION" ] ; then
            BASH_VERSION=none
        fi
        if ! [ "$BASH_VERSION" = "5.2.21(1)-release" ] && [ -f "$TMP_BINARY/bash" ] ; then
            "$TMP_BINARY"/bash "$0" "$@"
            exit $?
        fi
    ;;
esac


NEO_RESETPROP(){
    force_write=false
    if [ "$1" = "--force" ] ; then
        force_write=true
        shift 1
    fi
    if [ "$1" = resetprop ] ; then
        if ! [ "$(getprop "$2")" = "" ] || $force_write ; then
            "$TMP_BINARY/magisk" "$1" "$2" "$3"
        fi
    else
        "$TMP_BINARY/magisk" "$1" "$2" "$3"
    fi
}
maybe_set_prop() {
    prop="$1"
    contains="$2"
    value="$3"
    case "$(getprop "$prop")" in 
        *"$contains"*)
            NEO_RESETPROP resetprop "$prop" "$value"
        ;;
    esac
}

patch_fstab_neo(){ # <--- Определение функции [-m, -r|-p, -f, -o, -v]
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
                            $BBBIN echo "No patterns provided for removal."
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
            if [ "$output_fstab" == "fstab\*" ] ; then
                exit 192
            fi
            shift 2
            ;;
        -v) 
            removeoverlay=true
            shift 1
            ;;
        *)  
            echo "Unknown parameter: $1"
            exit 1
            ;;
        esac
    done
    $BBBIN echo -n "" > "$output_fstab"
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
                $BBBIN echo "comment line $line"
            ;;
            *)
                if [ "$($BBBIN echo "$removepattern" | $BBBIN wc -w)" -gt 0 ]; then
                    for arrp in $removepattern ; do
                        mountpoint=${arrp%%"--m--"*}
                        patterns=${arrp##*"--m--"}
                        remove_paterns=$($BBBIN echo -e ${patterns//"--p--"/"\n"} | $BBBIN grep "\-\-r--")
                        replace_patterns=$($BBBIN echo -e ${patterns//"--r--"/"\n"} | $BBBIN grep "\-\-p--")
                        if [ "$($BBBIN echo "$line" | $BBBIN awk '{print $2}')" == "$mountpoint" ]; then
                            for replace_pattern in ${replace_patterns//"--p--"/ } ; do
                                if $BBBIN echo "$line" | $BBBIN grep -q "${replace_pattern%%"--to--"*}" ; then
                                    line=$($BBBIN echo "$line" | $BBBIN sed -E "s/,${replace_pattern%%"--to--"*}*[^[:space:]|,]*/,${replace_pattern##*"--to--"}/")
                                fi
                                if $BBBIN echo "$line" | $BBBIN grep -q "${replace_pattern%%"--to--"*}" && ! ($BBBIN echo "$line" | $BBBIN grep -q "${replace_pattern##*"--to--"}"); then 
                                    line=$($BBBIN echo "$line" | $BBBIN sed -E "s/${replace_pattern%%"--to--"*}*[^[:space:]|,]*/${replace_pattern##*"--to--"}/")
                                fi 
                            done
                            for remove_pattern in ${remove_paterns//"--r--"/ }; do
                                if $BBBIN echo "$line" | $BBBIN grep -q "${remove_pattern}" ; then 
                                    line=$($BBBIN echo "$line" | sed -E "s/,${remove_pattern}*[^[:space:]|,]*//")
                                fi
                                if $BBBIN echo "$line" | $BBBIN grep -q "${remove_pattern}" ; then 
                                    line=$($BBBIN echo "$line" | $BBBIN sed -E "s/${remove_pattern}*[^[:space:]|,]*//")
                                fi
                            done
                        fi


                    done
                fi
            ;;
        esac
        $BBBIN echo "$line" >>"$output_fstab"
    done <"$input_fstab"
    $BBBIN echo "# NEOv1 fstab_patcher" >>"$output_fstab"

}

add_deny_list_func(){
    if [ "$1" = "add_deny_list_first_time_boot" ]; then 
        first_turn_on=true
    else
        first_turn_on=false
    fi

    if $first_turn_on ; then
        if ( "$TMP_BINARY/sqlite3" /data/adb/magisk.db "SELECT * FROM settings" | grep fisrt_add_deny_list | grep -q "1" ) ; then
            first_turn_on=true
        else 
            "$TMP_BINARY/sqlite3" /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_add_deny_list","1")'
            first_turn_on=false
        fi
    fi

    if ! $first_turn_on ; then
        "$TMP_BINARY/magisk" --denylist enable
        while IFS= read -r line; do
            line1=${line%\|*}
            line2=${line#*\|}
            "$TMP_BINARY/magisk" --denylist add "$line1" "$line2"
        done <"$TMP_BINARY/denylist.txt"
    fi
    

}

turn_on_zygisk(){

    if [ "$1" = "zygisk_on_first_time_boot" ]; then 
        first_turn_on=true
    else
        first_turn_on=false
    fi
    while ! [ -d /data/system ]; do
        sleep 0.04
    done
    if [ -f /data/adb/magisk.db ] ; then
        if $first_turn_on ; then
            if ( "$TMP_BINARY/sqlite3" /data/adb/magisk.db "SELECT * FROM settings" | grep fisrt_start_zygisk | grep "1" ) ; then
                first_turn_on=true
            else 
                "$TMP_BINARY/sqlite3" /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_start_zygisk","1")'
                first_turn_on=false
            fi
        fi
        if ! $first_turn_on ; then
            if ( "$TMP_BINARY/sqlite3" /data/adb/magisk.db "SELECT * FROM settings" | grep -q zygisk ) ; then
                if ( "$TMP_BINARY/sqlite3" /data/adb/magisk.db "SELECT * FROM settings" | grep zygisk | grep -q 0 ) ; then
                    valueDB=$( "$TMP_BINARY/sqlite3" /data/adb/magisk.db "SELECT rowid,* FROM settings" | grep zygisk )
                    rowid=${valueDB%%\|*}
                    "$TMP_BINARY/sqlite3" /data/adb/magisk.db "DELETE FROM settings WHERE rowid=$rowid"
                    "$TMP_BINARY/sqlite3" /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
                fi
            else
                "$TMP_BINARY/sqlite3" /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
            fi
        fi
    else
        cp "$TMP_BINARY/magisk.db" /data/adb/magisk.db
        if $first_turn_on ; then
            "$TMP_BINARY/sqlite3" /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_start_zygisk","1")'
        fi
        chmod 600 /data/adb/magisk.db
    fi 
}

case "$1" in

    hide_decrypted)
        NEO_RESETPROP --force resetprop ro.crypto.state encrypted
    ;;

    zygisk_on*)
        turn_on_zygisk "$1"
    ;;
    add_deny_list*)
        add_deny_list_func "$1"
    ;;
    custom_reset_prop*)
        NEO_RESETPROP --force resetprop "$2" "$3"
    ;;


    safetynet_init)
        NEO_RESETPROP --force resetprop ro.build.type user
        NEO_RESETPROP --force resetprop ro.debuggable 0
        NEO_RESETPROP --force resetprop ro.secure 1
        NEO_RESETPROP --force resetprop ro.boot.flash.locked 1
        NEO_RESETPROP --force resetprop ro.boot.verifiedbootstate green
        NEO_RESETPROP --force resetprop ro.boot.veritymode enforcing
        NEO_RESETPROP --force resetprop ro.boot.vbmeta.device_state locked
        NEO_RESETPROP --force resetprop vendor.boot.vbmeta.device_state locked
        NEO_RESETPROP --force resetprop ro.build.tags release-keys
        NEO_RESETPROP --force resetprop ro.boot.warranty_bit 0
        NEO_RESETPROP --force resetprop ro.vendor.boot.warranty_bit 0
        NEO_RESETPROP --force resetprop ro.vendor.warranty_bit 0
        NEO_RESETPROP --force resetprop ro.warranty_bit 0
        NEO_RESETPROP --force resetprop ro.is_ever_orange 0
    ;;

    safetynet_fs)
        maybe_set_prop resetprop ro.bootmode recovery unknown
        maybe_set_prop resetprop ro.boot.mode recovery unknown
        maybe_set_prop resetprop vendor.boot.mode recovery unknown
        maybe_set_prop ro.boot.hwc CN GLOBAL
        maybe_set_prop ro.boot.hwcountry China GLOBAL
        NEO_RESETPROP --force resetprop --delete ro.build.selinux

        if [ "$(toybox cat /sys/fs/selinux/enforce)" = "0" ]; then
            chmod 640 /sys/fs/selinux/enforce
            chmod 440 /sys/fs/selinux/policy
        fi
        
    ;;

    safatynet_postfs)
        if "$TMP_BINARY/magisk" --denylist status; then
            "$TMP_BINARY/magisk" --denylist rm com.google.android.gms
        fi
    ;;

    fstab_patch)
        for full_path_to_fstab_into_for in /odm/etc/*fstab* /vendor/etc/*fstab* /*fstab* /system/etc/*fstab* ; do
            if ! [ -f "$full_path_to_fstab_into_for" ] ; then
                continue
            fi
            if ! $BBBIN grep '# NEOv1 fstab_patcher' $full_path_to_fstab_into_for ; then
                out_fstab="$TMP_BINARY/fstab_temp_folder/$full_path_to_fstab_into_for"
                mkdir -pv "$TMP_BINARY/fstab_temp_folder/$(dirname "$full_path_to_fstab_into_for")"
                patch_fstab_neo $FSTAB_PATCH_PATERNS -f "$full_path_to_fstab_into_for" -o "$out_fstab"
                if [[ -f "$out_fstab" ]] ; then
                    mount "$out_fstab" "$full_path_to_fstab_into_for"
                fi
            fi
        done
    ;;


    safetynet_boot_complite)
        NEO_RESETPROP --force resetprop ro.boot.flash.locked 1
        NEO_RESETPROP --force resetprop ro.boot.vbmeta.device_state locked
        NEO_RESETPROP --force resetprop vendor.boot.verifiedbootstate green
        NEO_RESETPROP --force resetprop ro.boot.verifiedbootstate green
        NEO_RESETPROP --force resetprop ro.boot.veritymode enforcing
        NEO_RESETPROP --force resetprop vendor.boot.vbmeta.device_state locked
        NEO_RESETPROP --force resetprop vendor.boot.verifiedbootstate green
    ;;

    # patch120dynamic)
    #     pm $2 com.miui.powerkeeper/.statemachine.PowerStateMachineService
    # ;;
esac