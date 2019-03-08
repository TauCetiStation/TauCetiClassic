
/obj/item/weapon/shard/phoron
	name = "phoron shard"
	desc = "A shard of phoron glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8.0
	throwforce = 15.0
	icon_state = "phoronlarge"
	sharp = 1
	edge = 1

/obj/item/weapon/shard/phoron/atom_init()
	. = ..()

	icon_state = pick("phoronlarge", "phoronmedium", "phoronsmall")
	switch(icon_state)
		if("phoronsmall")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("phoronmedium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("phoronlarge")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/shard/phoron/attackby(obj/item/weapon/W, mob/user)
	..()
	if ( istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		user.SetNextMove(CLICK_CD_INTERACT)
		if(WT.use(0, user))
			new /obj/item/stack/sheet/glass/phoronglass(user.loc, , TRUE)
			qdel(src)

//legacy crystal
/obj/machinery/crystal
	name = "Crystal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "crystal"

/obj/machinery/crystal/atom_init()
	. = ..()
	if(prob(50))
		icon_state = "crystal2"

//large finds
				/*
				/obj/machinery/syndicate_beacon
				/obj/machinery/wish_granter
			if(18)
				item_type = "jagged green crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
			if(19)
				item_type = "jagged pink crystal"
				additional_desc = pick("It shines faintly as it catches the light.","It appears to have a faint inner glow.","It seems to draw you inward as you look it at.","Something twinkles faintly as you look at it.","It's mesmerizing to behold.")
				icon_state = "crystal2"
				apply_material_decorations = 0
				if(prob(10))
					apply_image_decorations = 1
				*/
			//machinery type artifacts?
