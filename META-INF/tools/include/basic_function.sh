# $WHERE_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]


my_out_print_not_usage_now(){
        
    ALL_WORDS="$1"
    ALL_WORDS=${ALL_WORDS// /"--SPACE--"}
    if [[ -n "$TERMINAL_SIZE" ]] ; then
        MAXLEN=$(( $TERMINAL_SIZE - 3 ))
    else
        MAXLEN=45
    fi
    case "$languages" in
        zh|hi)
            MAXLEN=$(( $MAXLEN / 2 ))
        ;;
    esac
    if [[ -n "$2" ]] && [[ "$2" == "-s" ]] ; then 
        FIRST_LINE=false
        NULL_FIRST_LINE=true
    else
        FIRST_LINE=true
        NULL_FIRST_LINE=false
    fi
    while true ; do
        if $FIRST_LINE ; then
            case "$out_words" in 
                "- "*)
                    FIRST_LINE_WORD=""
                ;;
                "-"*)
                    FIRST_LINE_WORD=" "
                ;;
                *)
                    FIRST_LINE_WORD="- "
                ;;
            esac
        else 
            if $NULL_FIRST_LINE ; then
                FIRST_LINE_WORD=""
            else
                FIRST_LINE_WORD="  "
            fi
        fi
        if (( $( echo -n "$out_words" | wc -m ) > $MAXLEN )) ; then
            if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                echo -e "ui_print ${FIRST_LINE_WORD}${out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
            else
                echo -e "${FIRST_LINE_WORD}${out_words}"
            fi
            FIRST_LINE=false
            out_words=""
        else
            bak_out_words=$out_words
            if [[ "$ALL_WORDS" == "${ALL_WORDS%%"--SPACE--"*}" ]] ; then
                if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                    echo -e "ui_print ${FIRST_LINE_WORD}$ALL_WORDS\nui_print" >>"/proc/self/fd/$ZIPARG2"
                else
                    echo -e "${FIRST_LINE_WORD}$ALL_WORDS"
                fi
                break
            fi
            
            out_words+="${ALL_WORDS%%"--SPACE--"*} "
            if (( $( echo -n "$out_words" | wc -m ) > $MAXLEN + 3 )) ; then
                if [[ -z $bak_out_words ]] ; then 
                    if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                        echo -e "ui_print ${FIRST_LINE_WORD}${out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
                    else
                        echo -e "${FIRST_LINE_WORD}${out_words}"
                    fi
                    FIRST_LINE=false
                    ALL_WORDS="${ALL_WORDS#*"--SPACE--"}"
                else
                    if [[ $WHEN_INSTALLING == "recovery" ]] ; then
                        echo -e "ui_print ${FIRST_LINE_WORD}${bak_out_words}\nui_print" >>"/proc/self/fd/$ZIPARG2"
                        else
                        echo -e "${FIRST_LINE_WORD}${bak_out_words}"
                    fi
                    FIRST_LINE=false
                fi
                out_words=""
            else
                ALL_WORDS="${ALL_WORDS#*"--SPACE--"}"
            fi
        fi
    done

}