#!/bin/sh -eux
#convert *generalNode*/1.png -transparent black generalNode.png
#convert *generalNode*/8.png -transparent black generalNodeSelected.png
#convert *specialNode*/1.png -transparent black specialNode.png
#convert *specialNode*/8.png -transparent black specialNodeSelected.png
#convert *deluxeNode*/1.png -transparent black deluxeNode.png
#convert *deluxeNode*/8.png -transparent black deluxeNodeSelected.png

for t in general special deluxe; do
  # can't do inline comments in multiline shell scripts, so here's what's happening below:
  #
  # rotate hue by 60 degrees - purple-ish to red, like css filter:hue-rotate - \
  #   \( then create a red outline around the image, by blurring and then making the blur less transparent \) \
  #   and finish creating a red outline around the image
  #
  # http://www.imagemagick.org/Usage/color_mods/
  # http://www.imagemagick.org/Usage/blur/
  convert ${t}NodeNext.png -modulate 100,100,133.3 \
          \( +clone   -background red -shadow 100x10+0+0 -channel A -level 0,20% +channel \) +swap \
          -background none   -layers merge  +repage    ${t}NodeHighlight.png
  # similar border for selected nodes, but smaller and green
  convert ${t}NodeSelected.png \
          \( +clone   -background green -shadow 100x6+0+0 -channel A -level 0,20% +channel \) +swap \
          -background none   -layers merge  +repage    ${t}NodeSelectedVis.png
done
