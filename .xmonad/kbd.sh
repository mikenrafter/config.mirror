#!/bin/env bash

map=setxkbmap
$map -query | grep variant >/dev/null || variant='colemak'
$map us $variant -option compose:rwin
xmodmap $HOME/.Xmodmap
echo $($map -query | awk 'NR>2{print $2} {gsub(/\n/, " ", $2)}')
unset variant
