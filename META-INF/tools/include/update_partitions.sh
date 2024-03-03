update_partitions(){
    my_print "- $word49"
    BOOTCTL_SUPPORT=false
    if $bootctl_state ; then
        SLOTCURRENT=$($TOOLS/bootctl get-current-slot)
    else
        SLOTCURRENT=""
    fi

    if [[ -z "$SLOTCURRENT" ]] ; then
        case $CSLOT in 
            _a)
                SLOTCURRENT=0
            ;;
            _b)
                SLOTCURRENT=1
            ;;
        esac 
    fi

    if [[ -n "$SLOTCURRENT" ]] ; then 
        case "$SLOTCURRENT" in
            0) 
            SUFFIXCURRENT="_a"
            SUFFIXINCURRENT="_b"
            ;;
            1) 
            SUFFIXCURRENT="_b"
            SUFFIXINCURRENT="_a"
            ;;
        esac
    else
    exit 14
    fi

    for part in /dev/block/mapper/* ; do
    line_to_remove=""
    if [ -b "$part" ] || ( [ -h "$part" ] && [ -b "$(readlink -f "$part")" ] ) ; then
        name_part=$(basename ${part%"$SUFFIXCURRENT"*})
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO
        umount -fl $part &>$LOGNEO

        $TOOLS/lptools_new --super $super_block --slot 1 --suffix _a --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 1 --suffix _b --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 0 --suffix _a --unmap $(basename ${part}) &>$LOGNEO
        $TOOLS/lptools_new --super $super_block --slot 0 --suffix _b --unmap $(basename ${part}) &>$LOGNEO
        if [ "$name_part" == "system" ] ; then 
        name_part=system_root
        fi
        line_to_remove=$(cat /etc/fstab | grep -w "/$name_part")
        if [[ -n $line_to_remove ]] ; then
        echo "$line_to_remove" &>$LOGNEO
        sed -i "/${line_to_remove//\//\\/}/d" /etc/fstab
        fi
    fi
    done


    for CHECK_SLOT in 0 1 ; do 
        for CHECK_SUFFIX in _a _b ; do
            if $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --map system$CHECK_SUFFIX &> $TMPN/outSlog ; then
                if $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --map vendor$CHECK_SUFFIX &> $TMPN/outVlog ; then
                    if ! (grep "Creating dm partition for" $TMPN/outSlog &>$LOGNEO) && ! (grep "Creating dm partition for" $TMPN/outVlog &>$LOGNEO)  ; then
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                        continue
                    fi
                    if (grep "Could not map partition:" $TMPN/outSlog &>$LOGNEO) && (grep "Could not map partition:" $TMPN/outVlog &>$LOGNEO) ; then
                        continue
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                    fi
                    
                    DM_PATHS=$(grep "Creating dm partition for" $TMPN/outSlog | awk '{print $9}')
                    DM_PATHV=$(grep "Creating dm partition for" $TMPN/outVlog | awk '{print $9}')

                    if [[ -n "$DM_PATHS" ]] ; then 
                        [ -d $TMPN/mount_test ] || mkdir $TMPN/mount_test
                        if ! mount -r $DM_PATHS $TMPN/mount_test &>$LOGNEO ; then
                            if ! mount -r $DM_PATHS $TMPN/mount_test &>$LOGNEO ; then
                                if ! mount -r $DM_PATHS $TMPN/mount_test &>$LOGNEO ; then 
                                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
                                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                                    continue
                                fi 
                            fi 
                        fi
                    else 
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                        continue 
                    fi 
                    umount -fl $DM_PATHS &>$LOGNEO
                    umount -fl $DM_PATHS &>$LOGNEO
                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
                    if [[ -n "$DM_PATHV" ]] ; then 
                        [ -d $TMPN/mount_test ] || mkdir $TMPN/mount_test
                        if ! mount -r $DM_PATHV $TMPN/mount_test &>$LOGNEO ; then
                            if ! mount -r $DM_PATHV $TMPN/mount_test &>$LOGNEO ; then
                                if ! mount -r $DM_PATHV $TMPN/mount_test &>$LOGNEO ; then 
                                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                                    continue
                                fi 
                            fi 
                        fi
                    else 
                        $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                        continue 
                    fi 
                    umount -fl $DM_PATHV &>$LOGNEO
                    umount -fl $DM_PATHV &>$LOGNEO
                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                    
                    
                    ACTIVE_SLOT_SUFFIX+="$CHECK_SLOT:$CHECK_SUFFIX "
                else 
                    $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap vendor$CHECK_SUFFIX &>$LOGNEO
                fi
            else
                $TOOLS/lptools_new --super $super_block --slot $CHECK_SLOT --suffix $CHECK_SUFFIX --unmap system$CHECK_SUFFIX &>$LOGNEO
            fi
        done 
    done

    echo "$ACTIVE_SLOT_SUFFIX" &>$LOGNEO
    case "${ACTIVE_SLOT_SUFFIX// /}" in 
    "0:_a1:_a"|"0:_a") 
        export FINAL_ACTIVE_SLOT=0
        export FINAL_ACTIVE_SUFFIX=_a
    ;;
    "0:_b1:_b"|"1:_b") 
        export FINAL_ACTIVE_SLOT=1
        export FINAL_ACTIVE_SUFFIX=_b
    ;;
    "0:_a1:_b")
        if grep -q "source_slot: A" /tmp/recovery.log && grep -q "target_slot: B" /tmp/recovery.log ; then
        export FINAL_ACTIVE_SLOT=1
        export FINAL_ACTIVE_SUFFIX=_b
        elif grep -q "target_slot: B" /tmp/recovery.log && grep -q "source_slot: A" /tmp/recovery.log ; then
        export FINAL_ACTIVE_SLOT=0
        export FINAL_ACTIVE_SUFFIX=_a
        else
        export FINAL_ACTIVE_SLOT=$SLOTCURRENT
        export FINAL_ACTIVE_SUFFIX=$SUFFIXCURRENT
        fi
    ;;
    "0:_a0:_b1_:a1:_b")
        my_print " !!!!!!!!! " 
        
        if ! $force_start ; then 
        my_print "- $word93"
            my_print "    $word94" -s
            my_print "    $word95" -s
            if volume_selector ; then 
                export FINAL_ACTIVE_SLOT=0
                export FINAL_ACTIVE_SUFFIX=_a
            else
                export FINAL_ACTIVE_SLOT=1
                export FINAL_ACTIVE_SUFFIX=_b
            fi
        else 
            my_print "- $word96"
            exit 119
        fi
    ;;
    *)
    exit 118
    ;;
    esac 
    for suffix_for in _a _b ; do 
        for file_for_mapper in /dev/block/mapper/*$suffix_for ; do
                $TOOLS/lptools_new --super $super_block --slot 0 --suffix $suffix_for --unmap $file_for_mapper &>$LOGNEO
                $TOOLS/lptools_new --super $super_block --slot 1 --suffix $suffix_for --unmap $file_for_mapper &>$LOGNEO
        done
    done
    for partition in $($TOOLS/lptools_new --super $super_block --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --get-info | grep "NamePartInGroup->" | grep -v "neo_inject" | awk '{print $1}') ; do
        name_part=${partition/"NamePartInGroup->"/}
        echo "$name_part" &>$LOGNEO
        if $TOOLS/lptools_new --super $super_block --slot $FINAL_ACTIVE_SLOT --suffix $FINAL_ACTIVE_SUFFIX --map $name_part > $TMPN/outlog ; then
            cat $TMPN/outlog
            DM_PATH=$(grep "Creating dm partition for" $TMPN/outlog | awk '{print $9}')
            name_part_without_suffix=$(basename ${name_part%"$FINAL_ACTIVE_SUFFIX"*})
            if [ "$name_part_without_suffix" == "system" ] ; then 
            name_part_without_suffix=system_root
            fi
            echo "$name_part_without_suffix" &>$LOGNEO
            echo "$DM_PATH /$name_part_without_suffix auto ro 0 0" >> /etc/fstab
            sleep 1
        fi

    done
   
    echo 4 &>$LOGNEO
    if ! [[ "$SLOTCURRENT" == "$FINAL_ACTIVE_SLOT" ]] ; then
        $TOOLS/magisk resetprop ro.boot.slot_suffix $FINAL_ACTIVE_SUFFIX
        grep androidboot.slot_suffix /proc/bootconfig && {
            echo 5 &>$LOGNEO
            edit_text="$(cat /proc/bootconfig | sed 's/androidboot.slot_suffix = "'$SUFFIXCURRENT'"/androidboot.slot_suffix = "'$FINAL_ACTIVE_SUFFIX'"/')"
            echo -e "$edit_text" > $TMPN/bootconfig_new 
            # my_print 1
            mount $TMPN/bootconfig_new /proc/bootconfig &>$LOGNEO
        }
        echo 7 &>$LOGNEO
        grep "androidboot.slot_suffix=$SUFFIXCURRENT" /proc/cmdline && {
            edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot_suffix='$SUFFIXCURRENT'/androidboot.slot_suffix='$FINAL_ACTIVE_SUFFIX'/')"
            echo -e "$edit_text" > $TMPN/cmdline_new 
            # my_print 2
            mount $TMPN/cmdline_new /proc/cmdline &>$LOGNEO
        }
        echo 8 &>$LOGNEO
        grep "androidboot.slot=$SUFFIXCURRENT" /proc/cmdline && {
            edit_text="$(cat /proc/cmdline | sed 's/androidboot.slot='$SUFFIXCURRENT'/androidboot.slot='$FINAL_ACTIVE_SUFFIX'/')"
            echo -e "$edit_text" > $TMPN/cmdline_new2 
            # my_print 3
            mount $TMPN/cmdline_new2 /proc/cmdline &>$LOGNEO
        }
        for part_link_to_slot in $(find /dev/block -name by-name) ; do
        #   my_print "$part_link_to_slot"
        echo 1 &>$LOGNEO
            for files_in_blockdev in $part_link_to_slot/*$SUFFIXCURRENT ; do
            # my_print "$files_in_blockdev"
            echo 2 &>$LOGNEO
            files_in_blockdev_suff=${files_in_blockdev%"$SUFFIXCURRENT"*}
            #   my_print "$files_in_blockdev_suff"
            if [ -h $files_in_blockdev_suff ] ; then
            #   my_print "- rm -rf $files_in_blockdev_suff " 
                echo  "$(basename $files_in_blockdev_suff)$FINAL_ACTIVE_SUFFIX" $files_in_blockdev_suff &>$LOGNEO
                rm -rf $files_in_blockdev_suff 
                ln -sf "$(basename $files_in_blockdev_suff)$FINAL_ACTIVE_SUFFIX" $files_in_blockdev_suff
            fi
            done

        done
        if $bootctl_state ; then
            $TOOLS/bootctl set-active-boot-slot $FINAL_ACTIVE_SLOT
        fi
    
    fi

    return 0 

}