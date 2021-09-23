# name: Kaboom
# author: notMike

function fish_prompt --description 'Write out the prompt'
	set -l n /dev/null
	set -l last_pipestatus $pipestatus
	set -l normal (set_color normal)
	set fish_user_color blue

	set -l cwd		# initialize cwd var

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
		set -l poetry (string split ' ' $PATH | grep '/pypoetry/')
		set -l nix (string split ' ' $PATH | grep '/nix/store' | grep -v '/pypoetry/')
		# Identify subshells and modifiers
		if test -n "$poetry"
			set -a shells poetry
		end
		if test -n "$nix"
			set -a shells nix
		end
		if test -n "$NUX"
			set -a shells nux
		end
	end

	if test (fish_vcs_prompt)
		set cwd (prompt_pwd)
		set suffix ''
	else
		set cwd (fish_shorten_path)
	end

	if test $fish_show_stats -gt 0
		# Write pipestatus
		set prompt_status (__fish_print_pipestatus " " "" " " (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)
		set suffix '↑'
	end

	# If we're running via SSH, change the host color.
	set -l color_host $fish_color_host
	if set -q SSH_TTY
		set color_host $fish_color_host_remote
		set -l host @(prompt_hostname)
	end

	set shell_colors 'yellow' 'yellow' 'brblack'
	for x in (seq (count $shells) )
		if test $shells[$x]
			echo -n (set_color $shell_colors[$x])$shells[$x]' '
		end
	end

	echo -n -s \
$normal (set_color $fish_user_color) $user \
$normal (set_color $color_host) $host \
$normal ' ' (set_color $color_cwd) $cwd \
$normal (fish_vcs_prompt) \
$normal $prompt_status \
$normal $suffix \
' '
end

# another prompt
# function fish_prompt --description 'Write out the prompt'
#     set -l last_status $status
# 
#     prompt_login
# 
#     echo -n ':'
# 
#     # PWD
#     set_color $fish_color_cwd
#     echo -n (prompt_pwd)
#     set_color normal
# 
#     __terlar_git_prompt
#     fish_hg_prompt
#     echo
# 
#     if not test $last_status -eq 0
#         set_color $fish_color_error
#     end
# 
#     echo -n '➤ '
#     set_color normal
# end
