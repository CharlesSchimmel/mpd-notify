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
    log "`python3 "$APP""/cogsCover.py" "$artAlb" "$DISCOGSKEY" "$DISCOGSSECRET"`"
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
        if [[ $AUTOSCRAPE = true ]]; then
            scrapeDiscogs
        fi
    fi
}

setWallpaper () {
    # Does what it says on the tin
    # Get resolution, might return value for all monitors, not just the current one. W/e
    # If image resolution is greater than or equal to monitor resolution, scale not tile.
    curRes=`xdpyinfo | grep dimensions | grep -E -o "   .+x" | sed -r 's/x.+?$//' | sed -r 's/^.+[^0-9]//g'` 
    if [[ $WALLPAPER = true ]]; then
        if [[ $maxRes -ge $curRes ]]; then
            feh --bg-scale "$coverPath" >/dev/null 2>&1
        else
            feh --bg-tile "$coverPath" >/dev/null 2>&1
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

