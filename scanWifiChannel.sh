#!/bin/bash
CMD="iw dev ap_2G scan | grep \"primary channel\" | grep \"\b1\b\|\b6\b\|\b11\b\" | sort -V | uniq -c | sort -V"
CHA="iw dev ap_2G info | grep \"channel\""
getInfo() {
	echo "${1}: $(ssh root@${2} ${CHA} | sed 's/channel \(.*\) (.*/\1/' | tr -d '\t')"
	ssh root@${2} ${CMD} | tr -d '\t'
}
getInfo Sverdlova-1 192.168.0.1
getInfo Sverdlova-2 192.168.0.2
getInfo Danilevskii-1 192.168.1.1
getInfo Danilevskii-2 192.168.1.2
getInfo Danilevskii-3 192.168.1.3
getInfo Danilevskii-4 192.168.1.4
getInfo Spb-1 192.168.2.1

