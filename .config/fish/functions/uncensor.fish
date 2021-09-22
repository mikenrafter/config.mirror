function uncensor -d 'change your mac address & hostname';
	# useful behind poorly configured firewalls that throttle individual devices
	# get sudo password before internet goes down
	sudo echo 1 > /dev/null
	nmcli radio wifi off
	set -l rhost 'DESKTOP-'(head -3 /dev/urandom | tr -cd '[:alnum:]' | cut -c -5)
	echo (hostname)' -> '$rhost
	sudo hostname $rhost
	sudo macchanger -r wlo1
	nmcli radio wifi on
end
