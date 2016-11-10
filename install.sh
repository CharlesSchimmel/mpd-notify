#!/bin/bash
APP=$HOME/.mpd-notify/
CONFIG="$APP"mpd-notify.cfg
BINLOC=/usr/local/bin/mpd-notify
OPT=/opt/mpd-notify

if [ "$(id -u)" == "0" ]; then
	echo "Don't use sudo for this script or it'll install into root's HOME"
	exit 1
else
    echo "This will install 'mpd-notify'"
    echo "Checking dependencies:"

    if [[ $(mpd --version >/dev/null 2>&1) -ne 0 ]]; then
        echo "mpd not installed. Please install it and try again."
        exit 1
    else
        echo -n "mpd found..."
    fi

    if [[ $(mpc help >/dev/null 2>&1) -ne 0 ]]; then
        echo "mpc not installed. Please install it and try again."
        exit 1
    else
        echo -n "mpc found..."
    fi

    
    if [[ $(notify-send -v >/dev/null 2>&1) -ne 0 ]]; then
        echo "Notify-send not installed. Please install it and try again."
        exit 1
    else
        echo -n "notify-send found..."
    fi

    
    if [[ $(identify --version >/dev/null 2>&1) -ne 0 ]]; then
        echo "ImageMagick not installed. It is necessary for setting wallpaper. If you wish to enable this function please install it and try again."
    else
        echo -n "imagemagick found..."
    fi
    
    if [[ $(feh --version >/dev/null 2>&1) -ne 0 ]]; then
        echo "feh not installed. It is necessary for setting wallpaper. If you wish to enable this function please install it and try again."
    else
        echo -n "imagemagick found..."
    fi

    #Check if python3 installed
    
    if [[ $(python3 --version >/dev/null 2>&1) -ne 0 ]]; then
        echo "Python3 is not installed. It is necessary for auto-fetching artwork."
        echo "If you wish to enable that functionality, please install Python3 and run this again."
    else
        echo -n "Python3 found..."
    fi

    # Check if requests is installed
    
    if [[ $(pip3 show requests >/dev/null 2>&1) -ne 0 ]]; then # Either pip3 isn't installed or requests isn't installed.
        # Check if pip3 is installed
        
        if [[ $(pip3 --version >/dev/null 2>&1) -ne 0 ]]; then
            echo "ERROR: Pip3 is not installed. It is necessary for auto-fetching artwork."
            echo "If you wish to enable that functionality, please install Pip3 and run this again."
        else
            # Pip3 is installed but not requests. Get requests. 
            echo -e "\nERROR: Requests not found, may I install it for you? [Y/n]"
            read response
            if [[ -z $response || $response == "Y" || $response == "y" ]]; then
                echo -n "sudo -H pip3 install requests >/dev/null 2>&1"
                read
                if [[ $(sudo -H pip3 install requests >/dev/null 2>&1) -eq 0 ]]; then
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

    echo ""
    echo "Making symlink to $BINLOC..."
    sudo rm $BINLOC
    sudo ln -s "$APP"mpd-notify-daemon.sh $BINLOC

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
