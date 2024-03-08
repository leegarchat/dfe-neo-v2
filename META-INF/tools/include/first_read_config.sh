

# $TMPN - Константа, объявлена в update-binary. Путь к основному каталогу neo data/local/TMPN/...


export CONFIG_FILE=""

if echo "$(basename "$ZIPARG3")" | grep -qi "extconfig"; then
    my_print "- В название архива присутсвует extconfig. Будет попытка считать конфиг из той же папки где распаложен установочный архив"
    if [[ -f "$(dirname "$ZIPARG3")/NEO.config" ]]; then
        CONFIG_FILE="$(dirname "$ZIPARG3")/NEO.config"
    else 
        my_print "- Внешний конфиг не найден. Будет произведено чтение из встроенного"
    fi
fi
if [[ -z "$CONFIG_FILE" ]] && [[ -f "$TMPN/unzip/NEO.config" ]]
    CONFIG_FILE="$TMPN/unzip/NEO.config"
else
    my_print "- Встроенный конфиг не обнаружен"
    my_print "- Выход..."
    abort_neo -e "8.0" -m "Не найден встроенный конфиг"
fi
my_print "- Конфиг обнаружен"
my_print "- Проверка аргументов на соответсвие"

source check_config "$CONFIG_FILE" || abort_neo -e "8.1" -m "Конфиг настроен не корреткно"
source "$CONFIG_FILE" || abort_neo -e "8.2" -m "Не удалось считать файл конфигурации"
my_print "- Все впорядке!"
