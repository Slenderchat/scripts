#!/bin/bash
TF=$(mktemp)
TD=$(mktemp -d)
for file in *.mp4
do
	ffmpeg -i $file -an -c:v libx264 -pix_fmt yuv420p -profile:v baseline -level 31 -crf 23 -r 10 -video_track_timescale 10 -y "$TD/$(basename $file)"
done
for file in $TD/*.mp4
do
	echo "file '$file'" >> $TF
done
ffmpeg -f concat -safe 0 -i $TF -c:v copy -an -y out.mp4
rm -rf $TF
rm -rf $TD

