set path_path $HOME/.path.fish
[ -f "$path_path" ] && . $path_path

set SHELL (which fish)
[ -f "$HOME/abbr.fish" ] && . $HOME/abbr.fish

set -q fish_greeting || set fish_greeting (random_quote)

set fish_user_color blue

for file in ~/.config/fish/functions/init/*
	. $file
end
