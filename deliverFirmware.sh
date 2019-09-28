#!/bin/bash
deliver() {
	scp /home/slenderchat/openwrt-firmware/${1}-sysupgrade.bin root@${2}:/tmp
}
deliver spb-1 192.168.2.1
deliver sverdlova-1 192.168.0.1
deliver sverdlova-2 192.168.0.2
deliver danilevskii-1 192.168.1.1
deliver danilevskii-2 192.168.1.2
deliver danilevskii-3 192.168.1.3
deliver danilevskii-4 192.168.1.4

