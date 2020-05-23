/datum/component/mob_modifier/frail
	modifier_name = RL_MM_FRAIL
	name_modifier_type = /datum/name_modifier/prefix/frail

	rarity_cost = -2

/datum/component/mob_modifier/frail/apply()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.maxHealth *= 1 / (1.5 * strength)
	H.health = H.maxHealth

	var/matrix/M = matrix(H.default_transform)
	// #define MAGIC_SHORTNESS_CONSTANT 5 / 7
	M.Scale(5 / 7)
	H.transform = M
	H.default_transform = H.transform

/datum/component/mob_modifier/frail/revert()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.maxHealth *= (1.5 * strength)
	H.health = H.maxHealth

	var/matrix/M = matrix(H.transform)
	M.Scale(7 / 5)
	H.transform = M
	H.default_transform = H.transform
