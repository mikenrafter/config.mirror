function cpa --argument from --argument to --description 'multithreaded cp' --wraps 'rsync';
	# dependencies
	which fish rsync find xargs realpath 1>/dev/null || return 127
	# require arguments
	if count $to > /dev/null
		# we'll be changing directories, ensure that the destination directory
		# is an absolute path
		set -x to (realpath $to)
		# inform the user of the thread count, and destinations
		echo '[5 threads] '$from'/ --> '$to'/'$from'/'
		sleep 1
	else
		echo 'both arguments (to, from) are required'
		return 1
	end
	# strip '.' from beginning of $from, but not './', leave the '/'
	function strip_beginning --argument content;
		echo $content | tail -c +2
	end
	# if $from is actually a directory
	if [ -d $from ];
		# temporarily enter $from
		pushd $from
		# if entering the directory failed
		if [ $status != 0 ];
			echo 'Perhaps try sudo?'
			return 1;
		end
	else
		echo $from' is not a directory.'
		return 1
	end
	# only recurse 2 directories deep, split on filenames, not on spaces - find
	# multithread the command with 5 instances at the most, and replace % with
	# the piped argument, in the execution string, also handle filenames
	# properly (--null) - xargs
	# "rsync ..." - inform the user of what's going on, run recursively on
	# directories, and pass any extra arguments
	# use fish as scripting language, not bash, for readability's sake
	set -x args $argv
	function copy;
		# separate doing directories/other types, this' because we need the
		# directory name usually
		find -maxdepth 1 -print0 -not -type d | xargs --null -P 5 -I % fish -c \
			"rsync --progress -rEp $args[3..] '%' $to/(dirname '%'); echo '--- thread closing ---'"
		find -maxdepth 2 -mindepth 2 -print0 -type d | xargs --null -P 5 -I % fish -c \
			"rsync --progress -rEp $args[3..] '%' $to/(dirname '%'); echo '--- thread closing ---'"
	end
	# inform user of transfer duration
	time copy
	# return to previous directory
	popd
end
