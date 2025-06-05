/obj/item/weapon/implantcase
	name = "Glass Case"
	cases = list("cтеклянный футляр", "cтеклянного футляра", "cтеклянному футляру", "cтеклянный футляр", "cтеклянным футляром", "cтеклянном футляре")
	desc = "Футляр для имплантов."
	gender = MALE
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_MINUSCULE

	var/init_type
	var/obj/item/weapon/implant/implant

/obj/item/weapon/implantcase/atom_init()
	. = ..()
	if(init_type)
		implant = new init_type(src)
	update_icon()
	update_desc()

/obj/item/weapon/implantcase/proc/update_desc()
	if(!implant)
		name = initial(name)
		desc = initial(desc)
		return

	name = "[initial(name)] - \"[implant.name]\""
	desc = "[initial(desc)] Содержит [CASE(implant, NOMINATIVE_CASE)]. [implant.desc]"

/obj/item/weapon/implantcase/update_icon()
	if (implant)
		icon_state = implant.legal ? "implantcase-b" : "implantcase-r"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/implantcase/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Какой бы вы хотели видеть этикетку?", input_default(name), null)  as text, MAX_NAME_LEN)

		if(user.get_active_hand() != I || !Adjacent(usr))
			return

		name = "Glass Case"
		if(t)
			name += " - '[t]'"

	else if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		if(!implant || !istype(implant, /obj/item/weapon/implant/chem))
			return

		if(implant.reagents.total_volume >= implant.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[C_CASE(src, NOMINATIVE_CASE)] [(ANYMORPH(src, "полон", "полна", "полно", "полны"))]</span>")
		else
			var/transfer_amount = I.reagents.trans_to(implant, 5)
			to_chat(user, "<span class='notice'>Вы вводите [transfer_amount] единиц раствора. Теперь в шприце содержится [I.reagents.total_volume] [PLUR_UNITS(I.reagents.total_volume)].</span>")

	else if(istype(I, /obj/item/weapon/implanter))
		var/obj/item/weapon/implanter/IMP = I
		if (IMP.implant)
			if (implant)
				return
			IMP.implant.forceMove(src)
			implant = IMP.implant
			IMP.implant = null
			update_icon()
			update_desc()
			IMP.update_icon()
			IMP.update_desc()
		else if(implant)
			if(IMP.implant)
				return
			implant.forceMove(IMP)
			IMP.implant = implant
			implant = null
			update_icon()
			update_desc()
			IMP.update_icon()
			IMP.update_desc()

	else
		return ..()

/obj/item/weapon/implantcase/tracking
	init_type = /obj/item/weapon/implant/tracking

/obj/item/weapon/implantcase/explosive
	init_type = /obj/item/weapon/implant/explosive

/obj/item/weapon/implantcase/freedom
	init_type = /obj/item/weapon/implant/freedom

/obj/item/weapon/implantcase/chem
	init_type = /obj/item/weapon/implant/chem

/obj/item/weapon/implantcase/mindshield
	init_type = /obj/item/weapon/implant/mind_protect/mindshield

/obj/item/weapon/implantcase/loyalty
	init_type = /obj/item/weapon/implant/mind_protect/loyalty

/obj/item/weapon/implantcase/death_alarm
	init_type = /obj/item/weapon/implant/death_alarm

/obj/item/weapon/implantcase/exile
	init_type = /obj/item/weapon/implant/exile
