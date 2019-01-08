/datum/dirt_cover
	var/name = "red blood"
	var/color = "#A10808"

/datum/dirt_cover/New(datum/dirt_cover/cover)
	if(cover)
		if(ispath(cover))
			name = initial(cover.name)
			color = initial(cover.color)
		else
			name = cover.name
			color = cover.color
	..()

/datum/dirt_cover/dirt
	name = "dirt"
	color = "#784800"

/datum/dirt_cover/oil
	name = "oil"
	color = "#1F181F"

/datum/dirt_cover/red_blood
	name = "red blood"
	color = "#A10808"

/datum/dirt_cover/blue_blood
	name = "blue blood"
	color = "#2299FC"

/datum/dirt_cover/purple_blood
	name = "purple blood"
	color = "#8817c1"
	
/datum/dirt_cover/green_blood
	name = "green blood"
	color = "#004400"

/datum/dirt_cover/gray_blood
	name = "gray blood"
	color = "#BCBCBC"

/datum/dirt_cover/black_blood
	name = "black blood"
	color = "#000000"

/datum/dirt_cover/adamant_blood
	name = "liquid adamant"
	color = "#515573"

/datum/dirt_cover/xeno_blood
	name = "xeno blood"
	color = "#05EE05"

/datum/dirt_cover/proc/add_dirt(datum/dirt_cover/A)
	var/red = (hex2num(copytext(color,2,4)) + hex2num(copytext(A.color,2,4))) / 2
	var/green = (hex2num(copytext(color,4,6)) + hex2num(copytext(A.color,4,6))) / 2
	var/blue = (hex2num(copytext(color,6,8)) + hex2num(copytext(A.color,6,8))) / 2
	color = rgb(red,green,blue)
	if(prob(50))      // lame but whatever
		name = A.name //

/*
/proc/get_dirt_mixed_color(list/dms)
	if(!dms)
		return 0
	var/red = 0
	var/green = 0
	var/blue = 0
	for(var/datum/dirt_cover/cover in dms)
		red += hex2num(copytext(cover.color,2,4))
		green += hex2num(copytext(cover.color,4,6))
		blue += hex2num(copytext(cover.color,6,8))
	red /= dms.len
	green /= dms.len
	blue /= dms.len
	return rgb(red,green,blue)
*/
