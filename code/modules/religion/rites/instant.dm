
/datum/religion_rites/instant/sacrifice
	name = "Sacrifice"
	desc = "Soul for the ancient gods."
	ritual_length = (5 SECONDS)
	invoke_msg = "For my gods!!"
	favor_cost = 50

/datum/religion_rites/instant/sacrifice/can_start(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!..())
		return FALSE

	var/mob/living/silicon/S = locate() in AOG.loc
	if(S)
		return TRUE
	else if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a human can go through the ritual.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/sacrifice/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	..()
	var/datum/religion/cult/R = religion
	var/datum/mind/sacrifice_target = R.mode.sacrifice_target

	var/mob/living/silicon/S = locate() in AOG.loc
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

/datum/religion_rites/instant/sacrifice/proc/calc_sacrifice_favor(mob/living/L)
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
