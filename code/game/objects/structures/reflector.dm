#define SINGLE_GLASS_COST 5
#define DOUBLE_GLASS_COST 10
#define BOX_DIAMOND_COST 1

/obj/structure/reflector
	name = "reflector frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	desc = "A frame to create a reflector.\n<span class='notice'>Use <b>5</b> sheets of <b>glass</b> to create a 1 way reflector.\nUse <b>10</b> sheets of <b>reinforced glass</b> to create a 2 way reflector.\nUse <b>1 diamond</b> to create a reflector cube.</span>"
	anchored = FALSE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/finished = FALSE

/obj/structure/reflector/bullet_act(obj/item/projectile/P)
	var/turf/reflector_turf = get_turf(src)
	var/turf/reflect_turf

	if(!istype(P, /obj/item/projectile/beam))
		return ..()

	var/new_dir = get_reflection(dir, P.dir)

	if(new_dir)
		reflect_turf = get_step(reflector_turf, new_dir)
		var/obj/item/projectile/beam/reflected = new P.type(reflector_turf)
		reflected.original = reflect_turf
		reflected.starting = reflector_turf
		reflected.firer = src
		reflected.def_zone = "chest"
		reflected.dir = new_dir
		reflected.yo = reflect_turf.y - reflector_turf.y
		reflected.xo = reflect_turf.x - reflector_turf.x
		reflected.process()

	qdel(P)

	return PROJECTILE_FORCE_MISS

/obj/structure/reflector/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	//Finishing the frame
	var/obj/item/stack/sheet/sheet = I
	if(istype(sheet))
		add_fingerprint(user)
		if(finished)
			to_chat(user, "<span class='warning'>The reflector is already completed!</span>")
			return TRUE

		if(istype(sheet, /obj/item/stack/sheet/glass))
			if(!sheet.use(SINGLE_GLASS_COST))
				to_chat(user, "<span class='warning'>You need at least [SINGLE_GLASS_COST] sheets of glass to create a reflector!</span>")
				return TRUE
			var/obj/structure/reflector/single/reflector = new(loc)
			transfer_fingerprints_to(reflector)
			reflector.add_fingerprint(user)
			qdel(src)
			return TRUE

		if(istype(sheet, /obj/item/stack/sheet/rglass))
			if(!sheet.use(DOUBLE_GLASS_COST))
				to_chat(user, "<span class='warning'>You need at least [DOUBLE_GLASS_COST] sheets of reinforced glass to create a double reflector!</span>")
				return TRUE
			var/obj/structure/reflector/double/reflector = new(loc)
			transfer_fingerprints_to(reflector)
			reflector.add_fingerprint(user)
			qdel(src)
			return TRUE

		if(istype(sheet, /obj/item/stack/sheet/mineral/diamond))
			if(!sheet.use(BOX_DIAMOND_COST))
				to_chat(user, "<span class='warning'>You need at least [BOX_DIAMOND_COST] diamond to create a reflector box!</span>")
				return TRUE
			var/obj/structure/reflector/box/reflector = new(loc)
			transfer_fingerprints_to(reflector)
			reflector.add_fingerprint(user)
			qdel(src)
			return TRUE

	if(iswrenching(I))
		if(anchored)
			to_chat(user, "Unweld [src] first!")
			return TRUE
		if(!I.use_tool(src, user, 8 SECONDS, volume = 50))
			return TRUE
		to_chat(user, "<span class='notice'>You dismantle [src].</span>")
		playsound(user, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(loc, 5)
		qdel(src)
		return TRUE

	if(iswelding(I))
		if(anchored)
			to_chat(user, "<span class='notice'>You start cutting [src] free from the floor...</span>")
			if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
				return TRUE
			to_chat(user, "<span class='notice'>You cut [src] free from the floor.</span>")
			anchored = FALSE
		else
			to_chat(user, "<span class='notice'>You start welding [src] to the floor...</span>")
			if(!I.use_tool(src, user, 2 SECONDS, volume = 50))
				return TRUE
			to_chat(user, "<span class='notice'>You weld [src] to the floor.</span>")
			anchored = TRUE
		return TRUE

	return ..()

/obj/structure/reflector/proc/get_reflection(srcdir, pdir)
	return FALSE

/obj/structure/reflector/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || usr.restrained())
		to_chat(usr, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(anchored)
		to_chat(usr, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE

	dir = turn(dir, 270)
	return TRUE

/obj/structure/reflector/AltClick(mob/user)
	if(!Adjacent(user))
		return
	rotate()

// SINGLE
/obj/structure/reflector/single
	name = "reflector"
	icon = 'icons/obj/reflector.dmi'
	icon_state = "reflector"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = TRUE

/obj/structure/reflector/single/get_reflection(srcdir, pdir)
	switch(srcdir)
		if(NORTH)
			return (pdir == SOUTH) ? WEST : (pdir == EAST) ? NORTH : 0
		if(EAST)
			return (pdir == SOUTH) ? EAST : (pdir == WEST) ? NORTH : 0
		if(SOUTH)
			return (pdir == NORTH) ? EAST : (pdir == WEST) ? SOUTH : 0
		if(WEST)
			return (pdir == NORTH) ? WEST : (pdir == EAST) ? SOUTH : 0
	return FALSE

//DOUBLE
/obj/structure/reflector/double
	name = "double sided reflector"
	icon = 'icons/obj/reflector.dmi'
	icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting lasers. This one does so at a 90 degree angle."
	finished = TRUE

/obj/structure/reflector/double/get_reflection(srcdir, pdir)
	switch(srcdir)
		if(NORTH, SOUTH)
			switch(pdir)
				if(NORTH) return WEST
				if(EAST) return SOUTH
				if(SOUTH) return EAST
				if(WEST) return NORTH
		if(EAST, WEST)
			switch(pdir)
				if(NORTH) return EAST
				if(WEST) return SOUTH
				if(SOUTH) return WEST
				if(EAST) return NORTH
	return FALSE

//BOX
/obj/structure/reflector/box
	name = "reflector box"
	icon = 'icons/obj/reflector.dmi'
	icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser fire in a single direction."
	finished = TRUE

/obj/structure/reflector/box/get_reflection(srcdir, pdir)
	return srcdir

#undef SINGLE_GLASS_COST
#undef DOUBLE_GLASS_COST
#undef BOX_DIAMOND_COST
