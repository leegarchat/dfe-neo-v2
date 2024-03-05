


# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...
# $ZIPARG3 - Константа, объявлена в update-binary. Путь к исходному архиву при запуске update-binary

if echo "$(basename "$ZIPARG3")" | busybox grep -qi "extconfig"; then
    if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
            languages="$(grep "languages=" "$(dirname "$ZIPARG3")/NEO.config")"
            languages=${languages#*"="}
    else
        languages="$(grep "languages=" "$TMPN/unzip/NEO.config")"
        languages=${languages#*"="}
    fi
else
    languages="$(grep "languages=" "$TMPN/unzip/NEO.config")"
    languages=${languages#*"="}
fi
if ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" ]] ; then
    my_print "- $languages.sh language file not found. English will be used"
    languages=en
    ! [[ -f "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" ]] && {
        abort_neo -e "23.27" -m "English language file not found, WHAT THE FUCK????"
    }
fi
sed -i 's/\r$//' "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh"
source "$TMPN/unzip/META-INF/tools/languages/$languages/$languages.sh" || abort_neo -e "23.31" -m "Failed to read language file"