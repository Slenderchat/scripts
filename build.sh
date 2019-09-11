#!/bin/bash
build () {
	echo "Building $1" &&
	echo "Pre-build cleaning" &&
	rm -rf .config .config.old files/* bin/* build_dir/* tmp/*
	echo "Copying configuration" &&
	cp -f ../openwrt-config/$1/config .config &&
	echo "Copying files" &&
	cp -Lrf ../openwrt-config/$1/etc files &&
	echo "Expanding configuration" &&
	make defconfig >> build.log 2>&1 &&
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
	for firmware in bin/targets/**/**/*.bin
	do
		tmp=$(basename $firmware) &&
		tmp=$(echo -n $tmp | perl -ne 's/.*?-(?=tftp-|sysupgrade|factory)//g; print;') &&
		tmp=$1-$tmp &&
		mv $firmware ../openwrt-firmware/$tmp
	done
	echo
}
echo "Fetching from GIT" &&
git fetch >> build.log 2>&1 &&
echo "Reseting working tree to origin/master's state" &&
git reset --hard origin/master >> build.log 2>&1 &&
echo "Cleaning working tree" &&
git clean -ffdx -e build.sh -e staging_dir >> build.log 2>&1 &&
echo "Updating feeds" &&
scripts/feeds update -a >> build.log 2>&1 &&
echo "Installing feeds" &&
scripts/feeds install -a >> build.log 2>&1 &&
#echo "Creating 'build_dir'" &&
#mkdir -p /tmp/build_dir &&
#ln -sf /tmp/build_dir build_dir &&
echo "Creating directories" &&
mkdir -p files &&
mkdir -p ../openwrt-firmware &&
echo
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build $arg
	done
else
	for tgt in ../openwrt-config/*-[1-4]
	do
		build $(basename $tgt)
	done
fi
echo "Cleaning working tree"
git clean -ffdx -e build.sh -e staging_dir >> build.log 2>&1

