- Русское [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_ru.md)
- English [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README.md)
- Bahasa Indonesia [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_id.md)
- 中文 [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_zh.md)
- हिन्दी [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_hi.md)

# Disable Force Encryption Native Early Override (DFE NEO v2)

## Обсуждение на форумах:

- **XDA Developers:**
  [Тема на форуме XDA](https://xdaforums.com/t/a-b-a-only-script-read-only-erofs-android-10-disable-force-encryption-native-early-override-dfe-neo-v2-disable-encryption-data-userdata.4454017/)

- **4PDA:**
  [Тема на форуме 4PDA](https://4pda.to/forum/index.php?showtopic=1084916)


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

## Плюсы и минусы отключения шифрования /data

### Плюсы

- **Упрощение резервного копирования и восстановления данных**: При отключенном шифровании данные в /data проще резервировать и восстанавливать. Это упрощает ситуации перепрошивки устройства, восстановления после сбоя или переноса данных на новое устройство.
- **Упрощение смены прошивок**: Отключение шифрования предотвращает необходимость полного форматирования данных при смене прошивки, что экономит время и упрощает процесс перехода между прошивками.
- **Доступ к данным в недоделанном TWRP**: Отключение шифрования позволяет получить доступ к данным в недоделанных или несовершенных версиях TWRP, которые не поддерживают расшифровку зашифрованных данных.

### Минусы

- **Уязвимость для утери данных**: При отключенном шифровании данные становятся уязвимыми для несанкционированного доступа. Это увеличивает риск доступа к вашим личным данным злоумышленниками.
- **Повышенный риск утери устройства**: В случае утери или кражи устройства, данные могут быть украдены или скомпрометированы без необходимости расшифровки, что увеличивает риск утери конфиденциальных данных.
- **Уязвимость для обхода защиты**: Отключение шифрования также увеличивает уязвимость для обхода защиты. Например, удаление файла блокировки может быть проще, что позволяет злоумышленнику получить доступ к устройству без необходимости ввода пароля.

Важно внимательно взвесить все плюсы и минусы перед решением отключить шифрование данных на устройстве. Безопасность и удобство использования должны быть уравновешены в зависимости от ваших потребностей и угроз, с которыми вы сталкиваетесь.
### Работа скрипта DFE-Neo:

#### Первый этап:
1. **Определение слота прошивки**: Скрипт определяет, в каком суффиксе/слоте должна запуститься прошивка.

2. **Переразметка разделов**: Необходимо для определения корректного слота. После этого можно устанавливать любые zip файлы даже без перезагрузки TWRP после установки новой прошивки.

3. **Обман TWRP**: Задает TWRP суффикс, который должен загрузиться в случае, если установлена новая прошивка.

#### Второй этап:
1. **Проверка наличия DFE-Neo v2**: Проверяется, установлен ли DFE-Neo v2. Если установлен, скрипт предлагает удалить DFE или установить его заново.

2. **Задание аргументов**: Аргументы задаются пользователем либо считываются из файла NEO.config.

#### Третий этап:
1. **Монтирование раздела vendor загрузочной прошивки**: Скрипт монтирует раздел vendor загрузочной прошивки.

2. **Копирование файлов из каталога /vendor/etc/init/hw**: Все файлы из указанного каталога копируются во временную папку.

3. **Модификация файлов fstab и *.rc**: Модифицируются *.rc файлы и fstab в соответствии с параметрами из NEO.config.

4. **Создание ext4 образа с измененными файлами**: Создается ext4 образ с измененными файлами из временной папки.

#### Четвертый этап:
1. **Запись inject_neo.img в vendor_boot/boot**: inject_neo.img записывается в vendor_boot/boot противоположного суффикса или в super текущего слота и суффикса.

2. **Проверка загрузочных суффиксов**: Проверяется наличие ramdisk.cpio и fisrt_stage_mount fstab файла.

3. **Модификация fisrt_stage_mount**: fisrt_stage_mount файл модифицируется добавлением новой точки монтирования.

#### Опциональные действия:
- **Удаление PIN с локскрина**: Если выбрана соответствующая опция, PIN с локскрина будет удален.
- **Очистка данных (wipe data)**: Если выбрана соответствующая опция, будут стерты данные.
- **Установка Magisk**: Если указана версия Magisk, она будет установлена.

Это общее описание работы скрипта DFE-Neo. Он выполняет ряд шагов для подготовки и модификации системы, чтобы обеспечить корректное выполнение процедуры установки и обновления прошивки на устройстве.


## Использованные бинарники

- **Magisk, Busybox, Magiskboot**: Взято с последней версии [Magisk](https://github.com/topjohnwu/Magisk).
- **avbctl, bootctl, snapshotctl, toolbox, toybox**: Скомпилированы из исходного кода Android.
- **lptools_new**: Для создания бинарника использовался открытый исходный код с [GitHub](https://github.com/leegarchat/lptools_new), собственный код утилиты также включен.
- **make_ext4fs**: [GitHub](https://github.com/sunqianGitHub/make_ext4fs/tree/master/prebuilt_binary)
- **Bash**: Взят статичный бинарник с [Debian Packages](https://packages.debian.org/unstable/bash-static).
- **SQLite3**: Взят из [репозитория](https://github.com/rojenzaman/sqlite3-magisk-module).

