/datum/component/mob_modifier/healthy
	modifier_name = RL_MM_HEALTHY
	name_modifier_type = /datum/name_modifier/prefix/healthy

	rarity_cost = 2

/datum/component/mob_modifier/healthy/apply()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.maxHealth *= 1.5 * strength
	H.health = H.maxHealth

	var/matrix/M = matrix(H.default_transform)
	// #define MAGIC_TALLNESS_CONSTANT 7 / 5
	M.Scale(7 / 5)
	H.transform = M
	H.default_transform = H.transform

/datum/component/mob_modifier/healthy/revert()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.maxHealth *= 1 / (1.5 * strength)
	H.health = H.maxHealth

	var/matrix/M = matrix(H.transform)
	M.Scale(5 / 7)
	H.transform = M
	H.default_transform = H.transform



/datum/component/mob_modifier/ghostly
	modifier_name = RL_MM_GHOSTLY
	name_modifier_type = /datum/name_modifier/prefix/ghostly

	max_strength = 1

	rarity_cost = 4

	var/saved_color
	var/static/list/ghostly_matrix = list(
		0.2, 0.0, 0.0, 0.0,
		0.0, 0.2, 0.0, 0.0,
		0.0, 0.0, 0.2, 0.0,
		0.0, 0.0, 0.0, 0.8,
		0.1, 0.1, 0.2, 0.0
	)

/datum/component/mob_modifier/ghostly/apply()
	var/obj/randomcatcher/CATCH = new
	var/obj/item/I = CATCH.get_item(/obj/random/misc/toy)
	if(!I)
		return FALSE

	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	saved_color = H.color

	I.forceMove(H.loc)

	H.density = FALSE
	H.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE|PASSBLOB|PASSCRAWL|PASSMOB
	H.layer = FLY_LAYER

	H.maxHealth *= 0.3
	H.health = H.maxHealth

	H.AddComponent(/datum/component/bounded, I, 0, 3)

	H.color = ghostly_matrix

/datum/component/mob_modifier/ghostly/revert()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.density = initial(H.density)
	H.pass_flags = initial(H.pass_flags)
	H.layer = initial(H.layer)

	H.maxHealth *= 3.0
	H.health = H.maxHealth

	H.color = saved_color



/datum/component/mob_modifier/slimy
	modifier_name = RL_MM_SLIMY
	name_modifier_type = /datum/name_modifier/prefix/slimy

	max_strength = 1

	rarity_cost = 4

	var/saved_color
	var/static/list/ghostly_matrix = list(
		0.2, 0.0, 0.0, 0.0,
		0.0, 0.2, 0.0, 0.0,
		0.0, 0.0, 0.2, 0.0,
		0.0, 0.0, 0.0, 0.8,
		0.1, 0.1, 0.2, 0.0
	)

/datum/component/mob_modifier/slimy/apply()
	var/obj/randomcatcher/CATCH = new
	var/obj/item/I = CATCH.get_item(/obj/random/misc/toy)
	if(!I)
		return FALSE

	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	saved_color = H.color

	I.forceMove(H.loc)

	H.density = FALSE
	H.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE|PASSBLOB|PASSCRAWL|PASSMOB
	H.layer = FLY_LAYER

	H.maxHealth *= 0.3
	H.health = H.maxHealth

	H.AddComponent(/datum/component/bounded, I, 0, 3)

	H.color = ghostly_matrix

/datum/component/mob_modifier/slimy/revert()
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.density = initial(H.density)
	H.pass_flags = initial(H.pass_flags)
	H.layer = initial(H.layer)

	H.maxHealth *= 3.0
	H.health = H.maxHealth

	H.color = saved_color
