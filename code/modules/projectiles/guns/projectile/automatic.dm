/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/msmg9mm
	can_be_holstered = FALSE
	var/alarmed = FALSE

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(..() && chambered)
		alarmed = FALSE

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mac-10"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses 9mm rounds."
	icon_state = "mac"
	item_state = "mac"
	w_class = ITEM_SIZE_NORMAL
	can_be_holstered = TRUE
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	return


/obj/item/weapon/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "A lightweight, compact bullpup SMG. Uses .45 ACP rounds in medium-capacity magazines and has a threaded barrel for silencers. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=5;materials=2;syndicate=8"
	mag_type = /obj/item/ammo_box/magazine/m12mm
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'


/obj/item/weapon/gun/projectile/automatic/c20r/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/c20r/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/guns/empty_alarm.ogg', VOL_EFFECTS_MASTER, 40)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/c20r/attack_self(mob/user)
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

/obj/item/weapon/gun/projectile/automatic/c20r/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/silencer))
		return silencer_attackby(I, user, params)
	return ..()

/obj/item/weapon/gun/projectile/automatic/c20r/update_icon()
	..()
	cut_overlays()
	if(magazine)
		var/image/magazine_icon = image('icons/obj/gun.dmi', "mag-[CEIL(get_ammo(0) / 4) * 4]")
		add_overlay(magazine_icon)
	if(silenced)
		var/image/silencer_icon = image('icons/obj/gun.dmi', "c20r-silencer")
		add_overlay(silencer_icon)
	icon_state = "c20r[chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	desc = "A heavily modified light machine gun with a tactical plasteel frame resting on a rather traditionally-made ballistic weapon. Has 'Aussec Armoury - 2531' engraved on the reciever, as well as '7.62x51mm'."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = ITEM_SIZE_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m762
	fire_sound = 'sound/weapons/guns/Gunshot2.wav'
	var/cover_open = 0
	var/wielded = 0

/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/unwield()
	wielded = 0
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/proc/wield()
	wielded = 1
	update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/mob_can_equip(M, slot)
	//Cannot equip wielded items.
	if(wielded)
		to_chat(M, "<span class='warning'>Unwield the [initial(name)] first!</span>")
		return 0

	return ..()

/obj/item/weapon/gun/projectile/automatic/l6_saw/dropped(mob/user)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/gun/projectile/automatic/l6_saw/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/gun/projectile/automatic/l6_saw/pickup(mob/living/user)
	unwield()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	switch(alert("Would you like to [cover_open ? "open" : "close"], or change grip?","Choose.","Toggle cover","Change grip"))
		if("Toggle cover")
			if(wielded || user.get_inactive_hand())
				to_chat(user, "<span class='warning'>You need your other hand to be empty to do this.</span>")
				return
			else
				if(ishuman(user))
					var/mob/living/carbon/human/H = user
					if(!H.can_use_two_hands())
						to_chat(user, "<span class='warning'>You need both of your hands to be intact.</span>")
						return
				cover_open = !cover_open
				to_chat(user, "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>")
				update_icon()
				return
		if("Change grip")
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

/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEIL(get_ammo(0) / 12.5) * 25 : "-empty"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target, mob/user, proximity, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		to_chat(user, "<span class='notice'>You need wield [src] in both hands before firing!</span>")
		return
	if(cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
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
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/I, mob/user, params)
	if(!cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>")
		return
	return ..()

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = ITEM_SIZE_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
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

/obj/item/weapon/gun/projectile/automatic/c5
	name = "security submachine gun"
	desc = "C-5 submachine gun - cheap and light. Uses 9mm ammo."
	icon_state = "c5"
	item_state = "c5"
	w_class = ITEM_SIZE_NORMAL
	can_be_holstered = TRUE
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/c5_9mm
	fire_sound = 'sound/weapons/guns/gunshot_c5.wav'

/obj/item/weapon/gun/projectile/automatic/c5/update_icon(mob/M)
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
	icon_state = "l13"
	item_state = "l13"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/l13_38
	fire_sound = 'sound/weapons/guns/gunshot_l13.ogg'

/obj/item/weapon/gun/projectile/automatic/l13/update_icon(mob/M)
	icon_state = "l13[magazine ? "" : "-e"]"
	item_state = "l13[magazine ? "" : "-e"]"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_inv_l_hand()
		H.update_inv_r_hand()
		H.update_inv_belt()
	return

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "tommy gun"
	desc = "A genuine Chicago Typewriter."
	icon_state = "tommygun"
	item_state = "tommygun"
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'

/obj/item/weapon/gun/projectile/automatic/bar
	name = "Browning M1918"
	desc = "Browning Automatic Rifle."
	icon_state = "bar"
	item_state = "bar"
	w_class = ITEM_SIZE_HUGE
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/m3006
	fire_sound = 'sound/weapons/guns/Gunshot2.wav'

/obj/item/weapon/gun/projectile/automatic/luger
	name = "Luger P08"
	desc = "A small, easily concealable gun. Uses 9mm rounds."
	icon_state = "p08"
	w_class = ITEM_SIZE_SMALL
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m9pmm
	can_be_holstered = TRUE

/obj/item/weapon/gun/projectile/automatic/luger/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/colt1911/dungeon
	desc = "A single-action, semi-automatic, magazine-fed, recoil-operated pistol chambered for the .45 ACP cartridge."
	name = "Colt M1911"
	mag_type = /obj/item/ammo_box/magazine/c45m
	mag_type2 = /obj/item/ammo_box/magazine/c45r

/obj/item/weapon/gun/projectile/automatic/borg
	name = "Robot SMG"
	icon_state = "borg_smg"
	mag_type = /obj/item/ammo_box/magazine/borg45
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'

/obj/item/weapon/gun/projectile/automatic/borg/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/borg/attack_self(mob/user)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	return

/obj/item/weapon/gun/projectile/automatic/bulldog
	name = "V15 Bulldog shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors. Compatible only with specialized magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/guns/gunshot_shotgun.ogg'

/obj/item/weapon/gun/projectile/automatic/bulldog/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/bulldog/proc/update_magazine()
	if(magazine)
		cut_overlays()
		add_overlay("[magazine.icon_state]_o")
		return

/obj/item/weapon/gun/projectile/automatic/bulldog/update_icon()
	cut_overlays()
	update_magazine()
	icon_state = "bulldog[chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/bulldog/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(user, 'sound/weapons/guns/empty_alarm.ogg', VOL_EFFECTS_MASTER, 40)
		update_icon()
		alarmed = 1
	return

/obj/item/weapon/gun/projectile/automatic/a28
	name = "A28 assault rifle"
	desc = ""
	icon_state = "a28"
	item_state = "a28"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'

/obj/item/weapon/gun/projectile/automatic/a28/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/a28/update_icon()
	cut_overlays()
	if(magazine)
		add_overlay("[magazine.icon_state]-o")
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/a74
	name = "A74 assault rifle"
	desc = "Stradi and Practican Maid Bai Spess soviets corporation, bazed he original design of 20 centuriyu fin about baars and vodka vile patrimonial it, saunds of balalaika place minvile, yuzes 7.74 caliber"
	mag_type = /obj/item/ammo_box/magazine/a74mm
	w_class = ITEM_SIZE_NORMAL
	icon_state = "a74"
	item_state = "a74"
	origin_tech = "combat=5;materials=4;syndicate=6"
	fire_sound = 'sound/weapons/guns/gunshot_ak74.ogg'
	var/icon/mag_icon = icon('icons/obj/gun.dmi',"mag-a74")

/obj/item/weapon/gun/projectile/automatic/a74/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/a74/update_icon()
	cut_overlays()
	if(magazine)
		add_overlay(mag_icon)
		item_state = "[initial(icon_state)]"
	else
		item_state = "[initial(icon_state)]-e"
