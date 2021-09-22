function cat --wraps bat --description 'alias cat bat';
	set -l status (which bat | grep ': no ')
	if [ $status ]
		cat $argv
	else
		bat $argv
	end
end
