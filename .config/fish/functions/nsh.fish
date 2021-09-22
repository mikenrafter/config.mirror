function nsh --wraps nix --description 'nixpkgs.  shell';
	echo $argv[1] | grep \\w &&
	nix-shell -p 'pkgs.'(echo $argv[1]) --command $SHELL
	#nix run 'nixpkgs.'$argv[1] -c $SHELL # legacy, non-flakes
end
