#!/bin/bash

PORT=6600 # In case you don't use the default port.
MUSFOLDER="$HOME/Music/" # Your music directory as you defined for MPD

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
            echo $line
        fi
        ((ct++))
    done
}

notifyStatus () {
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

        # Compare old and new status.
        if [[ $curStatus != $newStatus ]]; then
            if [[ $newStatus -eq 0 ]]; then
                notify-send -i audio-headphones "Paused" -t 1000
            else
                notify-send -i audio-headphones "Playing" -t 1000
            fi
        fi
        
        # Compare old and new songs.
        if [[ $curSong != $newSong ]]; then
            songPath=`getFile | sed -r 's/\/[^/]*$//'`
            cover="/cover.jpg"
            songPath=$MUSFOLDER$songPath$cover
            echo $songPath
            notify-send -i "$songPath" "$newSong" -t 1000
        fi

    done
}

notifyStatus
