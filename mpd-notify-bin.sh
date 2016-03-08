#!/bin/bash
# Just get the currently playing song.

# Get the currently playing filename
getFile () {
    ct=0 
    mpc -p $PORT -f %file% | while read line; do
        if [[ $ct -eq 0 ]]; then
            echo $line
        fi
        ((ct++))
    done
}

getArtAlb () {
    ct=0 
    mpc -p $PORT -f "%artist% - %album%" | while read line; do
        if [[ $ct -eq 0 ]]; then
            echo $line
        fi
        ((ct++))
    done
}

getFirst () {
    ct=0
    echo "$1" | while read line; do
    if [[ $ct -eq 0 ]]; then
        echo $line
    fi
    ((ct++))
done
}

scrapeDiscogs () {
    artAlb=`getArtAlb`
    log "Fetching $artAlb"
    log "`python3.4 "$APP""/cogsCover.py" "$artAlb" "$DISCOGSKEY" "$DISCOGSSECRET"`"
    # cogsCover downloads to /tmp/image....
    cp /tmp/image.jpg "$coverPath" >/dev/null 2>&1
    rm /tmp/image.jpg >/dev/null 2>&1
}

notifyStatus () {
    # Compare old and new status.
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
}

findCover () {
    # FutureFeature: Potentially search for any image file and convert it to JPG with imagemagick.
        # Would require either additional dependency or inline missing dependency check similar to the following method:
    # Attempt to find a cover. Set coverPath to null so we can check if it found anything
    coverPath=
    # Reset triggers
    maxFile=
    maxRes=
    # Look for a jpg in the album folder
    for file in "$MUSFOLDER$albumPath"*; do
        if [[ "$file" == *".jpg" ]]; then
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
        # set coverpath to path of largest image
    done
    # If there are no jpgs, maxfile will be null and thus coverpath will be null
    coverPath="$maxFile"

    # If nothing found, set coverPath the fetcher expects then call the fetcher
    if [[ -z "$coverPath" ]]; then
        coverPath=$MUSFOLDER$albumPath"cover.jpg"
        if [[ $AUTOSCRAPE = true ]]; then
            scrapeDiscogs
        fi
    fi
}

setWallpaper () {
    # Does what it says on the tin
    if [[ $WALLPAPER = true ]]; then
        feh --bg-tile "$coverPath" >> "$logFile"
    fi
} 

notifySong () {
    # Compare old and new songs.
    if [[ $currTitleArtist != $newTitleArtist ]]; then
        findCover
        if [[ -e $coverPath ]]; then # If there's a cover...
            log "Found $coverPath for $newTitleArtist"
            notify-send -i "$coverPath" "$newTitleArtist" -t "$NOTIFTIME"
            setWallpaper
        else
            notify-send -i audio-headphones "$newTitleArtist" -t "$NOTIFTIME"
        fi 
    fi 
}

# currently implemented in the daemon loop, this function is not needed and is a redundancy liability.
notify () { 
    # Get the full MPC output so we can use it for both the status and the current song.
    currentSong=`mpc -p $PORT`
    currTitleArtist=`getFirst "$currentSong"`

    # Via mpc call and awk, get the status of mpd. For some reason, comparing the two as strings would not work. Converting their status to integers and comparing those, does.
    if [[ `echo "$currentSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
        curStatus=1
    elif [[ `echo "$currentSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
        curStatus=0
    fi

    newSong=`mpc -p $PORT`
    newTitleArtist=`getFirst "$newSong"`

    if [[ `echo "$newSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
        newStatus=1
    elif [[ `echo "$newSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
        newStatus=0
    fi

    # Get the path of the currently playing song as well as the cover.
    albumPath=`getFile | sed -r 's/\/[^/]*$//'`"/"
    
    notifySong
    notifyStatus
}

