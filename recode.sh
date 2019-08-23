#!/bin/bash
TF=$(mktemp)
TD=$(mktemp -d)
for file in [0-9][0-9]-[0-9][0-9]-[0-9][0-9].mp4
do
	ffmpeg -i $file -an -c:v libx264 -pix_fmt yuv420p -s 1280x720 -profile:v baseline -level 31 -r 10 -video_track_timescale 10 -y "$TD/$(basename $file)"
done
for file in $TD/*.mp4
do
	echo "file '$file'" >> $TF
done
ffmpeg -f concat -safe 0 -i $TF -c:v copy -an -y out.mp4
rm -f $TF
rm -rf $TD

