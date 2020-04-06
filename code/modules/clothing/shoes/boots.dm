/obj/item/clothing/shoes/boots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "wjboots"
	item_state = "wjboots"
	item_color = "hosred"
	siemens_coefficient = 0.7
	clipped_status = CLIPPABLE
	var/obj/item/knife

/obj/item/clothing/shoes/boots/MouseDrop(obj/over_object)
	if (ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (!(src.loc == usr))
			return
		if (!over_object)
			return

		if (!( usr.restrained() ) && !( usr.stat ))
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			src.add_fingerprint(usr)
			return
	return

/obj/item/clothing/shoes/boots/Destroy()
	if(knife)
		QDEL_NULL(knife)
	return ..()

/obj/item/clothing/shoes/boots/attack_hand(mob/living/user)
	if(knife && loc == user && !user.incapacitated())
		if(user.put_in_active_hand(knife))
			playsound(user, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER, 25)
			to_chat(user, "<span class='notice'>You slide [knife] out of [src].</span>")
			knife = null
			update_icon()
	else
		return ..()

/obj/item/clothing/shoes/boots/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/pen/edagger))
		if(knife)
			return
		user.drop_item()
		knife = I
		I.forceMove(src)
		playsound(user, 'sound/items/lighter.ogg', VOL_EFFECTS_MASTER, 25)
		to_chat(user, "<span class='notice'>You slide the [I] into [src].</span>")

/obj/item/clothing/shoes/boots/galoshes
	desc = "Rubber boots."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN + 1
	species_restricted = null
	clipped_status = NO_CLIPPING

/obj/item/clothing/shoes/boots/work
	name = "work boots"
	desc = "Boots of a simple working man."
	icon_state = "workboots"
	item_color = "workboots"
	item_state = "b_shoes"  // need sprites for this

/obj/item/clothing/shoes/boots/swat
	name = "SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	flags = NOSLIP
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/boots/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	flags = NOSLIP
	siemens_coefficient = 0.6

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/boots/combat/cut // Basically combat shoes but for xenos.
	name = "mangled combat boots"
	desc = "When you REALLY want to turn up the heat<br>They have the toe caps cut off of them."
	icon_state = "swat_cut"
	clipped_status = CLIPPED
	species_restricted = list("exclude", DIONA, VOX, VOX_ARMALIS)

/obj/item/clothing/shoes/boots/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"
	clipped_status = NO_CLIPPING

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null
