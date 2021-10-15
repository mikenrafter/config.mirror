set path_path $HOME/.path.fish
[ -f "$path_path" ] && . $path_path

set SHELL (which fish)
[ -f "$HOME/abbr.fish" ] && . $HOME/abbr.fish

function greeting_is_imported
	set -S fish_greeting | head -n1 | grep -cv unexported
end

if test (greeting_is_imported) -eq 1
	set fish_greeting ""
else
	set -q fish_greeting || set -x fish_greeting (random_quote)
end

set fish_user_color blue

for file in ~/.config/fish/functions/init/*
	. $file
end
