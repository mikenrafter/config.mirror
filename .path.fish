set nix_path $HOME/.config/fish/functions/nix_path.fish
[ -f "$nix_path" ] && . $nix_path

set -p PATH $HOME/appimages $HOME/scripts

