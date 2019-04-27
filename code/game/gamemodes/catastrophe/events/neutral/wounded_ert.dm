/datum/catastrophe_event/wounded_ert
	name = "Wounded ERT"

	one_time_event = TRUE

	weight = 100

	event_type = "neutral"
	steps = 1

	var/turf/shuttle_turf
	var/found_commander = FALSE

/datum/catastrophe_event/wounded_ert/on_step()
	switch(step)
		if(1)
			var/turf/T = find_spot()
			if(!T)
				return
			shuttle_turf = T

			var/datum/map_template/wounded_ert_shuttle/temp = new /datum/map_template/wounded_ert_shuttle()
			temp.load(T, centered = TRUE)

			announce("Исход, один из наших отр[JA_PLACEHOLDER]дов быстрого реагировани[JA_PLACEHOLDER] возвращаетс[JA_PLACEHOLDER] с задани[JA_PLACEHOLDER] и в данный момент пролетает р[JA_PLACEHOLDER]дом с вашей станцией. Они сильно ранены и хотели бы остановитьс[JA_PLACEHOLDER] у вас, помогите им, чем сможете.")
			message_admins("ERT shuttle was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")

			director.start_ghost_join_event("Wounded ERT", list("ERT"), CALLBACK(src, .proc/spawn_ert))

/datum/catastrophe_event/wounded_ert/proc/spawn_ert(list/joined)
	var/list/players = joined["ERT"]

	var/max_ert = 6
	var/turf/T = get_step(get_step(shuttle_turf, WEST), WEST) // Move 2 turfs to the left so we can fit everyone
	var/loc_text = ""
	if(T.y > 141)
		loc_text = "south-"
	else
		loc_text = "north-"

	if(T.x < 119)
		loc_text += "east"
	else
		loc_text += "west"

	while(max_ert)
		max_ert -= 1

		var/mob/dead/observer/G
		if(players.len)
			G = pick(players)
			players -= G

		var/mob/living/carbon/human/H = new /mob/living/carbon/human(T)
		equip_ert(H, G)
		T = get_step(T, EAST)

		if(G)
			H.key = G.key
		else
			H.death(0) // Couldnt find a player, just spawn a dead guy

		for (var/i in 1 to rand(4,5))
			if(prob(40))
				H.adjustBruteLoss(rand(18,22))
			else if(prob(50))
				H.adjustFireLoss(rand(18,22))
			else
				H.adjustToxLoss(rand(18,22))

		to_chat(H, "<span class='notice'>The station is to [loc_text] from your location</span>")

/datum/catastrophe_event/wounded_ert/proc/equip_ert(mob/living/carbon/human/H, mob/dead/observer/G)
	H.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()
	A.randomize_appearance_for(H)

	H.age = rand(35,45)

	var/commando_rank = pick("Lieutenant", "Captain", "Major", "Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/commando_name = pick(last_names)
	H.real_name = "[commando_rank] [commando_name]"
	H.dna.ready_dna(H)//Creates DNA.

	H.mind = new
	H.mind.current = H
	H.mind.original = H
	H.mind.assigned_role = "MODE"
	H.mind.special_role = "Response Team"
	if(!(H.mind in ticker.minds))
		ticker.minds += H.mind//Adds them to regular mind list.

	//Special radio setup
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/ert(H), SLOT_L_EAR)

	//Replaced with new ERT uniform
	H.equip_to_slot_or_del(new /obj/item/clothing/under/ert(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), SLOT_GLASSES)

	if(!found_commander)
		found_commander = TRUE
		var/obj/item/weapon/card/id/ert/W = new(H)
		W.assignment = "Emergency Response Team Leader"
		W.rank = "Emergency Response Team Leader"
		W.registered_name = H.real_name
		W.name = "[H.real_name]'s ID Card ([W.assignment])"
		W.icon_state = "ert-leader"
		H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

		H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/commander(H), SLOT_WEAR_SUIT)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/commander(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/commander(H), SLOT_BACK)
	else
		var/obj/item/weapon/card/id/ert/W = new(H)
		W.assignment = "Emergency Response Team"
		W.rank = "Emergency Response Team"
		W.registered_name = H.real_name
		W.name = "[H.real_name]'s ID Card ([W.assignment])"
		W.icon_state = "ert"
		H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

		var/list/ert_types = list("combat", "medic", "eng")
		var/ert_type = pick(ert_types)
		switch(ert_type)
			if("combat")
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/security(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/security(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/security(H), SLOT_BACK)
			if("medic")
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/medical(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/medical(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/medical(H), SLOT_BACK)
			if("eng")
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/ert/engineer(H), SLOT_WEAR_SUIT)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/ert/engineer(H), SLOT_HEAD)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
				H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/ert/engineer(H), SLOT_BACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), SLOT_IN_BACKPACK)
	if(prob(30)) // You might get an energy gun or just a pistol
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/nuclear(H), SLOT_BELT)
	else
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/sigi/spec(H), SLOT_BELT)
		for (var/i in 1 to rand(0,2))
			H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m9mmr_2(H), SLOT_IN_BACKPACK)

	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	L.inject(H)
	START_PROCESSING(SSobj, L)


	H.internal = H.s_store

/datum/catastrophe_event/wounded_ert/proc/find_spot()
	var/try_count = 0
	while(try_count < 30)
		try_count += 1

		var/turf/space/T = locate(rand(40, world.maxx - 40), rand(40, world.maxy - 40), ZLEVEL_STATION)
		if(!istype(T))
			continue

		var/good = TRUE
		for(var/turf/simulated/G in orange(10, T))
			good = FALSE
			break
		if(good)
			return T
	return null

/datum/map_template/wounded_ert_shuttle
	name = "Wounded Ert Shuttle"
	mappath = "maps/templates/catastrophe/wounded_ert_shuttle.dmm"
