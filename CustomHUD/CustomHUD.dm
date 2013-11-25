
//TODO: make this better
/proc/sanitize_hudcolor(var/color_hash)
	if(length(color_hash) !=7)
		return

	if(copytext(color_hash , 1, 2) != "#")
		return

	var/color = copytext(color_hash , 2)

	var/i = length(color)
	while(i > 0)
		var/char = copytext(color, i, i + 1)
		switch(char)
			if("9", "8", "7", "6", "5", "4", "3", "2", "1", "0", "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f")
				//lalala, indian code
				i--
			else
				return

	return color_hash

/proc/sanitize_hudalpha(var/alpha)
	if(alpha < 256 && alpha >=0)
		return alpha
	return