/datum/religion_tech
	var/id
	var/researching = FALSE
	var/datum/building_agent/tech/info

/datum/religion_tech/New()
	if(info)
		info = new info

/datum/religion_tech/proc/on_add(datum/religion/R)
	return

/datum/religion_tech/cult
/datum/religion_tech/cult/memorizing_rune
	id = RTECH_MEMORIZE_RUNE
	info = /datum/building_agent/tech/cult/memorize_rune

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

/datum/religion_tech/cult/cooldown_reduction
	id = RTECH_COOLDOWN_REDUCTION
	info = /datum/building_agent/tech/cult/cooldown_reduction

/datum/religion_tech/cult/reusable_runes
	id = RTECH_REUSABLE_RUNE
	info = /datum/building_agent/tech/cult/reusable_runes

/datum/religion_tech/cult/build_everywhere
	id = RTECH_BUILD_EVERYWHERE
	info = /datum/building_agent/tech/cult/build_everywhere

/datum/religion_tech/cult/more_runes
	id = RTECH_MORE_RUNES
	info = /datum/building_agent/tech/cult/more_runes

/datum/religion_tech/cult/more_runes/on_add(datum/religion/cult/R)
	R.max_runes_on_mob += 5

/datum/religion_tech/cult/mirror_shield
	id = RTECH_MIRROR_SHIELD
	info = /datum/building_agent/tech/cult/mirror_shield

/datum/religion_tech/cult/improved_pylons
	id = RTECH_IMPROVED_PYLONS
	info = /datum/building_agent/tech/cult/improved_pylons

/datum/religion_tech/cult/improved_pylons/on_add(datum/religion/cult/R)
	for(var/obj/structure/cult/pylon/P as anything in global.pylons)
		P.init_healing()

/datum/religion_tech/upgrade_aspect
	var/datum/aspect/aspect_type

/datum/religion_tech/upgrade_aspect/on_add(datum/religion/R)
	if(aspect_type::name in R.aspects)
		var/datum/aspect/A = R.aspects[aspect_type::name]
		A.power += 1
	else
		var/list/L = list()
		L[aspect_type] = 1
		R.add_aspects(L)

	var/datum/religion_tech/upgrade_aspect/tech = new
	tech.id = id + "+"
	tech.aspect_type = aspect_type
	tech.info = new /datum/building_agent/tech/aspect(info.name, info.icon, info.icon_state)
	tech.calculate_costs(R)
	R.available_techs += tech

/datum/religion_tech/upgrade_aspect/proc/calculate_costs(datum/religion/R)
	if(aspect_type::name in R.aspects)
		var/datum/aspect/A = R.aspects[aspect_type::name]
		info.piety_cost = A.power * 50
	else
		info.piety_cost = max(100, 50 + 25 * R.aspects.len) //We don't count 6 initial aspects and scale for static 150, +50 piety for each new aspect
