/obj/item/decoration
	name = "decoration"
	desc = "Winter is coming!"
	icon = 'code/modules/holidays/new_year/decorations.dmi'
	icon_state = "santa"
	layer = 4.1

/obj/item/decoration/attack_hand(mob/user)
	var/choice = input("Do you want to take \the [src]?") in list("Yes", "Cancel")
	if(choice == "Yes" && get_dist(src, user) <= 1)
		..()

/obj/item/decoration/afterattack(atom/target, mob/living/user, flag, params)
	if(istype(target,/turf/simulated/wall))
		usr.remove_from_mob(src)
		src.forceMove(target)

// Garland
/obj/item/decoration/garland
	name = "garland"
	desc = "Beautiful lights! Shinee!"
	icon_state = "garland_on"
	var/on = TRUE
	var/brightness = 4

/obj/item/decoration/garland/proc/update_garland()
	if(on)
		icon_state = "garland_on"
		set_light(brightness)
	else
		icon_state = "garland"
		set_light(0)

/obj/item/decoration/garland/atom_init()
	. = ..()
	light_color = pick("#FF0000", "#6111FF", "#FFA500", "#44FAFF")
	update_garland()

/obj/item/decoration/garland/attack_self(mob/user)
	. = ..()
	if(user.is_busy())
		return
	if(use_tool(src, user, 5, volume = 50))
		toggle()

/obj/item/decoration/garland/verb/toggle()
	set name = "Toggle garland"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr
	on = !on
	C.visible_message("<span class='notice'>[C] turns \the [src] [on ? "on" : "off"].</span>", "<span class='notice'>You turn \the [src] [on ? "on" : "off"].</span>")
	update_garland()

// Tinsels
/obj/item/decoration/tinsel
	name = "tinsel"
	desc = "Soft tinsel, pleasant to the touch. Ahhh..."
	icon_state = "tinsel_g"
	var/random = TRUE // random color

/obj/item/decoration/tinsel/atom_init()
	. = ..()
	if(random)
		icon_state = "tinsel[pick("_g", "_r", "_y", "_w")]"

/obj/item/decoration/tinsel/green
	icon_state = "tinsel_g"
	random = FALSE

/obj/item/decoration/tinsel/red
	icon_state = "tinsel_r"
	random = FALSE

/obj/item/decoration/tinsel/yellow
	icon_state = "tinsel_y"
	random = FALSE

/obj/item/decoration/tinsel/white
	icon_state = "tinsel_w"
	random = FALSE

// Snowflakes
/obj/item/decoration/snowflake
	name = "snowflake"
	desc = "Snowflakes from very soft and pleasant to touch material."
	icon_state = "snowflakes_1"

/obj/item/decoration/snowflake/atom_init()
	. = ..()
	icon_state = "snowflakes_[rand(1, 4)]"

// Snowman head
/obj/item/decoration/snowman
	name = "snowman head"
	desc = "Snowman head, which looks right into your soul."
	icon_state = "snowman"

// Xmas tree
/obj/item/device/flashlight/lamp/fir/special
	name = "present xmas tree"
	desc = "Hello, happy holidays, we have got presents..."

	layer = 5
	var/gifts_dealt = 0
	var/list/decals = list()

/obj/item/device/flashlight/lamp/fir/special/attackby(obj/item/W, mob/user, params)
	if (!W) return

	if(!(W.flags & ABSTRACT))
		if(user.drop_item())
			user.visible_message("[user] attaches [W] to \the [src] .", "<span class='notice'>You attache [W] to \the [src].</span>")
			W.forceMove(loc)
			W.layer = 5.1 // Item should be on the tree, not under
			W.anchored = 1 // Make item a part of the tree
			decals += W
			var/list/click_params = params2list(params)
			// Center the icon where the user clicked.
			W.pixel_x = (text2num(click_params["icon-x"]) - 16)
			W.pixel_y = (text2num(click_params["icon-y"]) - 16)
			if(istype(W,/obj/item/weapon/organ/head))
				W.pixel_y -= 10 // Head always has 10 pixels shift
				W.dir = 2 // Rotate head face to us
				W.transform = turn(null, null)	//Turn it to initial angle
	return

/obj/item/device/flashlight/lamp/fir/special/attack_hand(mob/user)
	shake()
	return

/obj/item/device/flashlight/lamp/fir/special/verb/shake()
	set name = "Shake tree"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr

	if(iscarbon(C))
		if(!gifts_dealt || ((world.time - gifts_dealt) > 5000))

			C.visible_message("<span class='notice'>[C] shakes [src].</span>","<span class='notice'>You shake [src].</span>")

			var/bad_boy = 0
			for(var/datum/job/job in SSjob.occupations)
				if(jobban_isbanned(C, job.title))
					bad_boy += 1
			if(!bad_boy)
				to_chat(C, "<span class='notice'>You understand that this year you was good boy!</span>")
				C.adjustBruteLoss(-1)
				C.adjustToxLoss(-1)
				C.adjustFireLoss(-1)
			if(bad_boy >= 5)
				to_chat(C, "<span class='notice'>You understand that this year you was bad boy!</span>")
				C.adjustBruteLoss(10)
				C.adjustToxLoss(10)
				C.adjustFireLoss(10)

			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			if(prob(10))
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
			else
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
			gifts_dealt = world.time
		else
			C.visible_message("<span class='notice'>[C] shakes [src].</span>", "<span class='notice'>You shake [src] but nothing happens.</span>")

	if(decals.len && (C.a_intent != "help"))
		for(var/item in decals)
			var/obj/item/I = item
			if(!I)
				return
			I.forceMove(src.loc)
			I.layer = initial(layer)
			I.pixel_x = initial(pixel_x)
			I.pixel_y = initial(pixel_y)
			I.anchored = 0
			decals.Cut()

		src.visible_message("Something dropped from \the [src].")

/obj/item/device/flashlight/lamp/fir/special/alternative
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/snowman
	name = "snowman"
	desc = "That's a snowman. He is staring at you. Where is his hat, though?"
	icon = 'code/modules/holidays/new_year/decorations.dmi'
	icon_state = "snowman_s"
	anchored = FALSE
	var/health = 50

/obj/structure/snowman/attackby(obj/item/W, mob/user)
	. = ..()
	if(W.force > 4)
		health -= W.force
		if(health <= 0)
			visible_message("<span class='warning'>[src] is destroyed!</span>")
			for(var/i = 0 to 6)
				new /obj/item/snowball(get_turf(src))
			qdel(src)
		else
			visible_message("<span class='notice'>[src] is damaged!</span>")
