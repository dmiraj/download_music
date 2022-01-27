# In this script I will be choosing which dowload-item to add/download/update.
youtube_dl_bin="$PWD/yt-dl-fork/youtube-dl"
youtube_dl_config="$PWD/youtube-dl/youtube-dl.config"
download_types=( "Playlist" "Album" "Likes" "q - to quit")

# The following function contains the script to write in a file in each of the newly downloaded objects
function write_script () {
	cat > "$dirname"/script.sh <<delimiter
youtube_dl_bin="/home/dmiraj/Documents/Bash/yt-dl-fork/youtube-dl"
youtube_dl_config="/home/dmiraj/Documents/Bash/yt-dl-fork/youtube-dl.config"

# Run the 'youtube-dl' script.
cd "$dirname"
"\$youtube_dl_bin" --config-location "\$youtube_dl_config" "$link" &> "$logfile"
delimiter
}

echo "Select from the following which category corresponds to your download:"
select download_type in "${download_types[@]}"; do
	if [[ "$download_type" = "${download_types[0]}" ]]; then
		read -p "Enter the playlist link: " link
		# Don't forget to set up a log file in here.
		playlist_title="$(curl $link |& egrep -o '"><title>.+</title><lin')" # This will output a short sequence containing the playlist name. 
		playlist_title="${playlist_title#'"><title>'}"
		playlist_title="${playlist_title%'</title><lin'}" # Playlist should now be the playlist name
		playlist_title="${playlist_title//&amp;/&}"
		playlist_title="${playlist_title//&#39;/\'}"
		playlist_title="${playlist_title//;/''}"
		# I could add more substitution for special character codes in html i.e: ${playlist_title/&amp/'}
		# Script to intercept the playlist link.
		export dirname="$PWD/$playlist_title"
		export logfile="$dirname/log"
		mkdir "$dirname"
		write_script
		bash "$dirname"/script.sh & # Run it in the background for now, and only close the script if no jobs are left in the background.

	elif [[ "$download_type" = "${download_types[1]}" ]]; then
		read -p "Enter the link of the album: " link
		# Script to intercept the album name
		# Also don't forget to set up a log file in ehre.
		albumname="$(curl $link |& egrep -o '"><title>.+</title><lin')"
		albumname="${albumname#'"><title>'}"
		albumname="${albumname%'</title><lin'}"
		albumname="${albumname//&amp;/&}"
		albumname="${albumname//&#39;/\'}"
		albumname="${albumname//;/''}"
		export dirname="$PWD/$albumname"
		export logfile="$dirname/log"
		mkdir "$dirname"
		write_script
		bash "$dirname/script.sh" &

	elif [[ "$download_type" = "${download_types[2]}" ]]; then
		read -p "Enter link to your liked song: " link
		# It will be a bit different for this one here.
		# Also don't forget to set up a log file in here.
		if ! [ -a "My Likes" ]; then
			export dirname="$PWD/My Likes"
			mkdir "$dirname"
			cd "$dirname"
			bash "$youtube_dl_bin" --config-location "$youtube_dl_config" "$link" &
		else
			cd "$PWD/My Likes"
			bash "$youtube_dl_bin" --config-location "$youtube_dl_config" "$link" &
		fi

	elif [[ "$download_type" == 'q' ]]; then
		# Verify if there are any jobs running in the background, wait for them to exit, and exit.
		wait

	fi
	break

done
