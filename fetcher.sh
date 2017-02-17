#!/bin/bash

pic=$(ls -t /tmp/jonpic*.jpg | head -n 1);
echo "$pic - pic";
osascript <<END
    tell application "System Events"
        set desktopCount to count of desktops
        repeat with desktopNumber from 1 to desktopCount
            tell desktop desktopNumber
                set picture to "$pic"
            end tell
        end repeat
    end tell
END
rand=$(/usr/bin/openssl rand -base64 12)
FILE="/tmp/jonpic$rand.jpg"
echo "$FILE - file"
URL=$(/usr/local/bin/wget -O "$FILE" "https://source.unsplash.com/random/2560x1440")
[[ -z "$pic" ]] && echo 'setting after fetch' && sleep 5 && \
osascript <<END
    tell application "System Events"
        set desktopCount to count of desktops
        repeat with desktopNumber from 1 to desktopCount
            tell desktop desktopNumber
                set picture to "$pic"
            end tell
        end repeat
    end tell
END
# clean up 
files=$(ls -tl /tmp/jonpic*.jpg)
fileslen=$(echo "$files" | wc -l)
oldlen=$((fileslen-2));
[[ $fileslen -gt 1 ]] && ls -tr /tmp/jonpic*.jpg | head -n $oldlen | xargs rm || echo 'no cleanup';
echo 'Done.'
whoami
