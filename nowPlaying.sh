#!/bin/bash

MUSFOLDER="$HOME/Music/" # Your music directory as you defined for MPD
AUTOSCRAPE=false # Will automatically pull missing covers from discogs. Assumes your music folder is in Music/Artist/Album format.
APP="$HOME/.nowPlaying"
PORT=6600 # In case you don't use the default port.
NOTIFTIME=1500 # in milliseconds

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
    python3.4 "$APP""/cogsCover.py" "$artAlb"
    cp /tmp/image.jpg "$coverPath"
    rm /tmp/image.jpg
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
        songPath=`getFile | sed -r 's/\/[^/]*$//'`
        COVER="/cover.jpg"
        coverPath=$MUSFOLDER$songPath$COVER

        if [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
            newStatus=1
        elif [[ `mpc -p $PORT | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
            newStatus=0
        fi

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
        
        # Compare old and new songs.
        if [[ $curSong != $newSong ]]; then
            if [[ -e $coverPath ]]; then
                notify-send -i "$coverPath" "$newSong" -t "$NOTIFTIME"
            else
                if [[ $AUTOSCRAPE == "true" ]]; then
                    scrapeDiscogs
                    if [[ -e $coverPath ]]; then
                        notify-send -i "$coverPath" "$newSong" -t "$NOTIFTIME"
                    else
                        notify-send -i audio-headphones "$newSong" -t "$NOTIFTIME"
                    fi

                else
                    notify-send -i audio-headphones "$newSong" -t "$NOTIFTIME"
                fi

            fi

        fi

    done
}

notifyStatus
