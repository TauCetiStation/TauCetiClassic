/datum/religion_rites/instant/chaplain/death_alarm
	name = "Ангел-хранитель"
	desc = "Ангел заточенный в колоколе в церкви хоть и не сможет уберечь вас в трудную минуту, но всегда оповестит экипаж о вашей кончине."
	ritual_length = (50 SECONDS)
	favor_cost = 200
	invoke_msg = "Oh, holy angel, intercessor before our Lord for my soul, my body and my life. Save him from encroachment!"
	can_talismaned = FALSE
	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/instant/chaplain/death_alarm/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE
	if(!AOG.buckled_mob)
		return FALSE
	if(!iscarbon(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Ангел не будет охранять это существо.</span>")
		return FALSE
	var/datum/M = AOG.buckled_mob
	if(M.GetComponent(/datum/component/bell_death_alarm))
		to_chat(user, "<span class='warning'>Эта цель уже охраняется ангелом.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/chaplain/death_alarm/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	var/mob/living/carbon/H = AOG.buckled_mob
	H.AddComponent(/datum/component/bell_death_alarm)
