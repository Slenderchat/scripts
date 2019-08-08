#!/bin/bash
mkdir buffer
for file in input/*.mp4
do
	ffmpeg -i $file -an -c:v libx264 -pix_fmt yuv420p -profile:v baseline -crf 18 -r 10 -video_track_timescale 10 -y "buffer/$(basename $file)"
done
> list
for file in buffer/*.mp4
do
        echo "file '$file'" >> list
done
ffmpeg -f concat -safe 0 -i list -c:v copy -an -y "out.mp4"
rm -f list
rm -rf buffer

