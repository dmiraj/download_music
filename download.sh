#!/bin/bash
# in this script i will be choosing which dowload-item to add/download/update.
youtube_dl_bin="$HOME/download_music/yt-dl-fork/youtube-dl"
youtube_dl_config="$HOME/download_music/yt-dl-fork/youtube-dl.config"
music_directory="$HOME/Music"
download_types=( "Playlist" "Album" "Likes" "Quit?")
playlist_dir="$music_directory/playlists"
album_dir="$music_directory/albums"
likes_dir="$music_directory/My Likes"

set -x

# The following function contains the script to write in a file in each of the newly downloaded objects
function write_script () {
	cd "$music_directory/$1/$inner_dir_name"
	cat > script.sh <<delimiter
youtube_dl_bin="$HOME/download_music/yt-dl-fork/youtube-dl"
youtube_dl_config="$HOME/download_music/yt-dl-fork/youtube-dl.config"

# Run the 'youtube-dl' script.
"\$youtube_dl_bin" --config-location "\$youtube_dl_config" "$link" &> "$logfile"
delimiter
}

echo "Select from the following which category corresponds to your download:"
select download_type in "${download_types[@]}"; do
	cd "$music_directory"
	# Lets put inner directory name for playlists and album inside exportable paraneter `inner_dir_name`
	if [[ "$download_type" = "${download_types[0]}" || "$download_type" = "${download_types[1]}" ]]; then
		read -p "Give me a link> " link
		export inner_dir_name="$(curl $link |& egrep -o '"><title>.+</title><lin')" # This will output a short sequence containing the playlist name. 
		inner_dir_name="${inner_dir_name#'"><title>'}"
		inner_dir_name="${inner_dir_name%'</title><lin'}" # Playlist should now be the playlist name
		inner_dir_name="${inner_dir_name//&amp;/&}"
		inner_dir_name="${inner_dir_name//&#39;/\'}"
		inner_dir_name="${inner_dir_name//;/''}"
		# I could add more substitution for special character codes in html i.e: ${inner_dir_name/&amp/'}
		# Script to intercept the playlist link.
	fi

	if [[ "$download_type" = "${download_types[0]}" ]]; then
		if ! [ -a "$playlist_dir/$inner_dir_name" ]; then
			mkdir -p "$playlist_dir/$inner_dir_name"
		fi
		logfile="$playlist_dir/$inner_dir_name/log"
		write_script "playlists"
		bash "$playlist_dir/$inner_dir_name"/script.sh & # Run it in the background for now, and only close the script if no jobs are left in the background.

	elif [[ "$download_type" == "${download_types[1]}" ]]; then
		if ! [ -a "$album_dir/$inner_dir_name" ]; then
			mkdir -p "$album_dir/$inner_dir_name"
		fi
		logfile="$album_dir/$inner_dir_name/log"
		write_script "albums"
		bash "$album_dir/$inner_dir_name"/script.sh &

	elif [[ "$download_type" == "${download_types[2]}" ]]; then
		read -p "Enter link to your liked song: " link
		# It will be a bit different for this one here.
		# Also don't forget to set up a log file in here.
		logfile=log
		if ! [ -a "$likes_dir" ]; then
			mkdir -p "$likes_dir"
			cd "$_"
			python "$youtube_dl_bin" --config-location "$youtube_dl_config" "$link" &> "$logfile" &
		else
			cd "$likes_dir"
			python "$youtube_dl_bin" --config-location "$youtube_dl_config" "$link" &> "$logfile" &
		fi

	elif [[ "$download_type" == "Quit?" ]]; then
		# Verify if there are any jobs running in the background, wait for them to exit, and exit.
		echo "Checking if all of your downloads finished downloading. The script will exit once all your downloads have finished."
		wait
		break
	fi
done
