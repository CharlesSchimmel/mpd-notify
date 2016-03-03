#!/bin/bash
APP=$HOME/.nowPlaying/
CONFIG=$APP/nowPlaying.cfg
BINLOC=/usr/local/bin/nowPlaying

if [[ "$(id -u)" != "0" ]]; then
    echo "You must be root to install this script." 1>&2
    exit 1
else
    echo "This will install 'nowPlaying'"
    echo "[[ENTER]] to confirm"
    read confirm

    #check if app location exists; only make it if it exists
    if ! [[ -e $APP ]]; then
        mkdir -m 777 $APP
    fi

    #cp will overwrite
    cp -p nowPlaying.sh $APP
    cp -p cogsCover.py $APP

    #if there's already something in the bin location, delete it
    if [[ -e $BINLOC ]]; then
        rm $BINLOC
    fi

    #make a softlink from the app location to the bin location
    ln -s "$APP"nowPlaying.sh $BINLOC

    if ! [[ -e $CONFIG ]]; then
        echo "Copying config..."
        cp -p nowPlaying.cfg $CONFIG
    else
        cp -p nowPlaying.cfg $CONFIG.default
    fi

    echo "Run 'nowPlaying' to run. Please edit the config file at $CONFIG"
fi
