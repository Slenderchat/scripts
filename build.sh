#!/bin/bash
build () {
	echo "Building $1" &&
	echo "Pre-build cleaning" &&
	rm -rf ~/openwrt/.config ~/openwrt/.config.old ~/openwrt/files/* ~/openwrt/bin/* ~/openwrt/build_dir/* ~/openwrt/tmp/*
	echo "Copying configuration" &&
	cp -f ~/openwrt-config/$1/config ~/openwrt/.config &&
	echo "Copying files" &&
	cp -Lrf ~/openwrt-config/$1/etc ~/openwrt/files &&
	echo "Expanding configuration" &&
	make -j -l 4.0 defconfig >> build.log 2>&1 &&
	echo "Downloading" &&
	make -j -l 4.0 download >> build.log 2>&1 &&
	echo "Building" &&
	make -j -l 4.0 >> build.log 2>&1
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
	for file in ~/openwrt/bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		local tmp=$(basename $file) &&
		tmp=${file2#*-*-*-*-*-*-*-} &&
		mv $file ~/openwrt-firmware/$(basename ${file%openwrt-*-squashfs-*.bin}$1-$tmp)
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
~/openwrt/scripts/feeds update -a >> build.log 2>&1 &&
echo "Installing feeds" &&
~/openwrt/scripts/feeds install -a >> build.log 2>&1 &&
echo "Creating 'build_dir'" &&
mkdir -p /tmp/build_dir &&
echo "Creating symlink to 'build_dir'" &&
ln -sf /tmp/build_dir build_dir &&
echo "Creating 'files'" &&
mkdir -p ~/openwrt/files &&
echo "Cleaning and creating 'openwrt-firmware'" &&
rm -rf ~/openwrt-firmware &&
mkdir -p ~/openwrt-firmware &&
echo
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build $arg
	done
else
	for tgt in ~/openwrt-config/*-[1-9]
	do
		build $(basename $tgt)
	done
fi
echo "Nuking junk files and folders"
rm -rf ~/openwrt/bin ~/openwrt/build_dir ~/openwrt/files ~/openwrt/tmp /tmp/build_dir

