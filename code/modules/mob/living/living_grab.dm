/mob/living/canGrab(atom/movable/target, show_warnings = TRUE)
	. = ..()
	if(.)
		if(isliving(target))
			var/mob/living/L = target
			if(L.is_bigger_than(src))
				return FALSE

/mob/living/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	start_pulling(target)

// When all mobs have a "hand", make this a living proc.
// тут тоже нужна помощь от собрания переводчиков, почему кукла может пристегнуться к стулу ? Если он держиться неужто нельзя его вытащить с него.
/mob/living/carbon/human/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	if(ismob(target))
		var/mob/M = target
		if(!(M.status_flags & CANPUSH))
			return
		if(M.buckled)
			if(show_warnings)
				to_chat(src, "<span class='notice'>Вы не можете схватить [M], он пристегнут!</span>")
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.w_uniform)
				H.w_uniform.add_fingerprint(src)
			if(H.pull_damage())
				if(show_warnings)
					to_chat(src, "<span class='danger'>Тащить [H] в его теукщем состоянии, будет плохая идея.</span>")
		M.inertia_dir = 0

	return new /obj/item/weapon/grab(src, target, force_state)

/mob/living/carbon/xenomorph/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	if(ismob(target))
		var/mob/M = target
		if(!(M.status_flags & CANPUSH))
			return
		if(M.buckled)
			if(show_warnings)
				to_chat(src, "<span class='notice'>Вы не можете схватить [M], он пристегнут!</span>")
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.pull_damage())
				if(show_warnings)
					to_chat(src, "<span class='danger'>Тащить [H] в его теукщем состоянии, будет плохая идея.</span>")
		M.inertia_dir = 0

	return new /obj/item/weapon/grab(src, target, force_state)

/mob/living/carbon/xenomorph/larva/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	start_pulling(target)
