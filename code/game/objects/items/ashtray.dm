/obj/item/ashtray
	icon = 'icons/obj/ashtray.dmi'
	var/max_butts 	= 0
	var/empty_desc 	= ""
	var/icon_empty 	= ""
	var/icon_half  	= ""
	var/icon_full  	= ""
	var/icon_broken	= ""
	integrity_failure = 0.5

/obj/item/ashtray/atom_init()
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-6, 6)

/obj/item/ashtray/attackby(obj/item/I, mob/user, params)
	if (get_integrity() < max_integrity * integrity_failure)
		return
	if (istype(I, /obj/item/weapon/cigbutt) || istype(I, /obj/item/clothing/mask/cigarette) || istype(I, /obj/item/weapon/match))
		if (contents.len >= max_butts)
			to_chat(user, "This ashtray is full.")
			return
		user.drop_from_inventory(I, src)

		if (istype(I, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/cig = I
			if (cig.lit == 1)
				visible_message("[user] crushes [cig] in [src], putting it out.")
				STOP_PROCESSING(SSobj, cig)
				var/obj/item/butt = new cig.type_butt(src)
				cig.transfer_fingerprints_to(butt)
				qdel(cig)
				I = butt
			else if (cig.lit == 0)
				to_chat(user, "You place [cig] in [src] without even smoking it. Why would you do that?")

		visible_message("[user] places [I] in [src].")
		add_fingerprint(user)
		if (contents.len == max_butts)
			icon_state = icon_full
			desc = empty_desc + " It's stuffed full."
		else if (contents.len > max_butts/2)
			icon_state = icon_half
			desc = empty_desc + " It's half-filled."
	else
		. = ..()

/obj/item/ashtray/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	take_damage(3, BRUTE, MELEE)
	if(contents.len)
		visible_message("<span class='warning'>[src] slams into [hit_atom] spilling its contents!</span>")
		for (var/obj/item/I in contents)
			I.forceMove(loc)
		icon_state = icon_empty
	return ..()

/obj/item/ashtray/atom_break(damage_flag)
	visible_message("<span class='warning'>[src] shatters spilling its contents!</span>")
	for (var/obj/item/I in contents)
		I.forceMove(loc)
	icon_state = icon_broken
	..()

/obj/item/ashtray/plastic
	name = "plastic ashtray"
	desc = "Cheap plastic ashtray."
	icon_state = "ashtray_bl"
	icon_empty = "ashtray_bl"
	icon_half  = "ashtray_half_bl"
	icon_full  = "ashtray_full_bl"
	icon_broken  = "ashtray_bork_bl"
	max_butts = 14
	max_integrity = 48
	g_amt = 30
	m_amt = 30
	empty_desc = "Cheap plastic ashtray."
	throwforce = 3.0

/obj/item/ashtray/plastic/atom_break(damage_flag)
	..()
	name = "pieces of plastic"
	desc = "Pieces of plastic with ash on them."

/obj/item/ashtray/bronze
	name = "bronze ashtray"
	desc = "Massive bronze ashtray."
	icon_state = "ashtray_br"
	icon_empty = "ashtray_br"
	icon_half  = "ashtray_half_br"
	icon_full  = "ashtray_full_br"
	icon_broken  = "ashtray_bork_br"
	max_butts = 10
	max_integrity = 144
	m_amt = 80
	empty_desc = "Massive bronze ashtray."
	throwforce = 10.0

/obj/item/ashtray/bronze/atom_break(damage_flag)
	..()
	name = "pieces of bronze"
	desc = "Pieces of bronze with ash on them."

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_empty = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	icon_broken  = "ashtray_bork_gl"
	max_butts = 12
	max_integrity = 24
	g_amt = 60
	empty_desc = "Glass ashtray. Looks fragile."
	throwforce = 6.0

/obj/item/ashtray/glass/atom_break()
	..()
	name = "shards of glass"
	desc = "Shards of glass with ash on them."
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER, 30)
