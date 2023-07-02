// A small /datum for applying some technology to religion
/datum/religion_tech
	var/id

/datum/religion_tech/proc/on_add(datum/religion/R)
	return

/datum/religion_tech/cult
/datum/religion_tech/cult/memorizing_rune
	id = RTECH_MEMORIZE_RUNE

/datum/religion_tech/cult/memorizing_rune/proc/give_spell(datum/religion/R, mob/M, holy_role)
	var/obj/effect/proc_holder/spell/no_target/memorize_rune/MR = M.GetSpell(/obj/effect/proc_holder/spell/no_target/memorize_rune)
	if(MR || M.GetSpell(/obj/effect/proc_holder/spell/no_target/scribe_rune))
		return
	MR = new
	M.AddSpell(MR)

/datum/religion_tech/cult/memorizing_rune/proc/remove_spell(datum/religion/R, mob/M)
	var/obj/effect/proc_holder/spell/no_target/memorize_rune/S = locate() in M.spell_list
	M.RemoveSpell(S)

/datum/religion_tech/cult/memorizing_rune/on_add(datum/religion/cult/R)
	for(var/mob/M in R.members)
		give_spell(R, M)

	RegisterSignal(R, list(COMSIG_REL_ADD_MEMBER), PROC_REF(give_spell))
	RegisterSignal(R, list(COMSIG_REL_REMOVE_MEMBER), PROC_REF(remove_spell))

/datum/religion_tech/cult/reusable_runes
	id = RTECH_REUSABLE_RUNE

/datum/religion_tech/cult/build_everywhere
	id = RTECH_BUILD_EVERYWHERE

/datum/religion_tech/cult/more_runes
	id = RTECH_MORE_RUNES

/datum/religion_tech/cult/more_runes/on_add(datum/religion/cult/R)
	R.max_runes_on_mob += 5

/datum/religion_tech/cult/mirror_shield
	id = RTECH_MIRROR_SHIELD

/datum/religion_tech/cult/improved_pylons
	id = RTECH_IMPROVED_PYLONS

/datum/religion_tech/cult/improved_pylons/on_add(datum/religion/cult/R)
	for(var/obj/structure/cult/pylon/P as anything in global.pylons)
		P.init_healing()
