nix_path=$HOME/.nix-profile/etc/profile.d/nix.sh
[ -f "$nix_path" ] && . $nix_path

PATH=$HOME/appimages:$HOME/scripts:$PATH
