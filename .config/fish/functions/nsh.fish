function nsh --wraps nix --description 'nixpkgs.  shell';
	if test -n "$argv[1]"
		# temp variant of 'set -x'
		fish_greeting=(set_color red)$argv[1] \
		nix-shell -p 'pkgs.'$argv[1] --command $SHELL
		#nix run 'nixpkgs.'$argv[1] -c $SHELL # legacy, non-flakes
	end
end
