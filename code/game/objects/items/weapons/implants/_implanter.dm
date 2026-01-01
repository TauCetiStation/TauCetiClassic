/obj/item/weapon/implanter
	name = "implanter"
	cases = list("имплантер", "имплантера", "имплантеру", "имплантер", "имплантером", "имплантере")
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY

	var/init_type
	var/obj/item/weapon/implant/implant = null

/obj/item/weapon/implanter/atom_init()
	. = ..()
	if(init_type)
		implant = new init_type(src)
	update_icon()
	update_desc()

/obj/item/weapon/implanter/proc/update_desc()
	if(!implant)
		name = initial(name)
		desc = initial(desc)
		return

	name = "[initial(name)] - \"[implant.name]\""
	desc = "Содержит [CASE(implant, NOMINATIVE_CASE)]. [implant.desc]"

/obj/item/weapon/implanter/update_icon()
	if (implant)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"

/obj/item/weapon/implanter/attack(mob/living/M, mob/user, def_zone)
	if (!iscarbon(M))
		return
	if(!M.try_inject(user, TRUE))
		return

	user.visible_message("<span class ='userdanger'>[user] пытается имплантировать [M].</span>")

	if(M == user || (!user.is_busy() && do_after(user, 50, target = M)))
		if(src && implant)
			if(!implant.pre_inject(M, user))
				return

			M.log_combat(user, "implanted with [name]")
			user.visible_message("<span class ='userdanger'>[M] был[VERB_RU(M)] [(ANYMORPH(M, "имплантирован", "имплантирована", "имплантировано", "имплантированы"))] [user].</span>", "Вы вживили имплантат в [M].")
			implant.inject(M, def_zone, FALSE) // field implantation is not safe for some implants (mindshield, loyality)
			implant = null
			update_icon()
			update_desc()

/obj/item/weapon/implanter/mindshield
	init_type = /obj/item/weapon/implant/mind_protect/mindshield

/obj/item/weapon/implanter/loyalty
	init_type = /obj/item/weapon/implant/mind_protect/loyalty

/obj/item/weapon/implanter/explosive
	init_type = /obj/item/weapon/implant/explosive

/obj/item/weapon/implanter/adrenaline
	init_type = /obj/item/weapon/implant/adrenaline

/obj/item/weapon/implanter/emp
	init_type = /obj/item/weapon/implant/emp

/obj/item/weapon/implanter/storage
	init_type = /obj/item/weapon/implant/storage

/obj/item/weapon/implanter/freedom
	init_type = /obj/item/weapon/implant/freedom

/obj/item/weapon/implanter/uplink
	init_type = /obj/item/weapon/implant/uplink

/obj/item/weapon/implanter/willpower
	init_type = /obj/item/weapon/implant/willpower

/obj/item/weapon/implanter/exile
	init_type = /obj/item/weapon/implant/exile

/obj/item/weapon/implanter/abductor
	init_type = /obj/item/weapon/implant/abductor
	icon_state = "abductor_implanter0"

/obj/item/weapon/implanter/abductor/update_icon()
	if (implant)
		icon_state = "abductor_implanter1"
	else
		icon_state = "abductor_implanter0"
