/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	flags = HEAR_TALK
	density = TRUE
	layer = CONTAINER_STRUCTURE_LAYER

	max_integrity = 100
	damage_deflection = 15
	resistance_flags = CAN_BE_HIT

	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/locked = 0
	var/broken = 0
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/lastbang
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.

/obj/structure/closet/atom_init(mapload)
	. = ..()
	closet_list += src
	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		for(var/obj/O in src.loc)
			if(O.density || O.anchored || O == src)
				continue
			O.forceMove(src)
	PopulateContents()
	update_icon()

	AddComponent(/datum/component/clickplace)

/obj/structure/closet/Destroy()
	closet_list -= src
	return ..()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0)
	if(wall_mounted)
		return TRUE
	return ..()

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.forceMove(src.loc)

	for(var/mob/M in src)
		M.forceMove(src.loc)
		M.instant_vision_update(0)

	for(var/obj/I in src)
		I.forceMove(src.loc)

/obj/structure/closet/proc/collect_contents()
	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src.loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/living/M in loc)
		if(itemcount >= storage_capacity)
			break
		if(M.buckled)
			continue

		M.forceMove(src)
		M.instant_vision_update(1,src)
		itemcount++

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!can_open())
		return 0

	src.icon_state = src.icon_opened
	src.opened = 1

	dump_contents()

	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER, 15, FALSE, null, -3)
	else
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, FALSE, null, -3)
	density = FALSE
	SSdemo.mark_dirty(src)
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!can_close())
		return 0

	collect_contents()

	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER, 15, FALSE, null, -3)
	else
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, FALSE, null, -3)
	density = TRUE
	SSdemo.mark_dirty(src)
	return 1

/obj/structure/closet/proc/toggle(mob/user)
	if(!(src.opened ? close() : open()))
		to_chat(user, "<span class='notice'>It won't budge!</span>")
	return

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return
	for(var/atom/A in src)//pulls everything out of the locker and hits it with an explosion
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += A
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += A
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += A
	dump_contents()
	qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W, mob/user)
	if(tools_interact(W, user))
		add_fingerprint(user)
		return

	else if(opened || istype(W, /obj/item/weapon/grab))
		return ..()

	else if(istype(W, /obj/item/weapon/packageWrap))
		return

	else if(istagger(W))
		return

	else
		attack_hand(user)

/obj/structure/closet/proc/tools_interact(obj/item/weapon/W, mob/user)
	if(iswelding(W))
		var/obj/item/weapon/weldingtool/WT = W
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!WT.isOn())
			return FALSE
		if(WT.use(0, user) && W.use_tool(src, user, 20, volume = 100))
			if(opened)
				user.visible_message("[user] cut apart [src] with [WT].",
				                     "<span class='notice'>You cut apart [src] with [WT].</span>")
				deconstruct(TRUE)
				return TRUE
			else
				src.welded = !src.welded
				update_icon()
				user.visible_message("[user] [welded?"welded":"unwelded"] [src]'s shutter with [WT].",
				                     "<span class='notice'>You [welded?"welded":"remove weld from"] [src]'s shutter with [WT].</span>")
				return TRUE
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return TRUE

/obj/structure/closet/deconstruct(disassembled)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
	dump_contents()
	return ..()

/obj/structure/closet/play_attack_sound(damage_amount, damage_type, damage_flag)
	playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.incapacitated() || !isturf(src.loc))
		return

	if(!open())
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0


/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	toggle(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(usr.incapacitated())
		return

	if(ishuman(usr))
		add_fingerprint(usr)
		toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	cut_overlays()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			add_overlay("welded")
	else
		icon_state = icon_opened
	SSdemo.mark_dirty(src)

/obj/structure/closet/hear_talk(mob/M, text, verb, datum/language/speaking)
	for (var/atom/A in src) // todo: we need it? say() should already catch all objects recursively
		if(istype(A,/obj))
			var/obj/O = A
			O.hear_talk(M, text, verb, speaking)

/obj/structure/closet/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2 //2 minutes by default
	//if(istype(user.loc, /obj/structure/closet/critter) && !welded)
	//	breakout_time = 0.75 //45 seconds if it's an unwelded critter crate

	if(opened || (!welded && !locked))
		return  //Door's open, not locked or welded, no point in resisting.

	//okay, so the closet is either welded or locked... resist!!!
	user.SetNextMove(100)
	user.last_special = world.time + 100
	visible_message(
		"<span class='warning'>[src] begins to shake violently!</span>"
	)
	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>")

	if(do_after(user, (breakout_time MINUTES), target=src))
		if(!user || user.loc != src || opened || (!locked && !welded))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")
		open()
