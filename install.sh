#!/bin/bash
APP=$HOME/.nowPlaying.sh
BINLOC=/usr/local/bin/nowPlaying

if [[ "$(id -u)" != "0" ]]; then
    echo "You must be root to install this script." 1>&2
    exit 1
else
    # echo "This will install 'silt'"
    # echo "[[ENTER]] to confirm"
    # read confirm

    #check if app location exists; only make it if it exists
    if ! [[ -e $APP ]]; then
        mkdir -m 777 $APP
    fi

    #cp will overwrite
    cp -p nowPlaying.sh $APP

    #if there's already something in the bin location, delete it
    if [[ -e $BINLOC ]]; then
        rm $BINLOC
    fi

    #make a softlink from the app location to the bin location
    ln -s $APP $BINLOC

    echo "Run 'nowPlaying' to run. Daemon in development."
fi
