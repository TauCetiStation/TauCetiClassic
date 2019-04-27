/datum/catastrophe_event/supply_drop
	name = "Supply drop"

	one_time_event = FALSE

	weight = 100

	event_type = "help"
	steps = 1

/datum/catastrophe_event/supply_drop/on_step()
	switch(step)
		if(1)
			var/area/impact_area = findEventArea()
			var/turf/simulated/floor/T = find_random_floor(impact_area, check_mob = TRUE)

			if(!istype(T) || !impact_area)
				return

			new /obj/effect/falling_effect(T, /obj/structure/closet/crate/medical/supplydrop)

			announce("»сход, мы сейчас мало чем можем вам помочь, но это хоть что-то. ¬ данный момент к вам летит груз с полезными вещами. ѕримерное место приземление груза: [impact_area.name]")
			message_admins("Supply drop was dropped in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")

/obj/structure/closet/crate/medical/supplydrop
	name = "supply crate"
	desc = "A crate with usefull supplies"

/obj/structure/closet/crate/medical/supplydrop/PopulateContents()
	for (var/i in 1 to rand(1,4))
		if(prob(60))
			new /obj/item/weapon/storage/firstaid(src)
		else
			new /obj/item/weapon/storage/firstaid/adv(src)

	var/list/cell_weights = list(/obj/item/weapon/stock_parts/cell = 4, /obj/item/weapon/stock_parts/cell/high = 6, /obj/item/weapon/stock_parts/cell/super = 4, /obj/item/weapon/stock_parts/cell/hyper = 2, /obj/item/weapon/stock_parts/cell/bluespace = 1)
	for (var/i in 1 to rand(0,2))
		var/e = pickweight(cell_weights)
		new e(src)

	for (var/i in 1 to rand(0,4))
		new /obj/item/clothing/suit/space(src)
		new /obj/item/clothing/head/helmet/space(src)

	if(prob(70))
		new /obj/item/weapon/storage/toolbox/emergency(src)
	if(prob(30))
		new /obj/item/weapon/crowbar/power(src)
	if(prob(30))
		new /obj/item/weapon/weldingtool/experimental(src)
	if(prob(20))
		new /obj/item/weapon/storage/belt/medical/surg/full(src)
