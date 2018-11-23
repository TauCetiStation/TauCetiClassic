/*
	Telekinesis

	This needs more thinking out, but I might as well.
*/
var/const/tk_maxrange = 15

/*
	Telekinetic attack:

	By default, emulate the user's unarmed attack
*/
/atom/proc/attack_tk(mob/user)
	if(user.stat)
		return
	user.UnarmedAttack(src,0) // attack_hand, attack_paw, etc

/obj/attack_tk(mob/user)
	if(user.stat)
		return
	if(istype(loc, /mob))
		if(user.a_intent == I_HELP)
			var/mob/M = loc
			M.drop_from_inventory(src, M.loc)
			return
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, get_turf(src))
		return
	switch(user.a_intent)
		if(I_HELP)
			if(istype(src, /obj/item) && Adjacent(user)) // Even telekinesis requires being near clothing to put it on.
				user.equip_to_appropriate_slot(src)
			else
				user.UnarmedAttack(src, 0)
		if(I_GRAB)
			var/obj/item/tk_grab/O = new(src)
			user.put_in_active_hand(O)
			O.host = user
			O.focus_object(src)
		else
			user.UnarmedAttack(src, 0)

/mob/living/attack_tk(mob/user)
	if(user.stat)
		return
	var/psy_resist_chance = 50 + (get_dist(src, user) * 2)// A chance that our target will not be affected.

	if(a_intent == I_HELP)
		psy_resist_chance = 0
	else if(stat)
		psy_resist_chance = 0
	if(!prob(psy_resist_chance))
		switch(user.a_intent)
			if(I_DISARM)
				drop_item(loc)
			if(I_GRAB)
				var/obj/item/tk_grab/O = new(src)
				user.put_in_active_hand(O)
				O.host = user
				O.focus_object(src)
			if(I_HURT)
				apply_effect(3, PARALYZE)
	else
		to_chat(host, "<span class='notice'>[src] is resisting your efforts.</span>")

/*
	This is similar to item attack_self, but applies to anything
	that you can grab with a telekinetic grab.

	It is used for manipulating things at range, for example, opening and closing closets.
	There are not a lot of defaults at this time, add more where appropriate.
*/
/atom/proc/attack_self_tk(mob/user)
	return user.do_telekinesis(get_dist(src, user))

/obj/item/attack_self_tk(mob/user)
	. = ..()
	if(.)
		attack_self(user)

/mob/attack_self_tk(mob/user)
	. = ..()
	if(.)
		var/obj/item/I
		if(user.hand)
			I = l_hand
		else
			I = r_hand

		if(I)
			I.attack_self(user)

/*
	TK Grab Item (the workhorse of old TK)

	* If you have not grabbed something, do a normal tk attack
	* If you have something, throw it at the target.  If it is already adjacent, do a normal attackby()
	* If you click what you are holding, or attack_self(), do an attack_self_tk() on it.
	* Deletes itself if it is ever not in your hand, or if you should have no access to TK.
*/
/obj/item/tk_grab
	name = "Telekinetic Grab"
	desc = "Magic."
	icon = 'icons/obj/magic.dmi'//Needs sprites
	icon_state = "2"
	flags = NOBLUDGEON | ABSTRACT
	//item_state = null
	w_class = 10.0
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

	var/last_throw = 0
	var/atom/movable/focus = null
	var/mob/living/host = null

/obj/item/tk_grab/dropped(mob/user)
	if(focus && user && loc != user && loc != user.loc) // drop_item() gets called when you tk-attack a table/closet with an item
		if(focus.Adjacent(loc))
			focus.loc = loc

	qdel(src)

	//stops TK grabs being equipped anywhere but into hands
/obj/item/tk_grab/equipped(mob/user, slot)
	if((slot == slot_l_hand) || (slot == slot_r_hand))
		return
	qdel(src)

/obj/item/tk_grab/attack_self(mob/user)
	if(focus && !QDELING(focus))
		apply_focus_overlay()
		focus.attack_self_tk(user)

/obj/item/tk_grab/attack_hand(mob/user)
	if(focus && !QDELING(focus))
		apply_focus_overlay()
		focus.attack_hand(user)

// Since we ourselves can telekinetically do this, this is useless.
/*
/obj/item/tk_grab/MouseDrop_T(atom/A)
	if(istype(A, /obj/item/tk_grab))
		var/obj/item/tk_grab/T = A
		if(focus && T.focus)
			focus.MouseDrop_T(T.focus, host)
	else if(focus)
		focus.MouseDrop_T(A, host)
*/

/obj/item/tk_grab/afterattack(atom/target, mob/living/user, proximity, params)//TODO: go over this
	if(!target || !user)
		return
	if(last_throw + 5 > world.time)
		return
	if(!host || host != user)
		qdel(src)
		return
	if(!(TK in host.mutations))
		qdel(src)
		return

	var/d = get_dist(user, target)
	if(focus)
		d = max(d, get_dist(user,focus) + get_dist(target, focus)) // whichever is further
	switch(d)
		if(0)
			;
		if(1 to 5) // not adjacent may mean blocked by window
			if(!proximity)
				host.SetNextMove(2)
		if(5 to 7)
			host.SetNextMove(5)
		if(8 to tk_maxrange)
			host.SetNextMove(10)
		else
			to_chat(user, "<span class='notice'>Your mind won't reach that far.</span>")
			return

	if(!host.do_telekinesis(d))
		return

	if(!focus)
		focus_object(target, user)
		return

	apply_focus_overlay()


	if(isliving(focus))
		var/mob/living/M = focus
		user.nutrition -= 10 // Manipulating living beings is TOUGH!

		var/psy_resist_chance = 50 + (d * 2) // A chance that our poor mob might resist our efforts to make him beat something up.
		if(target == M)
			psy_resist_chance += 30 // Resisting yourself being beaten up is kinda easier.
		if(M.a_intent == I_HELP)
			psy_resist_chance = 0
		else if(M.stat)
			psy_resist_chance = 0
		else if(M == host) // Tis' a feature.
			psy_resist_chance = 0

		if(prob(psy_resist_chance))
			to_chat(host, "<span class='notice'>[M] is resisting our efforts.</span>")
			return

		switch(host.a_intent)
			if(I_DISARM)
				M.drop_item()
			if(I_GRAB)
				step_towards(M, target)
			if(I_HURT)
				var/obj/item/I
				if(host.hand)
					I = M.l_hand
				else
					I = M.r_hand

				var/old_zone_sel = M.zone_sel
				M.zone_sel = host.zone_sel

				if(target.Adjacent(M))
					if(I)
						var/resolved = target.attackby(I, M, params)
						if(!resolved && target && I)
							I.afterattack(target, M, 1)
					else
						M.UnarmedAttack(target, 0)
				else
					if(I)
						I.afterattack(target, M, 0)
				M.zone_sel = old_zone_sel
		last_throw = world.time // So we don't allow them to spam.
		return

	else if(istype(focus, /obj/item))
		if(!istype(target, /turf) || host.a_intent == I_HURT)
			var/obj/item/I = focus
			if(target.Adjacent(focus))
				var/resolved = target.attackby(I, user, params)
				if(!resolved && target && I)
					I.afterattack(target, user, 1)
			else
				I.afterattack(target, user, 0)
			last_throw = world.time // So we don't allow them to spam.
			return

	if(!focus.anchored)
		focus.throw_at(target, 10, 1, user)
		last_throw = world.time

/obj/item/tk_grab/attack(mob/living/M, mob/living/user, def_zone)
	return


/obj/item/tk_grab/proc/focus_object(atom/movable/target, mob/living/user)
	if(!istype(target, /atom/movable))
		return
	focus = target
	update_icon()
	apply_focus_overlay()

/obj/item/tk_grab/proc/apply_focus_overlay()
	if(!focus)
		return
	var/obj/effect/overlay/O = new /obj/effect/overlay(get_turf(focus))
	O.name = "sparkles"
	O.anchored = TRUE
	O.density = FALSE
	O.layer = FLY_LAYER
	O.dir = pick(cardinal)
	O.icon = 'icons/effects/effects.dmi'
	O.icon_state = "nothing"
	flick("empdisable", O)
	QDEL_IN(O, 5)
	var/obj/effect/overlay/O2 = new /obj/effect/overlay(get_turf(host))
	O2.name = "sparkles"
	O2.anchored = TRUE
	O2.density = FALSE
	O2.layer = FLY_LAYER
	O2.dir = pick(cardinal)
	O2.icon = 'icons/effects/effects.dmi'
	O2.icon_state = "nothing"
	flick("empdisable", O2)
	QDEL_IN(O2, 5)

/obj/item/tk_grab/update_icon()
	overlays.Cut()
	if(focus && focus.icon && focus.icon_state)
		overlays += icon(focus.icon,focus.icon_state)
	return

/*Not quite done likely needs to use something thats not get_step_to
	proc/check_path()
		var/turf/ref = get_turf(src.loc)
		var/turf/target = get_turf(focus.loc)
		if(!ref || !target)	return 0
		var/distance = get_dist(ref, target)
		if(distance >= 10)	return 0
		for(var/i = 1 to distance)
			ref = get_step_to(ref, target, 0)
		if(ref != target)	return 0
		return 1
*/

//equip_to_slot_or_del(obj/item/W, slot, del_on_fail = 1)
/*
		if(istype(user, /mob/living/carbon))
			if(user:mutations & TK && get_dist(source, user) <= 7)
				if(user:get_active_hand())	return 0
				var/X = source:x
				var/Y = source:y
				var/Z = source:z

*/

