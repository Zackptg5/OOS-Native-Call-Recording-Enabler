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
if [ -e /dev/block/platform/*/by-name/boot ]; then
  block=/dev/block/platform/*/by-name/boot
elif [ -e /dev/block/platform/*/*/by-name/boot ]; then
  block=/dev/block/platform/*/*/by-name/boot
elif [ -e /dev/block/platform/sdhci-tegra.3/by-name/LNX ]; then
  block=/dev/block/platform/sdhci-tegra.3/by-name/LNX
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

# Slot device support
if [ ! -z $slot ]; then            
  if [ -d $ramdisk/.subackup -o -d $ramdisk/.backup ]; then
    patch_cmdline "skip_override" "skip_override"
  else
    patch_cmdline "skip_override" ""
  fi
  # Overlay stuff
  if [ -d $ramdisk/.backup ]; then
    overlay=$ramdisk/overlay
  elif [ -d $ramdisk/.subackup ]; then
    overlay=$ramdisk/boot
  fi
  for rdfile in $list; do
    rddir=$(dirname $rdfile)
    mkdir -p $overlay/$rddir
    test ! -f $overlay/$rdfile && cp -rp /system/$rdfile $overlay/$rddir/
  done                       
else
  overlay=$ramdisk
fi

# determine install or uninstall
test "$(grep "NCRINDICATOR" $overlay/init.rc)" && ACTION=Uninstall

# begin ramdisk changes
if [ -z $ACTION ]; then
  # Add line to init.rc
  backup_file $overlay/init.rc
  ui_print "Enabling NCR..."
  append_file init.rc "enable_native_call_recording_oos" ncrpatch
else
  ui_print "Removing NCR..."
  restore_file $overlay/init.rc
fi

# end ramdisk changes
ui_print " "
ui_print "Repacking boot image..."
write_boot

# end install
