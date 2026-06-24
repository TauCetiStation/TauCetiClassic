/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = INFRONT_MOB_LAYER
	opacity = TRUE
	density = FALSE
	anchored = TRUE

	resistance_flags = CAN_BE_HIT

	var/can_be_painted = TRUE

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
		change_color(S.colour)
		S.uses = max(S.uses - 2, 0)
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

/obj/structure/curtain/proc/change_color(new_color)
	color = new_color

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
