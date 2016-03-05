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
    log "Scraping..."
    log "`python3.4 "$APP""/cogsCover.py" "$artAlb" "$DISCOGSKEY" "$DISCOGSSECRET"`"
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
            elif [[ -e $folderPath ]]; then
                notify-send -i "$folderPath" "Playing" "$newTitleArtist" -t "$NOTIFTIME"
            else
                notify-send -i audio-headphones "Playing" "$newTitleArtist" -t "$NOTIFTIME"
            fi
        fi
    fi
}

notifySong () {
    # Compare old and new songs.
    if [[ $currTitleArtist != $newTitleArtist ]]; then
        if [[ -e $coverPath ]]; then
            notify-send -i "$coverPath" "$newTitleArtist" -t "$NOTIFTIME"
        elif [[ -e $folderPath ]]; then
            notify-send -i "$folderPath" "$newTitleArtist" -t "$NOTIFTIME"
        else
            # If there's no cover available and autoscrape is true, try to get it
            if [[ $AUTOSCRAPE == "true" ]]; then
                scrapeDiscogs
                if [[ -e $coverPath ]]; then
                    log "Scraping \"$artAlb\" was successful."
                    notify-send -i "$coverPath" "$newTitleArtist" -t "$NOTIFTIME"
                else
                    log "Scraping $artAlb failed."
                    notify-send -i audio-headphones "$newTitleArtist" -t "$NOTIFTIME"
                fi 
            else
                notify-send -i audio-headphones "$newTitleArtist" -t "$NOTIFTIME"
            fi 
        fi 
    fi 
}

# currently implemented in the daemon loop, this function is not needed and is a redundancy liability.
notify () { 
    # Just get the song title and artist.
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
    songPath=`getFile | sed -r 's/\/[^/]*$//'`
    coverPath=$MUSFOLDER$songPath"/cover.jpg"
    folderPath=$MUSFOLDER$songPath"/folder.jpg"
    
    notifyStatus
    notifySong
}
