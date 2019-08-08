#!/bin/bash
ER=1
chk () {
	if [  $? -eq 0  ]
	then
		let ER++;
	else
		echo "Operation unsuccessful: $ER";
		exit $ER;
	fi
}
clean () {
	echo "Cleaning"
	echo "Cleaning configuration"
	rm -f .config
	chk
	echo "Cleaning old configuration"
	rm -f .config.old
	chk 
	echo "Cleaning files"
	rm -rf files/*
	chk
}
build () {
	echo "Building $1"
	clean
	echo "Copying configuration"
	cp -f ../openwrt-config/$1/.config .
	chk
	echo "Copying files"
	cp -rf ../openwrt-config/$1/etc files
	chk
	echo "Expanding configuration"
	make -j 5 defconfig >> build.log 2>&1
	chk
	echo "Pre-build cleaning"
	make -j 5 clean >> build.log 2>&1
	chk
	echo "Pre-build downloading"
	make -j 5 download >> build.log 2>&1
	chk
	echo "Building"
	make -j 5 V=s >> build.log 2>&1
	if [  $? -eq 0  ]
	then
		let ER++;
	else
		echo -e "Building attempt failed\nRetrying with one thread and debug output";
		make -j 1 V=s >> build.log 2>&1
		if [  $? -eq 0  ]
		then
			let ER++;
		else
			echo "Second building attempt unsuccessful: $ER";
			exit $ER;
		fi
	fi
	echo "Copying results"
	for file in bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2="`basename $file`"
		file2="${file2#*-*-*-*-*-*-*-}"
		mv "$file" "../openwrt-firmware/`basename ${file%openwrt-*-squashfs-*.bin}${1}-${file2}`"
	done
	echo "Post-build cleaning"
	make -j 5 clean >> build.log 2>&1
	chk
	clean
	echo -e '\n'
}
echo "Removing build log"
rm -f build.log
chk
echo "Updating from GIT"
git pull >> build.log 2>&1
chk
echo "Checking out from GIT"
git checkout -f >> build.log 2>&1
chk
echo "Updating feeds"
./scripts/feeds update -a >> build.log 2>&1
chk
echo "Installing feeds"
./scripts/feeds install -a >> build.log 2>&1
chk
echo -e "\n"
if [ $# -gt 0 ]
then
	for arg in $*
	do
		build "$arg"
	done
else
	build "sverdlova-1"
	build "sverdlova-2"
	build "danilevskii-1"
	build "danilevskii-2"
	build "danilevskii-3"
	build "danilevskii-4"
fi

