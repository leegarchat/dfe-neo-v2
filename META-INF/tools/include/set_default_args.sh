# $WHERE_INSTALLING - Константа, объявлена в update-binary. magiskapp/kernelsu/recovery
# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIP - Константа, объявлена в update-binary. Путь к основному tmp.zip файлу neo $TMPN/zip/DFENEO.zip
# $TMP_TOOLS - Константа, объявлена в update-binary. Путь к каталогу с подкаталогами бинарников $TMPN/unzip/META-INF/tools. В нем каталоги [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $ARCH - Константа, объявлена в update-binary. Архитектура устройства [arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]
# $TOOLS - Константа, объявлена в update-binary. Путь к каталогу с бинарниками $TMP_TOOLS/[arm64-v8a]|[armeabi-v7a]|[x86]|[x86_64]



# NEO.config аргументы \/--------------------\/

export languages=""
export force_start=""
export ro_hardware=""
export disable_verity_and_verification=""
export hide_not_encrypted=""
export custom_reset_prop=""
export add_custom_deny_list=""
export zygisk_turn_on=""
export safety_net_fix=""
export remove_pin=""
export wipe_data=""
export modify_early_mount=""
export dfe_paterns=""
export where_to_inject=""
export magisk=""

# NEO.config аргументы /\--------------------/\



# lng.sh аргументы    \/--------------------\/

for number in {1..250} ; do 
    export word${number}=""
done

# lng.sh аргументы    /\--------------------/\


# info аргументы      \/--------------------\/
export bootctl_state=""
export snapshotctl_state=""
export languages=""
export NEO_VERSION="DFE NEO 2.5.x"
export LOGNEO="$TMPN/outneo.log"
export MAGISK_ZIP=""
export where_to_inject_auto=""
if [[ -n "$EXEMPLE_VERSION" ]] ; then
    NEO_VERSION="DFE-NEO $EXEMPLE_VERSION"
fi

# info аргументы      /\--------------------/\










