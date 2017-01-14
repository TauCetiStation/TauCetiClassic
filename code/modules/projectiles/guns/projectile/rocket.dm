/obj/item/weapon/gun/projectile/revolver/rocketlauncher
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = 4.0
	force = 5
	flags =  CONDUCT | USEDELAY
	origin_tech = "combat=8;materials=5"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rocket
	var/wielded = 0
	fire_sound = 'sound/effects/bang.ogg'

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/unwield()
	wielded = 0
	update_icon()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/proc/wield()
	wielded = 1
	update_icon()

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

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/pickup(mob/user)
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
		if(user.get_inactive_hand())
			to_chat(user, "<span class='warning'>You need your other hand to be empty</span>")
			return
		wield()
		to_chat(user, "<span class='notice'>You grab the [initial(name)] with both hands.</span>")

		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()

		var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
		O.name = "[initial(name)] - offhand"
		O.desc = "Your second grip on the [initial(name)]."
		user.put_in_inactive_hand(O)
		return

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

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/afterattack(atom/target, mob/living/user, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		to_chat(user, "<span class='notice'>You need wield [src] in both hands before firing!</span>")
		return
	else
		..()
		if(chambered)
			qdel(chambered)
			chambered = null
