<<<<<<< HEAD
# mpd-notify
For MPD/MPC: Gives you a notification on play/pause and song change.
85 lines of bash...

# Installation
Run install.sh

# Dependencies
MPD, MPC, notify-osd, and nofity-send.

# It takes forever for the notifications to disappear.
=======
# nowPlaying
For MPD/MPC: Gives you a notification on play/pause and song change.

Now with album art! Assumes cover art is stored in the same folder as the currently playing song and is named cover.jpg.

## Installation
Run install.sh and set your config in $HOME/.nowPlaying/nowPlaying.cfg. Dependencies: MPD, MPC, notify-osd, and nofity-send.


## Automatic cover retrieval
As you're listening to music, if nowPlaying detects no cover.jpg it can fetcch it from Discogs with the included script. However you must supply your own key/secret for Discogs and enable it in $HOME/.nowPlaying/nowPlaying.sh

## It takes forever for the notifications to disappear.
>>>>>>> 1a02ab89acafea9d1a579d81d4dc2387a2f7db43
Notify-osd doens't respect timing, install something like <a href="https://launchpad.net/~leolik/+archive/ubuntu/leolik">leolik's notify-osd.</a>
