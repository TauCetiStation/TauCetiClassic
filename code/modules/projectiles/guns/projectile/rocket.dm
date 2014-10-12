/*/obj/item/weapon/gun/rocketlauncher
	var/projectile
	name = "rocket launcher"
	desc = "MAGGOT."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = 0
	origin_tech = "combat=8;materials=5"
	projectile = /obj/item/missile
	var/missile_speed = 2
	var/missile_range = 30
	var/max_rockets = 1
	var/list/rockets = new/list()

/obj/item/weapon/gun/rocketlauncher/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return
	usr << "\blue [rockets.len] / [max_rockets] rockets."

/obj/item/weapon/gun/rocketlauncher/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/rocket))
		if(rockets.len < max_rockets)
			user.drop_item()
			I.loc = src
			rockets += I
			user << "\blue You put the rocket in [src]."
			user << "\blue [rockets.len] / [max_rockets] rockets."
		else
			usr << "\red [src] cannot hold more rockets."

/obj/item/weapon/gun/rocketlauncher/can_fire()
	return rockets.len

/obj/item/weapon/gun/rocketlauncher/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(rockets.len)
		var/obj/item/ammo_casing/rocket/I = rockets[1]
		var/obj/item/missile/M = new projectile(user.loc)
		playsound(user.loc, 'sound/effects/bang.ogg', 50, 1)
		M.primed = 1
		M.throw_at(target, missile_range, missile_speed,user)
		message_admins("[key_name_admin(user)] fired a rocket from a rocket launcher ([src.name]).")
		log_game("[key_name_admin(user)] used a rocket launcher ([src.name]).")
		rockets -= I
		del(I)
		return
	else
		usr << "\red [src] is empty." */

/obj/item/weapon/gun/projectile/revolver/rocketlauncher
	name = "Goliath missile launcher"
	desc = "The Goliath is a single-shot shoulder-fired multipurpose missile launcher."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = 4.0
	force = 5
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
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

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/mob_can_equip(M as mob, slot)
	//Cannot equip wielded items.
	if(wielded)
		M << "<span class='warning'>Unwield the [initial(name)] first!</span>"
		return 0

	return ..()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/process_chamber()
	return ..(1, 1)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/dropped(mob/user as mob)
	//handles unwielding a twohanded weapon when dropped as well as clearing up the offhand
	if(user)
		var/obj/item/weapon/gun/projectile/revolver/rocketlauncher/O = user.get_inactive_hand()
		if(istype(O))
			O.unwield()
	return	unwield()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/pickup(mob/user)
	unwield()

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_self(mob/user as mob)
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

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_hand(mob/user as mob)
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
		user << "<span class = 'notice'>You unload [num_unloaded] missile\s from [src].</span>"
	else
		user << "<span class='notice'>[src] is empty.</span>"

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(!wielded)
		user << "<span class='notice'>You need wield [src] in both hands before firing!</span>"
		return
	else
		..()
		if(chambered)
			del(chambered)
			chambered = null