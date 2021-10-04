#!/bin/env fish
set up /usr/bin/uptime
$up -p | awk ' { print $2 "d " $4 "h " $6 "m" } '
# days, or
#set one ($up | awk '{print $3}' | cut -d',' -f1 | grep -E '[0-9]+')
#if test "$one"
#	echo -n "$one"
#end
#set noDays (echo "$one" | grep -E ':')
## if there are days
#if test "$noDays" = ""
#	set two ($up | awk '{print $5}' | cut -d',' -f1 | grep -E '[0-9]+:[0-9]+')
#	if test "$two"
#		echo -n ":$two"
#	end
#end
