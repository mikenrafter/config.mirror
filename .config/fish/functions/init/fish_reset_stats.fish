function fish_reset_stats -e fish_prompt
	set -g fish_show_stats (math $fish_show_stats - 1)
end

