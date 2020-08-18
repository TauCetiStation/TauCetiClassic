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
	if(iswrench(W) && buildable_sign)
		if(user.is_busy(src))
			return
		user.visible_message("<span class='notice'>[user] starts removing [src]...</span>",
							 "<span class='notice'>You start unfastening [src].</span>")
		if(W.use_tool(src, user, 40, volume = 50))
			playsound(src, 'sound/items/deconstruct.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("<span class='notice'>[user] unfastens [src].</span>",
								 "<span class='notice'>You unfasten [src].</span>")
			var/obj/item/sign_backing/SB = new (get_turf(user))
			SB.icon_state = icon_state
			SB.sign_path = type
			qdel(src)
		return
	else if(istype(W, /obj/item/weapon/airlock_painter) && buildable_sign)
		if(user.is_busy())
			return
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
		playsound(src, 'sound/effects/spray2.ogg', VOL_EFFECTS_MASTER)
		var/obj/structure/sign/newsign = new sign_type(get_turf(src))
		newsign.pixel_x = pixel_x
		newsign.pixel_y = pixel_y
		qdel(src)

	else
		switch(W.damtype)
			if("fire")
				playsound(src, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER)
				src.health -= W.force * 1
			if("brute")
				playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
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

/obj/item/sign_backing/afterattack(atom/target, mob/user, proximity, params)
	if(isturf(target) && proximity)
		var/turf/T = target
		user.visible_message("<span class='notice'>[user] fastens [src] to [T].</span>",
							 "<span class='notice'>You attach the sign to [T].</span>")
		playsound(T, 'sound/items/deconstruct.ogg', VOL_EFFECTS_MASTER)
		new sign_path(T)
		qdel(src)
	else
		return ..()

/obj/item/sign_backing/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		if(I.use(0, user))
			if(I.use_tool(src, user, 20, volume = 50))
				new /obj/item/stack/sheet/mineral/plastic(user.loc, 2)
				qdel(src)
				return
	return ..()
/obj/structure/sign/nanotrasen
	name = "Nanotrasen Logo"
	desc = "A sign with the Nanotrasen Logo on it. Glory to Nanotrasen!"
	icon_state = "nanotrasen"

/obj/structure/sign/mark
	layer = TURF_LAYER
	icon = 'icons/misc/mark.dmi'
	name = "Symbol"
	desc = "You look at a symbol."
	icon_state = "b1"

/obj/structure/sign/mark/symbol_b
	icon = 'icons/misc/blue_symbol.dmi'
	icon_state = "C"

/obj/structure/sign/chinese
	name = "chinese restaurant sign"
	desc = "A glowing dragon invites you in."
	icon_state = "chinese"
	light_color = "#d00023"
	light_power = 1
	light_range = 3

/obj/structure/sign/barber
	name = "barbershop sign"
	desc = "A glowing red-blue-white stripe you won't mistake for any other!"
	icon_state = "barber"

/obj/structure/sign/monkey_painting
	name = "Mr. Deempisi portrait"
	desc = "Under the painting a plaque reads: 'While the meat grinder may not have spared you, fear not. Not one part of you has gone to waste... You were delicious.'"
	icon_state = "monkey_painting"
