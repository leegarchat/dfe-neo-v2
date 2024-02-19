# DFE-NEO v2

## Отключение шифрования /data для Android

### Описание

DFE-NEO v2 - это скрипт, разработанный для отключения принудительного шифрования раздела /userdata на устройствах Android. Он предназначен для обеспечения простого переключения между ROMs и доступа к данным в TWRP, не требуя форматирования данных и удаления важных файлов пользователя, таких как ./Download, ./DCIM и прочие, расположенные во внутренней памяти устройства.

### Использование

На данный момент скрипт можно использовать только в качестве установочного файла через TWRP.

1. Установите `dfe-neo.zip`.
2. Выберите нужную конфигурацию.
3. После успешной установки, если ваши данные зашифрованы, вам необходимо отформатировать данные:
   - Зайдите в меню TWRP "Меню очистки" ("Wipe").
   - Выберите "format data".
   - Подтвердите выполнение операции, введя "yes".

## Примечание

Внимание: перед использованием скрипта убедитесь, что вы понимаете, как он работает, и сделайте резервную копию ваших данных для предотвращения потери информации.

## Конфигурация NEO.config

### Рабочие инструкции

NEO.config - это файл конфигурации, который используется для настройки параметров скрипта DFE-NEO v2. Ниже приведено описание доступных параметров:

- `languages`: Определяет языковые настройки. Доступные значения: `en` (английский), `ru` (русский), `id` (индонезийский).

- `hide_not_encrypted`: Опция, позволяющая скрыть отсутствие шифрования /data. Доступные значения: `false`, `true`, `ask`.

- `add_custom_deny_list`: Опция для добавления пользовательского списка запретов. Эта опция позволяет определить, когда скрипт будет выполнять добавление в список запретов. Доступные значения:
  - `false`: Отключить добавление пользовательского списка запретов.
  - `ask`: Запросить во время установки, чтобы определить, нужно ли добавлять пользовательский список запретов.
  - `first_time_boot`: Скрипт будет выполнен только один раз при первой загрузке системы. Запись о первом использовании хранится в памяти Magisk.
  - `always_on_boot`: Скрипт будет выполняться при каждой загрузке системы.

- `zygisk_turn_on`: Опция для принудительного включения режима `zygisk`. Эта опция позволяет определить, когда скрипт будет выполнять включение режима `zygisk`. Доступные значения:
  - `false`: Отключить принудительное включение режима `zygisk`.
  - `ask`: Запросить во время установки, чтобы определить, нужно ли включать режим `zygisk`.
  - `first_time_boot`: Скрипт будет выполнен только один раз при первой загрузке системы. Запись о первом использовании хранится в памяти Magisk.
  - `always_on_boot`: Скрипт будет выполняться при каждой загрузке системы.

- `safety_net_fix`: Опция, включающая встроенное исправление SafetyNet. Доступные значения: `false`, `true`, `ask`.

- `remove_pin`: Опция, удаляющая блокировку PIN. Доступные значения: `false`, `true`, `ask`.

- `wipe_data`: Опция, стирающая данные во время установки. Доступные значения: `false`, `true`, `ask`.

- `modify_early_mount`: Опция, определяющая необходимость внедрения в `--early mount`. Доступные значения: `false`, `true`, `ask`.

- `dfe_paterns`: Эта опция предназначена для удаления или замены шаблонов в файле `fstab`, который используется для монтирования разделов в системе Android. По умолчанию оставьте ее без изменений, если вы не знаете, для чего это нужно.

  - `-m`: Этот параметр указывает строку точки монтирования, в которой нужно удалить или заменить шаблоны. Например, `-m /data`. После этого флага нужно указать `-r` и/или `-p`.

  - `-r`: Этот параметр указывает, какие шаблоны нужно удалить. Шаблоны будут удалены до запятой или пробела. Например:
    ```
    /.../userdata	/data	f2fs	noatime,....,inlinecrypt	wait,....,fileencryption=aes-256-xts:aes-256-cts:v2,....,fscompress
    ```
    с `-m /data -r fileencryption= inlinecrypt` будет удалено `fileencryption=aes-256-xts:aes-256-cts:v2`. В результате получится строка:
    ```
    /.../userdata	/data	f2fs	noatime,....	wait,....,....,fscompress
    ```

  - `-p`: Этот параметр указывает, какие шаблоны нужно заменить. Например, `-m /data -p inlinecrypt--to--ecrypt`. В результате получится следующее:
    ```
    /.../userdata	/data	f2fs	noatime,....,ecrypt	wait,....,fileencryption=aes-256-xts:aes-256-cts:v2,....,fscompress
    ```
    Можно указать несколько параметров `-p inlinecrypt--to--ecrypt fileencryption--to--notencryption`.

  - `-v`: Если этот флаг указан, все строки в `fstab`, начинающиеся с `overlay`, будут закомментированы, тем самым отключив системный overlay от производителя. Чтобы ощутить этот эффект, установите значение `true` для опции `modify_early_mount`.

  - Пример заполнения: 
    ```
    "-m /data -p fileencryption--to--notencrypteble ice--to--not-ice -r forceencrypt= -m /system -p ro--to--rw -m /metadata -r keydirectory="
    ```

  - Значение по умолчанию:
    ```
    "-m /data -r fileencryption= forcefdeorfbe= encryptable= forceencrypt= metadata_encryption= keydirectory= inlinecrypt quota wrappedkey"
    ```


- `where_to_inject`: Эта опция определяет место для инъекции модуля. Доступные значения:
  - `super`: Модуль будет прошит в текущий слот рядом с системой, вендором и т. д.
  - `vendor_boot`: Модуль будет прошит в неактивный слот vendor_boot (недоступно для устройств только с A-разделением).
  - `boot`: Модуль будет прошит в неактивный слот boot (недоступно для устройств только с A-разделением).
  - `auto`: автоматически определяет место инъекции по приоритету: `vendor_boot`, `boot`, `super`.

- `path_to_inject`: Путь к месту инъекции.

- Опция установки Magisk

  `magisk`: Укажите версию Magisk для установки или оставьте поле пустым. Доступные версии:

  - `Magisk-v27.0`
  - `Magisk-v26.4-kitsune-2`
  - `Magisk-v26.4`
  - `MagiskDelta-v26.4`

Чтобы установить Magisk из того же каталога, что и neo.zip, добавьте префикс "EXT:", например, "EXT:Magisk-v24.3.zip".


Каждый параметр имеет свое описание и доступные значения. Изменяйте их в соответствии с вашими потребностями в файле NEO.config.





