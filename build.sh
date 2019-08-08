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
		make -j 1 V=s >> build.log 2>&1
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
build () {
	echo "Building $1"
	clean
	cp -f ../openwrt-config/$1/.config .
	chk "Copying .config"
	cp -rf ../openwrt-config/$1/etc files
	chk "Copying files"
	make -j 5 defconfig >> build.log 2>&1
	chk "Expanding .config"
	make -j 5 clean >> build.log 2>&1
	chk "Cleaning"
	make -j 5 download >> build.log 2>&1
	chk "Downloading"
	make -j 5 >> build.log 2>&1
	chkBld
	for file in bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2="`basename $file`"
		file2="${file2#*-*-*-*-*-*-*-}"
		mv "$file" "../openwrt-firmware/`basename ${file%openwrt-*-squashfs-*.bin}${1}-${file2}`"
	done
	chk "Copying results"
	make -j 5 clean >> build.log 2>&1
	chk "Cleaning"
	clean
	echo -e '\n'
}
rm -f build.log
chk "Removing build.log"
build "sverdlova-1"
build "sverdlova-2"
build "danilevskii-1"
build "danilevskii-2"
build "danilevskii-3"
build "danilevskii-4"

