//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp.item_color)
	else
		src.icon_state = "implantcase-0"
	return


/obj/item/weapon/implantcase/attackby(obj/item/weapon/I, mob/user)
	..()
	if (istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "What would you like the label to be?", input_default(src.name), null)  as text, MAX_NAME_LEN)
		if (user.get_active_hand() != I)
			return
		if((!in_range(src, usr) && src.loc != user))
			return
		if(t)
			src.name = text("Glass Case- '[]'", t)
		else
			src.name = "Glass Case"
	else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		if(!src.imp)	return
		if(!src.imp.allow_reagents)	return
		if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
			to_chat(user, "\red [src] is full.")
		else
			spawn(5)
				I.reagents.trans_to(src.imp, 5)
				to_chat(user, "\blue You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.")
	else if (istype(I, /obj/item/weapon/implanter))
		if (I:imp)
			if ((src.imp || I:imp.implanted))
				return
			I:imp.loc = src
			src.imp = I:imp
			I:imp = null
			src.update()
			I:update()
		else
			if (src.imp)
				if (I:imp)
					return
				src.imp.loc = I
				I:imp = src.imp
				src.imp = null
				update()
			I:update()
	return



/obj/item/weapon/implantcase/tracking
	name = "Glass Case- 'Tracking'"
	desc = "A case containing a tracking implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/tracking/atom_init()
	imp = new /obj/item/weapon/implant/tracking(src)
	. = ..()



/obj/item/weapon/implantcase/explosive
	name = "Glass Case- 'Explosive'"
	desc = "A case containing an explosive implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/explosive/atom_init()
	imp = new /obj/item/weapon/implant/explosive(src)
	. = ..()

/obj/item/weapon/implantcase/freedom
	name = "Glass Case- 'Freedom'"
	desc = "A case containing an freedom implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/freedom/atom_init()
	imp = new /obj/item/weapon/implant/freedom(src)
	. = ..()

/obj/item/weapon/implantcase/chem
	name = "Glass Case- 'Chem'"
	desc = "A case containing a chemical implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/chem/atom_init()
	imp = new /obj/item/weapon/implant/chem(src)
	. = ..()

/obj/item/weapon/implantcase/mindshield
	name = "Glass Case- 'MindShield'"
	desc = "A case containing a mindshield implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/mindshield/atom_init()
	imp = new /obj/item/weapon/implant/mindshield(src)
	. = ..()

/obj/item/weapon/implantcase/loyalty
	name = "Glass Case- 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/loyalty/atom_init()
	imp = new /obj/item/weapon/implant/mindshield/loyalty(src)
	. = ..()

/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case- 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/death_alarm/atom_init()
	imp = new /obj/item/weapon/implant/death_alarm(src)
	. = ..()
