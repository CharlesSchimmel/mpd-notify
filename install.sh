#!/bin/bash
APP=$HOME/.mpd-notify/
CONFIG="$APP"mpd-notify.cfg
BINLOC=/usr/local/bin/mpd-notify

if [[ "$(id -u)" != "0" ]]; then
    echo "You must be root to install this script." 1>&2
    exit 1
else
    echo "This will install 'mpd-notify'"
    echo "Checking dependencies:"

    mpd --version >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "mpd not installed. Please install it and try again."
        exit 1
    else
        echo -n "mpd found..."
    fi

    mpc -v >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "mpc not installed. Please install it and try again."
        exit 1
    else
        echo -n "mpc found..."
    fi

    notify-send -v >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Notify-send not installed. Please install it and try again."
        exit 1
    else
        echo -n "notify-send found..."
    fi

    #Check if python3 installed
    python3 --version >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Python3 is not installed. It is necessary for auto-fetching artwork."
        echo "If you wish to enable that functionality, please install Python3 and run this again."
    else
        echo -n "Python3 found..."
    fi

    # Check if requests is installed
    sudo -H pip3 show requests >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then # Either pip3 isn't installed or requests isn't installed.
        # Check if pip3 is installed
        pip3 --version >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            echo "Pip3 is not installed. It is necessary for auto-fetching artwork."
            echo "If you wish to enable that functionality, please install Pip3 and run this again."
        else
            # Pip3 is installed but not requests. Get requests. 
            echo -n "Requests not found, may I install it for you? [Y/n]"
            read response
            if [[ -z $response || $response == "Y" || $response == "y" ]]; then
                sudo -H pip3 install requests >/dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "Requests installed, proceeding."
                else
                    echo "Requests is not installed. It is necessary for auto-fetching artwork."
                    echo "If you wish to enable that functionality, please install Requests and run this again."
                fi
            else
                echo "Requests is not installed. It is necessary for auto-fetching artwork."
                echo "If you wish to enable that functionality, please install Requests and run this again."
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

    if ! [[ -e $APP"doNotFetch.txt" ]]; then
        cp -p doNotFetch.txt $APP
    fi

    echo "Done."
    echo "Please edit the config file at $CONFIG and run 'mpd-notify start & disown' to run. "
fi
