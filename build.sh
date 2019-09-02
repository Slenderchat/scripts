#!/bin/bash
clean () {
	echo "Cleaning configuration" &&
	rm -f ~/openwrt/.config ~/openwrt/.config.old &&
	echo "Cleaning files" &&
	rm -rf ~/openwrt/files/* &&
	echo "Cleaning bin" &&
	rm -rf ~/openwrt/bin &&
	echo "Cleaning build_dir" &&
	rm -rf ~/openwrt/build_dir/*
}
build () {
	echo "Building $1" &&
	clean &&
	echo "Copying configuration" &&
	cp -f ~/openwrt-config/$1/.config . &&
	echo "Copying files" &&
	cp -rf ~/openwrt-config/$1/etc files &&
	echo "Expanding configuration" &&
	make defconfig >> build.log 2>&1 &&
	echo "Pre-build cleaning" &&
	make clean >> build.log 2>&1 &&
	echo "Pre-build downloading" &&
	make download >> build.log 2>&1 &&
	echo "Building" &&
	make FORCE_UNSAFE_CONFIGURE=1 -j 4 >> build.log 2>&1
	if [  $? -ne 0  ]
	then
		echo -e "Building attempt failed\nRetrying with one thread" &&
		echo >> build.log &&
		echo -e "Building attempt failed\nRetrying with one thread" >> build.log &&
		echo >> build.log &&
		make FORCE_UNSAFE_CONFIGURE=1 V=s >> build.log 2>&1
		if [  $? -ne 0  ]
		then
			echo "Second building attempt unsuccessful" &&
			exit 1
		fi
	fi
	echo "Copying results" &&
	for file in ~/openwrt/bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2=$(basename $file) &&
		file2=${file2#*-*-*-*-*-*-*-} &&
		mv $file ~/openwrt-firmware/$(basename ${file%openwrt-*-squashfs-*.bin}$1-$file2)
	done
	echo "Post-build cleaning" &&
	make clean >> build.log 2>&1 &&
	clean &&
	echo
}
echo "Removing build log" &&
rm -f build.log &&
echo "Fetching from GIT" &&
git fetch >> build.log 2>&1 &&
echo "Reseting working tree to origin/master's state" &&
git reset --hard origin/master >> build.log 2>&1 &&
echo "Updating feeds" &&
./scripts/feeds update -a >> build.log 2>&1 &&
echo "Installing feeds" &&
./scripts/feeds install -a >> build.log 2>&1 &&
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
	for tgt in ~/openwrt-config/*-[0-9]
	do
		build $(basename $tgt)
	done
fi
rm -rf ~/openwrt/bin ~/openwrt/build_dir ~/openwrt/files ~/openwrt/tmp

