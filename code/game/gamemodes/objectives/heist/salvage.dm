/datum/objective/heist/salvage
	var/str_target

/datum/objective/heist/salvage/find_target()
	var/loot = "an object"
	switch(rand(1, 3))
		if(1)
			str_target = /obj/item/stack/sheet/metal
			target_amount = pick(150, 200)
			loot = "металла"
		if(2)
			str_target = /obj/item/stack/sheet/glass
			target_amount = pick(150, 200)
			loot = "стекла"
		if(3)
			str_target = /obj/item/stack/sheet/plasteel
			target_amount = pick(20, 30, 40, 50)
			loot = "пластали"

	explanation_text = "Разграбьте станцию и сбегите с [target_amount] [loot] листами."
	return TRUE

/datum/objective/heist/salvage/check_completion()
	var/total_amount = 0
	var/list/area/arkship_areas = list(/area/shuttle/vox/arkship, /area/shuttle/vox/arkship_hold)

	for(var/type in arkship_areas)
		for(var/obj/O in get_area_by_type(type))

			var/obj/item/stack/sheet/S
			if(istype(O, /obj/item/stack/sheet))
				if(O.name == str_target)
					S = O
					total_amount += S.get_amount()
			for(var/obj/I in O.contents)
				if(istype(I, /obj/item/stack/sheet))
					if(I.name == str_target)
						S = I
						total_amount += S.get_amount()

	for(var/datum/role/raider in faction.members)
		if(raider.antag.current)
			for(var/obj/item/O in raider.antag.current.GetAllContents())
				if(istype(O,/obj/item/stack/sheet))
					if(O.name == str_target)
						var/obj/item/stack/sheet/S = O
						total_amount += S.get_amount()

	if(total_amount >= target_amount)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
