/****************
* picture frame *
****************/

/obj/item/weapon/picture_frame
	name = "picture frame"
	cases = list("фоторамка", "фоторамки", "фоторамке", "фоторамку", "фоторамкой", "фоторамке")
	desc = "Рамка для картин или фотографий."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "wooden_frame"
	w_class = SIZE_TINY
	var/datum/weakref/displayed_weakref
	var/frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/Destroy()
	. = ..()
	if(displayed_weakref)
		var/obj/item/I = displayed_weakref?.resolve()
		QDEL_NULL(I)
		displayed_weakref = null

/obj/item/weapon/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/structure/picture_frame/metal

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/canvas))
		if(displayed_weakref)
			to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] не пуста.</span>")
			return

		if(istype(I, /obj/item/canvas))
			var/obj/item/canvas/Canvas = I
			if(!Canvas.finalized)
				to_chat(user, "<span class='notice'>[C_CASE(Canvas, NOMINATIVE_CASE)] не завершён.</span>")
				return

		if(!user.drop_from_inventory(I, src))
			return ..()

		displayed_weakref = WEAKREF(I)
		update_icon()
		return

	if(iswrenching(I))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(frame_type == /obj/structure/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(src.loc)
		else
			new /obj/item/stack/sheet/metal(src.loc)
		for(var/obj/C in contents)
			C.forceMove(get_turf(src))
		qdel(src)
		return

	return ..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		var/obj/item/I = displayed_weakref?.resolve()
		if(!I)
			return ..()
		if(!user.put_in_hands(I))
			return ..()

		to_chat(user, "<span class='notice'>Вы аккуратно достаёте [CASE(src, ACCUSATIVE_CASE)] из [CASE(src, GENITIVE_CASE)].</span>")
		displayed_weakref = null
		update_icon()
		return
	..()

/obj/item/weapon/picture_frame/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/picture_frame/examine(mob/user)
	var/obj/item/canvas/Canvas = displayed_weakref?.resolve()
	if(Canvas && (user.r_hand == src || user.l_hand == src))
		Canvas.show(user)
	else
		..()

/obj/item/weapon/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(!displayed_weakref)
		return

	var/obj/item/I = displayed_weakref?.resolve()
	if(istype(I, /obj/item/canvas))
		var/obj/item/canvas/Canvas = I
		icon_state = "[initial(icon_state)]_[Canvas.width]x[Canvas.height]"
		var/mutable_appearance/MA = mutable_appearance(Canvas.generated_icon)
		MA.pixel_x = Canvas.framed_offset_x
		MA.pixel_y = Canvas.framed_offset_y
		add_overlay(MA)
	else
		add_overlay(image(I.icon, "photo"))

/obj/item/weapon/picture_frame/proc/try_build(turf/on_wall)
	if (!Adjacent(on_wall))
		return
	var/ndir = get_dir(on_wall, usr)
	if(!(ndir in cardinal))
		return
	var/turf/T = get_turf(usr)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return

	if(A.always_unpowered)
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return

	if(gotwallitem(T, ndir))
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return


	var/obj/structure/picture_frame/PF = new frame_type(T, reverse_dir[ndir], 1)
	if(displayed_weakref)
		var/obj/item/I = displayed_weakref?.resolve()
		displayed_weakref = null
		I.forceMove(PF)
		PF.framed_weakref = WEAKREF(I)
	PF.set_dir(ndir)
	PF.update_icon()
	PF.update_name()
	qdel(src)

/obj/structure/picture_frame
	name = "picture frame"
	cases = list("фоторамка", "фоторамки", "фоторамке", "фоторамку", "фоторамкой", "фоторамке")
	desc = "Рамка для картин или фотографий."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "wooden_frame"
	anchored = TRUE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	var/datum/weakref/framed_weakref
	var/frame_type = /obj/item/weapon/picture_frame/wooden

	var/continuity_tag

/obj/structure/picture_frame/atom_init(mapload, ndir, building = 0)
	. = ..()
	if(building)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir == 1 ? 28 : -30) : 0
	update_icon()

	if(mapload && continuity_tag)
		AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(Write_Memory)), CALLBACK(src, PROC_REF(Read_Memory)), "/objects/picture_frames/[SSmapping.config.map_name]/[continuity_tag]", list(
			"canvas_size" = new /datum/continuity_field/string(
				in_list = list("11x11", "19x19", "23x19", "23x23", null)
			),
			"canvas_grid" = new /datum/continuity_field/listfield(
				can_be_null = TRUE,
				entry_config = new /datum/continuity_field/listfield(
					entry_config = new /datum/continuity_field/string(
						regex = @"^#[0-9a-f]{6}$"
					)
				)
			),
			"canvas_name" = new /datum/continuity_field/string(
				can_be_null = TRUE,
				max_length = 100
			),
		))

/obj/structure/picture_frame/proc/Read_Memory(list/save_data)
	var/can_size = save_data["canvas_size"]
	var/can_grid = save_data["canvas_grid"]
	var/can_name = save_data["canvas_name"]

	if(!(can_size && can_grid))
		return

	var/canvas_type = /obj/item/canvas/twentythree_twentythree
	switch(can_size)
		if("11x11")
			canvas_type = /obj/item/canvas
		if("19x19")
			canvas_type = /obj/item/canvas/nineteen_nineteen
		if("23x19")
			canvas_type = /obj/item/canvas/twentythree_nineteen
		if("23x23")
			canvas_type = /obj/item/canvas/twentythree_twentythree

	var/obj/item/canvas/Canvas = new canvas_type
	Canvas.grid = can_grid
	Canvas.painting_name = can_name
	Canvas.finalized = TRUE
	Canvas.generate_proper_overlay()

	Canvas.forceMove(src)
	framed_weakref = WEAKREF(Canvas)
	update_icon()
	update_name()


/obj/structure/picture_frame/proc/Write_Memory()
	var/list/data = list(
		"canvas_size" = null,
		"canvas_grid" = null,
		"canvas_name" = null,
	)

	if(!framed_weakref)
		return data

	var/obj/item/I = framed_weakref?.resolve()
	if(!istype(I, /obj/item/canvas))
		return data

	var/obj/item/canvas/Canvas = I
	data["canvas_size"] = "[Canvas.width]x[Canvas.height]"
	data["canvas_grid"] = Canvas.grid
	data["canvas_name"] = Canvas.painting_name

	return data

/obj/structure/picture_frame/Destroy()
	. = ..()
	if(framed_weakref)
		var/obj/item/I = framed_weakref?.resolve()
		QDEL_NULL(I)
		framed_weakref = null

/obj/structure/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/item/weapon/picture_frame/wooden

/obj/structure/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/item/weapon/picture_frame/metal
	max_integrity = 100

/obj/structure/picture_frame/examine(mob/user)
	var/obj/item/canvas/Canvas = framed_weakref?.resolve()
	if(Canvas && in_range(src, user))
		Canvas.show(user)
	else
		..()

/obj/structure/picture_frame/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/canvas))
		if(framed_weakref)
			to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] не пуста.</span>")
			return

		if(istype(O, /obj/item/canvas))
			var/obj/item/canvas/Canvas = O
			if(!Canvas.finalized)
				to_chat(user, "<span class='notice'>[C_CASE(Canvas, NOMINATIVE_CASE)] не завершён.</span>")
				return

		if(!user.drop_from_inventory(O, src))
			return

		framed_weakref = WEAKREF(O)
		update_icon()
		update_name()
		return

	if(iswrenching(O))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		deconstruct(TRUE, user)
		return

	else
		..()

// TODO move all handling into picture_frame item
/obj/structure/picture_frame/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/picture_frame/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(damage_amount < 5)
		return
	switch(damage_type)
		if(BRUTE)
			return 0.75 * damage_amount
		if(BURN)
			return damage_amount

/obj/structure/picture_frame/deconstruct(disassembled, mob/living/user)
	var/turf/T = get_turf(user || loc)
	if(framed_weakref && (flags & NODECONSTRUCT || !disassembled))
		var/obj/item/I = framed_weakref?.resolve()
		I.forceMove(T)
		framed_weakref = null
	if(flags & NODECONSTRUCT)
		return ..()
	if(disassembled)
		var/obj/item/weapon/picture_frame/F = new frame_type(T)
		if(framed_weakref)
			var/obj/item/I = framed_weakref?.resolve()
			F.displayed_weakref = WEAKREF(I)
			I.forceMove(F)
			framed_weakref = null
		F.update_icon()
		if(user && !issilicon(user))
			user.put_in_hands(F)
	else
		if(frame_type == /obj/item/weapon/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(T)
		if(frame_type == /obj/item/weapon/picture_frame/metal)
			new /obj/item/stack/sheet/metal(T)
	..()

/obj/structure/picture_frame/attack_hand(mob/user)
	if(framed_weakref)
		user.examinate(src)

/obj/structure/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(framed_weakref)
		var/obj/item/I = framed_weakref?.resolve()
		var/mutable_appearance/MA
		if(istype(I, /obj/item/canvas))
			var/obj/item/canvas/Canvas = I
			icon_state = "[initial(icon_state)]_[Canvas.width]x[Canvas.height]"
			MA = mutable_appearance(Canvas.generated_icon)
			MA.pixel_x = Canvas.framed_offset_x
			MA.pixel_y = Canvas.framed_offset_y
		else
			MA = mutable_appearance(I.icon, "photo")
		add_overlay(MA)

/obj/structure/picture_frame/proc/update_name()
	if(framed_weakref)
		var/obj/item/I = framed_weakref?.resolve()
		if(istype(I, /obj/item/canvas))
			var/obj/item/canvas/Canvas = I
			name = "painting - [Canvas.painting_name]"
		else
			name = "photo - [I.name]"
	else
		name = initial(name)
