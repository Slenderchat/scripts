#!/bin/bash
clean () {
	echo "Cleaning" &&
	echo "Cleaning configuration" &&
	rm -f .config &&
	echo "Cleaning old configuration" &&
	rm -f .config.old &&
	echo "Cleaning files" &&
	rm -rf files/*
}
build () {
	echo "Building $1" &&
	clean &&
	echo "Copying configuration" &&
	cp -f ../openwrt-config/$1/.config . &&
	echo "Copying files" &&
	cp -rf ../openwrt-config/$1/etc files &&
	echo "Expanding configuration" &&
	make defconfig >> build.log 2>&1 &&
	echo "Pre-build cleaning" &&
	make clean >> build.log 2>&1 &&
	echo "Pre-build downloading" &&
	make download >> build.log 2>&1 &&
	echo "Building" &&
	make -j 4 V=s >> build.log 2>&1
	if [  $? -ne 0  ]
	then
		echo -e "Building attempt failed\nRetrying with one thread" &&
		echo -e '\n' >> build.log &&
		echo -e "Building attempt failed\nRetrying with one thread" >> build.log &&
		echo -e '\n' >> build.log &&
		make V=s >> build.log 2>&1
		if [  $? -ne 0  ]
		then
			echo "Second building attempt unsuccessful" &&
			exit 1
		fi
	fi
	echo "Copying results" &&
	for file in bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2=$(basename $file) &&
		file2=${file2#*-*-*-*-*-*-*-} &&
		mv $file ../openwrt-firmware/$(basename ${file%openwrt-*-squashfs-*.bin}$1-$file2)
	done
	echo "Post-build cleaning" &&
	make clean >> build.log 2>&1 &&
	clean &&
	echo -e '\n'
}
echo "Removing build log" &&
rm -f build.log &&
echo "Fetching from GIT" &&
git fetch >> build.log 2>&1 &&
echo "Reseting working tree to origin/master state" &&
git reset --hard origin/master >> build.log 2>&1 &&
echo "Updating feeds" &&
./scripts/feeds update -a >> build.log 2>&1 &&
echo "Installing feeds" &&
./scripts/feeds install -a >> build.log 2>&1 &&
echo -e "\n" &&
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build "$arg"
		if [ $? -ne 0 ]
		then
			exit 2
		fi
	done
else
	build "sverdlova-1" &&
	build "sverdlova-2" &&
	build "danilevskii-1" &&
	build "danilevskii-2" &&
	build "danilevskii-3" &&
	build "danilevskii-4"
fi

