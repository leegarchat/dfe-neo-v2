
set -e
#----------------
    # Working instructions 
    # Language settings available:
    # English `en`
    # Russian `ru` 
    # Indonesian `id`
    # Chinese `zh`
    # Hindi `hi`
    
LANGUAGE=en

#----------------
    # The `FORCE_START` option forces the script to start without selection from the menu using volume buttons. The script will output an error if the configuration is not set up correctly. 
    # There should be no values of `ask` in any of the arguments. 
    # Available values `false` or `true`.

FORCE_START=false

#----------------
    # Configure the option if you receive error 36.1 fstab not found. This can happen if the ro.hardware variable differs in TWRP and the running system
    # You can check this in TWRP terminal by typing the command `getprop ro.hardware` and in the running system through any terminal, if the props differ, you need to enter the value that is displayed in the running system
    # Otherwise, leave the value blank

FSTAB_EXTENSION=auto

#----------------
    # The option disables system integrity check
    # Available options false, true, ask

DISABLE_VERITY_VBMETA_PATCH=ask

#----------------
    # The option allows hiding the absence of encryption /data, only works if selinux is not set to enforcing mode, also works if Magisk or KernelSU is installed
    # Available options false, true, ask

HIDE_NOT_ENCRYPTED=ask

#----------------
    # *** The option will work only if Magisk/KernelSu is installed or if you have slinux=premisive
    # Custom props, will be set at the stage at which you specified
    # Usage example: 
    # `CUSTOM_SETPROP="--init my.prop=value my.prop2=value my.prop3=value --early-fs my.prop=value my.prop2=value my.prop3=value"` and so on
    # Available stages init: `--init`, `--early-fs`, `--post-fs-data`, `--boot_completed`
    # Otherwise, leave it empty

CUSTOM_SETPROP=""

#----------------
    # The option to Add Custom Denylist:
    # This option writes application packages to `denylist` at boot time. Works only if `Magisk` is installed.
    # You can manually configure the configuration file in `.zip/META-INF/tools/denylist.txt`.
    # Available options:  
    # `false` - disable, 
    # `ask` - prompt during installation,
    # `first_time_boot` - the script will be executed only once during the first boot, the record of the first use is stored in Magisk memory,
    # `always_on_boot` - the script will be executed at every system boot.

INJECT_CUSTOM_DENYLIST_IN_BOOT=ask

#----------------
    # Enable `Zygisk` Mode:
    # This option forcibly enables `zygisk` mode on device startup, even if `Magisk` is installed for the first time.
    # Available options: 
    # `false` - disable, `ask` - prompt during installation,
    # `first_time_boot` - the script will be executed only once during the first boot, the record of the first use is stored in Magisk memory,
    # `always_on_boot` - the script will be executed at every system boot.

ZYGISK_TURN_ON_IN_BOOT=ask

#----------------
    # Enables built-in security fix integrated into dfe-neo, which runs at the initialization stage during boot, works only if selinux is not set to enforcing mode, also works if Magisk or KernelSU is installed
    # Available options false, true, ask

SAFETY_NET_FIX_PATCH=ask


#----------------
    # Set to `true` to remove PIN lock, `false` otherwise
    # Set to `ask` to prompt the user during installation

REMOVE_LOCKSCREEN_INFO=ask

#----------------
    # Set to `true` to wipe data during installation, `false` otherwise
    # Set to `ask` to prompt the user during installation

WIPE_DATA_AFTER_INSTALL=false

#----------------
    # This option specifies whether fstab substitution should also be done in --early as well as in --late init when mounting partitions from fstab. --early mount includes all partitions except those with first_stage_mount and latemount flags set.
    # By default, it is set to false.
    # If set to `ask`, the script will prompt the user to choose the option during installation.

MOUNT_FSTAB_EARLY_TOO=ask

#----------------
    # Block for setting to remove or replace patterns in fstab. Leave default if you don't know what you need it for.
    #   `-m` specifies the mount point line where patterns should be removed. For example, `-m /data`. After this flag, specify `-r and/or -p`.
    #   `-r` specifies which patterns to remove. Patterns will be removed up to comma or space. For example:
    #        /.../userdata	/data	f2fs	noatime,....,inlinecrypt	wait,....,fileencryption=aes-256-xts:aes-256-cts:v2,....,fscompress
    #        with `-m /data -r fileencryption= inlinecrypt` fileencryption=aes-256-xts:aes-256-cts:v2 will be removed. Resulting line will be:
    #        /.../userdata	/data	f2fs	noatime,....	wait,....,....,fscompress
    #   `-p` specifies which patterns to replace. For example, `-m /data -p inlinecrypt--to--ecrypt`. Result will be:
    #        /.../userdata	/data	f2fs	noatime,....,ecrypt	wait,....,fileencryption=aes-256-xts:aes-256-cts:v2,....,fscompress
    #        You can specify multiple parameters `-p inlinecrypt--to--ecrypt fileencryption--to--notencryption`
    #   `-v` When this flag is specified, all lines in fstab starting with `overlay` will be commented out, thereby disabling the manufacturer's system overlay. To feel the effect, set true for the modify_early_mount option.
    #   Example of filling:
    #        "-m /data -p fileencryption--to--notencrypteble ice--to--not-ice -r forceencrypt= -m /system -p ro--to--rw -m /metadata -r keydirectory="
    #        Default value: "-m /data -r fileencryption= forcefdeorfbe= encryptable= forceencrypt= metadata_encryption= keydirectory= inlinecrypt quota wrappedkey"

FSTAB_PATCH_PATERNS="-m /data -r fileencryption= forcefdeorfbe= encryptable= forceencrypt= metadata_encryption= keydirectory= inlinecrypt quota wrappedkey"

#----------------
    # Configuration Section: Injection Options
    #  `WHERE_TO_INJECT`: This option determines where the module will be injected. Choose one of the options:
    #      `super`: The module will be flashed into the current slot next to the system, vendor, etc.
    #      `vendor_boot`: The module will be flashed into the inactive vendor_boot slot (not available for devices with A-only partitioning).
    #      `boot`: The module will be flashed into the inactive boot slot (not available for devices with A-only partitioning).

WHERE_TO_INJECT=auto

#----------------
    #  `magisk`: Specify the Magisk version to install or leave the field blank.
    #      Available versions: 
    #                       Magisk-Delta-v26.4
    #                       Magisk-Delta-v27.0
    #                       Magisk-kitsune-v27-R65C33E4F
    #                       Magisk-v26.4-kitsune-2
    #                       Magisk-v26.4
    #                       Magisk-v27.0
    #      Example: magisk Magisk-v27.0
    #      To install Magisk from the same directory as neo.zip, add the "EXT:" prefix, for example, "EXT:Magisk-v24.3.zip".

INSTALL_MAGISK=
