/proc/mix_color_from_reagents(list/reagent_list)
	if(!reagent_list || !length(reagent_list))
		return 0

	var/contents = length(reagent_list)
	var/list/weight = new /list(contents)
	var/list/redcolor = new /list(contents)
	var/list/greencolor = new /list(contents)
	var/list/bluecolor = new /list(contents)
	var/i

	//fill the list of weights
	for(i=1; i<=contents; i++)
		var/datum/reagent/re = reagent_list[i]
		var/reagentweight = re.volume * re.color_weight
		weight[i] = reagentweight


	//fill the lists of colours
	for(i=1; i<=contents; i++)
		var/datum/reagent/re = reagent_list[i]
		var/hue = re.color
		if(length(hue) != 7)
			return 0
		redcolor[i] = HEX_VAL_RED(hue)
		greencolor[i] = HEX_VAL_GREEN(hue)
		bluecolor[i] = HEX_VAL_BLUE(hue)

	//mix all the colors
	var/red = mixOneColor(weight,redcolor)
	var/green = mixOneColor(weight,greencolor)
	var/blue = mixOneColor(weight,bluecolor)

	//assemble all the pieces
	var/finalcolor = "#[red][green][blue]"
	return finalcolor

/proc/mixOneColor(list/weight, list/color)
	if (!weight || !color || length(weight)!=length(color))
		return 0

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i=1; i<=contents; i++)
		listsum += weight[i]
	for(i=1; i<=contents; i++)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i=1; i<=contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	//until someone writes a formal proof for this algorithm, let's keep this in
	if(mixedcolor<0x00 || mixedcolor>0xFF)
		return 0

	var/finalcolor = num2hex(mixedcolor)
	while(length(finalcolor)<2)
		finalcolor = text("0[]",finalcolor) //Takes care of leading zeroes
	return finalcolor
