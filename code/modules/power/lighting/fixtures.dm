/* object part */
/obj/item/light_fixture_frame
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags = CONDUCT
	var/fitting = LAMP_FITTING_TUBE
	var/sheets_refunded = 2

/obj/item/light_fixture_frame/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	flags = CONDUCT
	fitting = LAMP_FITTING_BULB
	sheets_refunded = 1

/obj/item/light_fixture_frame/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		deconstruct(TRUE)
		user.SetNextMove(CLICK_CD_RAPID)
		return
	return ..()

/obj/item/light_fixture_frame/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	if(disassembled) // don't spawn small shit if we in mass destruction event
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
		to_chat(usr, "<span class='warning'>[name] cannot be placed on this spot.</span>")
		return
	to_chat(usr, "Attaching [src] to the wall.")
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (usr.is_busy() || !do_after(usr, 30, target = on_wall))
		return

	var/obj/machinery/light_construct/construct
	switch(fitting)
		if(LAMP_FITTING_BULB)
			construct = new /obj/machinery/light_construct/small(constrloc)
		if(LAMP_FITTING_TUBE)
			construct = new /obj/machinery/light_construct(constrloc)
	construct.set_dir(constrdir)
	transfer_fingerprints_to(construct)

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)


#define STAGE_START 1
#define STAGE_COILED 2
#define STAGE_SCREWED 3 // spoiler: no such stage, we just spawn lamp

/* wall machinery(?) part */

/obj/machinery/light_construct // why tf construct is machinery?
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = LAMPS_LAYER
	var/stage = STAGE_START
	var/fitting = LAMP_FITTING_TUBE
	var/sheets_refunded = 2

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = TRUE
	fitting = LAMP_FITTING_BULB
	sheets_refunded = 1

/obj/machinery/light_construct/atom_init()
	. = ..()
	if (fitting == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	if (src in view(2, user))
		switch(stage)
			if(STAGE_START)
				to_chat(user, "It's an empty frame.")
			if(STAGE_COILED)
				to_chat(user, "It's wired.")
			if(STAGE_SCREWED)
				to_chat(user, "The casing is closed.")

/obj/machinery/light_construct/attackby(obj/item/weapon/W, mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if (iswrenching(W))
		if (stage == STAGE_START)
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
		if (stage == STAGE_COILED)
			to_chat(usr, "You have to remove the wires first.")
			return

		if (stage == STAGE_SCREWED)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(iscutter(W))
		if (stage != STAGE_COILED)
			return
		if(!W.use_tool(src, usr, 30, volume = 75))
			return
		stage = STAGE_START
		switch(fitting)
			if(LAMP_FITTING_BULB)
				icon_state = "tube-construct-stage1"
			if(LAMP_FITTING_TUBE)
				icon_state = "bulb-construct-stage1"

		new /obj/item/stack/cable_coil/random(get_turf(loc), 1)
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		return

	if(iscoil(W))
		if (stage != STAGE_START)
			return
		if(!W.use_tool(src, usr, 30, amount = 1, volume = 75))
			return
		switch(fitting)
			if(LAMP_FITTING_BULB)
				icon_state = "bulb-construct-stage2"
			if(LAMP_FITTING_TUBE)
				icon_state = "tube-construct-stage2"
		stage = STAGE_COILED
		user.visible_message("[user.name] adds wires to [src].", \
			"You add wires to [src].")
		return

	if(isscrewing(W))
		if (stage != STAGE_COILED)
			return
		if(!W.use_tool(src, usr, 30, volume = 75))
			return

		user.visible_message("[user.name] closes [src]'s casing.", \
			"You close [src]'s casing.", "You hear a noise.")

		var/obj/machinery/light/newlight
		switch(fitting)
			if(LAMP_FITTING_BULB)
				newlight = new /obj/machinery/light/small/built(loc)
			if(LAMP_FITTING_TUBE)
				newlight = new /obj/machinery/light/built(loc)

		newlight.set_dir(dir)
		transfer_fingerprints_to(newlight)
		qdel(src)
		return
	..()

/obj/machinery/light_construct/deconstruct(disassembled) 
	if(flags & NODECONSTRUCT)
		return ..()

	if(disassembled)
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)

	..()

#undef STAGE_START
#undef STAGE_COILED
#undef STAGE_SCREWED
