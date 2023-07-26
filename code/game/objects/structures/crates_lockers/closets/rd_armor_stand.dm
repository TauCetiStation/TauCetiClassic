/obj/structure/closet/rd_armor_stand
	name = "Experimental Armor Storage"
	desc = "Storage of experimental teleportation armor."

	icon_state = "telearmorstand"
	icon_closed = "telearmorstand"
	icon_opened = "telearmorstand" // uses overlay
	anchored = TRUE
	opened = TRUE
	locked = TRUE

	integrity_failure = 0.5

	var/obj/item/clothing/suit/armor/vest/reactive/reactive
	var/localopened = FALSE
	var/smashed = FALSE

/obj/structure/closet/rd_armor_stand/atom_init(mapload)
	. = ..()
	add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "telearmor_overlay"))
	add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))

/obj/structure/closet/rd_armor_stand/Destroy()
	QDEL_NULL(reactive)
	return ..()

/obj/structure/closet/rd_armor_stand/PopulateContents()
	reactive = new /obj/item/clothing/suit/armor/vest/reactive(src)

/obj/structure/closet/rd_armor_stand/attackby(obj/item/O, mob/living/user)
	if (user.is_busy(src))
		return

	if (isrobot(usr) || locked)
		if(ispulsing(O))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', VOL_EFFECTS_MASTER)
			if (do_after(user, 100, target = src))
				locked = FALSE
				to_chat(user, "<span class='notice'>You disable the locking modules.</span>")
				return
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/I = O
			if(!(access_rd in I.access))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return
			else
				locked = FALSE
				to_chat(user, "<span class='notice'>You disable the locking modules.</span>")
				return

	else if (istype(O, /obj/item/clothing/suit/armor/vest/reactive) && localopened)
		if(!reactive)
			user.drop_from_inventory(O, src)
			reactive = O
			to_chat(user, "<span class='notice'>You place the armor back in the [src.name].</span>")
			add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "telearmor_overlay"))
	else
		if(smashed)
			return
		if(ispulsing(O))
			if(localopened)
				localopened = FALSE
				add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				if(O.use_tool(src, user, 100, volume = 50))
					locked = TRUE
					to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
					playsound(user, 'sound/machines/lockenable.ogg', VOL_EFFECTS_MASTER)
					return
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/ID = O
			if(!(access_rd in ID.access))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return
			if(localopened)
				localopened = FALSE
				add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))
				return
			if((!localopened) && (!locked))
				locked = TRUE
				to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
				playsound(user, 'sound/machines/lockenable.ogg', VOL_EFFECTS_MASTER)
		else
			if(localopened)
				localopened = FALSE
				add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))

/obj/structure/closet/rd_armor_stand/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(smashed)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
			else
				playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/closet/rd_armor_stand/atom_break(damage_flag)
	if(smashed || flags & NODECONSTRUCT)
		return ..()
	smashed = TRUE
	localopened = TRUE
	locked = FALSE
	cut_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))
	add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_broken_overlay"))
	playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	new /obj/item/weapon/shard(loc)
	new /obj/item/weapon/shard(loc)
	. = ..()

/obj/structure/closet/rd_armor_stand/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()

	if(reactive)
		reactive.forceMove(loc)
		reactive = null
	new /obj/item/stack/sheet/metal(loc, 2)
	if(!smashed)
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
	return ..()

/obj/structure/closet/rd_armor_stand/attack_hand(mob/living/user)
	if(user.is_busy(src))
		return
	user.SetNextMove(CLICK_CD_MELEE)

	if(locked)
		to_chat(user, "<span class='warning'>The storage won't budge!</span>")
		return
	if((!localopened) && (!smashed))
		localopened = TRUE
		cut_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))
		to_chat(user, "<span class='notice'>You opened the [name].</span>")
		return

	if((localopened) || (smashed))
		if(reactive)
			user.try_take(reactive, loc)
			reactive = null
			to_chat(user, "<span class='notice'>You take the armor from the [name].</span>")
			add_fingerprint(user)
			cut_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "telearmor_overlay"))
			return
		if((localopened) && (!smashed))
			to_chat(user, "<span class='notice'>You closed the [name].</span>")
			localopened = FALSE
			add_overlay(image(icon = 'icons/obj/closet.dmi', icon_state = "standglass_overlay"))
			return

/obj/structure/closet/rd_armor_stand/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/closet/rd_armor_stand/attack_ai(mob/user)
	if(smashed)
		to_chat(user, "<span class='warning'>The security of the storage is compromised.</span>")
	else
		if(locked)
			locked = TRUE
			to_chat(user, "<span class='warning'>Storage locked.</span>")
		else
			locked = FALSE
			to_chat(user, "<span class='notice'>Storage unlocked.</span>")

/obj/structure/closet/rd_armor_stand/open()
	return

/obj/structure/closet/rd_armor_stand/close()
	return

/obj/structure/closet/rd_armor_stand/emag_act()
	locked = FALSE
	visible_message("<span class='warning'>[name] lock sparkles!</span>")
	return
