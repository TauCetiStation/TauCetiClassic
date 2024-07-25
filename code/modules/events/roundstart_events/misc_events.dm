/datum/event/feature/headset/start()
	for(var/mob/living/carbon/human/H as anything in human_list)
		if((H.l_ear || H.r_ear) && prob(80) && !isanyantag(H))
			var/headset_to_del = H.l_ear ? H.l_ear : H.r_ear
			message_admins("RoundStart Event: [headset_to_del] was removed from [H]")
			log_game("RoundStart Event: [headset_to_del] was removed from [H]")
			qdel(headset_to_del)

/datum/event/feature/survbox/start()
	for(var/mob/living/carbon/human/H as anything in human_list)
		if(!prob(10) || isanyantag(H))
			continue
		var/list/boxs = H.get_all_contents_type(/obj/item/weapon/storage/box/survival)
		if(!boxs.len)
			continue
		for(var/box in boxs)
			message_admins("RoundStart Event: [box] was removed from [H]")
			log_game("RoundStart Event: [box] was removed from [H]")
			qdel(box)

var/global/list/fueltank_list = list()
/datum/event/feature/fueltank/start()
	for(var/atom/fueltank as anything in global.fueltank_list)
		message_admins("RoundStart Event: All fueltanks have been deleted.")
		log_game("RoundStart Event: All fueltanks have been deleted.")
		qdel(fueltank)

var/global/list/watertank_list = list()
/datum/event/feature/watertank/start()
	for(var/atom/watertank as anything in global.watertank_list)
		message_admins("RoundStart Event: All watertanks have been deleted.")
		log_game("RoundStart Event: All watertank have been deleted.")
		qdel(watertank)

var/global/list/cleaners_list = list()
/datum/event/feature/cleaner/start()
	for(var/atom/cleaner as anything in global.cleaners_list)
		message_admins("RoundStart Event: All cleaners have been deleted.")
		log_game("RoundStart Event: All cleaners have been deleted.")
		qdel(cleaner)

var/global/list/extinguisher_list = list()
/datum/event/feature/extinguisher/start()
	for(var/obj/item/weapon/reagent_containers/spray/extinguisher/E as anything in global.extinguisher_list)
		if(istype(E, /obj/item/weapon/reagent_containers/spray/extinguisher/golden))
			continue
		if(prob(70))
			E.reagents.remove_reagent(E.reagent_inside, E.reagents.get_reagent_amount(E.reagent_inside), TRUE)
			message_admins("RoundStart Event: [E] has changed amount of reagents in [COORD(E.loc)]")
			log_game("RoundStart Event: [E] has changed amount of reagents in [COORD(E.loc)]")
		else if(prob(30))
			if(istype(E.loc, /obj/structure/extinguisher_cabinet))
				var/obj/structure/extinguisher_cabinet/EC = E.loc
				message_admins("RoundStart Event: [E] was removed from [COORD(EC)]")
				log_game("RoundStart Event: [E] was removed from [COORD(EC)]")
				qdel(E)
				EC.update_icon()

var/global/list/particle_accelerator_list = list()
/datum/event/feature/PA/start()
	for(var/atom/PA as anything in global.particle_accelerator_list)
		var/old_loc = COORD(PA)
		for(var/i in 1 to rand(3, 5))
			step(PA, pick(NORTH, SOUTH, EAST, WEST))
		message_admins("RoundStart Event: [PA] was moved from [old_loc] to [COORD(PA)]")
		log_game("RoundStart Event: [PA] was moved from [old_loc] to [COORD(PA)]")

var/global/list/tank_dispenser_list = list()
/datum/event/feature/tank_dispenser/start()
	for(var/obj/structure/dispenser/D as anything in global.tank_dispenser_list)
		if(!prob(50))
			continue
		if(D.oxygentanks)
			for(var/i in 1 to rand(1, D.oxygentanks))
				D.oxygentanks--
			message_admins("RoundStart Event: [D] has reduced of oxygen tanks in [COORD(D)]")
			log_game("RoundStart Event: [D] has reduced of oxygen tanks in [COORD(D)]")
		if(D.phorontanks)
			for(var/i in 1 to rand(1, D.phorontanks))
				D.phorontanks--
			message_admins("RoundStart Event: [D] has reduced of phoron tanks in [COORD(D)]")
			log_game("RoundStart Event: [D] has reduced of phoron tanks in [COORD(D)]")
		D.update_icon()

var/global/list/sec_closets_list = list()
/datum/event/feature/sec_equipment/start()
	for(var/obj/structure/closet/closet as anything in global.sec_closets_list)
		message_admins("RoundStart Event: Random items has been removed from [closet] in [COORD(closet)]")
		for(var/obj/item/I in closet)
			if(prob(20))
				log_game("RoundStart Event: [I] was removed from [closet] in [COORD(closet)]")
				qdel(I)

/datum/event/feature/vending_products/start()
	message_admins("RoundStart Event: The range of vending machines has changed amount and price.")
	for(var/obj/machinery/vending/V in machines)
		for(var/datum/data/vending_product/VP in V.product_records)
			if(!prob(80))
				continue
			VP.amount = rand(0, VP.amount)
			VP.price = rand(-1, VP.amount**2)
			log_game("RoundStart Event: [VP.product_name] has changed amount and price in [V] [COORD(V)].")

/datum/event/feature/apc/start()
	for(var/obj/machinery/power/apc/A in apc_list)
		if(!prob(5))
			continue
		// bluescreen
		A.emagged = TRUE
		A.locked = FALSE
		A.update_icon()
		message_admins("RoundStart Event: [A] has bluescreen in [COORD(A)].")
		log_game("RoundStart Event: [A] bluescreen in [COORD(A)].")

/datum/event/feature/dead_monkeys/start()
	message_admins("RoundStart Event: All the monkeys died.")
	log_game("RoundStart Event: All the monkeys died.")
	for(var/mob/M as anything in monkey_list)
		M.death()

/datum/event/feature/salary/start()
	for(var/i in 1 to all_money_accounts.len)
		if(!prob(50))
			continue

		var/datum/money_account/account1 = pick(all_money_accounts)
		var/datum/money_account/account2 = pick(all_money_accounts)
		if(account1 != account2)
			VAR_SWAP(account1.owner_salary, account2.owner_salary)

			message_admins("RoundStart Event: [account1.owner_name] and [account2.owner_name] salaries has been swapped.")
			log_game("RoundStart Event: [account1.owner_name] and [account2.owner_name] salaries has been swapped.")

/datum/event/feature/airlock_joke/start()
	var/list/possible_types = list(/obj/item/weapon/bananapeel, /obj/item/device/assembly/mousetrap/armed, /obj/item/weapon/legcuffs/beartrap/armed, /obj/effect/decal/cleanable/blood/oil)
	for(var/obj/machinery/door/airlock/A as anything in airlock_list)
		if(!is_station_level(A.z))
			continue
		if(prob(10))
			var/type = pick(possible_types)
			var/atom/atom = new type(get_turf(A))

			message_admins("RoundStart Event: Spawned '[atom]' in [COORD(atom)] - [ADMIN_JMP(atom.loc)].")
			log_game("RoundStart Event: Spawned '[atom]' in [COORD(atom)].")

var/global/list/chief_animal_list = list()
/datum/event/feature/head_animals/start()
	for(var/i in 1 to global.chief_animal_list.len)
		var/mob/M1 = pick(global.chief_animal_list)
		var/mob/M2 = pick(global.chief_animal_list)
		if(M1 != M2)
			LOC_SWAP(M1, M2)

		message_admins("RoundStart Event: [M1] and [M2] has been swapped.")
		log_game("RoundStart Event: [M1] and [M2] has been swapped.")

var/global/list/toilet_list = list()
/datum/event/feature/del_toilet/start()
	for(var/atom/A as anything in global.toilet_list)
		if(is_station_level(A.z))
			qdel(A)

	message_admins("RoundStart Event: All toilets have been deleted.")
	log_game("RoundStart Event: All toilets have been deleted.")

/datum/event/feature/leaked_pipe/start()
	message_admins("RoundStart Event: Water was spawned in all toilet rooms.")
	log_game("RoundStart Event: Water was spawned in all toilet rooms.")

	for(var/atom/A as anything in global.toilet_list)
		if(!is_station_level(A.z))
			continue

		var/turf/T = get_turf(A)
		for(var/thing in RANGE_TURFS(1, T))
			var/obj/effect/fluid/F = locate() in thing
			if(!F)
				F = new(thing)
			F.set_depth(4000)

/datum/event/feature/bomb_journey/start()
	for(var/obj/machinery/nuclearbomb/bomb in global.poi_list)
		if(!is_station_level(bomb.z))
			continue
		var/area/A = SSevents.findEventArea()
		var/list/turfs = get_area_turfs(A, TRUE, ignore_blocked = TRUE)
		bomb.forceMove(pick(turfs))
