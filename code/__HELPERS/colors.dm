#define HEX_VAL_RED(col)   hex2num(copytext(col, 2, 4))
#define HEX_VAL_GREEN(col) hex2num(copytext(col, 4, 6))
#define HEX_VAL_BLUE(col)  hex2num(copytext(col, 6, 8))
#define HEX_VAL_ALPHA(col) hex2num(copytext(col, 8, 10))

/proc/random_short_color()
	return "#" + random_string(3, global.hex_characters)

/proc/random_color()
	return "#" + random_string(6, global.hex_characters)


// normalize hex color
/proc/normalize_color(color) 
	var/list/hexes = rgb2num(color)

	// Normalize color when RGB color shade is not less than the sum 180
	// todo: probably should be based on HSL, this is not good
	if((hexes[1] + hexes[2] + hexes[3]) < 180)
		if(hexes[1] < 60)
			hexes[1] += 60
		if(hexes[2] < 60)
			hexes[2] += 60
		if(hexes[3] < 60)
			hexes[3] += 60

	return rgb(hexes[1], hexes[2], hexes[3])

/proc/adjust_brightness(color, value)
	if (!color) return "#ffffff"
	if (!value) return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = clamp(RGB[1]+value,0,255)
	RGB[2] = clamp(RGB[2]+value,0,255)
	RGB[3] = clamp(RGB[3]+value,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])

// make hex color brighter before one value is #ff
// todo: replace with hsl procs
/proc/adjust_to_white(color)
	var/list/RGB[3]
	RGB[1] = HEX_VAL_RED(color)
	RGB[2] = HEX_VAL_GREEN(color)
	RGB[3] = HEX_VAL_BLUE(color)

	var/min_diff = 255
	for(var/i in 1 to 3)
		var/diff = 255 - RGB[i]
		if(min_diff > diff)
			min_diff = diff

	for(var/i in 1 to 3)
		RGB[i] += min_diff

	return rgb(RGB[1],RGB[2],RGB[3])

/// Caps HSL luminance value of a HEX color to the provided minimum
/proc/color_luminance_max(color, min_lightness)
	var/list/hsl = rgb2num(color, COLORSPACE_HSL)
	hsl[3] = clamp(max(hsl[3], min_lightness), 0, 100)
	if(length(hsl) == 4) // check for alpha channel
		return rgb(hsl[1], hsl[2], hsl[3], hsl[4], space = COLORSPACE_HSL)
	else
		// You NEED to use a named space argument for 4 parameters rgb(),
		// otherwise colorspace will be parsed as alpha for the default RGB colorspace.
		// Guess who spend an hour on this and almost filled a bug report!
		// Although this is in the refs i still think that maybe lummox just hates us...
		return rgb(hsl[1], hsl[2], hsl[3], space = COLORSPACE_HSL)

/// Caps HSL luminance value of a HEX color to the provided maximum
/proc/color_luminance_min(color, max_lightness)
	var/list/hsl = rgb2num(color, COLORSPACE_HSL)
	hsl[3] = clamp(min(hsl[3], max_lightness), 0, 100)
	if(length(hsl) == 4) // check for alpha channel
		return rgb(hsl[1], hsl[2], hsl[3], hsl[4], space = COLORSPACE_HSL)
	else
		return rgb(hsl[1], hsl[2], hsl[3], space = COLORSPACE_HSL)

/// Shifts HSL luminance of a HEX color by value
/proc/color_shift_luminance(color, shift)
	var/list/hsl = rgb2num(color, COLORSPACE_HSL)
	hsl[3] = clamp(hsl[3] + shift, 0, 100)
	if(length(hsl) == 4) // check for alpha channel
		return rgb(hsl[1], hsl[2], hsl[3], hsl[4], space = COLORSPACE_HSL)
	else
		return rgb(hsl[1], hsl[2], hsl[3], space = COLORSPACE_HSL)
