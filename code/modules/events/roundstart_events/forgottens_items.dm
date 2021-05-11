/datum/event/roundstart/headset/start()
	for(var/mob/living/carbon/human/H in human_list)
		if((H.l_ear || H.r_ear) && prob(10))
			var/headset_to_del = H.l_ear ? H.l_ear : H.r_ear
			qdel(headset_to_del)

/datum/event/roundstart/survbox/start()
	for(var/mob/living/carbon/human/H in human_list)
		if(!prob(10))
			continue
		var/list/boxs = H.get_all_contents_type(/obj/item/weapon/storage/box/survival)
		if(!boxs.len)
			continue
		for(var/box in boxs)
			qdel(box)

var/global/list/fueltank_list = list()
/datum/event/roundstart/fueltank/start()
	for(var/fueltank in fueltank_list)
		if(prob(10))
			qdel(fueltank)

var/global/list/watertank_list = list()
/datum/event/roundstart/watertank/start()
	for(var/watertank in watertank_list)
		if(prob(10))
			qdel(watertank)

var/global/list/cleaners_list = list()
/datum/event/roundstart/cleaner/start()
	for(var/cleaner in cleaners_list)
		if(prob(50))
			qdel(cleaner)

var/global/list/extinguisher_list = list()
/datum/event/roundstart/extinguisher/start()
	for(var/obj/item/weapon/reagent_containers/spray/extinguisher/E in extinguisher_list)
		if(istype(E, /obj/item/weapon/reagent_containers/spray/extinguisher/golden))
			continue
		if(prob(60))
			E.reagents.remove_reagent(E.reagent_inside, rand(200, 600), TRUE)
		else if(prob(30))
			if(istype(E.loc, /obj/structure/extinguisher_cabinet))
				var/obj/structure/extinguisher_cabinet/EC = E.loc
				message_admins("RoundStart Event: \"[event_meta.name]\" replace [E] in ([E.x] [E.y] [E.z]) - [ADMIN_JMP(get_turf(E))]")
				qdel(E)
				EC.update_icon()

var/global/list/PA_list = list()
/datum/event/roundstart/PA/start()
	for(var/PA in PA_list)
		if(!prob(60))
			continue
		for(var/i in 1 to rand(2, 5))
			step(PA, pick(NORTH, SOUTH, EAST, WEST))

var/global/list/tank_dispenser_list = list()
/datum/event/roundstart/tank_dispenser/start()
	for(var/obj/structure/dispenser/D in tank_dispenser_list)
		if(!prob(50))
			continue
		if(D.oxygentanks)
			for(var/i in 1 to rand(1, D.oxygentanks))
				D.oxygentanks--
		if(D.phorontanks)
			for(var/i in 1 to rand(1, D.phorontanks))
				D.phorontanks--

var/global/list/sec_closets_list = list()
/datum/event/roundstart/sec_equipment/start()
	for(var/obj/structure/closet/closet in sec_closets_list)
		for(var/obj/item/I in closet)
			if(prob(20))
				qdel(I)

/datum/event/roundstart/vending_products/start()
	for(var/obj/machinery/vending/V in machines)
		if(!prob(80))
			continue
		for(var/datum/data/vending_product/VP in V.product_records)
			VP.amount = rand(0, VP.amount)
			VP.price = rand(0, VP.amount**2)

/datum/event/roundstart/apc/start()
	for(var/obj/machinery/power/apc/A in apc_list)
		if(!prob(5))
			continue
		// bluescreen
		A.emagged = TRUE
		A.locked = FALSE
		A.update_icon()
