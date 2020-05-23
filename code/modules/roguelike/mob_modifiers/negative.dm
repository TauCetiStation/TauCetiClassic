/datum/component/mob_modifier/frail
	modifier_name = RL_MM_FRAIL
	name_modifier_type = /datum/name_modifier/prefix/frail

	rarity_cost = -2

/datum/component/mob_modifier/frail/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod *= 1 / (1.5 * strength)

	H.maxHealth *= 1 / (1.5 * strength)
	H.health = health_proportion * H.maxHealth

	var/matrix/M = matrix(H.default_transform)
	// #define MAGIC_SHORTNESS_CONSTANT 5 / 7
	M.Scale(5 / 7)
	H.transform = M
	H.default_transform = H.transform

/datum/component/mob_modifier/frail/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod *= 1.5 * strength

	H.maxHealth *= (1.5 * strength)
	H.health = health_proportion * H.maxHealth

	var/matrix/M = matrix(H.transform)
	M.Scale(7 / 5)
	H.transform = M
	H.default_transform = H.transform
	return ..()



/datum/component/mob_modifier/friendly
	modifier_name = RL_MM_FRIENDLY
	name_modifier_type = /datum/name_modifier/prefix/friendly

	max_strength = 1

	rarity_cost = -4

/datum/component/mob_modifier/friendly/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.loot_mod = 0.0
	H.faction = "neutral"

/datum/component/mob_modifier/friendly/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.loot_mod = initial(H.loot_mod)
	H.faction = initial(H.faction)
	return ..()
