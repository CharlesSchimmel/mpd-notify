#!/bin/bash
APP=$HOME/.mpd-notify/
CONFIG="$APP"mpd-notify.cfg
BINLOC=/usr/local/bin/mpd-notify

if [[ "$(id -u)" != "0" ]]; then
    echo "You must be root to install this script." 1>&2
    exit 1
else
    echo "This will install 'mpd-notify'"
    echo "Checking dependencies..."

    #Check if python3 installed
    python3 --version >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Python3 is not installed. It is required for this script."
        exit 1
    else
        echo -n "Python3 found..."
    fi

    # Check if requests is installed
    sudo -H pip3 show requests >/dev/null 2>&1
    if [[ $? -ne 0 ]] && [[ ! -d "$APP"requests ]]; then
        echo -n"Requests and/or pip3 not installed. I'll put it in the install folder for you."
        # wget -O /tmp/requests.tar.gz https://pypi.python.org/packages/source/r/requests/requests-2.9.1.tar.gz >/dev/null 2>&1
        wget -nv -O /tmp/requests.tar.gz https://pypi.python.org/packages/source/r/requests/requests-2.9.1.tar.gz 
        # tar xfz /tmp/requests.tar.gz >/dev/null 2>&1
        tar xfz /tmp/requests.tar.gz -C /tmp /dev/null 2>&1
        cp -r /tmp/requests-2.9.1/requests $APP >/dev/null 2>&1
        echo "Done."
    else
        echo -n "Requests found..."
    fi

    #check if app location exists; only make it if it exists
    if ! [[ -e $APP ]]; then
        mkdir -m 777 $APP
    fi

    #cp will overwrite
    cp -p mpd-notify-bin.sh $APP
    cp -p mpd-notify-daemon.sh $APP
    cp -p cogsCover.py $APP

    #if there's already something in the bin location, delete it
    if [[ -e $BINLOC ]]; then
        rm $BINLOC
    fi

    #make a softlink from the app location to the bin location
    ln -s "$APP"mpd-notify-daemon.sh $BINLOC

    if ! [[ -e $CONFIG ]]; then
        echo "Copying config..."
        cp -p mpd-notify.cfg $CONFIG
    else
        cp -p mpd-notify.cfg $CONFIG.default
    fi

    echo "Done."
    echo "Run 'mpd-notify start' to run. Please edit the config file at $CONFIG"
fi
