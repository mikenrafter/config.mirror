function nux
	set -l n /dev/null
	if test -n "$NUX"
		for n in $NIX; set -gxp PATH $n; end
		set -e NIX
		set -e NUX
	else
		# copy path to local var
		set -l path $PATH
		# clear global path
		set PATH
		# loop through paths
		for p in $path
			# remove exceptions, and check if nix profile is present in the path
			echo $p | grep -v $NUX_EXCEPTION | grep \\.nix-profile >$n && set -l nix 1
			if test -n "$nix"
				set -gxa NIX $p
			else
				set -gxa PATH $p
			end
			set -e nix
		end
		set -gx NUX 1
	end
	set -x PATH (string split ' ' $PATH | uniq)
	return 0
end
