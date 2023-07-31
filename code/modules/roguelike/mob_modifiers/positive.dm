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
	/// Already 514
	// var/ghostly_filter
	var/saved_color

/datum/component/mob_modifier/ghostly/Destroy()
	var/mob/living/simple_animal/hostile/H = parent

	qdel(possessed.GetComponent(/datum/component/bounded))
	UnregisterSignal(possessed, list(COMSIG_PARENT_QDELETING))

	if(rejuve_timer)
		SEND_SIGNAL(possessed, COMSIG_NAME_MOD_REMOVE, /datum/name_modifier/prefix/cursed, 1)
		deltimer(rejuve_timer)
		H.forceMove(get_turf(possessed))

	possessed = null
	return ..()

/datum/component/mob_modifier/ghostly/apply(update = FALSE)
	if(!update)
		possessed = new PATH_OR_RANDOM_PATH(/obj/random/misc/toy)

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

	RegisterSignal(possessed, list(COMSIG_PARENT_QDELETING), PROC_REF(on_phylactery_destroyed))
	possessed.forceMove(H.loc)

	if(QDELING(possessed) || !get_turf(possessed))
		return FALSE

	var/list/allowed_name_mods = list(
		RL_GROUP_PREFIX = 2,
		RL_GROUP_SUFFIX = 2,
	)
	possessed.AddComponent(/datum/component/name_modifiers, allowed_name_mods)

	H.AddComponent(/datum/component/bounded, possessed, 0, 3)

	// THE RECIPY OF IMMORTALITY BUAHAHAHA
	RegisterSignal(H, list(COMSIG_MOB_DIED), PROC_REF(retreat))

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

	if(!update && rejuve_timer)
		deltimer(rejuve_timer)
		rejuve_timer = null

		if(possessed)
			SEND_SIGNAL(possessed, COMSIG_NAME_MOD_REMOVE, /datum/name_modifier/prefix/cursed, 1)
			H.forceMove(get_turf(possessed))

	return ..()

/datum/component/mob_modifier/ghostly/proc/on_phylactery_destroyed()
	qdel(parent)

/datum/component/mob_modifier/ghostly/proc/retreat(datum/source, gibbed)
	// How to destroy a ghost 101: meat hooks
	if(gibbed)
		return

	SEND_SIGNAL(possessed, COMSIG_NAME_MOD_ADD, /datum/name_modifier/prefix/cursed, 1)

	var/mob/living/simple_animal/hostile/H = parent
	qdel(H.GetComponent(/datum/component/bounded))
	H.forceMove(possessed)

	rejuve_timer = addtimer(CALLBACK(src, PROC_REF(come_back)), rand(6, 10) MINUTES, TIMER_STOPPABLE)

/datum/component/mob_modifier/ghostly/proc/come_back()
	if(!possessed)
		return

	var/mob/living/simple_animal/hostile/H = parent

	SEND_SIGNAL(possessed, COMSIG_NAME_MOD_REMOVE, /datum/name_modifier/prefix/cursed, 1)
	H.rejuvenate()
	H.forceMove(get_turf(possessed))
	H.AddComponent(/datum/component/bounded, possessed, 0, 3)



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
		"#490008FF" = SLIME_COLOR_RED,
		"#0049008F" = SLIME_COLOR_GREEN,
		"#002049FF" = SLIME_COLOR_BLUE,
		"#493500FF" = SLIME_COLOR_YELLOW,
		"#004940FF" = SLIME_COLOR_CYAN,
	)

	// var/slimy_color_filter
	var/slimy_outline_filter

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
	H.remove_status_flags(CANSTUN|CANWEAKEN)
	H.pass_flags |= PASSTABLE

	saved_color = H.color

	if(update)
		return

	var/my_color = pick(pos_colors)
	var/my_color_matrix = pos_colors[my_color]

	H.add_filter("slimy_color", 2, color_matrix_filter(1, my_color_matrix))
	H.add_filter("slimy_outline", 2, outline_filter(1, my_color))

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
		H.remove_filter("slimy_outline")

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

	H.melee_damage *= 1.5 * strength
	H.loot_mod *= 1.5 * strength

	if(update)
		return

	RegisterSignal(H, list(COMSIG_MOVABLE_MOVED), PROC_REF(shake_ground))

/datum/component/mob_modifier/strong/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.melee_damage *= 1 / (1.5 * strength)
	H.loot_mod *= 1 / (1.5 * strength)

	return ..()

/datum/component/mob_modifier/strong/proc/shake_ground()
	var/mob/living/simple_animal/hostile/H = parent

	if(H.incapacitated())
		return

	H.loc.shake_act(2 + strength)

/atom/movable/antiwarp_effect
	plane = ANOMALY_PLANE
	appearance_flags = PIXEL_SCALE // no tile bound so you can see it around corners and so
	icon = 'icons/effects/288x288.dmi'
	icon_state = "gravitational_anti_lens"
	pixel_x = -128
	pixel_y = -128

/atom/movable/antiwarp_effect/atom_init(mapload, ...)
	. = ..()
	add_filter("ripple", 1, ripple_filter(radius = 0, size = 250, falloff = 0.5, repeat = 100))
	START_PROCESSING(SSobj, src)

/atom/movable/antiwarp_effect/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/antiwarp_effect/process()
	animate(src, time = 6, transform = matrix().Scale(0.5, 0.5))
	animate(time = 14, transform = matrix(), flags = ANIMATION_PARALLEL)
	animate(get_filter("ripple"), radius = 0, size = 150, time = 14, flags = ANIMATION_PARALLEL)
	animate(radius = 250, size = 0, time = 0)

/datum/component/mob_modifier/singular
	modifier_name = RL_MM_SINGULAR
	name_modifier_type = /datum/name_modifier/prefix/singular

	rarity_cost = 4

	max_strength = 5

	var/grav_pull = 4
	var/pull_stage = STAGE_ONE

	var/atom/movable/antiwarp_effect/warp

/datum/component/mob_modifier/singular/Destroy()
	STOP_PROCESSING(SSmob_modifier, src)
	QDEL_NULL(warp)
	return ..()

/datum/component/mob_modifier/singular/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	switch(strength)
		if(1)
			pull_stage = STAGE_ONE
			grav_pull = 4
		if(2)
			pull_stage = STAGE_TWO
			grav_pull = 6
		if(3)
			pull_stage = STAGE_THREE
			grav_pull = 8
		if(4)
			pull_stage = STAGE_FOUR
			grav_pull = 10
		else
			pull_stage = STAGE_FIVE
			grav_pull = 10

	if(update)
		return

	var/mob/living/simple_animal/hostile/H = parent

	warp = new(src)
	warp.transform = matrix().Scale(0.01)
	warp.pixel_x = -128
	warp.pixel_y = -128

	H.vis_contents += warp
	H.plane = ABOVE_GAME_PLANE

	START_PROCESSING(SSmob_modifier, src)
	RegisterSignal(H, list(COMSIG_MOB_DIED), PROC_REF(stop_pulling))
	RegisterSignal(H, list(COMSIG_LIVING_REJUVENATE), PROC_REF(start_pulling))

/datum/component/mob_modifier/singular/revert(update = FALSE)
	if(!update)
		var/mob/living/simple_animal/hostile/H = parent
		H.vis_contents -= warp
		H.plane = initial(H.plane)

		STOP_PROCESSING(SSmob_modifier, src)
	return ..()

/datum/component/mob_modifier/singular/process()
	pull()

/datum/component/mob_modifier/singular/proc/consume(atom/movable/AM)
	if(!isitem(AM))
		return

	var/mob/living/simple_animal/hostile/H = parent

	var/obj/item/I = AM
	H.heal_overall_damage(I.w_class, I.w_class)
	qdel(I)

/datum/component/mob_modifier/singular/proc/pull()
	set background = BACKGROUND_ENABLED

	var/mob/living/simple_animal/hostile/H = parent
	if(QDELETED(parent))
		return

	for(var/tile in spiral_range_turfs(grav_pull, H, 1))
		var/turf/T = tile
		if(!T)
			continue
		T.singularity_pull(H, pull_stage)
		for(var/thing in T)
			var/atom/movable/X = thing
			if(!X)
				continue
			X.singularity_pull(H, pull_stage)
			CHECK_TICK

	for(var/thing in get_turf(H))
		var/atom/movable/X = thing
		if(!X)
			continue
		consume(X)
		CHECK_TICK

/datum/component/mob_modifier/singular/proc/start_pulling()
	START_PROCESSING(SSmob_modifier, src)

/datum/component/mob_modifier/singular/proc/stop_pulling()
	STOP_PROCESSING(SSmob_modifier, src)



/datum/component/mob_modifier/invisible
	modifier_name = RL_MM_INVISIBLE
	name_modifier_type = /datum/name_modifier/prefix/invisible

	rarity_cost = 4

	max_strength = 1

	var/saved_invisibility = 0
	var/saved_alpha = 0

	var/invisible = FALSE
	var/invis_timer

/datum/component/mob_modifier/invisible/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/hostile/H = parent
	saved_invisibility = H.invisibility
	saved_alpha = H.alpha

	if(update)
		return

	RegisterSignal(H, list(COMSIG_MOB_HOSTILE_ATTACKINGTARGET, COMSIG_MOB_HOSTILE_SHOOT, COMSIG_MOB_DIED), PROC_REF(reveal))
	RegisterSignal(H, list(COMSIG_LIVING_REJUVENATE), PROC_REF(start_hiding))

	INVOKE_ASYNC(src, PROC_REF(start_hiding))

/datum/component/mob_modifier/invisible/revert(update = FALSE)
	var/mob/living/simple_animal/hostile/H = parent

	H.invisibility = initial(H.invisibility)
	H.alpha = initial(H.alpha)

	if(!update)
		reveal()

	return ..()

/datum/component/mob_modifier/invisible/proc/start_hiding()
	if(invis_timer)
		return

	if(prob(50))
		become_invisible()
	else
		add_invis_timer()

/datum/component/mob_modifier/invisible/proc/reveal()
	deltimer(invis_timer)
	invis_timer = null

	if(invisible)
		become_visible()
	else
		add_invis_timer()

/datum/component/mob_modifier/invisible/proc/add_vis_timer()
	invis_timer = addtimer(CALLBACK(src, PROC_REF(become_visible)), rand(10, 30) SECONDS, TIMER_STOPPABLE)

/datum/component/mob_modifier/invisible/proc/add_invis_timer()
	invis_timer = addtimer(CALLBACK(src, PROC_REF(become_invisible)), rand(10, 30) SECONDS, TIMER_STOPPABLE)

/datum/component/mob_modifier/invisible/proc/become_visible()
	var/mob/living/simple_animal/hostile/H = parent

	invisible = FALSE
	H.invisibility = saved_invisibility
	H.alpha = 0
	animate(H, alpha=saved_alpha, time=1 SECOND)

	if(H.stat != CONSCIOUS)
		return

	add_invis_timer()

/datum/component/mob_modifier/invisible/proc/become_invisible()
	var/mob/living/simple_animal/hostile/H = parent

	if(H.stat != CONSCIOUS)
		return

	invisible = TRUE
	animate(H, alpha=0, time=1 SECOND)
	sleep(1 SECOND)
	if(QDELING(src))
		return

	H.invisibility = INVISIBILITY_LEVEL_ONE
	H.alpha = 127

	add_vis_timer()



/datum/component/mob_modifier/angelic
	modifier_name = RL_MM_ANGELIC
	name_modifier_type = /datum/name_modifier/prefix/angelic

	rarity_cost = 2

	max_strength = 1

/datum/component/mob_modifier/angelic/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	if(update)
		return

	var/obj/effect/effect/forcefield/eva/F = new
	AddComponent(/datum/component/forcefield, "AT field", 20, 5 SECONDS, 3 SECONDS, F, TRUE, TRUE)
	SEND_SIGNAL(src, COMSIG_FORCEFIELD_PROTECT, parent)

/datum/component/mob_modifier/angelic/revert(update = FALSE)
	if(!update)
		qdel(GetComponent(/datum/component/forcefield))

	return ..()
