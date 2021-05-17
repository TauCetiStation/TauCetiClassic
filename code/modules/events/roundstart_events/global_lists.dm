/datum/event/roundstart/headset/start()
	for(var/mob/living/carbon/human/H in human_list)
		if((H.l_ear || H.r_ear) && prob(10))
			var/headset_to_del = H.l_ear ? H.l_ear : H.r_ear
			message_admins("RoundStart Event: [headset_to_del] was removed from [H]")
			log_game("RoundStart Event: [headset_to_del] was removed from [H]")
			qdel(headset_to_del)
			H.update_inv_ears()

/datum/event/roundstart/survbox/start()
	for(var/mob/living/carbon/human/H in human_list)
		if(!prob(10))
			continue
		var/list/boxs = H.get_all_contents_type(/obj/item/weapon/storage/box/survival)
		if(!boxs.len)
			continue
		for(var/box in boxs)
			message_admins("RoundStart Event: [box] was removed from [H]")
			log_game("RoundStart Event: [box] was removed from [H]")
			qdel(box)

var/global/list/fueltank_list = list()
/datum/event/roundstart/fueltank/start()
	for(var/atom/fueltank in fueltank_list)
		if(prob(10))
			message_admins("RoundStart Event: [fueltank] was removed from [COORD(fueltank)]")
			log_game("RoundStart Event: [fueltank] was removed from [COORD(fueltank)]")
			qdel(fueltank)

var/global/list/watertank_list = list()
/datum/event/roundstart/watertank/start()
	for(var/atom/watertank in watertank_list)
		if(prob(10))
			message_admins("RoundStart Event: [watertank] was removed from [COORD(watertank)]")
			log_game("RoundStart Event: [watertank] was removed from [COORD(watertank)]")
			qdel(watertank)

var/global/list/cleaners_list = list()
/datum/event/roundstart/cleaner/start()
	for(var/atom/cleaner in cleaners_list)
		if(prob(50))
			message_admins("RoundStart Event: [cleaner] was removed from [COORD(cleaner)]")
			log_game("RoundStart Event: [cleaner] was removed from [COORD(cleaner)]")
			qdel(cleaner)

var/global/list/extinguisher_list = list()
/datum/event/roundstart/extinguisher/start()
	for(var/obj/item/weapon/reagent_containers/spray/extinguisher/E in extinguisher_list)
		if(istype(E, /obj/item/weapon/reagent_containers/spray/extinguisher/golden))
			continue
		if(prob(60))
			E.reagents.remove_reagent(E.reagent_inside, rand(200, 600), TRUE)
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
/datum/event/roundstart/PA/start()
	for(var/atom/PA in particle_accelerator_list)
		if(!prob(60))
			continue
		var/old_loc = COORD(PA)
		for(var/i in 1 to rand(3, 5))
			step(PA, pick(NORTH, SOUTH, EAST, WEST))
		message_admins("RoundStart Event: [PA] was moved from [old_loc] to [COORD(PA)]")
		log_game("RoundStart Event: [PA] was moved from [old_loc] to [COORD(PA)]")

var/global/list/tank_dispenser_list = list()
/datum/event/roundstart/tank_dispenser/start()
	for(var/obj/structure/dispenser/D in tank_dispenser_list)
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
/datum/event/roundstart/sec_equipment/start()
	for(var/obj/structure/closet/closet in sec_closets_list)
		message_admins("RoundStart Event: Random items has been removed from [closet] in [COORD(closet)]")
		for(var/obj/item/I in closet)
			if(prob(20))
				log_game("RoundStart Event: [I] was removed from [closet] in [COORD(closet)]")
				qdel(I)

/datum/event/roundstart/vending_products/start()
	for(var/obj/machinery/vending/V in machines)
		if(!prob(40))
			continue
		for(var/datum/data/vending_product/VP in V.product_records)
			if(!prob(30))
				continue
			VP.amount = rand(0, VP.amount)
			VP.price = rand(0, VP.amount**2)
			message_admins("RoundStart Event: [VP.product_name] has changed amount and price in [V] [COORD(V)].")
			log_game("RoundStart Event: [VP.product_name] has changed amount and price in [V] [COORD(V)].")

/datum/event/roundstart/apc/start()
	for(var/obj/machinery/power/apc/A in apc_list)
		if(!prob(3))
			continue
		// bluescreen
		A.emagged = TRUE
		A.locked = FALSE
		A.update_icon()
		message_admins("RoundStart Event: [A] has bluescreen in [COORD(A)].")
		log_game("RoundStart Event: [A] bluescreen in [COORD(A)].")

/datum/event/roundstart/dead_monkeys/start()
	for(var/mob/M in monkey_list)
		if(prob(20))
			message_admins("RoundStart Event: [M] was killed in [COORD(M)]")
			log_game("RoundStart Event: [M] was killed in [COORD(M)]")
			M.death()


