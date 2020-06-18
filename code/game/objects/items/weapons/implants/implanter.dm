/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implanter/proc/update()
	if (imp)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"


/obj/item/weapon/implanter/attack(mob/living/M, mob/user, def_zone)
	if (!iscarbon(M))
		return
	if (!user || !imp)
		return

	user.visible_message("<span class ='userdanger'>[user] is attemping to implant [M].</span>")

	if(M == user || (!user.is_busy() && do_after(user, 50, target = M)))
		if(src && imp)
			M.log_combat(user, "implanted with [name]")
			if(imp.implanted(M))
				user.visible_message("<span class ='userdanger'>[M] has been implanted by [user].</span>", "You implanted the implant into [M].")
				imp.inject(M, def_zone)
				imp = null
				update()



/obj/item/weapon/implanter/mindshield
	name = "implanter-mind shield"

/obj/item/weapon/implanter/mindshield/atom_init()
	imp = new /obj/item/weapon/implant/mindshield(src)
	. = ..()
	update()

/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"

/obj/item/weapon/implanter/loyalty/atom_init()
	imp = new /obj/item/weapon/implant/mindshield/loyalty(src)
	. = ..()
	update()

/obj/item/weapon/implanter/explosive
	name = "implanter (E)"

/obj/item/weapon/implanter/explosive/atom_init()
	imp = new /obj/item/weapon/implant/explosive(src)
	. = ..()
	update()

/obj/item/weapon/implanter/adrenaline
	name = "implanter (A)"

/obj/item/weapon/implanter/adrenaline/atom_init()
	imp = new /obj/item/weapon/implant/adrenaline(src)
	. = ..()
	update()

/obj/item/weapon/implanter/emp
	name = "implanter (M)"

/obj/item/weapon/implanter/emp/atom_init()
	imp = new /obj/item/weapon/implant/emp(src)
	. = ..()
	update()

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter1"

/obj/item/weapon/implanter/compressed/atom_init()
	imp = new /obj/item/weapon/implant/compressed(src)
	. = ..()
	update()

/obj/item/weapon/implanter/compressed/update()
	if (imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"
	return

/obj/item/weapon/implanter/compressed/attack(mob/M, mob/user)
	var/obj/item/weapon/implant/compressed/c = imp
	if (!c)	return
	if (c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target,/obj/item) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if (c.scanned)
			to_chat(user, "<span class='warning'>Something is already scanned inside the implant!</span>")
			return
		c.scanned = target
		if(istype(target.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = target.loc
			H.remove_from_mob(target)
		else if(istype(target.loc,/obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = target.loc
			S.remove_from_storage(target)
		target.loc.contents.Remove(target)
		update()

/obj/item/weapon/implanter/storage
	name = "implanter (storage)"
	icon_state = "cimplanter1"

/obj/item/weapon/implanter/storage/atom_init()
	imp = new /obj/item/weapon/implant/storage(src)
	. = ..()
