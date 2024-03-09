- Русское [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_ru.md)
- English [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README.md)
- Bahasa Indonesia [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_id.md)
- 中文 [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_zh.md)
- हिन्दी [readme.md](https://github.com/leegarchat/dfe-neo-v2/blob/master/README_hi.md)

# 禁用原生早期强制加密覆盖（DFE NEO v2）

## 论坛讨论：

- **XDA Developers：**
  [XDA 论坛主题](https://xdaforums.com/t/a-b-a-only-script-read-only-erofs-android-10-disable-force-encryption-native-early-override-dfe-neo-v2-disable-encryption-data-userdata.4454017/)

- **4PDA：**
  [4PDA 论坛主题](https://4pda.to/forum/index.php?showtopic=1084916)


## Android 数据加密禁用

### 描述

DFE-NEO v2 是一个脚本，旨在禁用 Android 设备上 /userdata 分区的强制加密。它旨在实现 ROM 之间的简单切换和在 TWRP 中访问数据，而无需格式化数据或删除用户重要文件，如 ./Download、./DCIM 等，这些文件位于设备的内部存储中。

### 使用方法

目前，该脚本只能作为 TWRP 安装文件使用。

1. 安装 `dfe-neo.zip`。
2. 选择所需的配置。
3. 安装成功后，如果您的数据已加密，则需要格式化数据：
   - 进入 TWRP 菜单中的 "Wipe"。
   - 选择 "format data"。
   - 输入 "yes" 确认执行操作。

## 注意

注意：在使用脚本之前，请确保您了解其工作原理，并备份您的数据，以防止数据丢失。

## 禁用 /data 加密的利弊

### 优点

- **简化数据备份和恢复**：在禁用加密的情况下，可以更轻松地备份和恢复 /data 中的数据。这简化了设备重新刷机、故障恢复或将数据转移到新设备的情况。
- **简化切换 ROM**：禁用加密可以避免切换 ROM 时需要完全格式化数据的情况，节省时间并简化 ROM 之间的过渡过程。
- **在未完成的 TWRP 中访问数据**：禁用加密允许在 TWRP 的未完成或不完美版本中访问数据，这些版本不支持解密加密数据。

### 缺点

- **数据丢失风险**：禁用加密后，数据容易受到未经授权的访问。这增加了黑客访问您个人数据的风险。
- **设备丢失风险增加**：如果设备丢失或被盗，数据可能会在不需要解密的情况下被盗或泄露，从而增加了机密数据丢失的风险。
- **绕过保护的风险**：禁用加密也增加了绕过保护的风险。例如，删除锁定文件可能更容易，从而使黑客可以无需输入密码即可访问设备。

在决定禁用设备上的数据加密之前，仔细权衡所有优缺点是很重要的。安全性和使用便利性应根据您的需求和面临的威胁来平衡。

### DFE-Neo 脚本操作：

#### 第一阶段：
1. **确定固件槽位**：脚本确定固件应启动的后缀/槽位。

2. **重新分区**：用于确定正确的槽位。之后，可以安装任何 zip 文件，甚至无需在安装新固件后重新启动 TWRP。

3. **欺骗 TWRP**：为新固件安装设置 TWRP 后缀。

#### 第二阶段：
1. **检查 DFE-Neo v2 的存在**：检查是否安装了 DFE-Neo v2。如果已安装，则脚本会提示删除 DFE 或重新安装。

2. **设置参数**：参数由用户设置或从 NEO.config 文件中读取。

#### 第三阶段：
1. **挂载固件引导分区**：脚本会挂载固件引导分区的 vendor 分区。

2. **从 /vendor/etc/init/hw 目录复制文件**：将该目录中的所有文件复制到临时文件夹中。

3. **修改 fstab 和 *.rc 文件**：根据 NEO.config 中的参数修改 *.rc 文件和 fstab。

4. **创建带有修改文件的 ext4 镜像**：从临时文件夹创建带有修改文件的 ext4 镜像。

#### 第四阶段：
1. **将 inject_neo.img 写入 vendor_boot/boot**：将 inject_neo.img 写入 vendor_boot/boot 的相对槽位或当前槽位和后缀。

2. **检查引导后缀**：检查是否存在 ramdisk.cpio 和 fisrt_stage_mount fstab 文件。

3. **修改 fisrt_stage_mount**：通过添加新的挂载点来修改 fisrt_stage_mount 文件。

#### 可选操作：
- **删除锁定屏幕的 PIN**：如果选择了相应选项，则会删除锁定屏幕的 PIN。
- **清除数据 (wipe data)**：如果选择了相应选项，则会擦除数据。
- **安装 Magisk**：如果指定了 Magisk 版本，则会安装该版本。

这是 DFE-Neo 脚本操作的概要描述。它执行一系列步骤来准备和修改系统，以确保在设备上正确执行固件安装和更新过程。


## 使用的二进制文件

- **Magisk、Busybox、Magiskboot**：取自最新版本的 [Magisk](https://github.com/topjohnwu/Magisk)。
- **avbctl、bootctl、snapshotctl、toolbox、toybox**：从 Android 源代码编译而来。
- **make_ext4fs**: [GitHub](https://github.com/sunqianGitHub/make_ext4fs/tree/master/prebuilt_binary)
- **lptools_new**：使用 [GitHub](https://github.com/leegarchat/lptools_new) 上的开源代码创建二进制文件，还包括自己的实用程序代码。
- **Bash**：从 [Debian Packages](https://packages.debian.org/unstable/bash-static) 获取了一个静态二进制文件。
- **SQLite3**：从 [仓库](https://github.com/rojenzaman/sqlite3-magisk-module) 获取了它。
