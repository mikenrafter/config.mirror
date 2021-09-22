function fish_shorten_path
	# This allows overriding fish_prompt_pwd_dir_length from the outside (global or universal) without leaking it
	set -q fish_prompt_pwd_dir_length
	or set -l fish_prompt_pwd_dir_length 1

	set -l arg1 ''
	set -g arg1 ''

	if set -q argv[1]
		set arg1 $argv[1]
	else
		set arg1 $PWD
	end

	# Replace $HOME with "~"
	set -l realhome ~
	set -l tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $arg1)

	if [ $fish_prompt_pwd_dir_length -eq 0 ]
		echo $tmp
	else
		# Shorten to at most $fish_prompt_pwd_dir_length characters per directory
		string replace -ar '(\.?[^/-]{'"$fish_prompt_pwd_dir_length"'})[^/-]*([/-])' '$1$2' $tmp
	end
end
