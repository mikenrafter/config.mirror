function random_quote
	echo ( set_color 0bf )(
		string replace -a '"' ( set_color yellow )'"'( set_color 0fb ) (
		string replace -a '	' ( set_color normal )' | '( set_color 0fb ) (
			random choice ( string split \n (cat ~/quotes | uniq | grep -ve '^#' | grep -ve '^$') )
		)))
end
