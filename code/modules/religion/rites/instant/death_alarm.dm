/datum/religion_rites/instant/chaplain/death_alarm
	name = "Ангел-хранитель"
	desc = "Ангел заточенный в колоколе в церкви хоть и не сможет уберечь вас в трудную минуту, но всегда оповестит экипаж о вашей кончине."
	ritual_length = (10 SECONDS)
	favor_cost = 200
	invoke_msg = "О, святой ангел, заступник перед нашим Господом за мою душу, мое тело и мою жизнь. Спаси его от посягательств!"
	can_talismaned = FALSE
	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/instant/chaplain/death_alarm/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE
	if(!AOG.buckled_mob)
		return FALSE
	if(!iscarbon(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Ангел не будет охранять это существо.</span>")
		return FALSE
	var/mob/living/carbon/M = AOG.buckled_mob
	if(M.GetComponent(/datum/component/bell_death_alarm))
		to_chat(user, "<span class='warning'>Эта цель уже охраняется ангелом.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/chaplain/death_alarm/invoke_effect(mob/user, obj/AOG)
	. = ..()
	var/mob/living/carbon/H = AOG.buckled_mob
	H.AddComponent(/datum/component/bell_death_alarm)
