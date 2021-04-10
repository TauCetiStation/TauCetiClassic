// A small /datum for applying some technology to religion
/datum/religion_tech

/datum/religion_tech/proc/apply_effect(datum/religion/R)
	return

/datum/religion_tech/cult

/datum/religion_tech/cult/memorizing_rune/apply_effect(datum/religion/cult/R)
	for(var/mob/M in R.members)
		var/obj/effect/proc_holder/spell/dumbfire/memorize_rune/MR = new
		M.AddSpell(MR)

/datum/religion_tech/cult/reusable_runes

/datum/religion_tech/cult/reusable_runes/apply_effect(datum/religion/cult/R)
	R.reusable_rune = TRUE

/datum/religion_tech/cult/build_everywhere

/datum/religion_tech/cult/build_everywhere/apply_effect(datum/religion/cult/R)
	R.can_build_everywhere = TRUE

/datum/religion_tech/cult/more_runes

/datum/religion_tech/cult/more_runes/apply_effect(datum/religion/cult/R)
	R.max_runes_on_mob += 5

/datum/religion_tech/cult/mirror_shield

/datum/religion_tech/cult/mirror_shield/apply_effect(datum/religion/cult/R)
	R.blade_with_shield = TRUE
