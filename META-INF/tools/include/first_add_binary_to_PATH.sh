


# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги binary/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]

binary_pull_busubox="mv cp dirname basename grep [ [[ sleep mountpoint sed echo mkdir ls ln readlink realpath cat awk wc"
binary_pull_busubox+=""
binary_pull_toybox="file"
# Добавление из busybox
for name_sub_bin in $binary_pull_busubox ; do
    ln -s "${TOOLS}/busybox" "${TOOLS}/${name_sub_bin}"
done
for name_sub_bin in $binary_pull_toybox ; do
    ln -s "${TOOLS}/toybox" "${TOOLS}/${name_sub_bin}"
done
# Добавление из toolbox
ln -s "${TOOLS}/toolbox" "${TOOLS}/getprop"
ln -s "${TOOLS}/toolbox" "${TOOLS}/setprop"
ln -s "${TOOLS}/toolbox" "${TOOLS}/getevent"
# Добавление из magisk
ln -s "${TOOLS}/magisk" "${TOOLS}/resetprop"

for shbin in $TMP_TOOLS/include/*.sh ; do
    ln -s "${shbin}" "$TOOLS/${shbin%\.sh*}" 
done

# Экспортирование PATH с новыми бинарниками!! mount использовать системный
export "$TOOLS:$PATH"

