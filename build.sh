#!/bin/bash
build () {
	echo "Building $1" &&
	echo "Pre-build cleaning" &&
	rm -rf $HOME/openwrt/.config $HOME/openwrt/.config.old $HOME/openwrt/files/* $HOME/openwrt/bin/* $HOME/openwrt/build_dir/* $HOME/openwrt/tmp/*
	echo "Copying configuration" &&
	cp -f $HOME/openwrt-config/$1/config $HOME/openwrt/.config &&
	echo "Copying files" &&
	cp -Lrf $HOME/openwrt-config/$1/etc $HOME/openwrt/files &&
	echo "Expanding configuration" &&
	make -j 2 defconfig >> build.log 2>&1 &&
	echo "Downloading" &&
	make -j 2 download >> build.log 2>&1 &&
	echo "Building" &&
	make -j 2 >> build.log 2>&1
	if [  $? -ne 0  ]
	then
		echo -e "Building attempt failed\nRetrying with one thread" | tee -a build.log &&
		make V=s >> build.log 2>&1
		if [  $? -ne 0  ]
		then
			echo "Second building attempt unsuccessful" &&
			exit 1
		fi
	fi
	echo "Copying results" &&
	for file in $HOME/openwrt/bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		local tmp=$(basename $file) &&
		tmp=${file2#*-*-*-*-*-*-*-} &&
		mv $file $HOME/openwrt-firmware/$(basename ${file%openwrt-*-squashfs-*.bin}$1-$tmp)
	done
	echo
}
echo "Removing build log" &&
rm -f build.log &&
echo "Fetching from GIT" &&
git fetch >> build.log 2>&1 &&
echo "Reseting working tree to origin/master's state" &&
git reset --hard origin/master >> build.log 2>&1 &&
echo "Updating feeds" &&
$HOME/openwrt/scripts/feeds update -a >> build.log 2>&1 &&
echo "Installing feeds" &&
$HOME/openwrt/scripts/feeds install -a >> build.log 2>&1 &&
echo "Creating 'build_dir'" &&
mkdir -p /tmp/build_dir &&
echo "Creating symlink to 'build_dir'" &&
ln -sf /tmp/build_dir build_dir &&
echo "Creating 'files'" &&
mkdir -p $HOME/openwrt/files &&
echo "Cleaning and creating 'openwrt-firmware'" &&
rm -rf $HOME/openwrt-firmware &&
mkdir -p $HOME/openwrt-firmware &&
echo
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build $arg
	done
else
	for tgt in $HOME/openwrt-config/*-[1-9]
	do
		build $(basename $tgt)
	done
fi
echo "Nuking junk files and folders"
rm -rf $HOME/openwrt/bin $HOME/openwrt/build_dir $HOME/openwrt/files $HOME/openwrt/tmp /tmp/build_dir

