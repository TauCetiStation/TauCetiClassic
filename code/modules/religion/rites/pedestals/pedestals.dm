/datum/religion_rites/pedestals/cult
	religion_type = /datum/religion/cult


/datum/religion_rites/pedestals/cult/narsie
	name = "Призыв Нар-Си"
	desc = "Призывает древнего бога, не бойтесь пожертвовать частями тела своего друга, вам всё сочтётся."
	ritual_length = (2 MINUTE)
	invoke_msg = "Venit ad nos!"
	favor_cost = 2000

	rules = list(
		/obj/item/organ/external/r_arm = 3,
		/obj/item/organ/external/l_arm = 3,
		/obj/item/organ/external/head = 3,
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = 1,
	)

	var/need_members = 4

/datum/religion_rites/pedestals/cult/narsie/proc/checks(mob/user, obj/structure/altar_of_gods/AOG)
	if(istype(get_area(AOG), religion.area_type))
		if(user)
			to_chat(user, "<span class='warning'>Мне нужно пространство станции.</span>")
		return FALSE

	if(religion.members.len < need_members)
		if(user)
			to_chat(user, "<span class='warning'>Слишком мало последователей.</span>")
		return FALSE

	var/cultists_around = 0
	for(var/mob/M as anything in AOG.get_members_around())
		if(M.get_species() != HOMUNCULUS)
			cultists_around++
	if(cultists_around < need_members)
		if(user)
			to_chat(user, "<span class='warning'>Недостаточно последователей вокруг алтаря.</span>")
		return FALSE

	if(SSticker.nar_sie_has_risen)
		if(user)
			to_chat(user, "<span class='danger big'>Я УЖЕ ЗДЕСЬ!</span>")
		return FALSE
	return TRUE

/datum/religion_rites/pedestals/cult/narsie/on_chosen(mob/user, obj/structure/altar_of_gods/AOG)
	. = ..()

	if(!checks(user, AOG))
		return FALSE

	var/datum/faction/cult/C = cult_religion.mode
	var/datum/objective/target/sacrifice/O = C.objective_holder.FindObjective(/datum/objective/target/sacrifice)
	if(O)
		if(O.check_completion() != OBJECTIVE_WIN)
			to_chat(user, "<span class='cult'>Жертвоприношение не было проведено! Порталу не хватит мощи на раскрытие, если вы попытаетесь провести ритуал!</span>")
			return FALSE

	var/datum/objective/cult/summon_narsie/S = C.objective_holder.FindObjective(/datum/objective/cult/summon_narsie)
	if(!S)
		to_chat(user, "<span class='cult big'>Я НЕ ЖЕЛАЮ К ВАМ ПРИХОДИТЬ!</span>")
		return FALSE

	var/confirm_final = tgui_alert(user, "Это ФИНАЛЬНЫЙ шаг к призыву Нар'Си; это очень долгий и сложный ритуал, а также экипаж определённо узнает о вашей попытке призыва", "Вы готовы к последнему бою?", list("Моя жизнь за Нар'Си!", "Нет"))
	if(confirm_final == "Нет")
		to_chat(user, "<span class='cult'>Вы решили подготовиться перед началом ритуала</span>")
		return FALSE

	addtimer(CALLBACK(src, PROC_REF(announce_summon), user), 15 SECONDS)

	return TRUE

/datum/religion_rites/pedestals/cult/narsie/proc/announce_summon(mob/user)
	var/datum/announcement/centcomm/narsie_summon/A = new(user)
	A.play()

/datum/religion_rites/pedestals/cult/narsie/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE
	if(!checks(user, AOG))
		return FALSE
	return TRUE

/datum/religion_rites/pedestals/cult/narsie/invoke_effect(mob/user, obj/structure/altar_of_gods/AOG)
	..()
	SSticker.nar_sie_has_risen = TRUE

// I'm commenting this out in favor of the new lighting effect
// this sound is terrible and does more harm than good for the atmosphere
// if no one is against it in the future - delete comment and the ogg file
//	for(var/mob/M in player_list)
//		if(!isnewplayer(M))
//			M.playsound_local(null, 'sound/effects/dimensional_rend.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

	// probably should be white list or something, maybe check by linkage?
	for(var/Z in SSmapping.levels_not_having_any_trait(list(ZTRAIT_CENTCOM, ZTRAIT_JUNKYARD)))
		var/datum/space_level/SL = SSmapping.get_level(Z)
		SL.set_level_light(new /datum/level_lighting_effect/narsie)

	addtimer(CALLBACK(src, PROC_REF(summon), get_turf(AOG)), 30 SECONDS)
	return TRUE

/datum/religion_rites/pedestals/cult/narsie/proc/summon(turf/T)
	new /obj/singularity/narsie(T, religion)
	global.cult_religion.eminence.start_process()

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

/datum/religion_rites/pedestals/cult/cult_portal/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE

	for(var/obj/effect/rune/R in religion.runes)
		if(istype(R.power, /datum/rune/cult/portal_beacon))
			return TRUE

	if(user)
		to_chat(user, "<span class='warning'>Сначала разместите руну-маяк.</span>")
	return FALSE

/datum/religion_rites/pedestals/cult/cult_portal/invoke_effect(mob/user, obj/structure/altar_of_gods/AOG)
	..()
	for(var/obj/effect/rune/R in religion.runes)
		if(istype(R.power, /datum/rune/cult/portal_beacon))
			new /obj/effect/anomaly/bluespace/cult_portal(R.loc, TRUE)
			qdel(R)
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

/datum/religion_rites/pedestals/cult/make_skeleton/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		if(user)
			to_chat(user, "<span class='warning'>На алтаре должен быть человек.</span>")
		return FALSE

	if(AOG.buckled_mob.get_species() == HOMUNCULUS)
		if(user)
			to_chat(user, "<span class='warning'>Тело гомункула слишком слабо.</span>")
		return FALSE

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(H.species.flags[NO_BLOOD] || jobban_isbanned(H, ROLE_CULTIST) || jobban_isbanned(H, "Syndicate") || H.ismindprotect())
		if(user)
			to_chat(user, "<span class='warning'>Неподходящее существо.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/pedestals/cult/make_skeleton/invoke_effect(mob/user, obj/structure/altar_of_gods/AOG)
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

	religion.add_member(H, CULT_ROLE_HIGHPRIEST)

	H.makeSkeleton()
	H.revive()
	H.visible_message("<span class='warning'>После того, как дым развеялся, на алтаре виден скелет человека.</span>",
					"<span class='cult'>Вы чувствуете, как с вас буквально содрали всю кожу, хотя у тебя теперь нет и нервов.</span>")
	H.regenerate_icons()

	return TRUE
