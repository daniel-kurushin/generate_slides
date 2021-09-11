#!/bin/bash

BG=/tmp/screenshot.jpeg

dir="$1"
max=$( ls /usr/share/wallpapers/ | wc -l )
i=$((RANDOM*max/32767))
source_bg=$( ls /usr/share/wallpapers/ | head -$i | tail -1 )
convert "/usr/share/wallpapers/$source_bg" -scale "1600x900!" $BG
pushd "$dir" > /dev/null
rm /tmp/*png 2> /dev/null
wget -q 'https://static.tildacdn.com/tild3238-3038-4930-a536-303530346337/logo.png' -O /tmp/logo.png
convert -size 1600x40 xc:white -font helvetica -fill black -pointsize 20 -draw "text 20,25 '$dir'" /tmp/section.png
n=0
ls | { while read section
    do
        echo $section
        pushd "$section" > /dev/null
        convert -size 1600x40 xc:white -font helvetica -fill black -pointsize 20 -draw "text 20,25 '$section'" /tmp/subsection.png
        for file in *png
        do
            convert "$file" -scale "1400x800" "/tmp/img.$n.png"
            [ "00000000" != $( convert "/tmp/img.$n.png" -format '%[hex:p{0,0}]' info: ) ] && {
                convert "/tmp/img.$n.png" -trim -bordercolor White -border 20x10 +repage "/tmp/cropped.$n.png"
            } || {
                cp "/tmp/img.$n.png" "/tmp/cropped.$n.png"
            }
            convert -composite -gravity center $BG "/tmp/cropped.$n.png" "/tmp/page.$n.png" 
            convert -composite -gravity NorthWest "/tmp/page.$n.png" /tmp/subsection.png "/tmp/page.$n.png"
            convert -composite -gravity SouthEast "/tmp/page.$n.png" /tmp/section.png "/tmp/page.$n.png"
            convert -composite -gravity NorthEast "/tmp/page.$n.png" /tmp/logo.png "/tmp/page.$n.png"
            n=$((n+1))
            # break
        done
        popd > /dev/null
        # break
    done
    convert $( seq -f "/tmp/page.%g.png" 0 $((n-1)) ) "../$dir.pdf"
}
popd > /dev/null
