#define HEX_VAL_RED(col)   hex2num(copytext(col, 2, 4))
#define HEX_VAL_GREEN(col) hex2num(copytext(col, 4, 6))
#define HEX_VAL_BLUE(col)  hex2num(copytext(col, 6, 8))
#define HEX_VAL_ALPHA(col) hex2num(copytext(col, 8, 10))

/proc/random_short_color()
	return "#" + random_string(3, global.hex_characters)

/proc/random_color()
	return "#" + random_string(6, global.hex_characters)

/proc/normalize_color(inphex) //normalize hex color and convert hex2num and num2hex

	var/rn_color
	var/gn_color
	var/bn_color
	var/rh_color
	var/gh_color
	var/bh_color
	var/final_hex
	rn_color = hex2num(copytext(inphex, 2,4))
	gn_color = hex2num(copytext(inphex, 4,6))
	bn_color = hex2num(copytext(inphex, 6,8))

	//Normalize color when RGB color shade is not less than the sum 180
	if((rn_color + gn_color + bn_color) < 180)
		if(rn_color < 60)
			rn_color += 60
		if(gn_color < 60)
			gn_color += 60
		if(bn_color < 60)
			bn_color += 60

	rh_color = num2hex(rn_color)
	gh_color = num2hex(gn_color)
	bh_color = num2hex(bn_color)

	//Set complete normalize hex color
	final_hex = "#" + rh_color + gh_color + bh_color
	return final_hex

/proc/adjust_brightness(color, value)
	if (!color) return "#ffffff"
	if (!value) return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = clamp(RGB[1]+value,0,255)
	RGB[2] = clamp(RGB[2]+value,0,255)
	RGB[3] = clamp(RGB[3]+value,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])

// make hex color brighter before one value is #ff
// todo: replace with color_lightness_max
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

/// Ensures that the lightness value of a color must be greater than the provided minimum.
/proc/color_lightness_max(color, min_lightness)
	var/list/rgb = rgb2num(color)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	hsl[3] = max(hsl[3], min_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])

/// Ensures that the lightness value of a color must be less than the provided maximum.
/proc/color_lightness_min(color, max_lightness)
	var/list/rgb = rgb2num(color)
	var/list/hsl = rgb2hsl(rgb[1], rgb[2], rgb[3])
	// Ensure high lightness (Minimum of 90%)
	hsl[3] = min(hsl[3], max_lightness)
	var/list/transformed_rgb = hsl2rgb(hsl[1], hsl[2], hsl[3])
	return rgb(transformed_rgb[1], transformed_rgb[2], transformed_rgb[3])
