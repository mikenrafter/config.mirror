function fish_mode_prompt_override
	switch $fish_bind_mode
		case default
			set_color -o brblack
			echo 'N'
		case replace_one
			set_color -o brred
			echo 'R'
		case visual
			set_color -o brblue
			echo 'V'
		#case insert
			#echo ''
		#case '*'
			#echo ''
	end
	echo -n ''
	set_color normal
end
