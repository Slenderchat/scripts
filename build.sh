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
		make -j 1
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
	rm -rf files/*
	chk "Cleaning files"
}
build () {
	clean
	cp -f ../openwrt-config/$1/.config .config
	chk "Copying .config"
	cp -rf ../openwrt-config/$1/etc files
	chk "Copying files"
	make clean
	chk "Cleaning"
	make download
	chk "Downloading"
	make -j 1
	chkBld
	for file in bin/targets/*/*/openwrt-*-squashfs-*.bin
	do
		file2=`basename $file`
		file2=${file2##*-*-*-*-*-*-*-}
		mv $file "${file%%openwrt-*-squashfs-*.bin}${1}-${file2}"
	done
	chk "Copying results"
	make clean
	chk "Cleaning"
	clean
}
build "sverdlova-1"
build "sverdlova-2"
build "danilevskii-1"
build "danilevskii-2"
build "danilevskii-3"
build "danilevskii-4"

