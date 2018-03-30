/obj/structure
	icon = 'icons/obj/structures.dmi'
	var/climbable
	var/list/climbers = list()

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

/obj/structure/meteorhit(obj/O)
	qdel(src)

/obj/structure/atom_init()
	. = ..()
	if(climbable)
		verbs += /obj/structure/proc/climb_on

/obj/structure/proc/climb_on()

	set name = "Climb structure"
	set desc = "Climbs onto a structure."
	set category = "Object"
	set src in oview(1)

	do_climb(usr)

/obj/structure/MouseDrop_T(mob/target, mob/user)
	if(isessence(user))
		return
	var/mob/living/H = user
	if(can_climb(H) && target == user)
		do_climb(target)
	else
		return ..()

/obj/structure/proc/can_climb(mob/living/user, post_climb_check=0)
	if (!can_touch(user) || !climbable || (!post_climb_check && (user in climbers)))
		return 0

	if (!user.Adjacent(src))
		to_chat(user, "<span class='danger'>You can't climb there, the way is blocked.</span>")
		return 0

	if(user.is_busy())
		return 0

	var/obj/occupied = turf_is_crowded()
	if(occupied)
		to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
		return 0
	return 1

/obj/structure/proc/turf_is_crowded()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return 0
	for(var/obj/O in T.contents)
		if(istype(O,/obj/structure))
			var/obj/structure/S = O
			if(S.climbable) continue
		if(O && O.density)
			return O
	return 0

/obj/structure/proc/do_climb(mob/living/user)
	if (!can_climb(user))
		return
	usr.visible_message("<span class='warning'>[user] starts climbing onto \the [src]!</span>")
	climbers |= user

	if(!do_after(user,50,target = user))
		climbers -= user
		return

	if (!can_climb(user, post_climb_check=1))
		climbers -= user
		return

	on_climb(user)
	climbers -= user

/obj/structure/proc/on_climb(mob/living/user)
	usr.forceMove(get_turf(src))

	if (get_turf(user) == get_turf(src))
		usr.visible_message("<span class='warning'>[user] climbs onto \the [src]!</span>")

/obj/structure/proc/structure_shaken()
	for(var/mob/living/M in climbers)
		M.Weaken(2)
		to_chat(M, "<span class='danger'>You topple as you are shaken off \the [src]!</span>")
		climbers.Cut(1,2)

	for(var/mob/living/M in get_turf(src))
		if(M.lying) return //No spamming this on people.
		M.Weaken(5)
		to_chat(M, "<span class='red'>You topple as \the [src] moves under you!</span>")

		if(prob(25))

			var/damage = rand(15,30)
			var/mob/living/carbon/human/H = M
			if(!istype(M))
				to_chat(H, "<span class='red'>You land heavily!</span>")
				M.adjustBruteLoss(damage)
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
				to_chat(M, "<span class='red'>You land heavily on your [BP.name]!</span>")
				BP.take_damage(damage, 0)
				if(BP.parent)
					BP.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(H, "<span class='red'>You land heavily!</span>")
				H.adjustBruteLoss(damage)

			H.updatehealth()
	return

/obj/structure/proc/can_touch(mob/user)
	if(!user)
		return 0
	if(!Adjacent(user))
		return 0
	if(user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return 0
	if(user.stat || user.paralysis || user.sleeping || user.lying || user.weakened)
		return 0
	if(issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return 0
	for(var/obj/O in src.loc)
		if((O.density && O.opacity) > 0)
			return 0
	return 1
