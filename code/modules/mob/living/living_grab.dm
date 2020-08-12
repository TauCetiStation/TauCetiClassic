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
/mob/living/carbon/human/Grab(atom/movable/target, force_state, show_warnings = TRUE)
	if(ismob(target))
		var/mob/M = target
		if(!(M.status_flags & CANPUSH))
			return
		if(M.buckled)
			if(show_warnings)
				to_chat(src, "<span class='notice'>You cannot grab [M], \he is buckled in!</span>")
			return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.w_uniform)
				H.w_uniform.add_fingerprint(src)
			if(H.pull_damage())
				if(show_warnings)
					to_chat(src, "<span class='danger'>Grabbing \the [H] in their current condition would probably be a bad idea.</span>")
		M.inertia_dir = 0

	return new /obj/item/weapon/grab(src, target, force_state)
