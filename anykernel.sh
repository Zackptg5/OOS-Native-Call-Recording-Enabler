# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=OOS Native Call Recording Enabler
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
device.name1=OnePlus5T
device.name2=dumpling
device.name3=Dumpling	 
device.name4=OnePlus5
device.name5=cheeseburger
device.name6=Cheeseburger
} # end properties

# shell variables
ramdisk_compression=auto
# determine the location of the boot partition
if [ "$(find /dev/block -name boot | head -n 1)" ]; then
  block=$(find /dev/block -name boot | head -n 1)
elif [ -e /dev/block/platform/sdhci-tegra.3/by-name/LNX ]; then
  block=/dev/block/platform/sdhci-tegra.3/by-name/LNX
else
  abort "! Boot img not found! Aborting!"
fi

# force expansion of the path so we can use it
block=`echo -n $block`;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*
chown -R root:root $ramdisk/*

## AnyKernel install
ui_print "Unpacking boot image..."
ui_print " "
dump_boot

# File list
list="init.rc"


# determine install or uninstall
[ "$(grep 'service Native_Call_Recording' $overlay/init.rc)" ] && ACTION=Uninstall

# begin ramdisk changes
if [ -z $ACTION ]; then
  # Add line to init.rc
  backup_file $overlay/init.rc
  ui_print "Enabling NCR..."
  append_file init.rc "enable_native_call_recording_oos" ncrpatch
else
  ui_print "Removing NCR..."
  sed -i "/service Native_Call_Recording/,/start Native_Call_Recording/d" $overlay/init.rc
fi

# end ramdisk changes
ui_print " "
ui_print "Repacking boot image..."
write_boot

# end install
