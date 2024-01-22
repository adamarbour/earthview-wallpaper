#!/bin/bash

# Set the wallpaper directory
WALL_DIR=$HOME/Pictures/wallpapers/earthview
mkdir -p $WALL_DIR

PREFIX=https://www.gstatic.com/prettyearth/assets/full/
# Cache the images if the file...
wget -q -c -N https://earthview.withgoogle.com/_api/photos.json -O .photo_cache.json

for i in {1..30}
do
    RINT=$(($RANDOM % 2608))
    SLUG=$(cat .photo_cache.json | jq --arg i $RINT '.[$i | tonumber].slug' | sed "s/[\"']//g")
    IMG=$PREFIX$(echo $SLUG | sed 's/[^0-9]*//g').jpg
    if ! [ -f $WALL_DIR/$SLUG.jpg ]; then
    	curl -s "$IMG" -o $SLUG.jpg --output-dir /tmp
    	magick /tmp/$SLUG.jpg -strip -interlace Plane -sampling-factor 4:2:0 -define jpeg:dct-method=float -quality 85% $WALL_DIR/$SLUG.jpg
    	rm /tmp/$SLUG.jpg
    else
        # Do it again...
        continue $i
    fi 
done

# Clean up old images
DAYS_TO_KEEP=30
find $WALL_DIR -name "*.jpg" -type f -ctime +$DAYS_TO_KEEP -delete
