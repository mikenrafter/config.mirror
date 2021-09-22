# name: Kaboom
# author: notMike

function fish_prompt --description 'Write out the prompt'
	set -l n /dev/null
	set -l last_pipestatus $pipestatus
	set -l normal (set_color normal)
	set fish_user_color blue

	# user-dependent functions
	if fish_is_root_user
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		end
		set suffix '#'
	else
		set color_cwd $fish_color_cwd
		set suffix '>'
		if sudo -n true &>$n
			set user sudo
		else
			set user $USER
		end
	end

	fish_git_prompt &>/dev/null && set suffix ''

	if test $fish_show_stats -gt 0
		# Write pipestatus
		set prompt_status (__fish_print_pipestatus " " "" " " (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)
		set suffix '↑'
	end

	# Identify subshells and modifiers
	if test -n "$NUX"
		set -a shells nux
	else if test (echo $PATH | grep '/nix/store')
		set -a shells nix
	end

	# If we're running via SSH, change the host color.
	set -l color_host $fish_color_host
	if set -q SSH_TTY
		set color_host $fish_color_host_remote
		set -l host @(prompt_hostname)
	end

	set shell_colors 'blue' 'brblack' 'yellow'
	for x in (seq (count $shells) )
		if test $shells[$x]
			echo -n (set_color $shell_colors[$x])$shells[$x]' '
		end
	end

	echo -n -s \
$normal (set_color $fish_user_color) $user \
$normal (set_color $color_host) $host \
$normal ' ' (set_color $color_cwd) (fish_shorten_path) \
$normal (fish_vcs_prompt) \
$normal $prompt_status \
$normal $suffix \
' '
end
