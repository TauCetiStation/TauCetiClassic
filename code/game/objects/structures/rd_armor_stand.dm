/obj/structure/rd_armor_stand
	name = "Experimental Armor Storage"
	desc = "Storage of experimental teleportation armor."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "telearmorstand"
	anchored = TRUE
	integrity_failure = 0.5

	var/obj/item/clothing/suit/armor/vest/reactive/reactive
	var/opened = FALSE
	var/smashed = FALSE
	var/lock = TRUE

/obj/structure/rd_armor_stand/atom_init(mapload)
	. = ..()
	reactive = new /obj/item/clothing/suit/armor/vest/reactive(src)
	update_icon()

/obj/structure/rd_armor_stand/Destroy()
	QDEL_NULL(reactive)
	return ..()

/obj/structure/rd_armor_stand/attackby(obj/item/O, mob/living/user)
	if (user.is_busy(src))
		return

	if (isrobot(usr) || lock)
		if(ispulsing(O))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(src, 'sound/machines/lockreset.ogg', VOL_EFFECTS_MASTER)
			if (do_after(user, 100, target = src))
				lock = FALSE
				to_chat(user, "<span class='notice'>You disable the locking modules.</span>")
				playsound(src, 'sound/machines/airlock/bolts_up_2.ogg', VOL_EFFECTS_MASTER)
				return
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/I = O
			if(!(access_rd in I.access))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return
			else
				lock = FALSE
				to_chat(user, "<span class='notice'>You disable the locking modules.</span>")
				playsound(src, 'sound/machines/airlock/bolts_up_2.ogg', VOL_EFFECTS_MASTER)
				return

	else if (istype(O, /obj/item/clothing/suit/armor/vest/reactive) && opened)
		if(!reactive)
			user.drop_from_inventory(O, src)
			reactive = O
			to_chat(user, "<span class='notice'>You place the armor back in the [src.name].</span>")
			update_icon()
	else
		if(smashed)
			return
		if(ispulsing(O))
			if(opened)
				opened = FALSE
				to_chat(user, "<span class='notice'>You closed the [name].</span>")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				if(O.use_tool(src, user, 100, volume = 50))
					lock = TRUE
					to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
					playsound(src, 'sound/machines/airlock/bolts_down_2.ogg', VOL_EFFECTS_MASTER)
					return
		if(istype(O, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/ID = O
			if(!(access_rd in ID.access))
				to_chat(user, "<span class='warning'>Access denied.</span>")
				return
			if(opened)
				opened = FALSE
				to_chat(user, "<span class='notice'>You closed the [name].</span>")
				update_icon()
				return
			if((!opened) && (!lock))
				lock = TRUE
				to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
				playsound(src, 'sound/machines/airlock/bolts_down_2.ogg', VOL_EFFECTS_MASTER)
		else
			if(opened)
				to_chat(user, "<span class='notice'>You closed the [name].</span>")
				opened = FALSE
				update_icon()

/obj/structure/rd_armor_stand/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(smashed)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
			else
				playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/rd_armor_stand/atom_break(damage_flag)
	if(smashed || flags & NODECONSTRUCT)
		return ..()
	smashed = TRUE
	opened = TRUE
	lock = FALSE
	update_icon()
	playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	new /obj/item/weapon/shard(loc)
	new /obj/item/weapon/shard(loc)
	. = ..()

/obj/structure/rd_armor_stand/deconstruct(disassembled = TRUE)
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

/obj/structure/rd_armor_stand/attack_hand(mob/living/user)
	if(user.is_busy(src))
		return
	user.SetNextMove(CLICK_CD_MELEE)

	if(lock)
		to_chat(user, "<span class='warning'>The storage won't budge!</span>")
		return
	if((!opened) && (!smashed))
		opened = TRUE
		update_icon()
		to_chat(user, "<span class='notice'>You opened the [name].</span>")
		return

	if((opened) || (smashed))
		if(reactive)
			user.try_take(reactive, loc)
			reactive = null
			to_chat(user, "<span class='notice'>You take the armor from the [name].</span>")
			add_fingerprint(user)
			update_icon()
			return
		if((opened) && (!smashed))
			to_chat(user, "<span class='notice'>You closed the [name].</span>")
			opened = FALSE
			update_icon()
			return

/obj/structure/rd_armor_stand/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/rd_armor_stand/attack_ai(mob/user)
	if(smashed)
		to_chat(user, "<span class='warning'>The security of the storage is compromised.</span>")
	else
		if(lock)
			lock = TRUE
			to_chat(user, "<span class='warning'>Storage locked.</span>")
			playsound(src, 'sound/machines/airlock/bolts_down_2.ogg', VOL_EFFECTS_MASTER)
		else
			lock = FALSE
			to_chat(user, "<span class='notice'>Storage unlocked.</span>")
			playsound(src, 'sound/machines/airlock/bolts_up_2.ogg', VOL_EFFECTS_MASTER)

/obj/structure/rd_armor_stand/emag_act()
	lock = FALSE
	visible_message("<span class='warning'>[name] lock sparkles!</span>")
	playsound(src, 'sound/machines/airlock/bolts_up_2.ogg', VOL_EFFECTS_MASTER)
	return

/obj/structure/rd_armor_stand/update_icon()
	cut_overlays()
	if(reactive)
		var/mutable_appearance/showpiece_overlay = mutable_appearance(reactive.icon, reactive.icon_state)
		showpiece_overlay.copy_overlays(reactive)
		showpiece_overlay.transform *= 0.75
		add_overlay(showpiece_overlay)
	if((!opened) && (!smashed))
		add_overlay(image(icon = 'icons/obj/stationobjs.dmi', icon_state = "standglass_overlay"))
	if(smashed)
		add_overlay(image(icon = 'icons/obj/stationobjs.dmi', icon_state = "standglass_broken_overlay"))
