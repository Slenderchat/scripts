#!/bin/bash
build () {
	echo "Building $1" &&
	echo "Copying configuration" &&
	cp ../openwrt-config/$1/config .config &&
	echo "Expanding configuration" &&
	make defconfig >> build.log 2>&1 &&
	echo "Pre-build cleaning" &&
	make clean >> build.log 2>&1 &&
	rm -rf files/
	echo "Copying files" &&
	mkdir -p files &&
	cp -Lr ../openwrt-config/$1/etc files &&
	echo "Downloading" &&
	make -j 4 download >> build.log 2>&1 &&
	echo "Building" &&
	make -j 4 >> build.log 2>&1
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
	mkdir -p ../openwrt-firmware &&
	for firmware in bin/targets/**/**/*squashfs*.bin
	do
		tmp=$(basename $firmware) &&
		tmp=$(echo -n $tmp | perl -ne 's/.*?-(?=tftp-|sysupgrade|factory)//g; print;') &&
		tmp=$1-$tmp &&
		mv $firmware ../openwrt-firmware/$tmp
	done
	echo
}
echo "Cleaning and updating openwrt from GIT" &&
git reset --hard >> build.log 2>&1 &&
git clean -fdx -e build.sh -e feeds -e staging_dir >> build.log 2>&1 &&
echo
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build $arg
	done
else
	for tgt in ../openwrt-config/*-[0-9]
	do
		build $(basename $tgt)
	done
fi
echo "Cleaning working tree" &&
git clean -fdx -e build.sh -e feeds -e staging_dir >> build.log 2>&1
