/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = INFRONT_MOB_LAYER
	opacity = TRUE
	density = FALSE
	anchored = TRUE

	resistance_flags = CAN_BE_HIT

	var/can_be_painted = FALSE

/obj/structure/curtain/open
	icon_state = "open"
	opacity = FALSE

/obj/structure/curtain/transparent
	name = "transparent curtain"
	opacity = FALSE
	alpha = 150
	can_be_painted = TRUE

/obj/structure/curtain/transparent/open
	icon_state = "open"

/obj/structure/curtain/transparent/toggle()
	icon_state = (icon_state == "open") ? "closed" : "open"

/obj/structure/curtain/attack_hand(mob/user)
	playsound(src, 'sound/effects/curtain.ogg', VOL_EFFECTS_MASTER, 15, null, FALSE, -5)
	toggle()
	..()

/obj/structure/curtain/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/cloth (loc, 2)
	new /obj/item/stack/sheet/mineral/plastic (loc, 2)
	new /obj/item/stack/rods (loc, 1)
	..()

/obj/structure/curtain/attackby(obj/item/I, mob/user)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/toy/crayon/spraycan) && can_be_painted)
		var/obj/item/toy/crayon/spraycan/S = I
		var/col = null
		if(!isnull(S.vars["colour"]))
			col = S.vars["colour"]
		else if(!isnull(S.vars["color"]))
			col = S.vars["color"]

		if(!col)
			return

		change_color(col)
		return

	if(istype(I, /obj/item/weapon/screwdriver))
		if(user.is_busy())
			return
		if(anchored)
			return
		if(I.use_tool(src, user, 1 SECOND, volume = 100))
			deconstruct(TRUE)
			return

	if(iswrenching(I))
		if(user.is_busy())
			return
		if(anchored)
			if(I.use_tool(src, user, 1 SECOND, volume = 100, quality = QUALITY_WRENCHING))
				anchored = FALSE
				to_chat(user, "<span class='notice'>You unfasten \the [src] with \the [I].</span>")
				return
		else
			if(I.use_tool(src, user, 1 SECOND, volume = 100, quality = QUALITY_WRENCHING))
				anchored = TRUE
				to_chat(user, "<span class='notice'>You fasten \the [src] to the floor with \the [I].</span>")
				return

/obj/structure/curtain/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 80, TRUE)

/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	if(opacity)
		icon_state = "closed"
	else
		icon_state = "open"

/obj/structure/curtain/proc/change_color(new_color_name)
	var/list/color_name_to_hex = list(
		"black" = "#222222",
		"blue" = "#3b7bd6",
		"yellow" = "#f1d54a",
		"red" = "#d74b4b",
		"purple" = "#7a4bd6",
		"green" = "#4caf50",
		"beige" = "#d8c6a5",
	)

	if(istext(new_color_name) && length(new_color_name) == 7 && copytext(new_color_name, 1, 2) == "#")
		var/hex = copytext(new_color_name, 2, 8)
		if(hex2num("0x[hex]"))
			src.color = lowertext(new_color_name)
			return

	if(!istext(new_color_name))
		return

	new_color_name = lowertext(new_color_name)
	var/hex_out = color_name_to_hex[new_color_name]
	if(!hex_out)
		return

	src.color = hex_out

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#b8f5e3"
	alpha = 200

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/privacy
	name = "privacy curtain"
	color = "#b8f5e3"

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#acd1e9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#ffa500"

/obj/structure/curtain/open/shower/security
	color = "#aa0000"
