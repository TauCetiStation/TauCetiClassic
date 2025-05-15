/datum/event/egg_hunt
	startWhen = 30
	endWhen = 900

	var/affecting_z = 2

/datum/event/egg_hunt/setup()
	affecting_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/datum/announcement/centcomm/egghunt/pre/announcement_pre = new
	announcement_pre.play()

/datum/event/egg_hunt/start()
	var/eggsspawned = 0
	var/eggsmax = player_list.len * 8 // 8 eggs per player
	for(var/i in 1 to 3000) // 3000 attempts
		var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), affecting_z)
		if(isfloorturf(candidate))
			eggsspawned += 1
			new /obj/random/foods/boiledegg(candidate)
		if(eggsspawned >= eggsmax)
			break

	// a chance to spawn an egg in each closet
	for(var/obj/structure/closet/C in closet_list)
		if(prob(5))
			new /obj/random/foods/boiledegg(C)

	var/datum/announcement/centcomm/egghunt/start/announcement_start = new
	announcement_start.play()

/datum/event/egg_hunt/end()
	var/list/winners_list = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/egg_amount = 0
		if(is_station_level(H.z))
			var/list/items_to_check = H.GetAllContents()
			for(var/A in items_to_check)
				if(istype(A, /obj/item/weapon/reagent_containers/food/snacks/egg))
					egg_amount++
				if(istype(A, /obj/item/weapon/reagent_containers/food/snacks/boiledegg))
					egg_amount++
		winners_list[H.name] = egg_amount
	sortTim(winners_list, GLOBAL_PROC_REF(cmp_numeric_dsc), associative=TRUE)

	var/message = "Объявляем победителей охоты за яйцами! <br>"
	var/position = 0
	for(var/key in winners_list)
		position++
		message += "<br> [position]: [key] - [winners_list[key]] яиц. "
		if(position == 1)
			message += "Победитель!"
		else if(position == 10)
			break

	var/datum/announcement/centcomm/egghunt/finish/announcement_finished = new
	announcement_finished.message = message
	announcement_finished.play()
