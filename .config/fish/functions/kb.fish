#!/bin/fish
function kb;
	set -l map setxkbmap
	$map -query | grep variant >/dev/null || set -l variant 'colemak'
	$map us $variant -option #altwin:swap_lalt_lwin
	xmodmap $HOME/.Xmodmap
	echo ($map -query | awk 'NR>2{print $2} {gsub(/\n/, " ", $2)}')
end
