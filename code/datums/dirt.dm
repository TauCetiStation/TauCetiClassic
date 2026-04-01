// todo: this also works as blood properties holder, this is dumb and we need to create separate blood datums
// dirt can be handled by decals

/datum/dirt_cover
	var/name = "red blood"
	var/color = "#a10808"
	var/alpha = 255

/datum/dirt_cover/New(datum/dirt_cover/cover)
	if(cover)
		// just to be safe, handle both object and typepath
		// we need to rewrite these ancient datums anyway
		if(ispath(cover))
			name = cover::name
			color = cover::color
			alpha = cover::alpha
		else
			name = cover.name
			color = cover.color
			alpha = cover.alpha
	..()

// mix colors of old and new dirt
/datum/dirt_cover/proc/add_dirt(datum/dirt_cover/cover)
	var/list/added_color
	var/added_alpha
	if(ispath(cover))
		added_color = rgb2num(cover::color)
		added_alpha = cover::alpha
	else
		added_color = rgb2num(cover.color)
		added_alpha = cover.alpha

	var/list/current_color = rgb2num(color)

	color = rgb((current_color[1] + added_color[1]) / 2, (current_color[2] + added_color[2]) / 2, (current_color[3] + added_color[3]) / 2)
	alpha = (alpha + added_alpha) / 2

	if(prob(50))
		name = "mixed dirt"

/datum/dirt_cover/dirt
	name = "dirt"
	color = "#784800"

/datum/dirt_cover/mud
	name = "mud"
	color = "#4d2f02"

/datum/dirt_cover/oil
	name = "oil"
	color = "#1f181f"

/datum/dirt_cover/snow
	name = "snow"
	color = "#aaaaaa"
	alpha = 80

/datum/dirt_cover/red_blood
	name = "red blood"
	color = "#a10808"

/datum/dirt_cover/blue_blood
	name = "blue blood"
	color = "#2299fc"

/datum/dirt_cover/purple_blood
	name = "purple blood"
	color = "#8817c1"

/datum/dirt_cover/green_blood
	name = "green blood"
	color = "#004400"

/datum/dirt_cover/gray_blood
	name = "gray blood"
	color = "#bcbcbc"

/datum/dirt_cover/black_blood
	name = "black blood"
	color = "#000000"

/datum/dirt_cover/adamant_blood
	name = "liquid adamant"
	color = "#515573"

/datum/dirt_cover/xeno_blood
	name = "xeno blood"
	color = "#05ee05"

/datum/dirt_cover/hemolymph
	name = "hemolymph"
	color = "#525252"

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
