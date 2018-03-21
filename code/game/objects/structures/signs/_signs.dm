/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = SIGN_LAYER
	var/health = 100
	var/buildable_sign = TRUE //unwrenchable and modifiable

/obj/structure/sign/basic
	name = "blank sign"
	desc = "How can signs be real if our eyes aren't real?"
	icon_state = "backing"

/obj/structure/sign/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && buildable_sign)
		user.visible_message("<span class='notice'>[user] starts removing [src]...</span>",
							 "<span class='notice'>You start unfastening [src].</span>")
		playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
			return
		if(do_after(user,40,target = src))
			playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src].</span>",
								 "<span class='notice'>You unfasten [src].</span>")
			var/obj/item/sign_backing/SB = new (get_turf(user))
			SB.icon_state = icon_state
			SB.sign_path = type
			qdel(src)
		return
	else if(istype(W, /obj/item/weapon/airlock_painter) && buildable_sign)
		var/list/sign_types = list("Secure Area", "Biohazard", "High Voltage", "Radiation", "Hard Vacuum Ahead", "Disposal: Leads To Space", "Danger: Fire", "No Smoking", "Medbay", "Science", "Chemistry", \
		"Hydroponics", "Xenobiology")
		var/obj/structure/sign/sign_type
		switch(input(user, "Select a sign type.", "Sign Customization") as null|anything in sign_types)
			if("Blank")
				sign_type = /obj/structure/sign/basic
			if("Secure Area")
				sign_type = /obj/structure/sign/warning/securearea
			if("Biohazard")
				sign_type = /obj/structure/sign/warning/biohazard
			if("High Voltage")
				sign_type = /obj/structure/sign/warning/electricshock
			if("Radiation")
				sign_type = /obj/structure/sign/warning/radiation
			if("Hard Vacuum Ahead")
				sign_type = /obj/structure/sign/warning/vacuum
			if("Disposal: Leads To Space")
				sign_type = /obj/structure/sign/warning/deathsposal
			if("Danger: Fire")
				sign_type = /obj/structure/sign/warning/fire
			if("No Smoking")
				sign_type = /obj/structure/sign/warning/nosmoking/circle
			if("Medbay")
				sign_type = /obj/structure/sign/departments/medbay/alt
			if("Science")
				sign_type = /obj/structure/sign/departments/science
			if("Chemistry")
				sign_type = /obj/structure/sign/departments/chemistry
			if("Hydroponics")
				sign_type = /obj/structure/sign/departments/botany
			if("Xenobiology")
				sign_type = /obj/structure/sign/departments/xenobio

		//Make sure user is adjacent still
		if(!Adjacent(user))
			return

		if(!sign_type)
			return

		//It's import to clone the pixel layout information
		//Otherwise signs revert to being on the turf and
		//move jarringly
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1)
		var/obj/structure/sign/newsign = new sign_type(get_turf(src))
		newsign.pixel_x = pixel_x
		newsign.pixel_y = pixel_y
		qdel(src)

	else
		user.SetNextMove(CLICK_CD_MELEE)
		switch(W.damtype)
			if("fire")
				playsound(loc, 'sound/items/welder.ogg', 80, 1)
				src.health -= W.force * 1
			if("brute")
				playsound(loc, 'sound/weapons/slash.ogg', 80, 1)
				src.health -= W.force * 0.75
			else
		if (src.health <= 0)
			visible_message("<span class='warning'>[user] smashed [src] apart!</span>")
			qdel(src)
		..()

/obj/item/sign_backing
	name = "sign backing"
	desc = "A sign with adhesive backing."
	icon = 'icons/obj/decals.dmi'
	icon_state = "backing"
	item_state = "sheet-metal"
	w_class = ITEM_SIZE_LARGE
	var/sign_path = /obj/structure/sign/basic //the type of sign that will be created when placed on a turf

/obj/item/sign_backing/afterattack(atom/target, mob/user, proximity)
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>",
							 "<span class='notice'>You attach the sign to [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', 50, 1)
		new sign_path(T)
		qdel(src)
	else
		return ..()

/obj/item/sign_backing/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/weldingtool))
		playsound(loc, 'sound/items/welder.ogg', 50, 1)
		new /obj/item/stack/sheet/mineral/plastic(user.loc, 2)
		qdel(src)

/obj/structure/sign/nanotrasen
	name = "\improper Nanotrasen Logo"
	desc = "A sign with the Nanotrasen Logo on it. Glory to Nanotrasen!"
	icon_state = "nanotrasen"

/obj/structure/sign/mark
	layer = TURF_LAYER
	icon = 'icons/misc/mark.dmi'
	name = "\improper Symbol"
	desc = "You look at a symbol."
	icon_state = "b1"

/obj/structure/sign/mark/symbol_b
	icon = 'icons/misc/blue_symbol.dmi'
	icon_state = "C"

/obj/structure/sign/chinese
	name = "\improper chinese restaurant sign"
	desc = "A glowing dragon invites you in."
	icon_state = "chinese"
	light_color = "#d00023"
	light_power = 1
	light_range = 3

/obj/structure/sign/monkey_painting
	name = "\improper Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
	icon_state = "monkey_painting"
