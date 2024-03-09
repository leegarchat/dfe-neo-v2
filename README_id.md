- Русское [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_ru.md)
- English [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README.md)
- Bahasa Indonesia [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_id.md)
- 中文 [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_zh.md)
- हिन्दी [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_hi.md)

# Menonaktifkan Override Awal Enkripsi Paksa (DFE NEO v2)

## Diskusi Forum:

- **XDA Developers:**
  [Thread Forum XDA](https://xdaforums.com/t/a-b-a-only-script-read-only-erofs-android-10-disable-force-encryption-native-early-override-dfe-neo-v2-disable-encryption-data-userdata.4454017/)

- **4PDA:**
  [Thread Forum 4PDA](https://4pda.to/forum/index.php?showtopic=1084916)


## Menonaktifkan Enkripsi untuk Android /data

### Deskripsi

DFE-NEO v2 adalah skrip yang dirancang untuk menonaktifkan enkripsi paksa pada partisi /userdata pada perangkat Android. Ini dimaksudkan untuk memudahkan beralih antara ROM dan akses ke data di TWRP tanpa memerlukan format data atau penghapusan file pengguna penting, seperti ./Download, ./DCIM, dan lainnya yang terletak di memori internal perangkat.

### Penggunaan

Saat ini, skrip hanya dapat digunakan sebagai file instalasi melalui TWRP.

1. Pasang `dfe-neo.zip`.
2. Pilih konfigurasi yang diinginkan.
3. Setelah instalasi berhasil, jika data Anda dienkripsi, Anda perlu memformat data:
   - Masuk ke menu "Wipe" TWRP.
   - Pilih "format data".
   - Konfirmasi operasi dengan memasukkan "yes".

## Catatan

Perhatian: Sebelum menggunakan skrip, pastikan Anda memahami cara kerjanya dan cadangkan data Anda untuk mencegah kehilangan data.

## Pro dan Kontra Menonaktifkan Enkripsi /data

### Pro

- **Pemudahan Backup dan Pemulihan Data**: Dengan enkripsi dinonaktifkan, data di /data lebih mudah untuk dibackup dan dipulihkan. Ini menyederhanakan situasi seperti flashing ulang perangkat, pemulihan setelah kegagalan, atau transfer data ke perangkat baru.
- **Pemudahan Peralihan Firmware**: Menonaktifkan enkripsi menghilangkan kebutuhan akan format data penuh saat beralih firmware, menghemat waktu dan menyederhanakan proses pergantian firmware.
- **Akses ke Data di Versi TWRP yang Belum Selesai**: Menonaktifkan enkripsi memungkinkan akses ke data di versi TWRP yang belum selesai atau tidak sempurna yang tidak mendukung dekripsi data terenkripsi.

### Kontra

- **Kerentanan Kehilangan Data**: Dengan enkripsi dinonaktifkan, data menjadi rentan terhadap akses tidak sah, meningkatkan risiko data pribadi diakses oleh pihak yang jahat.
- **Risiko Kehilangan Perangkat yang Lebih Tinggi**: Jika perangkat hilang atau dicuri, data dapat dicuri atau dikompromikan tanpa perlu dekripsi, meningkatkan risiko kehilangan data rahasia.
- **Kerentanan Pembuangan**: Menonaktifkan enkripsi juga meningkatkan kerentanan terhadap pembuangan tindakan keamanan. Misalnya, menghapus file kunci mungkin lebih mudah, memungkinkan penyerang untuk mengakses perangkat tanpa memasukkan kata sandi.

Penting untuk mempertimbangkan secara cermat semua pro dan kontra sebelum memutuskan untuk menonaktifkan enkripsi data pada perangkat Anda. Keamanan dan kemudahan penggunaan harus seimbang tergantung pada kebutuhan dan ancaman yang dihadapi.

### Operasi Skrip DFE-Neo:

#### Tahap Pertama:
1. **Menentukan Slot Firmware**: Skrip menentukan mana sufiks/slot firmware yang harus di-boot.

2. **Pemartisi Ulang**: Diperlukan untuk menentukan slot yang benar. Setelah ini, semua file zip dapat diinstal tanpa harus me-reboot TWRP setelah menginstal firmware baru.

3. **Melewati TWRP**: Menetapkan sufiks TWRP yang harus di-boot jika firmware baru diinstal.

#### Tahap Kedua:
1. **Memeriksa DFE-Neo v2**: Memeriksa apakah DFE-Neo v2 terinstal. Jika terinstal, skrip menawarkan untuk menghapus DFE atau menginstalnya kembali.

2. **Mengatur Argumen**: Argumen diatur oleh pengguna atau dibaca dari file NEO.config.

#### Tahap Ketiga:
1. **Memasang partisi vendor dari firmware boot**: Skrip memasang partisi vendor dari firmware boot.

2. **Menyalin file dari /vendor/etc/init/hw**: Semua file dari direktori yang ditentukan disalin ke folder sementara.

3. **Memodifikasi file fstab dan *.rc**: File *.rc dan fstab dimodifikasi sesuai dengan parameter dari NEO.config.

4. **Membuat gambar ext4 dengan file yang dimodifikasi**: Gambar ext4 dengan file yang dimodifikasi dari folder sementara dibuat.

#### Tahap Keempat:
1. **Menulis inject_neo.img ke vendor_boot/boot**: inject_neo.img ditulis ke vendor_boot/boot dari sufiks yang berlawanan atau slot dan sufiks saat ini.

2. **Memeriksa sufiks boot**: Memeriksa keberadaan file ramdisk.cpio dan fstab fisrt_stage_mount.

3. **Memodifikasi fisrt_stage_mount**: File fisrt_stage_mount dimodifikasi dengan menambahkan titik pemasangan baru.

#### Tindakan Opsional:
- **Menghapus PIN dari Layar Kunci**: Jika opsi yang sesuai dipilih, PIN dari layar kunci akan dihapus.
- **Menghapus Data**: Jika opsi yang sesuai dipilih, data akan dihapus.
- **Menginstal Magisk**: Jika versi Magisk ditentukan, itu akan diinstal.

Ini adalah deskripsi umum tentang bagaimana skrip DFE-Neo beroperasi. Ini melakukan serangkaian langkah untuk mempersiapkan dan memodifikasi sistem untuk memastikan eksekusi yang benar dari prosedur instalasi dan pembaruan firmware pada perangkat.

## Binari yang Digunakan

- **Magisk, Busybox, Magiskboot**: Diambil dari versi terbaru [Magisk](https://github.com/topjohnwu/Magisk).
- **avbctl, bootctl, snapshotctl, toolbox, toybox**: Dikompilasi dari kode sumber Android.
- **lptools_new**: Kode sumber terbuka dari [GitHub](https://github.com/leegarchat/lptools_new) digunakan untuk membuat binari, dengan kode utilitas sendiri termasuk.
- **make_ext4fs**: [GitHub](https://github.com/sunqianGitHub/make_ext4fs/tree/master/prebuilt_binary)
- **Bash**: Binari statis diambil dari [Paket Debian](https://packages.debian.org/unstable/bash-static).
- **SQLite3**: Diambil dari [repository](https://github.com/rojenzaman/sqlite3-magisk-module).
