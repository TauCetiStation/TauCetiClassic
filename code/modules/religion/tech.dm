// A small /datum for applying some technology to religion
/datum/religion_tech

/datum/religion_tech/proc/apply_effect(datum/religion/R)
	return

/datum/religion_tech/cult

/datum/religion_tech/cult/memorizing_rune/apply_effect(datum/religion/R)
	for(var/mob/M in R.members)
		var/obj/effect/proc_holder/spell/dumbfire/memorize_rune/MR = new
		M.AddSpell(MR)
