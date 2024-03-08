


if [[ $hide_not_encrypted == "ask" ]] ; then
        my_print " "
        my_print "- Установить патч, который скроет отсутствие шифрования?"
        my_print "- **Будет работать только если установлен Magisk или KSU или Selinux в режиме Permissive"
        my_print "    Да 'установить' - Громкость вверх (+)" -s
        my_print "    Нет 'не устанавливать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'установить' - Громкость вверх (+)"
            hide_not_encrypted=true
        else
            my_print "**> Нет 'не устанавливать' - Громкость вниз (-)"
            hide_not_encrypted=false
        fi
    fi
    if [[ $safety_net_fix == "ask" ]] ; then
        my_print " "
        my_print "- Установить встроенный safety net fix?"
        my_print "- **Будет работать только если установлен Magisk или KSU или Selinux в режиме Permissive"
        my_print "    Да 'установить' - Громкость вверх (+)" -s
        my_print "    Нет 'не устанавливать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'установить' - Громкость вверх (+)"
            safety_net_fix=true
        else
            my_print "**> Нет 'не устанавливать' - Громкость вниз (-)"
            safety_net_fix=false
        fi
    fi
    if [[ $wipe_data == "ask" ]] ; then
        my_print " "
        my_print "- Сделать wipe data? удалит все данные прошивки, внутренняя память не будет тронута"
        my_print "    Да 'удалить' - Громкость вверх (+)" -s
        my_print "    Нет 'не трогать!' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'удалить' - Громкость вверх (+)"
            wipe_data=true
        else
            my_print "**> Нет 'не трогать!' - Громкость вниз (-)"
            wipe_data=false
        fi
    fi
    if [[ $remove_pin == "ask" ]] ; then
        my_print " "
        my_print "- Удалить данные экрана блокировки?"
        my_print "    Да 'удалить' - Громкость вверх (+)" -s
        my_print "    Нет 'не трогать!' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'удалить' - Громкость вверх (+)"
            remove_pin=true
        else
            my_print "**> Нет 'не трогать!' - Громкость вниз (-)"
            remove_pin=false
        fi
    fi
    if [[ $modify_early_mount == "ask" ]] ; then
        my_print " "
        my_print "- Подключать измененный fstab во время раннего монтирования разделов?"
        my_print "- ** Нужно в основном если вы использовали дополнительные ключи dfe_paterns для системных разделов или использовали ключ -v для удаления оверлеев"
        my_print "    Да 'Подключить' - Громкость вверх (+)" -s
        my_print "    Нет 'Нет нужды' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'Подключить' - Громкость вверх (+)"
            modify_early_mount=true
        else
            my_print "**> Нет 'Нет нужды' - Громкость вниз (-)"
            modify_early_mount=false
        fi
    fi
    if [[ $disable_verity_and_verification == "ask" ]] ; then
        my_print " "
        my_print "- Удалить проверку целостности системы?"
        my_print "- ** Эта опция патчит vbmeta и system_vbmeta тем самым отключает проверку целостности системы, включите эту опцию если получили bootloop или если знаете зачем она нужна, в ином случае просто не трогайте"
        my_print "    Да 'Отключить' - Громкость вверх (+)" -s
        my_print "    Нет 'Не трогать' - Громкость вниз (-)" -s
        if volume_selector ; then
            my_print "**> Да 'Отключить' - Громкость вверх (+)"
            disable_verity_and_verification=true
        else
            my_print "**> Нет 'Не трогать' - Громкость вниз (-)"
            disable_verity_and_verification=false
        fi
    fi

    if [[ $zygisk_turn_on == "ask" ]] ; then
        my_print " "
        my_print "- $word84"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            zygisk_turn_on=true
            my_print " "
            my_print "- $word85"
            my_print "    $word86" -s 
            my_print "    $word87" -s
            if volume_selector ; then
                zygisk_turn_on_parm=first_time_boot
            else
                zygisk_turn_on_parm=always_on_boot
            fi
        else
            zygisk_turn_on=false
        fi
    elif [[ "$zygisk_turn_on" == "first_time_boot" ]] || [[ "$zygisk_turn_on" == "always_on_boot" ]] ; then
        zygisk_turn_on_parm=$zygisk_turn_on
        zygisk_turn_on=true
    fi
    if [[ $add_custom_deny_list == "ask" ]] ; then
        my_print " "
        my_print "- $word88"
        my_print "    $word65" -s
        my_print "    $word66" -s
        if volume_selector ; then
            add_custom_deny_list=true
            my_print " "
            my_print "- $word89"
            my_print "    $word90" -s
            my_print "    $word91" -s
            if volume_selector ; then
                add_custom_deny_list_parm=first_time_boot
            else
                add_custom_deny_list_parm=always_on_boot
            fi
        else
            add_custom_deny_list=false
        fi
    elif [[ "$add_custom_deny_list" == "first_time_boot" ]] || [[ "$add_custom_deny_list" == "always_on_boot" ]] ; then
        add_custom_deny_list_parm=$add_custom_deny_list
        add_custom_deny_list=true
    fi