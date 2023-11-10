#!/usr/bin/env bash
exec 2>"$XDG_RUNTIME_DIR/waybar-playerctl.log"
IFS=$'\n\t'

while true; do

	while read -r playing position length name artist title arturl hpos hlen; do
		# remove leaders
		playing=${playing:1} position=${position:1} length=${length:1} name=${name:1}
		artist=${artist:1} title=${title:1} arturl=${arturl:1} hpos=${hpos:1} hlen=${hlen:1}

		# build line
		line="${artist:+$artist ${title:+- }}${title:+$title }(${hpos:+$hpos${hlen:+|}}$hlen)"

		# json escaping
		line="${line//\"/\\\"}"
		((percentage = length ? (100 * (position % length)) / length : 0))

		# exit if print fails
		echo "$line" || break 2

	done < <(
		playerctl --follow metadata --player playerctld --format \
			$':{{emoji(status)}}\t:{{position}}\t:{{mpris:length}}\t:{{playerName}}\t:{{markup_escape(artist)}}\t:{{markup_escape(title)}}\t:{{mpris:artUrl}}\t:{{duration(position)}}\t:{{duration(mpris:length)}}' &
		echo $! >"$XDG_RUNTIME_DIR/waybar-playerctl.pid"
	)

done

kill "$(<"$XDG_RUNTIME_DIR/waybar-playerctl.pid")"

