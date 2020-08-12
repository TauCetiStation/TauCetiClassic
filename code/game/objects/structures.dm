/obj/structure
	icon = 'icons/obj/structures.dmi'
	var/climbable
	var/list/climbers = list()

/obj/structure/atom_init()
	. = ..()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)
	if(climbable)
		verbs += /obj/structure/proc/climb_on

/obj/structure/Destroy()
	if(smooth)
		queue_smooth_neighbors(src)
	return ..()

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/AM in contents)
				AM.forceMove(loc)
				AM.ex_act(severity++)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for(var/atom/movable/AM in contents)
					AM.forceMove(loc)
					AM.ex_act(severity++)
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = "Object"
	set src in oview(1)

	if(!can_climb(usr, usr))
		return

	do_climb(usr, usr)

/obj/structure/MouseDrop_T(atom/dropping, mob/user)
	if(isessence(user))
		return

	if(ismob(dropping) && can_climb(dropping, user))
		do_climb(dropping, user)
		return

	return ..()

/obj/structure/proc/can_climb(mob/living/climber, mob/living/user, post_climb_check = FALSE)
	if(!climbable || !can_touch(user) || (!post_climb_check && (climber in climbers)))
		return FALSE

	if(climber.loc == loc)
		return FALSE

	if(user.incapacitated())
		to_chat(user, "<span class='danger'>You can't pull [climber] up onto [src] while being incapacitated.</span>")
		return FALSE

	if(user != climber)
		if(!can_touch(climber))
			return FALSE
		if(climber.is_bigger_than(user))
			to_chat(user, "<span class='danger'>[climber] is too big for you to be pulled up by them!</span>")
			return FALSE

	if(!user.Adjacent(src))
		if(climber == user)
			to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		else
			to_chat(user, "<span class='danger'>You can't pull [climber] up onto [src], the way is blocked.</span>")
		return FALSE

	if(user != climber && !climber.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't pull [climber] up onto [src], the way is blocked.</span>")
		return FALSE

	if(user.is_busy())
		return FALSE

	var/obj/occupied = turf_is_crowded()
	if(occupied)
		to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
		return FALSE

	return TRUE

/obj/structure/proc/turf_is_crowded()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return null

	for(var/obj/O in T.contents)
		if(istype(O,/obj/structure))
			var/obj/structure/S = O
			if(S.climbable)
				continue

		if(O && O.density)
			return O

	return null

/obj/structure/proc/get_climb_time(mob/living/user)
	. = 50
	//climbing takes twice as long when restrained.
	if(user.restrained())
		. *= 2
	//aliens are terrifyingly fast
	if(isxeno(user))
		. *= 0.25
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		. *= 0.5


/obj/structure/proc/do_climb(mob/living/climber, mob/living/user)
	add_fingerprint(climber)
	if(user == climber)
		user.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	else
		user.visible_message("<span class='warning'>[user] starts pulling [climber] up onto \the [src]!</span>")
		add_fingerprint(user)

	climbers |= climber

	var/adjusted_climb_time = get_climb_time(climber)
	if(user != climber)
		adjusted_climb_time += get_climb_time(user)
		adjusted_climb_time *= 0.5 * get_size_ratio(user, climber)

	if(!do_after(user, adjusted_climb_time, target = climber))
		climbers -= climber
		return

	if(!can_climb(climber, user, post_climb_check = TRUE))
		climbers -= climber
		return

	on_climb(climber, user)
	climbers -= climber

/obj/structure/proc/on_climb(mob/living/climber, mob/living/user)
	climber.forceMove(get_turf(src))

	if(get_turf(climber) == get_turf(src))
		if(climber == user)
			user.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")
		else
			user.visible_message("<span class='warning'>[user] pulls [climber] up onto \the [src]!</span>")

/obj/structure/proc/structure_shaken()
	for(var/mob/living/M in climbers)
		M.Weaken(2)
		to_chat(M, "<span class='danger'>You topple as you are shaken off \the [src]!</span>")
		climbers -= M

	for(var/mob/living/M in get_turf(src))
		if(M.lying) return //No spamming this on people.
		M.Weaken(5)
		to_chat(M, "<span class='red'>You topple as \the [src] moves under you!</span>")

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				to_chat(H, "<span class='red'>You land heavily!</span>")
				H.adjustBruteLoss(damage)
				return

			var/obj/item/organ/external/BP

			switch(pick(list("knee","head","elbow")))
				if("knee")
					BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
				if("elbow")
					BP = H.bodyparts_by_name[pick(BP_L_ARM , BP_R_ARM)]
				if("head")
					BP = H.bodyparts_by_name[BP_HEAD]

			if(BP)
				to_chat(H, "<span class='red'>You land heavily on your [BP.name]!</span>")
				BP.take_damage(damage, 0)
				if(BP.parent)
					BP.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(H, "<span class='red'>You land heavily!</span>")
				H.adjustBruteLoss(damage)

			H.updatehealth()

/obj/structure/proc/can_touch(mob/user)
	if(!user)
		return 0
	if(!Adjacent(user))
		return 0
	if(user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return 0
	if(user.incapacitated())
		return 0
	if(issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return 0
	for(var/obj/O in src.loc)
		if((O.density && O.opacity) > 0)
			return 0
	return 1
