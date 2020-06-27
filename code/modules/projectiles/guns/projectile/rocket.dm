/obj/item/weapon/gun/projectile/revolver/rocketlauncher
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = ITEM_SIZE_LARGE
	force = 5
	flags =  CONDUCT
	origin_tech = "combat=8;materials=5"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rocket
	var/wielded = 0
	can_be_holstered = FALSE
	fire_sound = 'sound/effects/bang.ogg'

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/unwield()
	wielded = 0
	update_icon()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/wield()
	wielded = 1
	update_icon()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/MouseDrop(obj/over_object)
	if (ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (loc != usr)
			return
		if (!over_object)
			return

		if (!usr.incapacitated())
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/mob_can_equip(M, slot)
	//Cannot equip wielded items.
	if(wielded)
		to_chat(M, "<span class='warning'>Unwield the [initial(name)] first!</span>")
		return 0

	return ..()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/process_chamber()
	return ..(1, 1)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/dropped(mob/user)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/gun/projectile/revolver/rocketlauncher/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/pickup(mob/living/user)
	unwield()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_self(mob/user)
	if(wielded) //Trying to unwield it
		unwield()
		to_chat(user, "<span class='notice'>You are now carrying the [name] with one hand.</span>")
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()

		var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand()
		if(O && istype(O))
			O.unwield()
		return

	else //Trying to wield it
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/W = H.wield(src, initial(name))
			if(W)
				wield()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>You unload [num_unloaded] missile\s from [src].</span>")
	else
		to_chat(user, "<span class='notice'>[src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/afterattack(atom/target, mob/user, proximity, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		to_chat(user, "<span class='notice'>You need wield [src] in both hands before firing!</span>")
		return
	else
		..()
		if(chambered)
			qdel(chambered)
			chambered = null
