

/obj/structure/diona_plant
	name = "tile of biomass"
	desc = "Is it... Living?"
	icon = 'icons/misc/tools.dmi'
	icon_state = "diona_tile0"

	var/nutrition = 10

/obj/structure/diona_plant/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/diona_plant/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/diona_plant/process()
	if(nutrition <= 0)
		qdel(src)
		return
	nutrition -= 1
	switch(nutrition)
		if(0 to 30)
			icon_state = "diona_tile0"
		if(31 to 60)
			icon_state = "diona_tile1"
		if(61 to 100)
			icon_state = "diona_tile2"
		else
			icon_state = "diona_tile3"

	var/dirs_ = shuffle(cardinal)
	for(var/dir_ in dirs_)
		var/turf/T = get_step(src, dir_)
		var/obj/structure/diona_plant/DP = locate() in T
		if(DP)
			if(nutrition > 76 && DP.nutrition < 76)
				DP.nutrition += 15
				nutrition -= 15
			else if(nutrition > 116 && DP.nutrition < nutrition)
				var/to_give = (nutrition - DP.nutrition) * 0.5
				DP.nutrition += to_give
				nutrition -= to_give
		else
			if(nutrition > 111)
				nutrition -= 10
				DP = new(T)

	for(var/obj/item/I in get_turf(src))
		if(nutrition > 116)
			nutrition -= 15
			I.dionify()

/obj/item/dionificator
	name = "Dionificator"
	icon = 'icons/obj/candle.dmi'
	icon_state = "white_candle"
	item_state = "white_candle"

/obj/item/dionificator/afterattack(atom/A, mob/user)
	A.overlays += icon_dionify(icon(A.icon, A.icon_state))
