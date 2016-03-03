# nowPlaying
For MPD/MPC: Gives you a notification on play/pause and song change.

Now with album art! Assumes cover art is stored in the same folder as the currently playing song and is named cover.jpg.

# Installation
Run install.sh and set the two global variables in .nowPlaying.sh. I would recommend exec'ing it in your window manager's config as there is no daemon for it yet.

# Dependencies
MPD, MPC, notify-osd, and nofity-send.

# It takes forever for the notifications to disappear.
Notify-osd doens't respect timing, install something like <a href="https://launchpad.net/~leolik/+archive/ubuntu/leolik">leolik's notify-osd.</a>
