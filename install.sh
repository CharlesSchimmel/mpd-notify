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
    if [[ $? -ne 0 ]]; then # Either pip3 isn't installed or requests isn't installed.
        # Check if pip3 is installed
        pip3 --version >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Requests and pip3 not installed. Please install it before proceeding."
        else
            # Pip3 is installed but not requests. Get requests. 
            echo -n "Requests not found, may I install it through Pip3 for you? [Y/n]"
            read response
            if [[ -z $response || $response == "Y" || $response == "y" ]]; then
                sudo -H pip3 install requests >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "Requests installed, proceeding."
                else
                    echo "Unable to install requests, please install it before continuing."
                    exit 1
                fi
            else
                echo "Unable to install requests, please install it before continuing."
                exit 1
            fi
        fi
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
    cp -p blackList.txt $APP

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
