/*
 * Holds procs designed to change one type of value, into another.
 */

/proc/text2numlist(text, delimiter="\n")
	var/list/num_list = list()
	for(var/x in splittext(text, delimiter))
		num_list += text2num(x)
	return num_list

/proc/hex2color(hex)
	if(!hex_by_color)
		gen_hex_by_color()

	return hex_by_color[hex]

//Splits the text of a file at seperator and returns them in a list.
/proc/file2list(filename, seperator="\n")
	return splittext(trim(return_file_text(filename)),seperator)


//Turns a direction into text (what?)
/proc/num2dir(direction)
	switch(direction)
		if(1.0) return NORTH
		if(2.0) return SOUTH
		if(4.0) return EAST
		if(8.0) return WEST
		else
			world.log << "UNKNOWN DIRECTION: [direction]"

//Turns a direction into text
/proc/dir2text(direction)
	switch(direction)
		if(1.0)
			return "north"
		if(2.0)
			return "south"
		if(4.0)
			return "east"
		if(8.0)
			return "west"
		if(5.0)
			return "northeast"
		if(6.0)
			return "southeast"
		if(9.0)
			return "northwest"
		if(10.0)
			return "southwest"

//Turns text into proper directions
/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return 1
		if("SOUTH")
			return 2
		if("EAST")
			return 4
		if("WEST")
			return 8
		if("NORTHEAST")
			return 5
		if("NORTHWEST")
			return 9
		if("SOUTHEAST")
			return 6
		if("SOUTHWEST")
			return 10

//Converts an angle (degrees) into an ss13 direction
/proc/angle2dir(degree)
	degree = ((degree+22.5)%365)
	if(degree < 45)		return NORTH
	if(degree < 90)		return NORTHEAST
	if(degree < 135)	return EAST
	if(degree < 180)	return SOUTHEAST
	if(degree < 225)	return SOUTH
	if(degree < 270)	return SOUTHWEST
	if(degree < 315)	return WEST
	return NORTH|WEST

//returns the north-zero clockwise angle in degrees, given a direction
/proc/dir2angle(D)
	switch(D)
		if(NORTH)		return 0
		if(SOUTH)		return 180
		if(EAST)		return 90
		if(WEST)		return 270
		if(NORTHEAST)	return 45
		if(SOUTHEAST)	return 135
		if(NORTHWEST)	return 315
		if(SOUTHWEST)	return 225
		else			return null

//Returns the angle in english
/proc/angle2text(degree)
	return dir2text(angle2dir(degree))

//Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY) return ICON_MULTIPLY
		if(BLEND_ADD)      return ICON_ADD
		if(BLEND_SUBTRACT) return ICON_SUBTRACT
		else               return ICON_OVERLAY

//Converts a rights bitfield into a string
/proc/rights2text(rights,seperator="")
	if(rights & R_BUILDMODE)   . += "[seperator]+BUILDMODE"
	if(rights & R_ADMIN)       . += "[seperator]+ADMIN"
	if(rights & R_BAN)         . += "[seperator]+BAN"
	if(rights & R_FUN)         . += "[seperator]+FUN"
	if(rights & R_SERVER)      . += "[seperator]+SERVER"
	if(rights & R_DEBUG)       . += "[seperator]+DEBUG"
	if(rights & R_POSSESS)     . += "[seperator]+POSSESS"
	if(rights & R_PERMISSIONS) . += "[seperator]+PERMISSIONS"
	if(rights & R_STEALTH)     . += "[seperator]+STEALTH"
	if(rights & R_REJUVINATE)  . += "[seperator]+REJUVINATE"
	if(rights & R_VAREDIT)     . += "[seperator]+VAREDIT"
	if(rights & R_SOUNDS)      . += "[seperator]+SOUND"
	if(rights & R_SPAWN)       . += "[seperator]+SPAWN"
	if(rights & R_WHITELIST)   . += "[seperator]+WHITELIST"
	if(rights & R_EVENT)       . += "[seperator]+EVENT"
	if(rights & R_LOG)		   . += "[seperator]+LOG"
	return .

// heat2color functions. Adapted from: http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
/proc/heat2color(temp)
	return rgb(heat2color_r(temp), heat2color_g(temp), heat2color_b(temp))

/proc/heat2color_r(temp)
	temp /= 100
	if(temp <= 66)
		. = 255
	else
		. = max(0, min(255, 329.698727446 * (temp - 60) ** -0.1332047592))

/proc/heat2color_g(temp)
	temp /= 100
	if(temp <= 66)
		. = max(0, min(255, 99.4708025861 * log(temp) - 161.1195681661))
	else
		. = max(0, min(255, 288.1221695283 * ((temp - 60) ** -0.0755148492)))

/proc/heat2color_b(temp)
	temp /= 100
	if(temp >= 66)
		. = 255
	else
		if(temp <= 16)
			. = 0
		else
			. = max(0, min(255, 138.5177312231 * log(temp - 10) - 305.0447927307))

//Converts a positive interger to its roman numeral equivilent. Ignores any decimals.
//Numbers over 3999 will display with extra "M"s (don't tell the Romans) and can get comically long, so be careful.
/proc/num2roman(A)
	var/list/values = list("M" = 1000, "CM" = 900, "D" = 500, "CD" = 400, "C" = 100, "XC" = 90, "L" = 50, "XL" = 40, "X" = 10, "IX" = 9, "V" = 5, "IV" = 4, "I" = 1)
	if(!A || !isnum(A))
		return 0
	while(A >= 1)
		for(var/i in values)
			if(A >= values[i])
				. += i
				A -= values[i]
				break

/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			if(/obj, /mob)
				return /atom/movable
			if(/area, /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))
