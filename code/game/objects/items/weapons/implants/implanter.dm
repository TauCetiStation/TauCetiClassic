/obj/item/weapon/implanter
	name = "implanter"
	cases = list("имплантер", "имплантера", "имплантеру", "имплантер", "имплантером", "имплантере")
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY
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
	if (isskeleton(M))
		to_chat(user, "<span class='warning'>Куда имплантировать-то?</span>")
		return

	user.visible_message("<span class ='userdanger'>[user] пытается имплантировать [M].</span>")

	if(M == user || (!user.is_busy() && do_after(user, 50, target = M)))
		if(src && imp)
			M.log_combat(user, "implanted with [name]")
			if(imp.implanted(M))
				user.visible_message("<span class ='userdanger'>[M] был[VERB_RU(M)] [(ANYMORPH(M, "имплантирован", "имплантирована", "имплантировано", "имплантированы"))] [user].</span>", "Вы вживили имплантат в [M].")
				imp.inject(M, def_zone)
				imp = null
				update()



/obj/item/weapon/implanter/mindshield
	name = "implanter mindshield"
	cases = list("имплантер защиты разума", "имплантера защиты разума", "имплантеру защиты разума", "имплантер защиты разума", "имплантером защиты разума", "имплантере защиты разума")

/obj/item/weapon/implanter/mindshield/atom_init()
	imp = new /obj/item/weapon/implant/mind_protect/mindshield(src)
	. = ..()
	update()

/obj/item/weapon/implanter/loyalty
	name = "implanter loyalty"
	cases = list("имплантер лояльности", "имплантера лояльности", "имплантеру лояльности", "имплантер лояльности", "имплантером лояльности", "имплантере лояльности")

/obj/item/weapon/implanter/loyalty/atom_init()
	imp = new /obj/item/weapon/implant/mind_protect/loyalty(src)
	. = ..()
	update()

/obj/item/weapon/implanter/explosive
	name = "implanter (E)"
	cases = list("имплантер (Е)", "имплантера (Е)", "имплантеру (Е)", "имплантер (Е)", "имплантером (Е)", "имплантере (Е)")

/obj/item/weapon/implanter/explosive/atom_init()
	imp = new /obj/item/weapon/implant/explosive(src)
	. = ..()
	update()

/obj/item/weapon/implanter/adrenaline
	name = "implanter (A)"
	cases = list("имплантер (А)", "имплантера (А)", "имплантеру (А)", "имплантер (А)", "имплантером (А)", "имплантере (А)")

/obj/item/weapon/implanter/adrenaline/atom_init()
	imp = new /obj/item/weapon/implant/adrenaline(src)
	. = ..()
	update()

/obj/item/weapon/implanter/emp
	name = "implanter (M)"
	cases = list("имплантер (М)", "имплантера (М)", "имплантеру (М)", "имплантер (М)", "имплантером (М)", "имплантере (М)")

/obj/item/weapon/implanter/emp/atom_init()
	imp = new /obj/item/weapon/implant/emp(src)
	. = ..()
	update()

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	cases = list("имплантер (С)", "имплантера (С)", "имплантеру (С)", "имплантер (С)", "имплантером (С)", "имплантере (С)")
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
		to_chat(user, "Пожалуйста, сначала просканируйте объект с помощью имплантера.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(isitem(target) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if (c.scanned)
			to_chat(user, "<span class='warning'>Внутри имплантата уже что-то сканируется!</span>")
			return
		c.scanned = target
		if(ishuman(target.loc))
			var/mob/living/carbon/human/H = target.loc
			H.remove_from_mob(target)
		else if(istype(target.loc,/obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = target.loc
			S.remove_from_storage(target)
		target.loc.contents.Remove(target)
		update()

/obj/item/weapon/implanter/storage
	name = "implanter (storage)"
	cases = list("имплантер (хранилища)", "имплантера (хранилища)", "имплантеру (хранилища)", "имплантер (хранилища)", "имплантером (хранилища)", "имплантере (хранилища)")

	icon_state = "cimplanter1"

/obj/item/weapon/implanter/storage/atom_init()
	imp = new /obj/item/weapon/implant/storage(src)
	. = ..()

/obj/item/weapon/implanter/freedom
	name = "implanter (F)"
	cases = list("имплантер (Ф)", "имплантера (Ф)", "имплантеру (Ф)", "имплантер (Ф)", "имплантером (Ф)", "имплантере (Ф)")

/obj/item/weapon/implanter/freedom/atom_init()
	imp = new /obj/item/weapon/implant/freedom(src)
	. = ..()
	update()

/obj/item/weapon/implanter/uplink
	name = "implanter (U)"
	cases = list("имплантер (У)", "имплантера (У)", "имплантеру (У)", "имплантер (У)", "имплантером (У)", "имплантере (У)")

/obj/item/weapon/implanter/uplink/atom_init()
	imp = new /obj/item/weapon/implant/uplink(src)
	. = ..()
	update()

/obj/item/weapon/implanter/abductor
	name = "Strange implanter"
	cases = list("неизвестный имплантер", "неизвестного имплантера", "неизвестному имплантеру", "неизвестный имплантер", "неизвестным имплантером", "неизвестном имплантере")

/obj/item/weapon/implanter/abductor/atom_init()
	imp = new /obj/item/weapon/implant/abductor(src)
	. = ..()
	update()

/obj/item/weapon/implanter/abductor/update()
	if (imp)
		icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"
	return
