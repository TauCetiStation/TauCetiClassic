/obj/item/inflatable
	name = "inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall"
	w_class = SIZE_SMALL
	var/inflatable_type = /obj/structure/inflatable

/obj/item/inflatable/attack_self(mob/user)
	if(user.is_busy()) return
	playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
	user.visible_message(
		"<span class='notice'>[user] starts inflating \the [src]...</span>",
		"<span class='notice'>You start inflating \the [src]...</span>"
	)
	if(do_after(user, 40, target = user))
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER)
		user.visible_message(
			"<span class='notice'>[user] inflated \the [src].</span>",
			"<span class='notice'>You inflate \the [src].</span>"
		)
		var/obj/structure/inflatable/R = new inflatable_type(user.loc)
		transfer_fingerprints_to(R)
		R.add_fingerprint(user)
		qdel(src)

/obj/structure/inflatable
	name = "inflatable wall"
	desc = "An inflated membrane. Do not puncture."
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "wall"

	max_integrity = 50
	resistance_flags = CAN_BE_HIT


/obj/structure/inflatable/atom_init()
	. = ..()
	update_nearby_tiles()

/obj/structure/inflatable/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/inflatable/CanPass(atom/movable/mover, turf/target, height=0)
	return 0

/obj/structure/inflatable/attack_paw(mob/user)
	return attack_generic(user, 15, BRUTE, MELEE)

/obj/structure/inflatable/attack_hand(mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	return

/obj/structure/inflatable/deconstruct(disassembled)
	deflate(1)

/obj/structure/inflatable/attackby(obj/item/weapon/W, mob/user)
	if(W.can_puncture())
		visible_message("<span class='warning'><b>[user] pierces [src] with [W]!</b></span>")
		deflate(1)
		return
	..()

/obj/structure/inflatable/play_attack_sound(damage_amount, damage_type, damage_flag)
	playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)

/obj/structure/inflatable/proc/deflate(violent=0)
	playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/torn/R = new /obj/item/inflatable/torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		//user << "<span class='notice'>You slowly deflate the inflatable wall.</span>"
		visible_message("[src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/R = new /obj/item/inflatable(loc)
			transfer_fingerprints_to(R)
			qdel(src)

/obj/structure/inflatable/verb/hand_deflate()
	set name = "Deflate"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return
	deflate()

/obj/item/inflatable/door
	name = "inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door"
	inflatable_type = /obj/structure/inflatable/door

/obj/structure/inflatable/door //Based on mineral door code
	name = "inflatable door"
	density = TRUE
	anchored = TRUE
	opacity = 0

	icon = 'icons/obj/inflatable.dmi'
	icon_state = "door_closed"
	var/opening_state = "door_opening"
	var/closing_state = "door_closing"
	var/open_state = "door_open"
	var/closed_state = "door_closed"

	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0

///obj/structure/inflatable/door/Bumped(atom/user)
//	..()
//	if(!state)
//		return TryToSwitchState(user)
//	return

/obj/structure/inflatable/door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user)) //but cyborgs can
		if(get_dist(user,src) <= 1) //not remotely though
			return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_paw(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/inflatable/door/c_airblock(turf/other)
	return ..() | ZONE_BLOCKED

/obj/structure/inflatable/door/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/inflatable/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(world.time - last_bumped <= 22)
		return
	last_bumped = world.time
	if(ismob(user))
		var/mob/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/inflatable/door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()
	update_nearby_tiles()

/obj/structure/inflatable/door/proc/Open()
	isSwitchingStates = 1
	//playsound(src, 'sound/effects/stonedoor_openclose.ogg', VOL_EFFECTS_MASTER)
	flick(opening_state,src)
	sleep(10)
	density = FALSE
	opacity = 0
	state = 1
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/proc/Close()
	isSwitchingStates = 1
	//playsound(src, 'sound/effects/stonedoor_openclose.ogg', VOL_EFFECTS_MASTER)
	flick(closing_state,src)
	sleep(10)
	density = TRUE
	opacity = 0
	state = 0
	update_icon()
	isSwitchingStates = 0

/obj/structure/inflatable/door/update_icon()
	if(state)
		icon_state = open_state
	else
		icon_state = closed_state

/obj/structure/inflatable/door/deflate(violent=0)
	playsound(src, 'sound/machines/hiss.ogg', VOL_EFFECTS_MASTER)
	if(violent)
		visible_message("[src] rapidly deflates!")
		var/obj/item/inflatable/door/torn/R = new /obj/item/inflatable/door/torn(loc)
		transfer_fingerprints_to(R)
		qdel(src)
	else
		//user << "<span class='notice'>You slowly deflate the inflatable wall.</span>"
		visible_message("[src] slowly deflates.")
		spawn(50)
			var/obj/item/inflatable/door/R = new /obj/item/inflatable/door(loc)
			transfer_fingerprints_to(R)
			qdel(src)


/obj/item/inflatable/torn
	name = "torn inflatable wall"
	desc = "A folded membrane which rapidly expands into a large cubical shape on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_wall_torn"

/obj/item/inflatable/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable wall is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/inflatable/door/torn
	name = "torn inflatable door"
	desc = "A folded membrane which rapidly expands into a simple door on activation. It is too torn to be usable."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "folded_door_torn"

/obj/item/inflatable/door/torn/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The inflatable door is too torn to be inflated!</span>")
	add_fingerprint(user)

/obj/item/weapon/storage/briefcase/inflatable
	name = "inflatable barrier box"
	desc = "Contains inflatable walls and doors."
	icon_state = "inf_box"
	item_state = "inf_box"

/obj/item/weapon/storage/briefcase/inflatable/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/inflatable/door(src)
	for (var/i in 1 to 4)
		new /obj/item/inflatable(src)
