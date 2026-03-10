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

/datum/religion_rites/pedestals/cult/cult_portal/proc/spawn_type(turf/T)
	new /obj/effect/anomaly/bluespace/cult_portal(T, TRUE)

/datum/religion_rites/pedestals/cult/cult_portal/invoke_effect(mob/user, obj/structure/altar_of_gods/AOG)
	..()
	for(var/obj/effect/rune/R in religion.runes)
		if(istype(R.power, /datum/rune/cult/portal_beacon))
			spawn_type(get_turf(R.loc))
			qdel(R)
			return TRUE
	return FALSE


/datum/religion_rites/pedestals/cult/cult_portal/rift
	name = "Создание Разлома"
	desc = "Вуаль реальности треснет."
	invoke_msg = "Veni ad nos!"
	favor_cost = 500

	rules = list(
		/obj/item/organ/external/head = 1,
		/obj/item/organ/external/l_leg = 1,
		/obj/item/organ/external/r_leg = 1,
	)
	var/need_members = 2 //No to solo-griefing

	needed_aspects = list(
		ASPECT_MYSTIC = 2,
		ASPECT_CHAOS = 1
	)

/datum/religion_rites/pedestals/cult/cult_portal/rift/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	var/cultists_around = 0
	for(var/mob/M as anything in AOG.get_members_around())
		if(M.get_species() != HOMUNCULUS)
			cultists_around++
	if(cultists_around < need_members)
		if(user)
			to_chat(user, "<span class='warning'>Недостаточно последователей вокруг алтаря.</span>")
		return FALSE

/datum/religion_rites/pedestals/cult/cult_portal/rift/spawn_type(turf/T)
	new /obj/effect/portal/rift/stable(T)

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
	if(HAS_TRAIT(H, TRAIT_NO_BLOOD) || jobban_isbanned(H, ROLE_CULTIST) || jobban_isbanned(H, "Syndicate") || ismindprotect(H))
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

/datum/religion_rites/pedestals/cult/artifact
	name = "Призыв артефакта"
	desc = "Выковывает из знака власти артефакт и наделяет силой одного из 7 грехов и благодатей"
	ritual_length = (10 SECONDS)
	invoke_msg = "Venit ad nos!"
	favor_cost = 1000
	var/static/list/possible_sacrifices = list(
		/obj/item/clothing/suit/armor/hos = /obj/item/clothing/gloves/rage,
		/obj/item/clothing/suit/armor/vest/reactive = /obj/item/clothing/neck/envy,
		/obj/item/weapon/reagent_containers/hypospray = /obj/item/weapon/storage/belt/gluttony,
		/obj/item/clothing/suit/space/rig/engineering/chief = /obj/item/clothing/suit/space/pride,
		/obj/item/weapon/gun/energy/laser/selfcharging/captain = /obj/item/clothing/head/helmet/greed,
		/obj/item/clothing/under/rank/head_of_personnel = /obj/item/clothing/shoes/sadness,
		/obj/item/weapon/banhammer = /obj/item/weapon/banhammer/lust
		)

	rules = list(
		/obj/item/organ/external/head = 1,
		/obj/item/blood_gem = 2,
		/obj/item/weapon/nullrod = 1,
	)

	needed_aspects = list(
		ASPECT_WEAPON = 2,
		ASPECT_GREED = 2,
		ASPECT_TECH = 1,
	)

/datum/religion_rites/pedestals/cult/artifact/can_start(mob/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE
	var/turf/T = get_turf(AOG)

	var/datum/religion/cult/R = religion
	if(length(R.rifts) - 1 < R.artifacts)
		to_chat(user, "<span class='warning'>Реальность не выдержит ещё один артефакт! Нужно больше Разломов!/span>")
		return FALSE
	var/found = FALSE
	for(var/obj/item/I in T.contents)
		if(is_type_in_list(I, possible_sacrifices))
			found = TRUE
			break
	if(!found)
		to_chat(user, "<span class='warning'>На алтаре должен быть один из символов власти!/span>")
		return FALSE
	return TRUE

/datum/religion_rites/pedestals/cult/artifact/invoke_effect(mob/user, obj/AOG)
	. = ..()
	var/turf/T = get_turf(AOG)
	for(var/obj/item/I in T.contents)
		var/art = possible_sacrifices[I.type]
		if(is_type_in_list(I, possible_sacrifices))
			cult_religion.artifacts += new art (get_turf(AOG))
			break

/datum/religion_rites/pedestals/cult/surgery_gem
	name = "Хирургический стол"
	desc = "Вселяет в осколок дух, который можно поставить на хирургический стол, что бы тот лечил культистов."
	ritual_length = (18 SECONDS)
	invoke_msg = "Et curaba te!"
	favor_cost = 750

	rules = list(
		/obj/item/weapon/scalpel,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/circular_saw,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/cautery,
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
	)

	needed_aspects = list(
		ASPECT_RESCUE = 2,
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/pedestals/cult/surgery_gem/invoke_effect(mob/user, obj/AOG)
	. = ..()
	new /obj/item/surgery_gem (get_turf(AOG))

/datum/religion_rites/pedestals/cult/void_cloak
	name = "Плащ пустоты"
	desc = "Создаёт плащ, полностью одетый который незаметен ни для глаза, ни на ощупь. Имеет неплохие защитные свойства. Украденное знание другой реальности."
	ritual_length = (5 SECONDS)
	invoke_msg = "qua via discessit!"
	favor_cost = 300

	rules = list(
		/obj/item/weapon/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/weapon/bedsheet = 1
	)

	needed_aspects = list(
		ASPECT_WEAPON = 1,
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/pedestals/cult/void_cloak/invoke_effect(mob/user, obj/AOG)
	. = ..()
	new /obj/item/clothing/suit/hooded/cultrobes/void (get_turf(AOG))

/datum/religion_rites/pedestals/cult/shadow_belt
	name = "Пояс тени"
	desc = "Создаёт пояс, при надевании которого появляется возможность прятаться в тени. Пока находишься в темноте, заряд не тратится. Украденное знание другой реальности."
	ritual_length = (5 SECONDS)
	invoke_msg = "umbra amicus!"
	favor_cost = 300

	rules = list(
		/obj/item/weapon/storage/belt = 1,
		/obj/item/blood_gem = 1,
		/obj/item/weapon/nullrod = 1
	)

	needed_aspects = list(
		ASPECT_WEAPON = 1,
		ASPECT_OBSCURE = 2,
	)

/datum/religion_rites/pedestals/cult/shadow_belt/invoke_effect(mob/user, obj/AOG)
	. = ..()
	new /obj/item/shadowcloak/weaker (get_turf(AOG))

//Not sure how much this thing is balanced, so probably will comment it out
/datum/religion_rites/pedestals/cult/darkness_cloak
	name = "Пояс Тьмы"
	desc = "Создаёт пояс Тьмы, который позволяет стать невидимым во тьме. Пока находишься в темноте, заряд не тратится, после выхода на свет, начинает тратить заряд. Украденное знание другой реальности."
	ritual_length = (25 SECONDS)
	invoke_msg = "tenebris hie ego!"
	favor_cost = 1000

	rules = list(
		/obj/item/shadowcloak/weaker = 1,
		/obj/item/blood_gem = 2,
		/obj/item/organ/external/head = 1
	)

	needed_aspects = list(
		ASPECT_WEAPON = 2,
		ASPECT_OBSCURE = 5,
		ASPECT_TECH = 3
	)

/datum/religion_rites/pedestals/cult/darkness_cloak/invoke_effect(mob/user, obj/AOG)
	. = ..()
	new /obj/item/shadowcloak (get_turf(AOG))

//Creates item that acts as a spwner for gomunculs
/datum/religion_rites/pedestals/cult/darkness_cloak
	name = "Пояс Тьмы"
	desc = "Создаёт пояс Тьмы, который позволяет стать невидимым во тьме. Пока находишься в темноте, заряд не тратится, после выхода на свет, начинает тратить заряд. Украденное знание другой реальности."
	ritual_length = (25 SECONDS)
	invoke_msg = "tenebris hie ego!"
	favor_cost = 1000

	rules = list(
		/obj/item/shadowcloak/weaker = 1,
		/obj/item/blood_gem = 2,
		/obj/item/organ/external/head = 1
	)

	needed_aspects = list(
		ASPECT_WEAPON = 2,
		ASPECT_OBSCURE = 5,
		ASPECT_TECH = 3
	)

/datum/religion_rites/pedestals/cult/darkness_cloak/invoke_effect(mob/user, obj/AOG)
	. = ..()
	new /obj/item/shadowcloak (get_turf(AOG))
