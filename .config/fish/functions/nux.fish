function nux
	set -l n /dev/null
	if test -n "$NUX"
		for n in $NIX; set -gxp PATH $n; end
		set -e NIX
		set -e NUX
	else
		set -l path $PATH
		set PATH
		for p in $path
			echo $p | grep \\.nix-profile >$n && set -l nix 1
			if test -n "$nix"
				set -gxa NIX $p
			else
				set -gxa PATH $p
			end
			set -e nix
		end
		set -gx NUX 1
	end
	return 0
end
