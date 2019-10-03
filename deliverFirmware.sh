#!/bin/bash
parallel -j 0 "scp -B /home/slenderchat/openwrt-firmware/{1}-sysupgrade.bin root@192.168.{2}:/tmp" ::: danilevskii-4 danilevskii-3 danilevskii-2 danilevskii-1 sverdlova-2 sverdlova-1 spb-1 :::+ 1.4 1.3 1.2 1.1 0.2 0.1
