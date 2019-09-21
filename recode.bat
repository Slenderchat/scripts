@echo off
setlocal
type nul > %TMP%\rlist
set TF=%TMP%\rlist
md %TMP%\rfolder
set TD=%TMP%\rfolder
for %%f in (*.mp4) do (
	"ffmpeg.exe" -i %%f -an -c:v libx264 -pix_fmt yuv420p -s 1280x720 -profile:v baseline -level 31 -crf 18 -r 10 -movflags +faststart -video_track_timescale 10 -y %TD%\%%f
	del /q %%f
)
for %%f in (%TD%\*.mp4) do (
	echo file '%%f' >> %TF%
)
"ffmpeg.exe" -f concat -safe 0 -i %TF% -c:v copy -movflags +faststart -video_track_timescale 10 -an -y out.mp4
del /q %TF%
rmdir /q /s %TD%
endlocal
