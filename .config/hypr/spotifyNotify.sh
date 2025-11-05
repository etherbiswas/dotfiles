#!/bin/bash
# Spotify notifications for Wayland + Dunst with album art support 🎵

TMP_DIR="/tmp/spotify-art"
mkdir -p "$TMP_DIR"

playerctl --player=spotify metadata --follow | while read -r line; do
    title=$(playerctl --player=spotify metadata xesam:title)
    artist=$(playerctl --player=spotify metadata xesam:artist)
    art=$(playerctl --player=spotify metadata mpris:artUrl)

    [[ -z "$title" ]] && continue

    # Handle Spotify's weird art URLs
    if [[ $art == spotify:* ]]; then
        art=$(echo "$art" | sed 's#spotify:#https:#')
    fi

    # Download the cover art
    icon_path="$TMP_DIR/cover_$(echo "$title" | tr ' /' '_').jpg"
    curl -sL "$art" -o "$icon_path" &>/dev/null

    # Send pretty notification
    if [[ -f "$icon_path" ]]; then
        dunstify -a "Spotify" -i "$icon_path" -r 9999 -t 5000 "$title" "$artist"
    else
        dunstify -a "Spotify" -r 9999 -t 5000 "$title" "$artist"
    fi
done

