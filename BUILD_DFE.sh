#/bin/bash


FOLDER="DFE-NEO"

VERSION="$1" 
if [[ "$2" == "test" ]] ; then
    export compil_all_binary=false
    export language="ru en"
else
    export compil_all_binary=true
    export language="ru en id zh hi"
fi

if [ -z $FOLDER ] || [ -z $VERSION ] ; then 
    exit 22
fi



WORK_DIR=$(dirname $(realpath $FOLDER))
if ! [ -d "$WORK_DIR/$FOLDER" ] ; then
    exit 21
fi
if ! [ -d "$WORK_DIR/${FOLDER}-builds" ] ; then
    mkdir "$WORK_DIR/${FOLDER}-builds"
fi
if ! [ -d "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION" ] ; then
    mkdir "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION"
fi
for fulllite in Full Lite ; do
    rm -rf "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION/$fulllite/"*
    if ! [ -d "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION/$fulllite" ] ; then
        mkdir "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION/$fulllite"
    else 
        rm -rf "$WORK_DIR/${FOLDER}-builds/${FOLDER}-$VERSION/$fulllite/"*
    fi
done
for file in $(find "$WORK_DIR/$FOLDER" | grep "\.sh") $(find "$WORK_DIR/$FOLDER" | grep "NEO\.config") $(find "$WORK_DIR/$FOLDER" | grep "\.lng") ; do
    echo $file
    sed -i 's/\r$//' $file
done
# sleep 10
cd $WORK_DIR
mkdir $WORK_DIR/tmp
cat $WORK_DIR/$FOLDER/META-INF/com/google/android/update-binary > $WORK_DIR/tmp/UB
cat $WORK_DIR/$FOLDER/NEO.config > $WORK_DIR/tmp/CONFIG
sed -i "s/export EXEMPLE_VERSION=/export EXEMPLE_VERSION=\"$VERSION\"/" $WORK_DIR/$FOLDER/META-INF/com/google/android/update-binary

change_langues(){
cat $WORK_DIR/tmp/CONFIG > $WORK_DIR/$FOLDER/NEO.config

while IFS= read -r line; do
    echo "1'$line'"
    case $line in 
        *EXAMPLE_LNG)
        echo "2'$line'"
        new_line=${line/"-EXAMPLE_LNG"/}
        echo "3'$new_line'"
sed -i "/$line/ {r $WORK_DIR/$FOLDER/META-INF/tools/languages/$1/$new_line.lng
  d
}" $WORK_DIR/$FOLDER/NEO.config
        ;;
    esac
done <"$WORK_DIR/tmp/CONFIG"

}


cd $WORK_DIR/$FOLDER
for sortlanguage in ru en id zh hi ; do 
    case $sortlanguage in 
        en)
            language=english-language
        ;;
        ru)
            language=russian-language
        ;;
        id)
            language=indonesian-language
        ;;
        zh)
            language=chinese-language
        ;;
        hi)
            language=hindi-language
        ;;
    esac
<<<<<<< HEAD
=======
    for file in $(find $WORK_DIR | grep "\.sh") $(find $WORK_DIR | grep "NEO\.config") ; do
        sed -i 's/\r$//' $file
    done

    change_langues $sortlanguage
>>>>>>> 7f6ea85 (buildfix)

    change_langues $sortlanguage
sda
    ! [ -f $WORK_DIR/"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language" ] && {
        mkdir $WORK_DIR/"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language"
    }
    ! [ -f $WORK_DIR/"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language" ] && {
        mkdir $WORK_DIR/"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language"
    }
    current_lng=$(grep "languages=" $WORK_DIR/$FOLDER/NEO.config)
    sed -i "s/$current_lng/languages=$sortlanguage/" "$WORK_DIR/$FOLDER/NEO.config"
    # echo $current_lng
    # grep "languages=" $WORK_DIR/$FOLDER/NEO.config 
    # sleep 20
    for file in $(find "$WORK_DIR/$FOLDER" | grep "\.sh") $(find "$WORK_DIR/$FOLDER" | grep "NEO\.config") $(find "$WORK_DIR/$FOLDER" | grep "\.lng") ; do
        echo $file
        sed -i 's/\r$//' $file
    done
    {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language/Universal-$sortlanguage-$FOLDER-$VERSION-Lite.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" -x MAGISK/* -x MAGISK/
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language/x86-$sortlanguage-$FOLDER-$VERSION-Lite.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" -x MAGISK/* -x MAGISK/ \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* 
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language/x86_64-$sortlanguage-$FOLDER-$VERSION-Lite.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" -x MAGISK/* -x MAGISK/ \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language/armeabi-v7a-$sortlanguage-$FOLDER-$VERSION-Lite.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" -x MAGISK/* -x MAGISK/ \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 
    } & {
    zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language/arm64-v8a-$sortlanguage-$FOLDER-$VERSION-Lite.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" -x MAGISK/* -x MAGISK/ \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 


    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language/Universal-$sortlanguage-$FOLDER-$VERSION.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*"
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language/x86-$sortlanguage-$FOLDER-$VERSION.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* 
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language/x86_64-$sortlanguage-$FOLDER-$VERSION.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language/armeabi-v7a-$sortlanguage-$FOLDER-$VERSION.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" \
                    -x META-INF/tools/binary/arm64-v8a/ \
                    -x META-INF/tools/binary/arm64-v8a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 
    } & {
    $compil_all_binary && zip -9 -r ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language/arm64-v8a-$sortlanguage-$FOLDER-$VERSION.zip" ./* -x "BUILD_DFE.sh" -x ".git" -x ".git/" -x ".git/*" \
                    -x META-INF/tools/binary/armeabi-v7a/ \
                    -x META-INF/tools/binary/armeabi-v7a/* \
                    -x META-INF/tools/binary/x86_64/ \
                    -x META-INF/tools/binary/x86_64/* \
                    -x META-INF/tools/binary/x86/ \
                    -x META-INF/tools/binary/x86/* 
    } 
    wait
    $compil_all_binary && mkdir ./../"${FOLDER}-builds/${FOLDER}-$VERSION-GitHub"
    $compil_all_binary && cp ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Full/$language"/*.zip ./../"${FOLDER}-builds/${FOLDER}-$VERSION-GitHub/"
    $compil_all_binary && cp ./../"${FOLDER}-builds/${FOLDER}-$VERSION/Lite/$language"/*.zip ./../"${FOLDER}-builds/${FOLDER}-$VERSION-GitHub/"
done





cat $WORK_DIR/tmp/UB > $WORK_DIR/$FOLDER/META-INF/com/google/android/update-binary 
cat $WORK_DIR/tmp/CONFIG > $WORK_DIR/$FOLDER/NEO.config
rm -rf $WORK_DIR/tmp