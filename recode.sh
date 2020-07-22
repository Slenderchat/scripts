#!/bin/bash
TD=`mktemp -d`
TN=`mktemp`
for i in [0-9][0-9]-[0-9][0-9]-[0-9][0-9].mp4
do
	./ffmpeg -i $i -an -c:v libx264 -filter:v fps=fps=9 -y $TD/`basename $i`
	echo "file '$TD/`basename $i`'" >> $TN
done
./ffmpeg -f concat -safe 0 -i $TN -c:v copy -movflags +faststart -an out.mp4
rm -r $TD
rm $TN
