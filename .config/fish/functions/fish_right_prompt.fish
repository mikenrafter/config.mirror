#!/bin/env fish
# fish right prompt

# https://github.com/jorgebucaran/humantime.fish
function humantime --argument-names ms --description "Turn milliseconds into a human-readable string"
	set -q ms[1] || return

	set -l secs (math --scale=2 $ms/1000 % 60)
	set -l mins (math --scale=0 $ms/60000 % 60)
	set -l hours (math --scale=0 $ms/3600000)

	test $hours -gt 0 && set -la output $hours'h'
	test $mins  -gt 0  && set -la output $mins'm'
	test $secs  -gt 0  && set -la output $secs's'

	set -q output && echo -n $output || echo -n $ms'ms'
end

function timer
	# if show_time's unset, fix that
	set -q fish_show_stats || set -g fish_show_stats 0
	# if show_time is above 0, and if command duration is above 200ms
	if test $fish_show_stats -gt 0; and test $CMD_DURATION -gt 200
		# pretty print the time
		humantime $CMD_DURATION
		return
	end
	echo -n ''
end

function job_count
	set count (jobs | wc -l)
	if test $count -gt 0
		echo -n +$count
		return
	end
	echo -n ''
end

function fish_right_prompt
	set -l colors brblack cyan blue
	if set -q VIRTUAL_ENV; and contains -- $PATH $VIRTUAL_ENV $VIRTUAL_ENV/bin
		set -a out $VIRTUAL_ENV
	end

	if set -q out
		for x in (seq (count $out ) )
			set out[$x] (fish_shorten_path $out[$x])
		end
	end
	
	set out (string split ' ' $out | uniq)

	set -la output (timer)
	set -la output (job_count)
	set -la output (fish_mode_prompt_override)
	echo -n (set_color 'brblack')$out
	for i in (seq (count $output))
		if test (count $output[$i]) -gt 0
			echo -n -s ' '(set_color $colors[$i]) $output[$i]
		end
	end
end

