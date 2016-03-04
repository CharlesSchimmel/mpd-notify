#!/bin/bash
<<<<<<< HEAD
APP=$HOME/.mpd-notify/
CONFIG="$APP"mpd-notify.cfg
BINLOC=/usr/local/bin/mpd-notify
=======
APP=$HOME/.nowPlaying/
CONFIG=$APP/nowPlaying.cfg
BINLOC=/usr/local/bin/nowPlaying
>>>>>>> 1a02ab89acafea9d1a579d81d4dc2387a2f7db43

if [[ "$(id -u)" != "0" ]]; then
    echo "You must be root to install this script." 1>&2
    exit 1
else
<<<<<<< HEAD
    echo "This will install 'mpd-notify'"
    echo "Checking dependencies..."

    #Check if python3 installed
    python3 --version 
    if [[ $? -ne 0 ]]; then
        echo "Python3 is not installed. It is required for this script."
        exit 1
    fi
    echo "Python3 found."

    # Check if requests is installed
    if [[ $? -ne 0 ]]; then
        echo "Requests is not installed. I'll put it in the install folder for you."
        # wget -O /tmp/requests.tar.gz https://pypi.python.org/packages/source/r/requests/requests-2.9.1.tar.gz >/dev/null 2>&1
        wget -O /tmp/requests.tar.gz https://pypi.python.org/packages/source/r/requests/requests-2.9.1.tar.gz 
        tar xfz /tmp/requests.tar.gz >/dev/null 2>&1
        cp -r /tmp/requests-2.9.1/requests $APP >/dev/null 2>&1
        echo "Done."
    fi
    echo "Requests found."
=======
    echo "This will install 'nowPlaying'"
    echo "[[ENTER]] to confirm"
    read confirm
>>>>>>> 1a02ab89acafea9d1a579d81d4dc2387a2f7db43

    #check if app location exists; only make it if it exists
    if ! [[ -e $APP ]]; then
        mkdir -m 777 $APP
    fi

    #cp will overwrite
<<<<<<< HEAD
    cp -p mpd-notify-bin.sh $APP
    cp -p mpd-notify-daemon.sh $APP
=======
    cp -p nowPlaying.sh $APP
>>>>>>> 1a02ab89acafea9d1a579d81d4dc2387a2f7db43
    cp -p cogsCover.py $APP

    #if there's already something in the bin location, delete it
    if [[ -e $BINLOC ]]; then
        rm $BINLOC
    fi

    #make a softlink from the app location to the bin location
<<<<<<< HEAD
    ln -s "$APP"mpd-notify-daemon.sh $BINLOC

    if ! [[ -e $CONFIG ]]; then
        echo "Copying config..."
        cp -p mpd-notify.cfg $CONFIG
    else
        cp -p mpd-notify.cfg $CONFIG.default
    fi

    echo "Run 'mpd-notify start' to run. Please edit the config file at $CONFIG"
=======
    ln -s "$APP"nowPlaying.sh $BINLOC

    if ! [[ -e $CONFIG ]]; then
        echo "Copying config..."
        cp -p nowPlaying.cfg $CONFIG
    else
        cp -p nowPlaying.cfg $CONFIG.default
    fi

    echo "Run 'nowPlaying' to run. Please edit the config file at $CONFIG"
>>>>>>> 1a02ab89acafea9d1a579d81d4dc2387a2f7db43
fi
