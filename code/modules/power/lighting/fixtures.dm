/obj/item/light_fixture_frame
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags = CONDUCT
	var/fixture_type = "tube"
	var/obj/machinery/light/newlight = null
	var/sheets_refunded = 2

/obj/item/light_fixture_frame/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		deconstruct(TRUE)
		user.SetNextMove(CLICK_CD_RAPID)
		return
	return ..()

/obj/item/light_fixture_frame/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(get_turf(loc), sheets_refunded)
	..()

/obj/item/light_fixture_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf_loc(usr)
	if (!isfloorturf(loc))
		to_chat(usr, "<span class='warning'>[src.name] cannot be placed on this spot.</span>")
		return
	to_chat(usr, "Attaching [src] to the wall.")
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (usr.is_busy() || !do_after(usr, 30, target = on_wall))
		return
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
	newlight.set_dir(constrdir)
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)

/obj/item/light_fixture_frame/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	flags = CONDUCT
	fixture_type = "bulb"
	sheets_refunded = 1

/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = 5
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/atom_init()
	. = ..()
	if (fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	if (src in view(2, user))
		switch(src.stage)
			if(1)
				to_chat(user, "It's an empty frame.")
			if(2)
				to_chat(user, "It's wired.")
			if(3)
				to_chat(user, "The casing is closed.")

/obj/machinery/light_construct/attackby(obj/item/weapon/W, mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if (iswrenching(W))
		if (src.stage == 1)
			if(user.is_busy(src))
				return
			to_chat(user, "You begin deconstructing [src].")
			if(!W.use_tool(src, usr, 30, volume = 75))
				return
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			deconstruct(TRUE)
			return
		if (src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

		if (src.stage == 3)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(iscutter(W))
		if (src.stage != 2)
			return
		src.stage = 1
		switch(fixture_type)
			if ("tube")
				src.icon_state = "tube-construct-stage1"
			if("bulb")
				src.icon_state = "bulb-construct-stage1"
		new /obj/item/stack/cable_coil/random(get_turf(src.loc), 1)
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		return

	if(iscoil(W))
		if (src.stage != 1)
			return
		var/obj/item/stack/cable_coil/coil = W
		if(!coil.use(1))
			return
		switch(fixture_type)
			if ("tube")
				src.icon_state = "tube-construct-stage2"
			if("bulb")
				src.icon_state = "bulb-construct-stage2"
		src.stage = 2
		user.visible_message("[user.name] adds wires to [src].", \
			"You add wires to [src].")
		return

	if(isscrewing(W))
		if (src.stage == 2)
			switch(fixture_type)
				if ("tube")
					src.icon_state = "tube-empty"
				if("bulb")
					src.icon_state = "bulb-empty"
			src.stage = 3
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

			switch(fixture_type)

				if("tube")
					newlight = new /obj/machinery/light/built(src.loc)
				if ("bulb")
					newlight = new /obj/machinery/light/small/built(src.loc)

			newlight.set_dir(src.dir)
			transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()

/obj/machinery/light_construct/deconstruct(disassembled) // why tf construct is machinery?
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, sheets_refunded)
	..()

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = TRUE
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1
