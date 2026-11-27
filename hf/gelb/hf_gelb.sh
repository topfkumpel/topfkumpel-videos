#!/bin/bash
# Schnitt im Higgsfield-Sandkasten: Higgsfield-Clip (Seedance 2.5) + Text-Ebene (ov.webm, mit Alpha) + Ton (mix.m4a) -> final.mp4 (1080x1920, 30 fps)
set -e
cd ~/hf && mkdir -p gelb && cd gelb
R=https://raw.githubusercontent.com/topfkumpel/topfkumpel-videos/main/hf/gelb
curl -sfL -o ov.webm $R/ov.webm; curl -sfL -o mix.m4a $R/mix.m4a
CLIP=../test.mp4
V="-c:v libx264 -preset veryfast -crf 17 -pix_fmt yuv420p -r 30"
S="scale=1080:1920:flags=lanczos"
ffmpeg -y -v error -ss 0.3 -i $CLIP -frames:v 1 -vf scale=2160:3840:flags=lanczos still2.png
ffmpeg -y -v error -ss 4.2 -i $CLIP -frames:v 1 -vf $S stopf.png
ffmpeg -y -v error -ss 0 -i $CLIP -frames:v 1 -vf $S first.png
# A: Clip 0..4.21 s (Panik-Giessen)
ffmpeg -y -v error -i $CLIP -t 4.21 -vf "$S,fps=30" $V a.mp4
# B: Stopp! Standbild mit Ruck-Zoom (0.94 s)
ffmpeg -y -v error -framerate 30 -loop 1 -i stopf.png -t 0.94 -vf "scale=2160:3840,zoompan=z='1+0.08*min(on/6\,1)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30" $V b.mp4
# C: Zoom auf das gelbe Blatt (1.76 s)
ZX="max(0\,min(iw-iw/zoom\,1640-iw/zoom*0.5))";ZY="max(0\,min(ih-ih/zoom\,2560-ih/zoom*0.6146))"
ffmpeg -y -v error -framerate 30 -loop 1 -i still2.png -t 1.76 -vf "zoompan=z='1+0.9*(1-pow(1-min(on/13\,1)\,3))+0.0005*on':x='$ZX':y='$ZY':d=1:s=1080x1920:fps=30" $V c.mp4
# D: unscharf für die App-Karte (1.35 s)
ffmpeg -y -v error -framerate 30 -loop 1 -i still2.png -t 1.35 -vf "scale=1080:1920,boxblur=24:2,eq=brightness=-0.07:saturation=1.1" $V d.mp4
# E: Blatt nah, ganz langsam näher (2.15 s)
ffmpeg -y -v error -framerate 30 -loop 1 -i still2.png -t 2.15 -vf "zoompan=z='1.93+0.0012*on':x='$ZX':y='$ZY':d=1:s=1080x1920:fps=30" $V e.mp4
# F: Panik-Wasser in Zeitlupe mit Rotstich (2.22 s)
ffmpeg -y -v error -ss 3.0 -t 1.6 -i $CLIP -vf "setpts=1.3875*PTS,$S,fps=30,colorbalance=rs=.14:gs=-.04:bs=-.06" -t 2.22 $V f.mp4
# G: Schluss: unscharf und hell (2.6 s)
ffmpeg -y -v error -framerate 30 -loop 1 -i still2.png -t 2.6 -vf "scale=1080:1920,boxblur=26:2,eq=brightness=0.05:saturation=1.15" $V g.mp4
# H: zurück zum ersten Bild (Schleife, 0.55 s)
ffmpeg -y -v error -framerate 30 -loop 1 -i first.png -t 0.55 $V h.mp4
printf "file 'a.mp4'\nfile 'b.mp4'\nfile 'c.mp4'\nfile 'd.mp4'\nfile 'e.mp4'\nfile 'f.mp4'\nfile 'g.mp4'\nfile 'h.mp4'\n" > list.txt
ffmpeg -y -v error -f concat -safe 0 -i list.txt -c copy bg.mp4
ffmpeg -y -v error -i bg.mp4 -c:v libvpx-vp9 -i ov.webm -i mix.m4a -filter_complex "[0:v][1:v]overlay=0:0:format=auto,format=yuv420p[v]" -map "[v]" -map 2:a -c:v libx264 -preset veryfast -crf 19 -r 30 -c:a aac -b:a 192k -shortest -movflags +faststart final.mp4
ffprobe -v error -show_entries format=duration,size:stream=nb_frames,width,height -of default=nw=1 final.mp4 | tr '\n' ' '; echo
for t in 1.5 4.5 5.9 7.6 9.0 11.2 13.4 15.6; do ffmpeg -y -v error -ss $t -i final.mp4 -frames:v 1 -vf scale=270:480 k_$t.jpg; done
ffmpeg -y -v error -i k_1.5.jpg -i k_4.5.jpg -i k_5.9.jpg -i k_7.6.jpg -filter_complex hstack=4 -q:v 5 s1.jpg
ffmpeg -y -v error -i k_9.0.jpg -i k_11.2.jpg -i k_13.4.jpg -i k_15.6.jpg -filter_complex hstack=4 -q:v 5 s2.jpg
