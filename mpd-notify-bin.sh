#!/bin/bash
# Just get the currently playing song.

# Get the currently playing filename
getFile () {
    file="$(mpc -p $PORT -f %file% | head -n 1 )"
    albumPath="$(echo "$file" | sed 's/$(basename "$file")//')"
    mpc -p $PORT -f %file% | head -n 1 
}

getArtAlb () {
    mpc -p $PORT -f "%artist% - %album%" | head -n 1
}

scrapeDiscogs () {
    artAlb=`getArtAlb`
    log "`python3 "$APP""/cogsCover.py" "$artAlb" "$DISCOGSKEY" "$DISCOGSSECRET"`"
    # cogsCover downloads to /tmp/image....
    cp /tmp/image.jpg "$coverPath" >/dev/null 2>&1
    rm /tmp/image.jpg >/dev/null 2>&1
}

notifyStatus () {
    # Compare old and new status.
    if $STATUSNOTIF ; then
        if [[ $curStatus != $newStatus ]]; then
            if [[ $newStatus -eq 0 ]]; then
                notify-send -i audio-headphones "Paused" -t "$NOTIFTIME"
            else
                if [[ -e $coverPath ]]; then
                    notify-send -i "$coverPath" "Playing" "$newTitleArtist" -t "$NOTIFTIME"
                else
                    notify-send -i audio-headphones "Playing" "$newTitleArtist" -t "$NOTIFTIME"
                fi
            fi
        fi
    fi
}

findCover () {
    # Attempt to find a cover. Set coverPath to null so we can check if it found anything
    # Reset triggers
    coverPath=
    maxFile=
    maxRes=
    # Look for a jpg in the album folder
    for file in "$MUSFOLDER$albumPath"*; do
        if [[ "$file" == *".jpg" ]] || [[ "$file" == *".jpeg" ]] || [[ "$file" == *".png" ]]; then
            # Check size of image if it's larger, set it as current largest.
            curRes=`identify -format "%W" "$file"`
            if [[ -z $maxFile ]]; then
                maxFile="$file"
                maxRes="$curRes"
            elif [[ $curRes -gt $maxRes ]]; then
                maxFile="$file"
                maxRes="$curRes"
            fi
        fi
    done

    # If there are no jpgs, maxfile will be null and thus coverpath will be null
    # set coverpath to path of largest image
    coverPath="$maxFile"

    # Convert png to jpg for notification icon.
    if [[ "$coverPath" == *".png" ]]; then
        newPath=`echo $coverPath | sed 's/png/jpg/g'`
        convert "$coverPath" "$newPath"
        coverPath=$newPath
    fi

    # If nothing found, set coverPath the fetcher expects then call the fetcher
    if [[ -z "$coverPath" ]]; then
        coverPath=$MUSFOLDER$albumPath"cover.jpg"
        if $AUTOSCRAPE; then
            scrapeDiscogs
        fi
    fi
}

setWallpaper () {
    # Does what it says on the tin
    # Get resolution, might return value for all monitors, not just the current one. W/e
    # If image resolution is greater than or equal to monitor resolution, scale not tile.
    curRes=`xdpyinfo | grep dimensions | grep -E -o "   .+x" | sed -r 's/x.+?$//' | sed -r 's/^.+[^0-9]//g'` 
    dimensions=$(xdpyinfo | grep dimensions | awk '{print $2}')
    if $WALLPAPER ; then
        if [[ $maxRes -ge $curRes ]]; then
            feh --bg-scale "$coverPath" >/dev/null 2>&1
        else
            if $CENTERED; then
                if $COMMON; then
                    commonColor="$(convert "$coverPath" -colors 2 -depth 8 -unique-colors -format "%c" histogram:info: | grep -Eo "#.{6}" | tail -n 1)"
                    convert "$coverPath" -gravity center -background "$commonColor" -extent $dimensions "/tmp/cover.jpg"
                    feh --bg-center "/tmp/cover.jpg" > /dev/null 2>&1
                else
                    convert "$coverPath" -gravity center -background "#$MATCOLOR" -extent $dimensions "/tmp/cover.jpg"
                    feh --bg-center "/tmp/cover.jpg" >/dev/null 2>&1
                fi
            else
                feh --bg-tile "$coverPath" >/dev/null 2>&1
                # /bin/bash ~/.scripts/genparpal.sh "$coverPath"
            fi
        fi
    fi
} 

notifySong () {
    # Compare old and new songs.
    if [[ $currTitleArtist != $newTitleArtist ]]; then
        findCover
        if [[ -e $coverPath ]]; then # If there's a cover...
            setWallpaper
            if $NOTIFYSONG ; then
                notify-send -i "$coverPath" "$newTitleArtist" -t "$NOTIFTIME"
            fi
        else
            if $NOTIFYSONG ; then
                notify-send -i audio-headphones "$newTitleArtist" -t "$NOTIFTIME"
            fi
        fi 
    fi 
}

notifyVolume () {
    if [[ $curVol != $newVol ]]; then
        notify-send "$newVol" -t "$NOTIFTIME"
    fi
}
