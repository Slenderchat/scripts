#!/bin/bash
ER=1
chk () {
	if [  $? -eq 0  ]
	then
		echo "$1 succesful";
		let ER++;
	else
		echo "$1 failed";
		exit $ER;
	fi
}
chkBld () {
	if [  $? -eq 0  ]
	then
		echo "Building succesful";
		let ER++;
	else
		echo "Building failed";
		make -j 1 V=s 2>> build-errors.log 1>> build-output.log
		if [  $? -eq 0  ]
		then
			echo "Second building attempt succesful";
			let ER++;
		else
			echo "Second building attempt failed";
			exit $ER;
		fi
	fi
}
clean () {
	rm -f .config
	chk "Cleaning .config"
	rm -f .config.old
	chk "Cleaning .config.old"
	rm -rf files/*
	chk "Cleaning files"
}
cleanLogs () {
	rm -f build.log
	chk "Removing build.log"
	rm -f build-output.log
	chk "Removing build-output.log"
	rm -f build-errors.log
	chk "Removing build-errors.log"
}
build () {
	echo "Building $1"
	clean
	cp -f ../openwrt-config/$1/.config .
	chk "Copying .config"
	cp -rf ../openwrt-config/$1/etc files
	chk "Copying files"
	make defconfig 2>> build-errors.log 1>> build-output.log
	chk "Expanding .config"
	make clean 2>> build-errors.log 1>> build-output.log
	chk "Cleaning"
	make download 2>> build-errors.log 1>> build-output.log
	chk "Downloading"
	make -j 1 V=s 2>> build-errors.log 1>> build-output.log
	chkBld
	for file in bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2=`basename $file`
		file2=${file2##*-*-*-*-*-*-*-}
		mv $file "${file%%openwrt-*-squashfs-*.bin}${1}-${file2}"
	done
	chk "Copying results"
	make clean 2>> build-errors.log 1>> build-output.log
	chk "Cleaning"
	clean
	echo "\n"
}
cleanLogs
build "sverdlova-1"
build "sverdlova-2"
build "danilevskii-1"
build "danilevskii-2"
build "danilevskii-3"
build "danilevskii-4"

