/datum/religion_rites/pedestals/cult
	religion_type = /datum/religion/cult


/datum/religion_rites/pedestals/cult/narsie
	name = "Призыв Нар-Си"
	desc = "Призывает древнего бога, не бойтесь пожертвовать частями тела своего друга, вам всё сочтётся."
	ritual_length = (1 MINUTE)
	invoke_msg = "Venit ad nos!"
	favor_cost = 2000

	rules = list(
		/obj/item/organ/external/r_arm = 3,
		/obj/item/organ/external/l_arm = 3,
		/obj/item/organ/external/head = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
	)

	var/need_members = 4

/datum/religion_rites/pedestals/cult/narsie/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(istype(get_area(AOG), religion.area_type))
		if(user)
			to_chat(user, "<span class='warning'>Мне нужно пространство станции.</span>")
		return FALSE

	if(religion.members.len < need_members)
		if(user)
			to_chat(user, "<span class='warning'>Слишком мало последователей.</span>")
		return FALSE

	var/datum/religion/cult/C = religion
	var/datum/game_mode/cult/cur_mode = C.mode

	if(cur_mode.eldergod)
		if(user)
			to_chat(user, "<font size='4'><span class='danger'>Я УЖЕ ЗДЕСЬ!</span></font>")
		return FALSE

	return TRUE

/datum/religion_rites/pedestals/cult/narsie/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/datum/religion/cult/C = religion
	var/datum/game_mode/cult/cur_mode = C.mode
	cur_mode.eldergod = TRUE

	new /obj/singularity/narsie/large(get_turf(AOG))
	return TRUE

/datum/religion_rites/pedestals/cult/cult_portal
	name = "Призыв Портала"
	desc = "Ваши подданные придут."
	ritual_length = (1 MINUTE)
	invoke_msg = "Venit ad nos!"
	favor_cost = 1100

	rules = list(
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/organ/external/l_leg = 1,
		/obj/item/weapon/stock_parts/scanning_module = 2,
		/obj/item/weapon/stock_parts/capacitor = 2,
		/obj/item/weapon/stock_parts/micro_laser = 2,
	)

	needed_aspects = list(
		ASPECT_SPAWN = 2,
		ASPECT_DEATH = 1
	)

/datum/religion_rites/pedestals/cult/cult_portal/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	for(var/obj/effect/rune/R in religion.runes)
		if(istype(R.power, /datum/rune/cult/portal_beacon))
			return TRUE

	if(user)
		to_chat(user, "<span class='warning'>Сначало разместите руну-маяк.</span>")
	return FALSE

/datum/religion_rites/pedestals/cult/cult_portal/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/spawned = FALSE
	for(var/obj/effect/rune/R in religion.runes)
		if(istype(R.power, /datum/rune/cult/portal_beacon))
			new /obj/effect/anomaly/bluespace/cult_portal(R.loc, TRUE)
			qdel(R)
			spawned = TRUE
	if(spawned)
		return TRUE
	return FALSE

/datum/religion_rites/pedestals/cult/make_skeleton
	name = "Скелетофикация"
	desc = "Превращает человека на алтаре в бессмертного скелета."
	ritual_length = (30 SECONDS)
	invoke_msg = "Venit ad nos!"
	favor_cost = 200

	rules = list(
		/obj/item/organ/external/r_arm = 1,
		/obj/item/organ/external/l_arm = 1,
		/obj/item/organ/external/l_leg = 1,
		/obj/item/organ/external/r_leg = 1,
	)

	needed_aspects = list(
		ASPECT_SPAWN = 2,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/pedestals/cult/make_skeleton/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		if(user)
			to_chat(user, "<span class='warning'>На алтаре должен быть человек.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/pedestals/cult/make_skeleton/invoke_effect(mob/living/user, obj/AOG)
	. = ..()

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!H || !ishuman(H))
		to_chat(user, "<span class='warning'>На алтаре должен быть человек.</span>")
		return FALSE

	var/datum/effect/effect/system/smoke_spread/chem/S = new
	AOG.create_reagents(1)
	AOG.reagents.add_reagent("blood", 1)
	S.set_up(AOG.reagents, 5, 0, get_turf(AOG))
	S.attach(get_turf(AOG))
	S.color = "#db0101"
	S.start()

	H.set_species(SKELETON)
	H.revive()
	H.visible_message("<span class='warning'>После того, как дым развеялся, на алтаре виден скелет человека.</span>",
					"<span class='cult'>Вы чувствуете, как с вас буквально содрали всю кожу, хотя у тебя теперь нет и нервов.</span>")
	var/datum/religion/cult/C = religion
	C.mode.add_cultist(H.mind)
	H.regenerate_icons()

	return TRUE
