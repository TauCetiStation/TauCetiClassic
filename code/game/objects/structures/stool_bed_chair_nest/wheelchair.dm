/obj/structure/stool/bed/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Either by will or force."
	icon_state = "wheelchair"
	anchored = FALSE
	buckle_movable = 1
	flags = NODECONSTRUCT

	var/driving = 0
	var/mob/living/pulling = null
	var/bloodiness
	var/brake = 0
	var/alert = 0

/obj/structure/stool/bed/chair/wheelchair/handle_rotation()
	cut_overlays()
	var/image/O = image(icon = 'icons/obj/objects.dmi', icon_state = "w_overlay", layer = FLY_LAYER, dir = src.dir)
	add_overlay(O)
	if(buckled_mob)
		buckled_mob.set_dir(dir)

/obj/structure/stool/bed/chair/wheelchair/post_buckle_mob(mob/living/M)
	. = ..()
	if(!buckled_mob && alert)
		M.clear_alert("brake")
		alert = 0

/obj/structure/stool/bed/chair/wheelchair/verb/toggle_brake()
	set name = "Toggle brake"
	set category = "Object"
	set src in oview(1)

	brake = !brake

	if(isliving(usr))
		var/mob/living/M = usr
		if(buckled_mob == M)
			if(brake)
				M.throw_alert("brake", /atom/movable/screen/alert/brake)
				alert = 1
			else
				M.clear_alert("brake")
				alert = 0
	if(brake)
		to_chat(usr, "<span class='notice'>You turn the brake on.</span>")
	else
		to_chat(usr, "<span class='notice'>You turn the brake off.</span>")

/obj/structure/stool/bed/chair/wheelchair/relaymove(mob/user, direction)
	if(brake)
		to_chat(user, "<span class='red'>You cannot drive while brake is on.</span>")
		return
	if(user.incapacitated())
		if(user==pulling)
			pulling = null
			user.pulledby = null
			to_chat(user, "<span class='red'>You lost your grip!</span>")
		return
	if(user.pulling && (user == pulling))
		pulling = null
		user.pulledby = null
		return
	if(propelled)
		return
	if(pulling && (get_dist(src, pulling) > 1))
		pulling = null
		user.pulledby = null
		if(user==pulling)
			return
	if(pulling && (get_dir(src.loc, pulling.loc) == direction))
		to_chat(user, "<span class='red'>You cannot go there.</span>")
		return
	if(pulling && buckled_mob && (buckled_mob == user))
		to_chat(user, "<span class='red'>You cannot drive while being pushed.</span>")
		return

	if(ishuman(user))
		var/mob/living/carbon/human/driver = user
		var/obj/item/organ/external/l_hand = driver.bodyparts_by_name[BP_L_ARM]
		var/obj/item/organ/external/r_hand = driver.bodyparts_by_name[BP_R_ARM]
		if((!l_hand || (l_hand.is_stump)) && (!r_hand || (r_hand.is_stump)))
			return // No hands to drive your chair? Tough luck!

	// Let's roll
	driving = 1
	var/turf/T = null
	//--1---Move occupant---1--//
	if(buckled_mob)
		buckled_mob.buckled = null
		step(buckled_mob, direction)
		buckled_mob.client?.move_delay += 2
		buckled_mob.buckled = src
	//--2----Move driver----2--//
	if(pulling)
		T = pulling.loc
		if(get_dist(src, pulling) >= 1)
			step(pulling, get_dir(pulling.loc, src.loc))
	//--3--Move wheelchair--3--//
	if(!buckled_mob)
		step(src, direction)
	else
		Move(buckled_mob.loc)
	set_dir(direction)
	handle_rotation()
	if(pulling) // Driver
		if(pulling.loc == src.loc) // We moved onto the wheelchair? Revert!
			pulling.loc = T
		else
			spawn(0)
			if(get_dist(src, pulling) > 1) // We are too far away? Losing control.
				pulling = null
				user.pulledby = null
			pulling.set_dir(get_dir(pulling, src)) // When everything is right, face the wheelchair
	if(bloodiness)
		create_track()
	driving = 0

/obj/structure/stool/bed/chair/wheelchair/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(brake)
		return FALSE
	. = ..()
	if(buckled_mob)
		var/mob/living/occupant = buckled_mob
		if(!driving)
			occupant.buckled = null
			occupant.Move(src.loc)
			occupant.buckled = src
			if (occupant && (src.loc != occupant.loc))
				if (propelled)
					for (var/mob/O in src.loc)
						if (O != occupant)
							Bump(O)
				else
					unbuckle_mob()
			if (pulling && (get_dist(src, pulling) > 1))
				pulling.pulledby = null
				to_chat(pulling, "<span class='red'>You lost your grip!</span>")
				pulling = null
		else
			if (occupant && (src.loc != occupant.loc))
				src.loc = occupant.loc // Failsafe to make sure the wheelchair stays beneath the occupant after driving
	if(has_gravity(src))
		playsound(src, 'sound/effects/roll.ogg', VOL_EFFECTS_MASTER)
	handle_rotation()

/obj/structure/stool/bed/chair/wheelchair/attack_hand(mob/living/user)
	if (pulling)
		MouseDrop(usr)
	else
		user_unbuckle_mob(user)
	return

/obj/structure/stool/bed/chair/wheelchair/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr))	return
		if(usr == buckled_mob)
			to_chat(usr, "<span class='red'>You realize you are unable to push the wheelchair you sit in.</span>")
			return
		if(!pulling)
			pulling = usr
			usr.pulledby = src
			if(usr.pulling)
				usr.stop_pulling()
			usr.set_dir(get_dir(usr, src))
			to_chat(usr, "You grip \the [name]'s handles.")
		else
			if(usr != pulling)
				visible_message("<span class='red'>[usr] breaks [pulling]'s grip on the wheelchair.</span>")
			else
				to_chat(usr, "You let go of \the [name]'s handles.")
			pulling.pulledby = null
			pulling = null
		return

/obj/structure/stool/bed/chair/wheelchair/proc/create_track()
	var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
	var/newdir = get_dir(get_step(loc, dir), loc)
	if(newdir == dir)
		B.set_dir(newdir)
	else
		newdir = newdir | dir
		if(newdir == 3)
			newdir = 1
		else if(newdir == 12)
			newdir = 4
		B.set_dir(newdir)
	bloodiness--
