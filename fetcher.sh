#!/bin/bash

is_image(){
  file $1 | grep "\(jpg\|png\)" | wc -l
}

# this is not used or necessary. -------------------------
get_index(){
  echo ${ARR[@]/$1/?} | cut -d? -f1 | wc -w | tr -d ' '
}
# but I like it ------------------------------------------

if [[ -z "$1" ]]; then
  IND=1
else
  IND=$1
  echo "Starting from: $IND"
fi

URL=$(curl -A "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5" "https://www.reddit.com/r/wallpaper/top.json?sort=top&t=day")
ARR=$(echo "$URL" | jq .data.children[].data.url | sed -ne $IND',$p')
FILE="/home/jon/Code/desktop-background-changer/wallpaper_pic"

a=0
for i in $ARR; do
  if [[ $(is_image $i) == 1 ]]; then
    NAME=$(echo $URL | jq .data.children[$a].data.title)
    echo $i | sed 's/"//g' | xargs -I {} wget -O $FILE {}
    echo $NAME | tee /home/jon/Code/desktop-background-changer/title.txt
    gsettings set org.gnome.desktop.background picture-uri "file://$FILE"
    break
  fi
  ((a++))
done

COLOURS=$(echo "$FILE" | /home/jon/Code/colorific/colorific-sandbox/bin/colorific | awk '{print $2}')

echo "$COLOURS"

BLUE=$(echo $COLOURS | awk -F, '{print $1}')
GREY=$(echo $COLOURS | awk -F, '{print $2}')
DARKBLUE=$(echo $COLOURS | awk -F, '{print $3}')
BG_DARK=$(echo $COLOURS | awk -F, '{print $4}')

# defaults:
# BLUE=#347D9F
# GREY=#546e7a
# DARKBLUE=#5a6367
# BG_DARK=#576165


STR="gtk-color-scheme = \"base_color:#FFFFFF\\\nfg_color:#555555\\\ntooltip_fg_color:#FFFFFF\\\nmenubar_color:$GREY\\\nselected_bg_color:$BLUE\\\nselected_fg_color:#FFFFFF\\\ntext_color:#555555\\\nwm_color:$GREY\\\nunfocused_wm_color:$DARKBLUE\\\nbg_color:#EFEFEF\\\ninsensitive_bg_color:#efefef\\\ntooltip_bg_color:#333333\\\npanel_bg_color:$BG_DARK\\\npanel_fg_color:#efefef\\\nlink_color:$BLUE\""

GTKRC='/home/jon/.themes/Paper/gtk-2.0/gtkrc'

NEWFILE=$(cat "$GTKRC" | sed "s/^gtk-color-scheme = .*/$STR/")
echo "$NEWFILE" > $GTKRC
gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell --method org.gnome.Shell.Eval 'Main.loadTheme();'
