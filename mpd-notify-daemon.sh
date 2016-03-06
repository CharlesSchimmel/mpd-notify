#!/bin/bash

daemonName="mpd-notify"
APP="$HOME/.mpd-notify"
source "$APP/mpd-notify.cfg"
source "$APP/mpd-notify-bin.sh"
pidFile="$APP/$daemonName.pid"
runInterval=1

myPid=`echo $$`

setupDaemon() {
    if [ ! -f "$logFile" ]; then
        touch "$logFile"
    else
        # Check to see if we need to rotate the logs.
        size=$((`ls -l "$logFile" | cut -d " " -f 8`/1024))
        if [[ $size -gt $logMaxSize ]]; then
            mv $logFile "$logFile.old"
            touch "$logFile"
        fi
    fi
}

startDaemon () {
    setupDaemon
    if [[ "`checkDaemon`" -eq 1 ]]; then
        echo "ERROR: $daemonName is already running."
        exit 1
    fi
    echo " *Starting $daemonName."
    echo "$myPid" > "$pidFile"
    log '*** '`date +"%Y-%m-%d"`": Starting up $daemonName."

    # Begin main loop
    loop
}

stopDaemon () {
    if [[ "`checkDaemon`" -eq 0 ]]; then
        echo here
        echo " ERROR: $daemonName is not running."
        exit 1
    fi
    echo "Stopping $daemonName"
    log '*** '`date +"%Y-%m-%d"`": $daemonName stopped."
    
    if [[ ! -z `cat $pidFile` ]]; then
        kill -9 `cat "$pidFile"` &> /dev/null
    fi
}

statusDaemon () {
    # Check if running
    if [[ "`checkDaemon`" -eq 1 ]]; then
        echo "$daemonName is running."
    else
        echo "$daemonName is not running."
    fi
    exit 0
}

restartDaemon () {
    if [[ "`checkDaemon`" -eq 0 ]]; then
        echo "$daemonName isn't running."
        exit 1
    fi
    stopDaemon
    startDaemon
}

checkDaemon() {
  # Check to see if the daemon is running.
  # This is a different function than statusDaemon
  # so that we can use it other functions.
    if [ -z "$oldPid" ]; then
        return 0
    elif [[ `ps aux | grep "$oldPid" | grep -v grep` > /dev/null ]]; then
        if [ -f "$pidFile" ]; then
            if [[ `cat "$pidFile"` == "$oldPid" ]]; then
                echo 1
                # Daemon is running.
                # echo 1
            else
                # Daemon isn't running.
                return 0
            fi
        fi
  # elif [[ `ps aux | grep "$daemonName" | grep -v grep | grep -v "$myPid" | grep -v "0:00.00"` > /dev/null ]]; then
  #   # Daemon is running but without the correct PID. Restart it.
  #   log '*** '`date +"%Y-%m-%d"`": $daemonName running with invalid PID; restarting."
  #   restartDaemon
  #   return 1
    else
    # Daemon not running.
    return 0
    fi
    return 1
}

loop () {
    # Just get the song title and artist.
    currentSong=`mpc -p $PORT`
    currTitleArtist=`getFirst "$currentSong"`

    # Via mpc call and awk, get the status of mpd. For some reason, comparing the two as strings would not work. Converting their status to integers and comparing those, does.
    if [[ `echo "$currentSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
        curStatus=1
    elif [[ `echo "$currentSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
        curStatus=0
    fi

    # zzz
    sleep 1

    newSong=`mpc -p $PORT`
    newTitleArtist=`getFirst "$newSong"`

    if [[ `echo "$newSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[playing]" ]]; then
        newStatus=1
    elif [[ `echo "$newSong" | awk '/\[(paused|playing)\]/ {print $1}'` == "[paused]" ]]; then
        newStatus=0
    fi

    # Get the path of the currently playing song as well as the cover.
    albumPath=`getFile | sed -r 's/\/[^/]*$//'`"/"

    findCover
    
    notifyStatus
    notifySong

    loop
}

log () {
    echo "$1" >> "$logFile"
}


##################
#    ArgParse    #
##################

if [ -f "$pidFile" ]; then
    oldPid=`cat "$pidFile"`
fi
checkDaemon
case "$1" in
    start)
        startDaemon
        ;;
    stop)
        stopDaemon
        ;;
    status)
        statusDaemon
        ;;
    restart)
        restartDaemon
        ;;
    *)
    echo "Error: usage $0 { start | stop | restart | status }"
    exit 1
esac

exit 0
