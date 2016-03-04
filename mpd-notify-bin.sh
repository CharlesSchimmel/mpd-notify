#!/bin/bash
# Just get the currently playing song.

getSong () {
    ct=0 
    mpc -p $PORT | while read line; do
        if [[ $ct -eq 0 ]]; then
            echo $line
        fi
        ((ct++))
    done
}

# Get the currently playing filename
getFile () {
    ct=0 
    mpc -p $PORT -f %file% | while read line; do
        if [[ $ct -eq 0 ]]; then
            echo $line fi
        ((ct++))
        fi
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

scrapeDiscogs () {
    artAlb=`getArtAlb`
    log python3.4 "$APP""/cogsCover.py" "$artAlb" "$DISCOGSKEY" "$DISCOGSSECRET"
    cp /tmp/image.jpg "$coverPath" >/dev/null 2>&1
    rm /tmp/image.jpg >/dev/null 2>&1
    log "Scraping..."
    if [[ -e $coverPath ]]; then
        log "Scraping $artAlb successful."
        notify-send -i "$coverPath" "$newSong" -t "$NOTIFTIME"
    else
        log "Scraping $artAlb failed."
        notify-send -i audio-headphones "$newSong" -t "$NOTIFTIME"
    fi 
}

notifyStatus () {
    # Compare old and new status.
    if [[ $curStatus != $newStatus ]]; then
        if [[ $newStatus -eq 0 ]]; then
            notify-send -i audio-headphones "Paused" -t "$NOTIFTIME"
        else
            if [[ -e $coverPath ]]; then
                notify-send -i "$coverPath" "Playing" "$newSong" -t "$NOTIFTIME"
            else
                notify-send -i audio-headphones "Playing" "$newSong" -t "$NOTIFTIME"
            fi
        fi
    fi
}

notifySong () {
    # Compare old and new songs.
    if [[ $curSong != $newSong ]]; then
        if [[ -e $coverPath ]]; then
            notify-send -i "$coverPath" "$newSong" -t "$NOTIFTIME"
        else
            # If there's no cover available and autoscrape is true, try to get it
            if [[ $AUTOSCRAPE == "true" ]]; then
                scrapeDiscogs
            else
                notify-send -i audio-headphones "$newSong" -t "$NOTIFTIME"
            fi 
        fi 
    fi 
}

notify () {
    while true; do
        # Just get the song title and artist.
        curSong=`getSong`

        # Via mpc call and awk, get the status of mpd. For some reason, comparing the two as strings would not work. Converting their status to integers and comparing those, does.
        if [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
            curStatus=1
        elif [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
            curStatus=0
        fi

        # zzz
        sleep 1

        # Just get the song title and artist.
        newSong=`getSong`

        if [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
            newStatus=1
        elif [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
            newStatus=0
        fi

        # Get the path of the currently playing song as well as the cover.
        songPath=`getFile | sed -r 's/\/[^/]*$//'`
        coverPath=$MUSFOLDER$songPath"/cover.jpg"
        
        notifyStatus
        notifySong

    done
}
