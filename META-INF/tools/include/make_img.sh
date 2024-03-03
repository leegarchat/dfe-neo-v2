make_img() {
    TARGET_DIR="$1"
    LABLE="$2"
    SYSTEM_FOLDER_OWNER="$3"
    INJECT_TMP_FOLDER_ONWER="$4"
    FILE_CONTEXTS_FILE="$TMPN/${LABLE}_file_contexts"
    FS_CONFIG_FILE="$TMPN/${LABLE}_fs_config"
    for file in "$FILE_CONTEXTS_FILE" "$FS_CONFIG_FILE" ; do
        [ -f "$file" ] && rm -f "$file"
    done
    {
    find $TARGET_DIR | while read FILE
    do
        if [ -e "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" ] && [ -n "$3" ] ; then
            OWNER=$($TOOLS/busybox stat -Z "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            if [ -z "${OWNER}" ] ; then
                OWNER=$($TOOLS/busybox stat -Z $(dirname "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}") | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            fi
        elif [ -e "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" ] && [ -n "$4" ] ; then
            OWNER=$($TOOLS/busybox stat -Z "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            if [ -z "${OWNER}" ] ; then
                OWNER=$($TOOLS/busybox stat -Z $(dirname "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}") | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            fi
        else
            OWNER=$($TOOLS/busybox stat -Z "$FILE" | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            if [ -z "${OWNER}" ] ; then
                OWNER=$($TOOLS/busybox stat -Z $(dirname "$FILE") | $TOOLS/busybox awk '/^S_Context/ {print $2}')
            fi
        fi
        FILE_FORMAT=$(echo "${FILE#$TARGET_DIR}" | $TOOLS/busybox awk '{ gsub(/\./, "\\."); gsub(/\ /, "\\ "); gsub(/\+/, "\\+"); gsub(/\[/, "\\["); print }')
        if [ -d "${FILE}" ] ; then 
            CONTEXT_LINE="/${LABLE}${FILE_FORMAT}(/.*)? ${OWNER}"
            echo $CONTEXT_LINE >> "${FILE_CONTEXTS_FILE}"
        fi
            su_contects=false
        for check_su_contects in "magisk.db" "denylist.txt" "sqlite3" "init.sh" "magisk" ; do 
            if echo "${FILE#$TARGET_DIR}" | grep -q "$check_su_contects" ; then 
               su_contects=true 
            fi
        done
        if $su_contects ; then 
            CONTEXT_LINE="/${LABLE}${FILE_FORMAT} u:r:su:s0"
        else 
            CONTEXT_LINE="/${LABLE}${FILE_FORMAT} ${OWNER}"
        fi
        if ! [ "${LABLE}${FILE#$TARGET_DIR}" == "${LABLE}" ] ; then
            echo $CONTEXT_LINE >> "${FILE_CONTEXTS_FILE}"
        fi
        
    done
    } & {

    find $TARGET_DIR | while read FILE
    do
        if ! [ "${LABLE}${FILE#$TARGET_DIR}" == "${LABLE}" ] ; then
            if [ -e "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" ] && [ -n "$3" ]  ; then
                PERMISSIONS_GROUPS=$($TOOLS/busybox stat -c "%u %g 0%a" "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}")
                LINKER_FILE=$($TOOLS/busybox stat "$SYSTEM_FOLDER_OWNER${FILE#$TARGET_DIR}" | $TOOLS/busybox awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
            elif [ -e "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" ] && [ -n "$4" ]  ; then
                PERMISSIONS_GROUPS=$($TOOLS/busybox stat -c "%u %g 0%a" "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}")
                LINKER_FILE=$($TOOLS/busybox stat "$INJECT_TMP_FOLDER_ONWER${FILE#$TARGET_DIR}" | $TOOLS/busybox awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
            else
                PERMISSIONS_GROUPS=$($TOOLS/busybox stat -c "%u %g 0%a" "$FILE")
                LINKER_FILE=$($TOOLS/busybox stat "$FILE" | $TOOLS/busybox awk -F"'" '/->/ && !found {split($0, arr, "->"); gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[2]); gsub(/\ /, "\\ ", arr[2]); gsub(/[\047]/, "", arr[2]); print arr[2]; found=1}')
            fi
            
            FILE_FORMAT=$(echo "${FILE#$TARGET_DIR}" | $TOOLS/busybox awk '{ gsub(/\ /, "\\ "); print }')
            FS_CONFIG_LINE="${LABLE}${FILE_FORMAT} ${PERMISSIONS_GROUPS} ${LINKER_FILE}"
            echo "$FS_CONFIG_LINE" >> "${FS_CONFIG_FILE}"
        fi
        
    done
    }
    wait
    $TOOLS/make_ext4fs -J -T 1230764400 \
            -S "${FILE_CONTEXTS_FILE}" \
            -l "$($TOOLS/busybox du -sb "${TARGET_DIR}" | $TOOLS/busybox awk '{print int($1*50)}')" \
            -C "${FS_CONFIG_FILE}" -a "${LABLE}" -L "${LABLE}" \
            "$TMPN/${LABLE}.img" "${TARGET_DIR}"

    resize2fs -M $TMPN/${LABLE}.img
    resize2fs -M $TMPN/${LABLE}.img
    resize2fs -M $TMPN/${LABLE}.img
    resize2fs -f $TMPN/${LABLE}.img "$(($(stat -c%s $TMPN/${LABLE}.img)*2/512))"s
        

}