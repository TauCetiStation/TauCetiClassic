
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

/obj/item/weapon/shard/phoron/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		user.SetNextMove(CLICK_CD_INTERACT)
		if(WT.use(0, user))
			new /obj/item/stack/sheet/glass/phoronglass(user.loc, , TRUE)
			qdel(src)
			return
	return ..()