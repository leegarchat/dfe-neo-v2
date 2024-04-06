#!/bin/bash

VERSION="$1"
TEST="$2"
if ! type "7z" &>/dev/null ; then
    echo "Не установлен 7z. Нужен для сборки"
fi
change_langues(){
cat "$WORK_DIR/tmp/CONFIG" > "$WORK_DIR/$FOLDER/NEO.config"

while IFS= read -r line; do
    echo "1'$line'"
    case $line in 
        *EXAMPLE_LNG)
        echo "2'$line'"
        new_line=${line/"-EXAMPLE_LNG"/}
        echo "3'$new_line'"
sed -i "/$line/ {r $WORK_DIR/$FOLDER/META-INF/tools/languages/$1/$new_line.lng
  d
}" "$WORK_DIR/$FOLDER/NEO.config"
        ;;
    esac
done <"$WORK_DIR/tmp/CONFIG"
}
DIRNAME="$(dirname "$(realpath "$0")")"
files_needed=(
    customize.sh
    META-INF/com/google/android/update-binary
    META-INF/com/google/android/updater-script
    META-INF/tools/denylist.txt
    META-INF/tools/init.sh
    META-INF/tools/install.sh
    META-INF/tools/languages/en/en.sh
    META-INF/tools/languages/hi/hi.sh
    META-INF/tools/languages/id/id.sh
    META-INF/tools/languages/ru/ru.sh
    META-INF/tools/languages/zh/zh.sh
    META-INF/tools/magisk.db
    module.prop
    NEO.config
    
)
magisk_files=(
    MAGISK/Magisk-Delta-v26.4.apk
    MAGISK/Magisk-Delta-v27.0.apk
    MAGISK/Magisk-kitsune-v27-R65C33E4F.apk
    MAGISK/Magisk-v26.4-kitsune-2.apk
    MAGISK/Magisk-v26.4.apk
    MAGISK/Magisk-v27.0.zip
)
arm64_bin=(
    META-INF/tools/binary/arm64-v8a/avbctl
    META-INF/tools/binary/arm64-v8a/bash
    META-INF/tools/binary/arm64-v8a/bootctl
    META-INF/tools/binary/arm64-v8a/busybox
    META-INF/tools/binary/arm64-v8a/lptools_new
    META-INF/tools/binary/arm64-v8a/magisk
    META-INF/tools/binary/arm64-v8a/magiskboot
    META-INF/tools/binary/arm64-v8a/make_ext4fs
    META-INF/tools/binary/arm64-v8a/resize2fs
    META-INF/tools/binary/arm64-v8a/snapshotctl
    META-INF/tools/binary/arm64-v8a/sqlite3
    META-INF/tools/binary/arm64-v8a/toolbox
    META-INF/tools/binary/arm64-v8a/toybox
)
arm32_bin=(
    META-INF/tools/binary/armeabi-v7a/avbctl
    META-INF/tools/binary/armeabi-v7a/bash
    META-INF/tools/binary/armeabi-v7a/bootctl
    META-INF/tools/binary/armeabi-v7a/busybox
    META-INF/tools/binary/armeabi-v7a/lptools_new
    META-INF/tools/binary/armeabi-v7a/magisk
    META-INF/tools/binary/armeabi-v7a/magiskboot
    META-INF/tools/binary/armeabi-v7a/make_ext4fs
    META-INF/tools/binary/armeabi-v7a/resize2fs
    META-INF/tools/binary/armeabi-v7a/snapshotctl
    META-INF/tools/binary/armeabi-v7a/sqlite3
    META-INF/tools/binary/armeabi-v7a/toolbox
    META-INF/tools/binary/armeabi-v7a/toybox
)
x86_bin=(
    META-INF/tools/binary/x86/avbctl
    META-INF/tools/binary/x86/bash
    META-INF/tools/binary/x86/bootctl
    META-INF/tools/binary/x86/busybox
    META-INF/tools/binary/x86/lptools_new
    META-INF/tools/binary/x86/magisk
    META-INF/tools/binary/x86/magiskboot
    META-INF/tools/binary/x86/make_ext4fs
    META-INF/tools/binary/x86/resize2fs
    META-INF/tools/binary/x86/snapshotctl
    META-INF/tools/binary/x86/sqlite3
    META-INF/tools/binary/x86/toolbox
    META-INF/tools/binary/x86/toybox
)
x86_64_bin=(
    META-INF/tools/binary/x86_64/avbctl
    META-INF/tools/binary/x86_64/bash
    META-INF/tools/binary/x86_64/bootctl
    META-INF/tools/binary/x86_64/busybox
    META-INF/tools/binary/x86_64/lptools_new
    META-INF/tools/binary/x86_64/magisk
    META-INF/tools/binary/x86_64/magiskboot
    META-INF/tools/binary/x86_64/make_ext4fs
    META-INF/tools/binary/x86_64/resize2fs
    META-INF/tools/binary/x86_64/snapshotctl
    META-INF/tools/binary/x86_64/sqlite3
    META-INF/tools/binary/x86_64/toolbox
    META-INF/tools/binary/x86_64/toybox
)

if [[ -z "$TEST" ]] ; then
    FULL_LITE_ARGS="full lite"
    LNG_ARGS="ru en id hi zh"
    ARCH_ARGS="arm64-v8a armeabi-v7a x86 x86_64 Universal"
else
    FULL_LITE_ARGS="lite"
    LNG_ARGS="ru en"
    ARCH_ARGS="arm64-v8a"
fi
cd "$DIRNAME"
sed -i 's/^export EXEMPLE_VERSION=.*/export EXEMPLE_VERSION="'$VERSION'"/' META-INF/com/google/android/update-binary

for line in $(find ./ -name *"\.sh" -or -name "update"* -or -name "NEO.config" -or -name "module.prop" ) ; do 
    before=$(cat "$line")
    sed -i 's/\r$//' "$line"
    after=$(cat "$line")
    if [ "$before" != "$after" ]; then
        echo "Пофикшено: $line"
    fi
done 

for full_lite in $FULL_LITE_ARGS ; do
    for language in $LNG_ARGS ; do
        cd "$DIRNAME"
        lng="$language"
        case "$lng" in
            en) 
                long_lng="english-language"
                README_FILE="README.md"
                ;;
            ru) 
                long_lng="russian-language" 
                README_FILE="README_ru.md"
                ;;
            id) 
                long_lng="indonesian-language" 
                README_FILE="README_id.md"
                ;;
            hi) 
                long_lng="hindi-language" 
                README_FILE="README_hi.md"
                ;;
            zh) 
                long_lng="chinese-language" 
                README_FILE="README_zh.md"
                ;;
        esac
        
        [[ -d "$DIRNAME/../DFE-NEO-builds/DFE-NEO-$VERSION/$full_lite/$long_lng" ]] || mkdir -pv "$DIRNAME/../DFE-NEO-builds/DFE-NEO-$VERSION/$full_lite/$long_lng" &>/dev/null
        
        for arch in $ARCH_ARGS ; do
            { 
            if [[ "$full_lite" == full ]] ; then
                NAME_ZIP="$DIRNAME/../DFE-NEO-builds/DFE-NEO-$VERSION/$full_lite/$long_lng/$arch-$lng-DFE-NEO-$VERSION.zip"
            else
                NAME_ZIP="$DIRNAME/../DFE-NEO-builds/DFE-NEO-$VERSION/$full_lite/$long_lng/$arch-$lng-DFE-NEO-$VERSION-lite.zip"
            fi
            echo "- Компиляция... $full_lite:$(basename "$NAME_ZIP")"
            case $arch in
                arm64-v8a) 
                    7z a -mx9 "$NAME_ZIP" "${files_needed[@]}" "${arm64_bin[@]}" &>/dev/null
                ;;
                armeabi-v7a) 
                    7z a -mx9 "$NAME_ZIP" "${files_needed[@]}" "${arm32_bin[@]}" &>/dev/null
                ;;
                x86)
                    7z a -mx9 "$NAME_ZIP" "${files_needed[@]}" "${x86_bin[@]}" &>/dev/null
                ;;
                x86_64)
                    7z a -mx9 "$NAME_ZIP" "${files_needed[@]}" "${x86_64_bin[@]}" &>/dev/null
                ;;
                Universal)
                    7z a -mx9 "$NAME_ZIP" "${files_needed[@]}" "${x86_64_bin[@]}" "${x86_bin[@]}" "${arm32_bin[@]}" "${arm64_bin[@]}" &>/dev/null
                ;;
            esac 
            cd "$DIRNAME/META-INF/tools/languages/$language"
            7z a -mx9 "$NAME_ZIP" NEO.config &>/dev/null
            cd "$DIRNAME"
            7z a -mx9 "$NAME_ZIP" $README_FILE &>/dev/null 
            [[ "$full_lite" == full ]] && 7z a -mx9 "$NAME_ZIP" "${magisk_files[@]}" &>/dev/null
            echo "- Компиляция $full_lite:$(basename "$NAME_ZIP") завершена"
            if [[ -n "$TEST" ]] ; then
                cp "$NAME_ZIP" $DIRNAME/../DFE-NEO-builds/
            fi
            } &
        done
        wait
        
    done
done
echo "Зборка версии $VERSION завершена!"