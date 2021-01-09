/datum/religion_rites/instant/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/cult/sacrifice
	name = "Sacrifice"
	desc = "Soul for the ancient gods."
	ritual_length = (5 SECONDS)
	invoke_msg = "Для моих богов!!"
	favor_cost = 50

/datum/religion_rites/instant/cult/sacrifice/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		return TRUE
	else if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только человек может пройти через ритуал.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/cult/sacrifice/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/datum/religion/cult/R = religion
	var/datum/mind/sacrifice_target = R.mode.sacrifice_target

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		S.dust()
		R.mode.sacrificed += S.mind
		if(sacrifice_target && sacrifice_target == S.mind)
			to_chat(user, "<span class='cult'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>")
			R.adjust_favor(300)
	else if(ishuman(AOG.buckled_mob))
		AOG.buckled_mob.gib()
		R.mode.sacrificed += AOG.buckled_mob.mind
		if(sacrifice_target && sacrifice_target == AOG.buckled_mob.mind)
			to_chat(user, "<span class='cult'>The Geometer of Blood accepts this sacrifice, your objective is now complete.</span>")
			R.adjust_favor(300)

	R.adjust_favor(calc_sacrifice_favor(AOG.buckled_mob))

	playsound(AOG, 'sound/magic/disintegrate.ogg', VOL_EFFECTS_MASTER)

/datum/religion_rites/instant/cult/sacrifice/proc/calc_sacrifice_favor(mob/living/L)
	if(!istype(L))
		return 0

	var/sacrifice_favor = 0
	if(isanimal(L))
		sacrifice_favor += 100
	else if(ismonkey(L))
		sacrifice_favor += 150
	else if(ishuman(L) && L.mind && L.ckey)
		sacrifice_favor += 350
	else
		sacrifice_favor += 200

	if(L.stat == DEAD)
		sacrifice_favor *= 0.5
	if(!L.ckey)
		sacrifice_favor  *= 0.5

	return sacrifice_favor

/datum/religion_rites/instant/cult/convert
	name = "Convert"
	desc = "The best brainwashing in the galaxy!"
	ritual_length = (5 SECONDS)
	invoke_msg = "Служи ему!!!"
	favor_cost = 100

/datum/religion_rites/instant/cult/convert/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только человек может пройти через ритуал.</span>")
		return FALSE

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(religion.is_member(H) || H.stat == DEAD || H.species.flags[NO_BLOOD])
		to_chat(user, "<span class='warning'>Неподходящее тело.</span>")
		return FALSE
	if(!global.cult_religion.mode.is_convertable_to_cult(H.mind))
		to_chat(user, "<span class='warning'>Разум тела сопротивляется.</span>")
		return FALSE
	if(jobban_isbanned(H, ROLE_CULTIST))
		to_chat(user, "<span class='warning'>Ему не нужно такое тело.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/convert/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/datum/religion/cult/cult = religion
	cult.mode.add_cultist(AOG.buckled_mob.mind)
	AOG.buckled_mob.mind.special_role = "Cultist"
	to_chat(AOG.buckled_mob, "<span class='cult'>Помогай другим культистам в тёмных делах. Их цель - твоя цель, а твоя - их. Вы вместе служите Тьме и тёмным богам.</span>")
	religion.adjust_favor(300)
