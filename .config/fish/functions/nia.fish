function nia --wraps nix-env --description 'nixpkgs.  install';
	echo $argv[1] | grep \\w &&
	nix-env -iA 'nixpkgs.'$argv[1]
end

