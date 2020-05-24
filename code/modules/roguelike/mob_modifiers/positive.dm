/datum/component/mob_modifier/healthy
	modifier_name = RL_MM_HEALTHY
	name_modifier_type = /datum/name_modifier/prefix/healthy

	rarity_cost = 2

/datum/component/mob_modifier/healthy/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod *= 1.5 * strength

	H.maxHealth *= 1.5 * strength
	H.health = health_proportion * H.maxHealth

	var/matrix/M = matrix(H.default_transform)
	// #define MAGIC_TALLNESS_CONSTANT 7 / 5
	M.Scale(7 / 5)
	H.transform = M
	H.default_transform = H.transform

/datum/component/mob_modifier/healthy/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod *= 1 / (1.5 * strength)

	H.maxHealth *= 1 / (1.5 * strength)
	H.health = health_proportion * H.maxHealth

	var/matrix/M = matrix(H.transform)
	M.Scale(5 / 7)
	H.transform = M
	H.default_transform = H.transform
	return ..()



/datum/component/mob_modifier/ghostly
	modifier_name = RL_MM_GHOSTLY
	name_modifier_type = /datum/name_modifier/prefix/ghostly

	max_strength = 1

	rarity_cost = 4

	updates = TRUE
	need_updates = TRUE

	var/obj/item/possessed

	var/rejuve_timer

	// Slightly blue-ish, ghostly vibe.
	var/static/list/ghostly_matrix = list(
		0.25, 0.0, 0.0, 0.0,
		0.0, 0.25, 0.0, 0.0,
		0.0, 0.0, 0.25, 0.0,
		0.0, 0.0, 0.0, 0.8,
		0.2, 0.2, 0.2, 0.0
	)

	// USE FILTER AFTER 513
	// var/ghostly_filter
	var/saved_color

/datum/component/mob_modifier/ghostly/Destroy()
	qdel(possessed.GetComponent(/datum/component/bounded))
	UnregisterSignal(possessed, list(COMSIG_PARENT_QDELETED))
	possessed = null
	deltimer(rejuve_timer)
	return ..()

/datum/component/mob_modifier/ghostly/apply(update = FALSE)
	if(!update)
		var/obj/randomcatcher/CATCH = new
		possessed = CATCH.get_item(/obj/random/misc/toy)
		if(!possessed)
			return FALSE

	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	H.density = FALSE
	H.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE|PASSBLOB|PASSCRAWL|PASSMOB
	H.layer = FLY_LAYER

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod = 0.0

	H.maxHealth *= 0.3
	H.health = health_proportion * H.maxHealth

	saved_color = H.color
	H.color = ghostly_matrix

	if(update)
		return

	// ghostly_filter = filter(type="color", color=ghostly_matrix)

	RegisterSignal(possessed, list(COMSIG_PARENT_QDELETED), .proc/on_phylactery_destroyed)
	possessed.forceMove(H.loc)
	H.AddComponent(/datum/component/bounded, possessed, 0, 3)

	// THE RECIPY OF IMMORTALITY BUAHAHAHA
	RegisterSignal(H, list(COMSIG_MOB_DIED), .proc/retreat)

	// H.filters += ghostly_filter

/datum/component/mob_modifier/ghostly/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.density = initial(H.density)
	H.pass_flags = initial(H.pass_flags)
	H.layer = initial(H.layer)

	var/health_proportion = H.health / H.maxHealth

	H.loot_mod = initial(H.loot_mod)

	H.maxHealth *= 3.0
	H.health = health_proportion * H.maxHealth

	H.color = saved_color

	return ..()

/datum/component/mob_modifier/ghostly/proc/on_phylactery_destroyed()
	qdel(parent)

/datum/component/mob_modifier/ghostly/proc/retreat(datum/source, gibbed)
	// How to destroy a ghost 101: meat hooks
	if(gibbed)
		return

	var/list/allowed_name_mods = list(
		RL_GROUP_PREFIX = 2,
		RL_GROUP_SUFFIX = 2,
	)
	possessed.AddComponent(/datum/component/name_modifiers, allowed_name_mods)
	SEND_SIGNAL(possessed, COMSIG_NAME_MOD_ADD, /datum/name_modifier/prefix/cursed, 1)

	var/mob/living/simple_animal/hostile/H = parent
	H.forceMove(possessed)

	rejuve_timer = addtimer(CALLBACK(src, .proc/come_back), rand(6, 10) MINUTES, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/component/mob_modifier/ghostly/proc/come_back()
	if(QDELING(src))
		return

	if(!possessed)
		return

	var/mob/living/simple_animal/hostile/H = parent

	SEND_SIGNAL(possessed, COMSIG_NAME_MOD_REMOVE, /datum/name_modifier/prefix/cursed, 1)
	H.rejuvenate()
	H.forceMove(get_turf(possessed))



/datum/component/mob_modifier/slimy
	modifier_name = RL_MM_SLIMY
	name_modifier_type = /datum/name_modifier/prefix/slimy

	max_strength = 1

	rarity_cost = 4

	updates = TRUE
	need_updates = TRUE

	var/saved_color
	var/saved_damtype

	var/static/list/pos_colors = list(
		"#A5040AE3" = SLIME_COLOR_RED,
		"#04A513E3" = SLIME_COLOR_GREEN,
		"#0460A5E3" = SLIME_COLOR_BLUE,
		"#A59704E3" = SLIME_COLOR_YELLOW,
		"#04A5E3E3" = SLIME_COLOR_CYAN,
	)

	// var/slimy_color_filter
	var/slimy_outline_filter

/datum/component/mob_modifier/slimy/Destroy()
	// QDEL_NULL(slimy_color_filter)
	QDEL_NULL(slimy_outline_filter)
	return ..()

/datum/component/mob_modifier/slimy/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	var/health_proportion = H.health / H.maxHealth

	H.maxHealth *= 0.6
	H.health = health_proportion * H.maxHealth

	H.melee_damtype = CLONE

	H.see_in_dark = 8
	H.ventcrawler = 2
	H.status_flags &= ~CANSTUN|CANWEAKEN
	H.pass_flags |= PASSTABLE

	saved_color = H.color

	if(update)
		return

	var/my_color = pick(pos_colors)
	var/my_color_matrix = pos_colors[my_color]

	// USE FILTER AFTER 513
	// slimy_color_filter = filter(type="color", color=my_color_matrix)
	H.color = my_color_matrix
	slimy_outline_filter = filter(type = "outline", size = 3, color = my_color)

	//H.filters += slimy_color_filter
	H.filters += slimy_outline_filter

/datum/component/mob_modifier/slimy/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.density = initial(H.density)
	H.pass_flags = initial(H.pass_flags)
	H.layer = initial(H.layer)

	var/health_proportion = H.health / H.maxHealth

	H.maxHealth *= 3.0
	H.health = health_proportion * H.maxHealth

	H.melee_damtype = initial(H.melee_damtype)

	H.see_in_dark = initial(H.see_in_dark)
	H.ventcrawler = initial(H.ventcrawler)
	H.status_flags = initial(H.status_flags)
	H.pass_flags = initial(H.pass_flags)

	H.color = saved_color

	if(!update)
		H.filters -= slimy_outline_filter


	return ..()



/datum/component/mob_modifier/strong
	modifier_name = RL_MM_STRONG
	name_modifier_type = /datum/name_modifier/prefix/strong

	rarity_cost = 2

/datum/component/mob_modifier/strong/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	RegisterSignal(H, list(COMSIG_MOVABLE_MOVED), .proc/shake_ground)

	H.melee_damage *= 1.5 * strength

	H.loot_mod *= 1.5 * strength
	H.faction = "Station"

/datum/component/mob_modifier/strong/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.melee_damage *= 1 / (1.5 * strength)
	H.loot_mod *= 1 / (1.5 * strength)

	H.faction = initial(H.faction)
	return ..()

/datum/component/mob_modifier/strong/proc/shake_ground()
	var/mob/living/simple_animal/hostile/H = parent

	if(H.incapacitated())
		return

	H.loc.shake_act(3)



/datum/component/mob_modifier/singular
	modifier_name = RL_MM_SINGULAR
	name_modifier_type = /datum/name_modifier/prefix/singular

	rarity_cost = 4

/datum/component/mob_modifier/singular/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent

	RegisterSignal(H, list(COMSIG_MOVABLE_MOVED), .proc/shake_ground)

	H.melee_damage *= 1.5 * strength

	H.loot_mod *= 1.5 * strength
	H.faction = "Station"

/datum/component/mob_modifier/singular/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.melee_damage *= 1 / (1.5 * strength)
	H.loot_mod *= 1 / (1.5 * strength)

	H.faction = initial(H.faction)
	return ..()

/datum/component/mob_modifier/singular/proc/eat()
	var/mob/living/simple_animal/hostile/H = parent

	if(H.incapacitated())
		return

	H.loc.shake_act(3)
