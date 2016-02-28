#!/bin/bash

getSong () {
ct=0 
mpc -p 6060 | while read line; do
        if [[ $ct -eq 0 ]]; then
            echo $line
        fi
    ((ct++))
done
}

returnSong () {
    while true; do
        # Just get the song title and artist.
        curSong=`getSong`

        # Via mpc call and awk, get the status of mpd. For some reason, comparing the two as strings would not work. Converting their status to integers and comparing those, does.
        if [[ `mpc -p 6060 | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
            curStatus=1
        elif [[ `mpc -p 6060 | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
            curStatus=0
        fi

        # Wait some interval to see if anything changes
        sleep 1

        # Just get the song title and artist.
        newSong=`getSong`

        if [[ `mpc -p 6060 | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
            newStatus=1
        elif [[ `mpc -p 6060 | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
            newStatus=0
        fi

        # Compare old and new status.
        if [[ $curStatus != $newStatus ]]; then
            # notify-send "$newStatus" -t 25
            if [[ $newStatus -eq 0 ]]; then
                notify-send "Paused" -t 25
            else
                notify-send "Playing" -t 25
            fi
        fi
        
        # Compare old and new songs.
        if [[ $curSong != $newSong ]]; then
            notify-send "$newSong" -t 50
        fi

    done
}

returnSong
