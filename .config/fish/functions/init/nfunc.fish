# -S gives it the ability to touch the variables of parent functions
function nfunc -S --description 'nix shorthand utility function';
	if test -n "$argv"

		set -q PAGER || set -x PAGER more
		set -l args
		set -l tacks

		for arg in $argv
			if test (echo "$arg" | cut -c2) = "-"
				set -a tacks $arg
			# `not` in fish is *not* fun
			else if test (echo "$arg" | cut -c1) = "-"
				set set (echo "$arg" | cut -c2-)
			else
				set -a args $arg
			end
		end

		#only repeat if there's a delimiter
		if set -q delimiter
			$fn $prefix $tacks $set$delimiter$args $suffix
		else
			$fn $prefix $tacks $set $args $suffix
		end


	end

end


function nsh --wraps nix-shell --description 'nix shell';
	set -x fish_greeting (set_color red)$argv

	set suffix    '--command' $SHELL
	set prefix    '-p'
	set set       'pkgs'
	set delimiter '.'
	set fn        'nix-shell'
#	# legacy
#	set suffix    '-c' $SHELL
#	set prefix    'run'
#	set set       'nixpkgs'
#	set delimiter '.'
#	set fn        'nix'
	nfunc $argv
end


function nsearch --wraps nix --description 'nix search';
	set suffix    '--offline'
	set prefix    'search'
	set set       'nixpkgs'
	#delimiter
	set fn        'nix'
	nfunc $argv
end

function nsc --wraps nsearch --description 'nsearch alias';
	nsearch $argv
end
