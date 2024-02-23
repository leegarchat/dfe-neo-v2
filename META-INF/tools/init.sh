#!/system/bin/sh

for file in magisk sqlite3 magisk.db ; do
    [ -f /vendor/etc/init/hw/$file ] && {
        chmod 777 /vendor/etc/init/hw/$file
    }
done

NEO_RESETPROP(){
    force_write=false
    if [ "$1" = "--force" ] ; then
        force_write=true
        shift 1
    fi
    if [ "$1" = resetprop ] ; then
        if ! [ "$(getprop "$2")" = "" ] || $force_write ; then
            /vendor/etc/init/hw/magisk "$1" "$2" "$3"
        fi
    else
        /vendor/etc/init/hw/magisk "$1" "$2" "$3"
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


add_deny_list_func(){
    if [ "$1" = "add_deny_list_first_time_boot" ]; then 
        first_turn_on=true
    else
        first_turn_on=false
    fi

    if $first_turn_on ; then
        if ( /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "SELECT * FROM settings" | grep fisrt_add_deny_list | grep -q "1" ) ; then
            first_turn_on=true
        else 
            /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_add_deny_list","1")'
            first_turn_on=false
        fi
    fi

    if ! $first_turn_on ; then
        /vendor/etc/init/hw/magisk --denylist enable
        while IFS= read -r line; do
            line1=${line%\|*}
            line2=${line#*\|}
            /vendor/etc/init/hw/magisk --denylist add "$line1" "$line2"
        done <"/vendor/etc/init/hw/denylist.txt"
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
            if ( /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "SELECT * FROM settings" | grep fisrt_start_zygisk | grep "1" ) ; then
                first_turn_on=true
            else 
                /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_start_zygisk","1")'
                first_turn_on=false
            fi
        fi
        if ! $first_turn_on ; then
            if ( /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "SELECT * FROM settings" | grep -q zygisk ) ; then
                if ( /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "SELECT * FROM settings" | grep zygisk | grep -q 0 ) ; then
                    valueDB=$( /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "SELECT rowid,* FROM settings" | grep zygisk )
                    rowid=${valueDB%%\|*}
                    /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db "DELETE FROM settings WHERE rowid=$rowid"
                    /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
                fi
            else
                /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db 'INSERT INTO settings VALUES("zygisk","1")'
            fi
        fi
    else
        cp /vendor/etc/init/hw/magisk.db /data/adb/magisk.db
        if $first_turn_on ; then
            /vendor/etc/init/hw/sqlite3 /data/adb/magisk.db 'INSERT INTO settings VALUES("fisrt_start_zygisk","1")'
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
        if /vendor/etc/init/hw/magisk --denylist status; then
            /vendor/etc/init/hw/magisk --denylist rm com.google.android.gms
        fi
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