/datum/catastrophe_event/war
	name = "War"

	one_time_event = TRUE

	weight = 100

	event_type = "neutral"
	steps = 3

	var/list/enemy_types = list("pirates", "nukers", "elite-syndicate", "mages", "ninjas")
	var/west_side
	var/east_side
	var/list/company_names = list("SolGov", "Эйнштейн Энджинс", "Вэй Мед", "BioTech Solutions", "Cybersun Industries")

	event_duration_min = 0.5 // so worst case is ~20 mins for 3 announces which is ok
	event_duration_max = 0.5
	event_min_space_required = 0.5 // only in the first part of the round

/datum/catastrophe_event/war/on_step()
	switch(step)
		if(1)
			var/company1 = pick(company_names)
			var/company2 = pick(company_names - company1)

			announce("…К политическим новост[JA_PLACEHOLDER]м. Сегодн[JA_PLACEHOLDER] между [company1] и [company2] произошел конфликт на почве [pick("гуманности кибернизации преступников", "легальности колонизации зан[JA_PLACEHOLDER]тых планет ради ресурсов", "вреда телепортировани[JA_PLACEHOLDER] дл[JA_PLACEHOLDER] пространства-времени", "того, можно ли использовать технологию клонировани[JA_PLACEHOLDER] как средство против старени[JA_PLACEHOLDER]")]. Дебаты вскоре переросли в жаркий спор. Спикеры с обеих сторон перешли на резкие слова и обвинени[JA_PLACEHOLDER] в адрес оппонента. Мы будем следить за развитием событий.", "--=Galaxy News=--")
		if(2)
			announce("С вами Джонни Доэ, и это Галактические Новости. Кажетс[JA_PLACEHOLDER] конфликт, который началс[JA_PLACEHOLDER] сегодн[JA_PLACEHOLDER] утром между представител[JA_PLACEHOLDER]ми мегакорпораций так и не желает прекращатьс[JA_PLACEHOLDER]. Наши источники сообщают, что обе стороны мобилизуют внутренние силы обороны. Надеемс[JA_PLACEHOLDER], что конфликт всё же будет решён мирно и стороны сойдутс[JA_PLACEHOLDER] к единому мнению.", "--=Galaxy News=--")
		if(3)
			announce("С вами Джонни Доэ, и это Галактические Новости. В системе Тау Кита разгорелс[JA_PLACEHOLDER] вооруженный конфликт между двум[JA_PLACEHOLDER] мегакорпораци[JA_PLACEHOLDER]ми. По информации от наших источников, в бо[JA_PLACEHOLDER]х так же принимают участие частные военные компании и группы наемников! Научна[JA_PLACEHOLDER] мирова[JA_PLACEHOLDER] общественность в ужасе, так как на рассто[JA_PLACEHOLDER]нии гиперпрыжка места боев сейчас находитс[JA_PLACEHOLDER] передова[JA_PLACEHOLDER] исследовательска[JA_PLACEHOLDER] станци[JA_PLACEHOLDER] корпорации Нанотрейзен. Наши источники сообщают, что на станции находитс[JA_PLACEHOLDER] её экипаж, который не подозревает о том, что место их работы может стать полем бо[JA_PLACEHOLDER]. Нанотрейзен комментариев по поводу ситуации не дает.", "--=Galaxy News=--")

			west_side = pick(enemy_types)
			east_side = pick(enemy_types - west_side)

			director.start_ghost_join_event("[west_side] vs [east_side] battle", list(west_side, east_side), CALLBACK(src, .proc/start_war))

/datum/catastrophe_event/war/proc/start_war(list/joined)
	spawn_side(joined[west_side], locate(23, 141, ZLEVEL_STATION), west_side)
	spawn_side(joined[east_side], locate(211, 141, ZLEVEL_STATION), east_side)


/datum/catastrophe_event/war/proc/spawn_side(list/players, turf/T, side_type)
	var/max_players = 6
	if(side_type == "mages")
		max_players = 3
	if(side_type == "ninjas")
		max_players = 2

	while(max_players > 0 && players.len > 0)
		var/mob/dead/observer/G = pick(players)
		max_players -= 1
		players -= G

		var/mob/living/carbon/human/H = new /mob/living/carbon/human(T)
		random_appearance(H)

		switch(side_type)
			if("pirates")
				equip_pirate(H)
			if("nukers")
				equip_nuker(H)
			if("elite-syndicate")
				equip_elitesyndicate(H)
			if("mages")
				equip_mage(H)
			if("ninjas")
				equip_ninja(H)

		H.key = G.key

		say_objectives(H)

		T = get_step(T, NORTH)

/datum/catastrophe_event/war/proc/say_objectives(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning big'>You are <b>neutral</b> to the station crew</span>")

	to_chat(H, "<B>Objective #1</B>: Kill or capture every mercenary that the opposite side sent")
	to_chat(H, "<B>Objective #2</B>: Survive until the end")

	if(H.x < 100)
		to_chat(H, "<span class='notice'>The station is to your east (&gt;)</span>")
	else
		to_chat(H, "<span class='notice'>The station is to your west (&lt;)</span>")

/datum/catastrophe_event/war/proc/random_appearance(mob/living/carbon/human/H)
	H.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()
	A.randomize_appearance_for(H)

	H.age = rand(23,45)

/datum/catastrophe_event/war/proc/equip_pirate(mob/living/carbon/human/H)
	var/newname = pick(list("Creeper ","Jim ","Storm ","John ","George ","O` ","Rat ","Jack ","Legs ",
		"Head ","Cackle ","Patch ","Bones ","Plank ","Greedy ","Space ","Mama ","Spike ",
		"Squiffy ","Gold ","Yellow ","Felony ","Eddie ","Bay ","Thomas ","Spot "))
	newname += pick(list("From the West","Byrd","Jackson","Sparrow","Of the Coast","Jones","Ned Head","Bart","O`Carp",
		"Kidd","O`Malley","Barnacle","Holystone","Hornswaggle","McStinky","Swashbuckler","Space Wolf","Beard",
		"Chumbucket","Rivers","Morgan","Tuna Breath","Three Gates","Bailey","Of Atlantis","Of Dark Space"))
	H.real_name = newname
	H.dna.ready_dna(H)//Creates DNA.

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(H)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	H.equip_to_slot_or_del(R, SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/globose/black/pirate(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/globose/black/pirate(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(H), SLOT_S_STORE)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/small_firstaid_kit/space(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/silenced/nonlethal(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m556/nonlethal(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m556/nonlethal(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/sm45/nonlethal(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/sm45/nonlethal(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/a28/nonlethal(H), SLOT_BELT)

	var/obj/item/weapon/card/id/syndicate/C = new(H)
	C.name = "[H.real_name]'s Legitimate Human ID Card"
	C.icon_state = "id"
	C.access = list(access_syndicate)
	C.assignment = "Pirate"
	C.registered_name = H.real_name
	C.registered_user = H
	var/obj/item/weapon/storage/wallet/W = new(H)
	W.handle_item_insertion(C)
	H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	H.internal = H.s_store
	//H.internals.icon_state = "internal1" // this doesnt work

/datum/catastrophe_event/war/proc/equip_ninja(mob/living/carbon/human/H)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	H.real_name = "[ninja_title] [ninja_name]"
	H.dna.ready_dna(H)//Creates DNA.
	H.create_mind_space_ninja()

	H.equip_space_ninja()
	H.wear_suit:randomize_param()

	H.internal = H.s_store

/datum/catastrophe_event/war/proc/equip_mage(mob/living/carbon/human/H)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	H.real_name = "[wizard_name_first] [wizard_name_second]"
	H.dna.ready_dna(H)//Creates DNA.

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/wizard(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/wizard(H), SLOT_HEAD)

	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(H), SLOT_S_STORE)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(H), SLOT_R_STORE)

	var/obj/item/weapon/storage/wallet/W = new(H)
	H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	addtimer(CALLBACK(src, .proc/give_spells, H), 10)

	H.internal = H.s_store

/datum/catastrophe_event/war/proc/give_spells(mob/living/carbon/human/H)
	var/list/wizard_classes = list("angry", "healy", "smartly", "mobily")
	var/selected_class = pick(wizard_classes)
	switch(selected_class)
		if("angry")
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/fireball())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/arcane_barrage())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/genetic/mutate())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal())
		if("healy")
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/arcane_barrage())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/res_touch())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport())
		if("smartly")
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/tesla())
			H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall())
			H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal())
		if("mobily")
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/fireball())
			H.AddSpell(new /obj/effect/proc_holder/spell/in_hand/heal())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/spacetime_dist())
			H.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/repulse())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink())
			H.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt())

/datum/catastrophe_event/war/proc/equip_elitesyndicate(mob/living/carbon/human/H)
	var/syndicate_commando_rank = pick("Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/syndicate_commando_name = pick(last_names)
	H.real_name = "[syndicate_commando_rank] [syndicate_commando_name]"
	H.dna.ready_dna(H)//Creates DNA.

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(H)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	H.equip_to_slot_or_del(R, SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/syndicate/elite(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/syndicate/elite(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(H), SLOT_GLASSES)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/sm45(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/grenade/empgrenade(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/silenced(H), SLOT_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(H), SLOT_IN_BACKPACK)

	var/obj/item/weapon/card/id/syndicate/W = new(H) //Untrackable by AI
	W.name = "[H.real_name]'s ID Card"
	W.icon_state = "id"
	//W.access = get_all_accesses()//They get full station access because obviously the syndicate has HAAAX, and can make special IDs for their most elite members.
	//W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage, access_syndicate)//Let's add their forged CentCom access and syndicate access.
	W.assignment = "Syndicate Commando"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	H.internal = H.s_store

/datum/catastrophe_event/war/proc/equip_nuker(mob/living/carbon/human/H)
	var/newname = "[H.gender==FEMALE?pick(first_names_female):pick(first_names_male)] [pick(last_names)]"
	if(prob(30))
		newname = pick(clown_names)
	H.real_name = newname
	H.dna.ready_dna(H)//Creates DNA.

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(H)
	R.set_frequency(SYND_FREQ) //Same frequency as the syndicate team in Nuke mode.
	H.equip_to_slot_or_del(R, SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), SLOT_W_UNIFORM)
	//H.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/syndi(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndi(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/card/emag(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen/double(H), SLOT_S_STORE)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/small_firstaid_kit/civilian(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)
	//H.equip_to_slot_or_del(new /obj/item/weapon/card/emag(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m12mm(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_box/magazine/m12mm(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/c20r(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/jetpack/oxygen/harness(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/crowbar(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/military(H), SLOT_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/card/id/syndicate/nuker(H), SLOT_WEAR_ID)

	H.internal = H.s_store

	var/obj/item/weapon/implant/dexplosive/E = new/obj/item/weapon/implant/dexplosive(H)
	E.imp_in = H
	E.implanted = 1

// These die in space :x
/datum/catastrophe_event/war/proc/equip_deathsquad(mob/living/carbon/human/H)
	var/commando_rank = pick("Lieutenant", "Captain", "Major", "Corporal", "Sergeant", "Staff Sergeant", "Sergeant 1st Class", "Master Sergeant", "Sergeant Major")
	var/commando_name = pick(last_names)
	H.real_name = "[commando_rank] [commando_name]"
	H.dna.ready_dna(H)//Creates DNA.

	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/deathsquad(H), SLOT_L_EAR)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), SLOT_W_UNIFORM)

	var/obj/item/weapon/card/id/W = new(H)
	W.name = "[H.real_name]'s ID Card"
	W.icon_state = "centcom"
	W.access = get_all_accesses()//They get full station access.
	W.access += list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)//Let's add their alloted CentCom access.
	W.assignment = "Death Commando"
	W.registered_name = H.real_name
	H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/swat(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/swat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/swat(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(H), SLOT_GLASSES)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_box/a357(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/flashbangs(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/plastique(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/grenade/flashbang(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/tank/emergency_oxygen(H), SLOT_S_STORE)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(H), SLOT_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(H), SLOT_R_HAND)

	H.internal = H.s_store
	H.internals.icon_state = "internal1"

	var/obj/item/weapon/implant/mindshield/loyalty/L = new(H)
	L.inject(H)
	START_PROCESSING(SSobj, L)