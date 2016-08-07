/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon = 'tauceti/icons/obj/guns.dmi'
	icon_state = "saber"	//ugly
	w_class = 3.0
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/msmg9mm
	var/alarmed = 0

/obj/item/weapon/gun/projectile/automatic/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/attackby(var/obj/item/A as obj, mob/user as mob)
	if(..() && chambered)
		alarmed = 0

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mac-10"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses 9mm rounds."
	icon_state = "mac"
	item_state = "mac"
	w_class = 3.0
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "A lightweight, compact bullpup SMG. Uses .45 ACP rounds in medium-capacity magazines and has a threaded barrel for silencers. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/m12mm
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'


/obj/item/weapon/gun/projectile/automatic/c20r/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/c20r/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r/attack_self(mob/user as mob)
	if(silenced)
		switch(alert("Would you like to unscrew silencer, or extract magazine?","Choose.","Silencer","Magazine"))
			if("Silencer")
				if(loc == user)
					if(silenced)
						silencer_attack_hand(user)
			if("Magazine")
				..()
	else
		..()

/obj/item/weapon/gun/projectile/automatic/c20r/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/silencer))
		return silencer_attackby(I,user)
	return ..()

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	icon_state = "c20r[silenced ? "-silencer" : ""][magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified light machine gun with a tactical plasteel frame resting on a rather traditionally-made ballistic weapon. Has 'Aussec Armoury - 2531' engraved on the reciever, as well as '7.62x51mm'."
	icon = 'tauceti/items/weapons/syndicate/syndicate_guns.dmi'
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m762
	fire_sound = 'tauceti/sounds/weapon/gunshot3.wav'
	var/cover_open = 0
	var/wielded = 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/unwield()
	wielded = 0
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/wield()
	wielded = 1
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/mob_can_equip(M as mob, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
		return 0

	return ..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/dropped(mob/user as mob)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/gun/projectile/automatic/l6_saw/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/gun/projectile/automatic/l6_saw/pickup(mob/user)
	unwield()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user as mob)
	switch(alert("Would you like to [cover_open ? "open" : "close"], or change grip?","Choose.","Toggle cover","Change grip"))
		if("Toggle cover")
			if(wielded)
				user << "<span class='notice'>You need your other hand to be empty.</span>"
				return
			else
				cover_open = !cover_open
				user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
				update_icon()
				return
		if("Change grip")
			if(wielded) //Trying to unwield it
				unwield()
				user << "<span class='notice'>You are now carrying the [name] with one hand.</span>"
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
					user << "<span class='warning'>You need your other hand to be empty</span>"
					return
				wield()
				user << "<span class='notice'>You grab the [initial(name)] with both hands.</span>"

				if(user.hand)
					user.update_inv_l_hand()
				else
					user.update_inv_r_hand()

				var/obj/item/weapon/twohanded/offhand/O = new(user) ////Let's reserve his other hand~
				O.name = "[initial(name)] - offhand"
				O.desc = "Your second grip on the [initial(name)]"
				user.put_in_inactive_hand(O)
				return


/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? Ceiling(get_ammo(0)/12.5)*25 : "-empty"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		user << "<span class='notice'>You need wield [src] in both hands before firing!</span>"
		return
	if(cover_open)
		user << "<span class='notice'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(var/obj/item/A as obj, mob/user as mob)
	if(!cover_open)
		user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
		return
	..()

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = 5
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'
	//can_suppress = 0
 	//burst_size = 4
 	//fire_delay = 1

/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */

/* Where Ausops failed, I have not. -SirBayer */

//=================NEW GUNS=================\\
/obj/item/weapon/gun/projectile/automatic/l10c
	name = "L10-c"
	desc = "A basic energy-based carbine with fast rate of fire."
	icon = 'icons/obj/gun.dmi'
	icon_state = "l10-car"
	item_state = "l10-car"
	w_class = 4.0
	origin_tech = "combat=3;magnets=2"
	mag_type = /obj/item/ammo_box/magazine/l10mag
	fire_sound = 'sound/weapons/guns/l10c-shot.ogg'
	recoil = 0
	energy_gun = 1

/obj/item/weapon/gun/projectile/automatic/l10c/New()
	..()
	update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/l10c/process_chamber()
	return ..(0, 1, 1)

/obj/item/weapon/gun/projectile/automatic/l10c/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..()
	update_icon(user)
	return

/obj/item/weapon/gun/projectile/automatic/l10c/attack_self(mob/user as mob)
	if(magazine && magazine.ammo_count())
		playsound(user, 'sound/weapons/guns/l10c-unload.ogg', 70, 1)
	if(chambered)
		var/obj/item/ammo_casing/AC = chambered //Find chambered round
		qdel(AC)
		chambered = null
		magazine.stored_ammo += new magazine.ammo_type(magazine)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	update_icon(user)
	return

/obj/item/weapon/gun/projectile/automatic/l10c/attackby(var/obj/item/A as obj, mob/user as mob)
	if (istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if (!magazine && istype(AM, mag_type))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.loc = src
			user << "<span class='notice'>You load a new magazine into \the [src].</span>"
			if(AM.ammo_count())
				playsound(user, 'sound/weapons/guns/l10c-load.ogg', 70, 1)
			chamber_round()
			A.update_icon()
			update_icon(user)
			return 1
		else if (magazine)
			user << "<span class='notice'>There's already a magazine in \the [src].</span>"
	return 0

/obj/item/weapon/gun/projectile/automatic/l10c/update_icon(var/mob/M)
	if(!magazine)
		icon_state = "[initial(icon_state)]-e"
		item_state = "[initial(item_state)]-e"
	else if(chambered)
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"
	else if(magazine && magazine.ammo_count())
		icon_state = "[initial(icon_state)]"
		item_state = "[initial(item_state)]"
	else
		icon_state = "[initial(icon_state)]-0"
		item_state = "[initial(item_state)]-0"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_inv_l_hand()
		H.update_inv_r_hand()
		H.update_inv_belt()
	return


/obj/item/weapon/gun/projectile/automatic/c5
	name = "security submachine gun"
	desc = "C-5 submachine gun - cheap and light. Uses 9mm ammo."
	icon = 'icons/obj/gun.dmi'
	icon_state = "c5"
	item_state = "c5"
	w_class = 3.0
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/c5_9mm
	fire_sound = 'sound/weapons/guns/c5_shot.wav'

/obj/item/weapon/gun/projectile/automatic/c5/update_icon(var/mob/M)
	icon_state = "c5[magazine ? "" : "-e"]"
	item_state = "c5[magazine ? "" : "-e"]"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_inv_l_hand()
		H.update_inv_r_hand()
		H.update_inv_belt()
	return

/obj/item/weapon/gun/projectile/automatic/l13
	name = "security submachine gun"
	desc = "L13 personal defense weapon - for combat security operations. Uses .38 ammo."
	icon = 'icons/obj/gun.dmi'
	icon_state = "l13"
	item_state = "l13"
	w_class = 3.0
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/l13_38
	fire_sound = 'sound/weapons/guns/l13_shot.ogg'

/obj/item/weapon/gun/projectile/automatic/l13/update_icon(var/mob/M)
	icon_state = "l13[magazine ? "" : "-e"]"
	item_state = "l13[magazine ? "" : "-e"]"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_inv_l_hand()
		H.update_inv_r_hand()
		H.update_inv_belt()
	return