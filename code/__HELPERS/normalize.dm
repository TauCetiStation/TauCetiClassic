// For proc which normalize something

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
	RGB[1] = CLAMP(RGB[1]+value,0,255)
	RGB[2] = CLAMP(RGB[2]+value,0,255)
	RGB[3] = CLAMP(RGB[3]+value,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])