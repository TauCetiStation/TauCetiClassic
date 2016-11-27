/atom/movable
	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/mob/living/buckled_mob = null

/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob && istype(user))
		user_unbuckle_mob(user)

/atom/movable/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M) && !buckled_mob && istype(user))
		user_buckle_mob(M, user)

/atom/movable/proc/buckle_mob(mob/living/M)
	if(!can_buckle || !istype(M) || (M.loc != loc) || M.buckled || src.buckled_mob || M.pinned.len || (buckle_require_restraints && !M.restrained()) || M == src)
		return 0

	//reset pulling
	if(M.pulledby)
		var/mob/P = M.pulledby
		if(P.pulling)
			P.pulling = null
		M.pulledby = null

	M.buckled = src
	M.set_dir(dir)
	M.update_canmove()
	buckled_mob = M
	post_buckle_mob(M)
	M.throw_alert("buckled", new_master = src)
	correct_pixel_shift(M)
	return 1

/atom/movable/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src && buckled_mob.can_unbuckle(usr))
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob.clear_alert("buckled")
		correct_pixel_shift(buckled_mob)
		buckled_mob = null

		post_buckle_mob(.)

/atom/movable/proc/correct_pixel_shift(mob/living/carbon/C)
	if(!istype(C))
		return
	if(C.lying)
		C.pixel_x = C.get_standard_pixel_x_offset()
		C.pixel_y = C.get_standard_pixel_y_offset()

/atom/movable/proc/post_buckle_mob(mob/living/M)
	return

/atom/movable/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!ticker)
		to_chat(user, "<span class='warning'>You can't buckle anyone in before the game starts.</span>")

	if(!user.Adjacent(M) || user.incapacitated() || user.lying || ispAI(user) || ismouse(user))
		return

	if(istype(M, /mob/living/simple_animal/construct))
		to_chat(user, "<span class='warning'>The [M] is floating in the air and can't be buckled.</span>")
		return

	if(isslime(M))
		to_chat(user, "<span class='warning'>The [M] is too squishy to buckle in.</span>")
		return

	add_fingerprint(user)
	unbuckle_mob()

	if(buckle_mob(M))
		if(M == user)
			M.visible_message(\
				"<span class='notice'>[M.name] buckles themselves to [src].</span>",\
				"<span class='notice'>You buckle yourself to [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='danger'>[M.name] is buckled to [src] by [user.name]!</span>",\
				"<span class='danger'>You are buckled to [src] by [user.name]!</span>",\
				"<span class='notice'>You hear metal clanking.</span>")

/atom/movable/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				"<span class='notice'>[M.name] was unbuckled by [user.name]!</span>",\
				"<span class='notice'>You were unbuckled from [src] by [user.name].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		else
			M.visible_message(\
				"<span class='notice'>[M.name] unbuckled themselves!</span>",\
				"<span class='notice'>You unbuckle yourself from [src].</span>",\
				"<span class='notice'>You hear metal clanking.</span>")
		add_fingerprint(user)
	return M
