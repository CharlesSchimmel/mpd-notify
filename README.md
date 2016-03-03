# nowPlaying
For MPD/MPC: Gives you a notification on play/pause and song change.

Now with album art! Assumes cover art is stored in the same folder as the currently playing song and is named cover.jpg.

## Installation
Run install.sh and set your music folder and other optional variables in $HOME/.nowPlaying/nowPlaying.sh. 
Dependencies:
MPD, MPC, notify-osd, and nofity-send.


## Automatic cover retrieval
As your listening to music, if nowPlaying detects no cover.jpg it can fetcch it from Discogs with the included script. However you must supply your own key/secret for Discogs and enable it in $HOME/.nowPlaying/nowPlaying.sh

## It takes forever for the notifications to disappear.
Notify-osd doens't respect timing, install something like <a href="https://launchpad.net/~leolik/+archive/ubuntu/leolik">leolik's notify-osd.</a>
