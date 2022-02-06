# if not ran through home-manager
if [ -z "$__HM_SESS_VARS_SOURCED" ]; then
	path_path=$HOME/.path.sh
	[ -f "$path_path" ] && . $path_path
	# launch X11 if on 1st/2nd TTY
	#tty | grep tty2 && exec fish -c /bin/weston
	tty | grep tty2 && exec startx
	tty | grep tty1 && exec startx
fi
if [ -e /home/v0id/.nix-profile/etc/profile.d/nix.sh ]; then . /home/v0id/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
