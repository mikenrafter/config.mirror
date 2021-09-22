function config
	set -x GIT_DISCOVERY_ACROSS_FILESYSTEM 1
	git --git-dir=$HOME/.files/ --work-tree=$HOME $argv
end
