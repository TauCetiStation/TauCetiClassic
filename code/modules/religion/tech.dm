// A small /datum for applying some technology to religion
/datum/religion_tech

/datum/religion_tech/proc/apply_effect(datum/religion/R)
	return

/datum/religion_tech/cult

/datum/religion_tech/cult/memorizing_rune/apply_effect(datum/religion/R)
	for(var/mob/M in R.members)
		var/obj/effect/proc_holder/spell/dumbfire/memorize_rune/MR = new
		M.AddSpell(MR)

/datum/religion_tech/cult/reusable_runes

/datum/religion_tech/cult/reusable_runes/apply_effect(datum/religion/R)
	R.disposable_rune = FALSE

/datum/religion_tech/cult/build_everywhere

/datum/religion_tech/cult/build_everywhere/apply_effect(datum/religion/R)
	R.can_build_everywhere = TRUE
