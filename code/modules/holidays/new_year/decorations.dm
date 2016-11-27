/obj/item/decoration
	name = "decoration"
	desc = "Winter is coming!"
	icon = 'code/modules/holidays/new_year/decorations.dmi'
	icon_state = "santa"
	layer = 4.1

///Garland
/obj/item/decoration/garland
	name = "garland"
	desc = "Beautiful lights! Shinee!"
	icon_state = "garland"
	var/on = 0
	var/brightness = 2

/obj/item/decoration/garland/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]_on"
		set_light(brightness)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/decoration/garland/New()
	on = 1
	light_color = pick("#FF0000","#6111FF","#FFA500","#44FAFF")
	initialize()

/obj/item/decoration/garland/attack_hand()
	on = !on
	initialize()

///Tinsels
/obj/item/decoration/tinsel
	name = "tinsel"
	desc = "Soft tinsel, pleasant to the touch. Ahhh..."
	icon_state = "tinsel_g"

/obj/item/decoration/tinsel/New()
	icon_state = "tinsel[pick("_g","_r","_y","_w")]"

/obj/item/decoration/tinsel/green
	icon_state = "tinsel_g"
	New()
		return

/obj/item/decoration/tinsel/red
	icon_state = "tinsel_r"
	New()
		return

/obj/item/decoration/tinsel/yellow
	icon_state = "tinsel_y"
	New()
		return

/obj/item/decoration/tinsel/white
	icon_state = "tinsel_w"
	New()
		return

//Snowflakes
/obj/item/decoration/snowflake
	name = "snowflake"
	desc = "Snowflakes from very soft and pleasant to touch material."
	icon_state = "snowflakes_1"

/obj/item/decoration/snowflake/New()
	icon_state = "snowflakes_[rand(1,4)]"

/obj/item/decoration/snowflake/afterattack(atom/target, mob/living/user, flag, params)
	if(istype(target,/turf/simulated/wall))
		usr.remove_from_mob(src)
		src.forceMove(target)

//Snowman head
/obj/item/decoration/snowman
	name = "snowman head"
	desc = "Snowman head, which looks right into your soul."
	icon_state = "snowman"

//Xmas tree
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
			user.visible_message("[user] attaches [W] to \the [src] .","<span class='notice'>You attache [W] to \the [src].</span>")
			W.forceMove(loc)
			W.layer = 5.1	//Item should be on the tree, not under
			W.anchored = 1	//Make item a part of the tree
			decals += W
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			W.pixel_x = (text2num(click_params["icon-x"]) - 16)
			W.pixel_y = (text2num(click_params["icon-y"]) - 16)
			if(istype(W,/obj/item/weapon/organ/head))
				W.pixel_y -= 10	//Head always has 10 pixels shift
				W.dir = 2	//Rotate head face to us
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
		if(!gifts_dealt || ((world.time - gifts_dealt) > 3000))

			C.visible_message("[C] shakes [src].","<span class='notice'>You shake [src].</span>")

			if(!C.client.prefs.warnbans)
				to_chat(C, "<span class='notice'>You understand that this year you was good boy!</span>")
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustFireLoss(-10)

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
			C.visible_message("[C] shakes [src].","<span class='notice'>You shake [src] but nothing happens.</span>")

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
