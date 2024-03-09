- Русское [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_ru.md)
- English [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README.md)
- Bahasa Indonesia [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_id.md)
- 中文 [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_zh.md)
- हिन्दी [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_hi.md)

# Disable Force Encryption Native Early Override (DFE NEO v2)

## Forum Discussions:

- **XDA Developers:**
  [XDA Forum Thread](https://xdaforums.com/t/a-b-a-only-script-read-only-erofs-android-10-disable-force-encryption-native-early-override-dfe-neo-v2-disable-encryption-data-userdata.4454017/)

- **4PDA:**
  [4PDA Forum Thread](https://4pda.to/forum/index.php?showtopic=1084916)


## Disabling Encryption for Android /data

### Description

DFE-NEO v2 is a script designed to disable forced encryption of the /userdata partition on Android devices. It is intended to facilitate easy switching between ROMs and access to data in TWRP without requiring data formatting or deletion of important user files, such as ./Download, ./DCIM, and others located in the device's internal memory.

### Usage

At the moment, the script can only be used as an installation file via TWRP.

1. Install `dfe-neo.zip`.
2. Select the desired configuration.
3. After successful installation, if your data is encrypted, you need to format the data:
   - Go to the TWRP "Wipe" menu.
   - Select "format data".
   - Confirm the operation by entering "yes".

## Note

Attention: Before using the script, make sure you understand how it works and backup your data to prevent data loss.

## Pros and Cons of Disabling /data Encryption

### Pros

- **Simplified Data Backup and Restore**: With encryption disabled, data in /data is easier to backup and restore. This simplifies situations such as device reflashing, recovery after failure, or data transfer to a new device.
- **Simplified Firmware Switching**: Disabling encryption eliminates the need for full data formatting when switching firmware, saving time and simplifying the firmware switching process.
- **Access to Data in Unfinished TWRP Builds**: Disabling encryption allows access to data in unfinished or imperfect TWRP builds that do not support decryption of encrypted data.

### Cons

- **Data Loss Vulnerability**: With encryption disabled, data becomes vulnerable to unauthorized access, increasing the risk of personal data being accessed by malicious actors.
- **Increased Device Loss Risk**: In case of device loss or theft, data can be stolen or compromised without the need for decryption, increasing the risk of confidential data loss.
- **Bypass Vulnerability**: Disabling encryption also increases vulnerability to bypassing security measures. For example, removing the lock file may be easier, allowing an attacker to access the device without entering a password.

It is important to carefully weigh all the pros and cons before deciding to disable data encryption on your device. Security and usability should be balanced depending on your needs and the threats you face.
### DFE-Neo Script Operation:

#### First Stage:
1. **Determining Firmware Slot**: The script determines which suffix/slot the firmware should boot into.

2. **Repartitioning**: Necessary for determining the correct slot. After this, any zip files can be installed without having to reboot TWRP after installing a new firmware.

3. **TWRP Bypass**: Sets the suffix TWRP should boot into if a new firmware is installed.

#### Second Stage:
1. **Checking for DFE-Neo v2**: Checks if DFE-Neo v2 is installed. If installed, the script offers to remove DFE or install it again.

2. **Setting Arguments**: Arguments are set by the user or read from the NEO.config file.

#### Third Stage:
1. **Mounting vendor partition of the boot firmware**: The script mounts the vendor partition of the boot firmware.

2. **Copying files from /vendor/etc/init/hw**: All files from the specified directory are copied to a temporary folder.

3. **Modifying fstab and *.rc files**: *.rc files and fstab are modified according to parameters from NEO.config.

4. **Creating ext4 image with modified files**: An ext4 image with modified files from the temporary folder is created.

#### Fourth Stage:
1. **Writing inject_neo.img to vendor_boot/boot**: inject_neo.img is written to vendor_boot/boot of the opposite suffix or current slot and suffix.

2. **Checking boot suffixes**: Checks for the presence of ramdisk.cpio and fisrt_stage_mount fstab file.

3. **Modifying fisrt_stage_mount**: fisrt_stage_mount file is modified by adding a new mount point.

#### Optional Actions:
- **Removing PIN from Lock Screen**: If the corresponding option is selected, PIN from the lock screen will be removed.
- **Wiping Data**: If the corresponding option is selected, data will be wiped.
- **Installing Magisk**: If Magisk version is specified, it will be installed.

This is a general description of how the DFE-Neo script operates. It performs a series of steps to prepare and modify the system to ensure the correct execution of the firmware installation and update procedure on the device.

## Used Binaries

- **Magisk, Busybox, Magiskboot**: Taken from the latest version of [Magisk](https://github.com/topjohnwu/Magisk).
- **avbctl, bootctl, snapshotctl, toolbox, toybox**: Compiled from Android source code.
- **make_ext4fs**: [GitHub](https://github.com/sunqianGitHub/make_ext4fs/tree/master/prebuilt_binary)
- **lptools_new**: Open-source code from [GitHub](https://github.com/leegarchat/lptools_new) was used to create the binary, with its own utility code included.
- **Bash**: Static binary taken from [Debian Packages](https://packages.debian.org/unstable/bash-static).
- **SQLite3**: Taken from the [repository](https://github.com/rojenzaman/sqlite3-magisk-module).
