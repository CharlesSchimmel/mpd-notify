# nowPlaying
For MPD/MPC: Gives you a notification on play/pause and song change

# Installation
Run install.sh

# Dependencies
MPD, MPC, notify-osd, and nofity-send.

# Wait so I have to background this script?
Yeah, I'm working on daemonizing it. Just run nowPlaying &

# It takes forever for the notifications to disappear
Notify-osd doens't respect timing, install something like libnotify-bin or notifyosdconfig
