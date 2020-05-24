/mob/living/simple_animal/hostile
	/// The chance of this mob being "special"(Having mob_modifiers)
	var/special_prob = 30

	/// A dict of sort type = amount.
	var/list/loot_list = list()
	/// All amounts of loot from loot_list are multiplied by this value.
	var/loot_mod = 1.0

/mob/living/simple_animal/hostile/death(gibbed)
	spawn_loot()
	return ..()

/mob/living/simple_animal/hostile/proc/spawn_loot()
	for(var/loot_type in loot_list)
		var/spawn_am = round(loot_list[loot_type] * loot_mod)
		for(var/am in 1 to spawn_am)
			new loot_type(loc)

/mob/living/simple_animal/hostile/proc/gen_modifiers(modifier_amount = 3, rarity_cost = rand(2, 6))
	return

// Currently only they are meaningful to have the modifiers.
/mob/living/simple_animal/hostile/asteroid/gen_modifiers(modifier_amount = 3, rarity_cost = rand(2, 6))
	if(!prob(special_prob))
		return

	var/list/allowed_name_mods = list(
		RL_GROUP_PREFIX = 2,
		RL_GROUP_SUFFIX = 2,
	)
	AddComponent(/datum/component/name_modifiers, allowed_name_mods)

	var/static/list/modifiers = subtypesof(/datum/component/mob_modifier)

	var/list/pos_modifiers = list() + modifiers
	var/list/pos_incomps = list() + global.incompatible_mob_modifiers

	while(modifier_amount > 0 && rarity_cost > 0 && pos_modifiers.len > 0)
		var/datum/component/mob_modifier/MM = pick(pos_modifiers)
		var/cost = initial(MM.rarity_cost)

		if(cost > rarity_cost)
			pos_modifiers -= MM
			continue

		var/datum/component/mob_modifier/existing = GetComponent(MM)
		if(existing && existing.strength == existing.max_strength)
			pos_modifiers -= MM
			continue

		var/datum/component/mob_modifier/new_mod = AddComponent(MM, 1)
		if(!new_mod || !new_mod.applied)
			pos_modifiers -= MM
			continue

		for(var/list/incomp in pos_incomps)
			if(MM in incomp)
				for(var/incomp_mod in incomp)
					pos_modifiers -= incomp_mod
				pos_incomps -= incomp

		rarity_cost -= cost
		modifier_amount -= 1
