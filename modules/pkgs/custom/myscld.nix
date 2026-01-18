{ config, pkgs, lib, ... }:

let
  my-scld = pkgs.writeScriptBin "my-scld" ''
        #!/usr/bin/env bash
        # Tolga Erok
        # LinuxTweaks Personal SoundCloud Downloader GUI with YAD

        # Suppress GTK warnings
        export G_MESSAGES_DEBUG=""
        export GTK_DEBUG=""

        if [[ -z "$TERM" || "$TERM" == "linux" ]] && [ -t 1 ]; then
            setsid "$0" "$@" >/dev/null 2>&1 &
            exit 0
        fi

        # activate scdl venv
        SC_DL_VENV="$HOME/scdl-venv"
        if [[ -d "$SC_DL_VENV" ]]; then
            source "$SC_DL_VENV/bin/activate"
        fi

        export LANG=en_AU.UTF-8
        export LC_ALL=en_AU.UTF-8
        export PATH="$HOME/.local/bin:${pkgs.python3}/bin:$PATH"

        REAL_USER="''${SUDO_USER:-$(logname)}"
        USER_HOME=$(eval echo "~$REAL_USER")

        # Icon setup
        icon_URL="https://raw.githubusercontent.com/tolgaerok/linuxtweaks/main/MY_PYTHON_APP/images/LinuxTweak.png"
        icon_dir="$USER_HOME/.config"
        icon_path="$icon_dir/LinuxTweak.png"
        mkdir -p "$icon_dir"
        ${pkgs.wget}/bin/wget -q -O "$icon_path" "$icon_URL"
        chmod 644 "$icon_path"

        DEFAULT_ART="$icon_path"

        if [ ! -f "$DEFAULT_ART" ]; then
            ${pkgs.imagemagick}/bin/convert -size 300x300 xc:gray "$DEFAULT_ART" 2>/dev/null || touch "$DEFAULT_ART"
        fi

        intro=$(cat <<'INTRO_EOF'
    🎧 LinuxTweaks SoundCloud Downloader Options

    🟢 Download single track, playlist, or user uploads
    🟢 Sync playlists using archive.txt
    🟢 Download only *new* tracks
    🟢 Save likes directly to music folder
    💡 Minimal hassle, maximum sound
    INTRO_EOF
    )

        downloading=$(cat <<'DOWN_EOF'
    🎧 LinuxTweaks SoundCloud Downloader live progress
    🟢 Download in progress...

    DOWN_EOF
    )

        mkdir -p "$HOME/Music/SOUNDCLOUD"
        cd "$HOME/Music/SOUNDCLOUD" || exit 1

        result=$(${pkgs.yad}/bin/yad --form \
            --title="🎵 LinuxTweaks SoundCloud Downloader" \
            --image="$icon_path" \
            --text="$intro" \
            --width=600 --height=200 \
            --field="Download mode:CB" \
            --field="SoundCloud URL or slug:" \
            "Single Track!Playlist!All Tracks of User (no reposts)!All Tracks + Reposts of User!All Likes of User!Only New Tracks from Playlist!Sync Playlist" \
            "" \
            --center)

        [[ $? -ne 0 ]] && exit 0

        MODE=$(echo "$result" | cut -d"|" -f1)
        INPUT=$(echo "$result" | cut -d"|" -f2 | sed -E 's#^https?://soundcloud\.com/##; s#^/##; s#/$##; s# *$##')
        URL="https://soundcloud.com/$INPUT"

        case "$MODE" in
            "Single Track")
                CMD="scdl -l \"$URL\" --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "Playlist")
                CMD="scdl -l \"$URL\" -t --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "All Tracks of User (no reposts)")
                CMD="scdl -l \"$URL\" -t --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "All Tracks + Reposts of User")
                CMD="scdl -l \"$URL\" -a --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "All Likes of User")
                CMD="scdl -l \"$URL\" -f --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "Only New Tracks from Playlist")
                CMD="scdl -l \"$URL\" --download-archive archive.txt -c --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            "Sync Playlist")
                CMD="scdl -l \"$URL\" --sync archive.txt --original-art --original-name --yt-dlp-args \"--embed-thumbnail --ppa \\\"FFmpegMetadata+FFmpegEmbedThumbnail:-id3v2_version 3\\\"\""
            ;;
            *)
                ${pkgs.yad}/bin/yad --error --title="Error" --text="Unknown mode."
                exit 1
            ;;
        esac

        bash -c "$CMD" 2>&1 | tee -a scdl_log.txt | ${pkgs.yad}/bin/yad --title="LinuxTweaks SoundCloud Progress" \
            --image="$icon_path" \
            --text="$downloading" \
            --width=1080 --height=605 \
            --text-info --tail --fontname="monospace" --show-uri &

        SC_PID=$!
        wait $SC_PID

        # Embed default artwork for files missing it
        for file in *.m4a; do
            [[ ! -f "$file" ]] && continue
            
            has_art=$(${pkgs.python3}/bin/python3 <<PY_EOF
    from mutagen.mp4 import MP4
    try:
        f = MP4("$file")
        print("yes" if "covr" in f else "no")
    except:
        print("no")
    PY_EOF
    )
            
            if [[ "$has_art" == "no" ]]; then
                ${pkgs.ffmpeg}/bin/ffmpeg -i "$file" -i "$DEFAULT_ART" -map 0 -map 1 -c copy -id3v2_version 3 "''${file%.m4a}-tmp.m4a"
                mv "''${file%.m4a}-tmp.m4a" "$file"
            fi
        done

        ${pkgs.yad}/bin/yad --title="Converting to MP3" \
            --image="$icon_path" \
            --text="✅ Downloaded tracks will be converted to MP3 yet preserving the downloaded m4a, proceed?" \
            --width=600 --height=150

        # Strip [ID] from M4A & convert to MP3
        for file in *.m4a; do
            [[ ! -f "$file" ]] && continue
            
            cleanname="''${file#*\] }"
            [[ "$file" != "$cleanname" ]] && mv "$file" "$cleanname"
            file="$cleanname"

            base="''${file%.m4a}"
            mp3file="''${base}.mp3"
            
            if [[ ! -f "$mp3file" ]]; then
                echo ">>> Converting $file -> $mp3file"
                ${pkgs.ffmpeg}/bin/ffmpeg -y -i "$file" -c:a libmp3lame -b:a 320k "$mp3file"
            fi
        done

        # Clean MP3s from [ID]
        for mp3 in *.mp3; do
            [[ ! -f "$mp3" ]] && continue
            cleanmp3="''${mp3#*\] }"
            [[ "$mp3" != "$cleanmp3" ]] && mv "$mp3" "$cleanmp3"
        done

        ${pkgs.yad}/bin/yad --title="Download Completed" \
            --image="$icon_path" \
            --text="✅ All tracks processed.\n\nDo you want to start another download?" \
            --width=600 --height=150 \
            --button=Yes:0 --button=No:1

        [[ $? -eq 0 ]] && exec "$0"

        ${pkgs.yad}/bin/yad --info --title="Goodbye" --text="🙏 Thanks for using LinuxTweaks SoundCloud Downloader."
        exit 0
  '';

  python-with-mutagen = pkgs.python3.withPackages (ps: with ps; [ mutagen ]);

in {
  environment.systemPackages = with pkgs; [
    ffmpeg
    imagemagick
    my-scld
    python-with-mutagen
    wget
    yad
  ];
}
