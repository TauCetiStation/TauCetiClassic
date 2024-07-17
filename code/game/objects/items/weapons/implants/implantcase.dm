/obj/item/weapon/implantcase
	name = "Glass Case"
	cases = list("cтеклянный футляр", "cтеклянного футляра", "cтеклянному футляру", "cтеклянный футляр", "cтеклянным футляром", "cтеклянном футляре")
	desc = "A case containing an implant."
	gender = MALE
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_MINUSCULE
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = "implantcase-[imp.implant_type]"
	else
		src.icon_state = "implantcase-0"
	return


/obj/item/weapon/implantcase/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Какой бы вы хотели видеть этикетку?", input_default(name), null)  as text, MAX_NAME_LEN)

		if(user.get_active_hand() != I || !Adjacent(usr))
			return

		name = "Glass Case"
		if(t)
			name += " - '[t]'"

	else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		if(!imp || !src.imp.allow_reagents)
			return

		if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[C_CASE(src, NOMINATIVE_CASE)] [(ANYMORPH(src, "полон", "полна", "полно", "полны"))]</span>")
		else
			I.reagents.trans_to(src.imp, 5)
			to_chat(user, "<span class='notice'>Вы вводите 5 единиц раствора. Теперь в шприце содержится [I.reagents.total_volume] [PLUR_UNITS(I.reagents.total_volume)].</span>")

	else if(istype(I, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/IMP = I
		if (IMP.imp)
			if (imp || IMP.imp.implanted)
				return
			IMP.imp.forceMove(src)
			imp = IMP.imp
			IMP.imp = null
			update()
			IMP.update()
		else if(imp)
			if(IMP.imp)
				return
			imp.forceMove(IMP)
			IMP.imp = imp
			imp = null
			update()
		IMP.update()

	else
		return ..()

/obj/item/weapon/implantcase/tracking
	name = "Glass Case - 'Tracking'"
	cases = list("cтеклянный футляр - 'Отслеживающий'", "cтеклянного футляра - 'Отслеживающий'", "cтеклянному футляру - 'Отслеживающий'", "cтеклянный футляр - 'Отслеживающий'", "cтеклянным футляром - 'Отслеживающий'", "cтеклянном футляре - 'Отслеживающий'")
	desc = "Футляр, содержащий имплант слежения."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/tracking/atom_init()
	imp = new /obj/item/weapon/implant/tracking(src)
	. = ..()



/obj/item/weapon/implantcase/explosive
	name = "Glass Case - 'Explosive'"
	cases = list("cтеклянный футляр - 'Взрывной'", "cтеклянного футляра - 'Взрывной'", "cтеклянному футляру - 'Взрывной'", "cтеклянный футляр - 'Взрывной'", "cтеклянным футляром - 'Взрывной'", "cтеклянном футляре - 'Взрывной'")
	desc = "Футляр, содержащий взрывной имплант."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/explosive/atom_init()
	imp = new /obj/item/weapon/implant/explosive(src)
	. = ..()

/obj/item/weapon/implantcase/freedom
	name = "Glass Case - 'Freedom'"
	cases = list("cтеклянный футляр - 'Cвобода'", "cтеклянного футляра - 'Cвобода'", "cтеклянному футляру - 'Cвобода'", "cтеклянный футляр - 'Cвобода'", "cтеклянным футляром - 'Cвобода'", "cтеклянном футляре - 'Cвобода'")
	desc = "Футляр, содержащий имплант \"Свобода\"."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/freedom/atom_init()
	imp = new /obj/item/weapon/implant/freedom(src)
	. = ..()

/obj/item/weapon/implantcase/chem
	name = "Glass Case - 'Chem'"
	cases = list("cтеклянный футляр - 'Химия'", "cтеклянного футляра - 'Химия'", "cтеклянному футляру - 'Химия'", "cтеклянный футляр - 'Химия'", "cтеклянным футляром - 'Химия'", "cтеклянном футляре - 'Химия'")
	desc = "Футляр, содержащий химический имплант."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/chem/atom_init()
	imp = new /obj/item/weapon/implant/chem(src)
	. = ..()

/obj/item/weapon/implantcase/mindshield
	name = "Glass Case - 'MindShield'"
	cases = list("cтеклянный футляр - 'Защита разума'", "cтеклянного футляра - 'Cвобода'", "cтеклянному футляру - 'Cвобода'", "cтеклянный футляр - 'Cвобода'", "cтеклянным футляром - 'Cвобода'", "cтеклянном футляре - 'Cвобода'")
	desc = "Футляр, содержащий имплант защиты разума"
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/mindshield/atom_init()
	imp = new /obj/item/weapon/implant/mind_protect/mindshield(src)
	. = ..()

/obj/item/weapon/implantcase/loyalty
	name = "Glass Case - 'Loyalty'"
	cases = list("cтеклянный футляр - 'Лояльность'", "cтеклянного футляра - 'Лояльность'", "cтеклянному футляру - 'Лояльность'", "cтеклянный футляр - 'Лояльность'", "cтеклянным футляром - 'Лояльность'", "cтеклянном футляре - 'Лояльность'")
	desc = "Футляр, содержит имплант лояльности."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/loyalty/atom_init()
	imp = new /obj/item/weapon/implant/mind_protect/loyalty(src)
	. = ..()

/obj/item/weapon/implantcase/death_alarm
	name = "Glass Case - 'Death Alarm'"
	cases = list("cтеклянный футляр - 'Оповещение о смерти'", "cтеклянного футляра - 'Оповещение о смерти'", "cтеклянному футляру - 'Оповещение о смерти'", "cтеклянный футляр - 'Оповещение о смерти'", "cтеклянным футляром - 'Оповещение о смерти'", "cтеклянном футляре - 'Оповещение о смерти'")
	desc = "Футляр, содержащий имплант оповещения о смерти."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"

/obj/item/weapon/implantcase/death_alarm/atom_init()
	imp = new /obj/item/weapon/implant/death_alarm(src)
	. = ..()
