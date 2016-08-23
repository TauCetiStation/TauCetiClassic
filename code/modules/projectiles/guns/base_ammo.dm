/obj/item/projectile/bullet
	icon = 'code/modules/projectiles/guns/base.dmi'
	name = "bullet"
	icon_state = "bullet"
	damage = 20
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	embed = 1
	sharp = 1
	var/stoping_power = 0
	muzzle_type = /obj/effect/projectile/bullet/muzzle

/obj/item/ammo_casing/pistol
	desc = "A pistol bullet casing."
	caliber = "pistol"
	projectile_type = "/obj/item/projectile/bullet/pistol"

/obj/item/ammo_casing/rifle
	desc = "A rifle bullet casing."
	caliber = "rifle"
	projectile_type = "/obj/item/projectile/bullet/rifle"

/obj/item/ammo_casing/sniper
	desc = "A sniper bullet casing."
	caliber = "sniper"
	projectile_type = "/obj/item/projectile/bullet/sniper"

/obj/item/ammo_casing/shotgun/buckshot
	name = "shotgun slug"
	desc = "A shotgun slug."
	caliber = "shotgun"
	projectile_type = "/obj/item/projectile/bullet/shotgun"

/obj/item/ammo_casing/shotgun/buckshot
	name = "shotgun shell"
	desc = "A shotgun shell."
	projectile_type = "/obj/item/projectile/bullet/shotgun/buckshot"
	pellets = 8

/obj/item/projectile/bullet/pistol
	damage = 15
	dispersion = 0.6

/obj/item/projectile/bullet/rifle
	damage = 20
	dispersion = 0.4

/obj/item/projectile/bullet/sniper
	damage = 50
	dispersion = 0.2

/obj/item/projectile/bullet/shotgun
	name = "pellet"
	damage = 75
	dispersion = 0.3

/obj/item/projectile/bullet/shotgun/buckshot
	damage = 12
	dispersion = 1.5

/obj/item/projectile/bullet/shotgun/buckshot/on_fire()
	..()
	pixel_x += rand(-8,8)
	pixel_y += rand(-8,8)

/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)
	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/ammo_container
	name = "ammo container"
	desc = ""
	icon = 'code/modules/projectiles/guns/base.dmi'
	icon_state = "357"
	item_state = "syringe_kit"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = 0
	m_amt = 2000
	throwforce = 2
	w_class = 2.0
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/spawn_with_ammo = 0
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/caliber = null
	var/multiload = 1

/obj/item/ammo_container/New()
	if(spawn_with_ammo && ammo_type)
		for(var/i = 1 to max_ammo)
			stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_container/Destroy()
	for(var/obj/item/ammo_casing/AC in contents)
		stored_ammo -= AC
		AC.loc = get_turf(src)
	stored_ammo.Cut()
	return ..()

/obj/item/ammo_container/proc/special_check()
	return

/obj/item/ammo_container/proc/get_round()
	if (!stored_ammo.len)
		return null
	else
		var/AC = stored_ammo[stored_ammo.len]
		stored_ammo -= AC
		update_icon()
		return AC

/obj/item/ammo_container/proc/give_round(obj/item/ammo_casing/AC, mob/user, obj/item/ammo_container/giver)
	if (AC)
		if (stored_ammo.len < max_ammo && AC.caliber == caliber)
			playsound(loc, 'sound/weapons/guns/generic_bullet_in.ogg', 100)
			if(do_after_in_action(user,5,src,giver))
				if(user)
					user.remove_from_mob(AC)
				stored_ammo += AC
				AC.loc = src
				update_icon()
				if(giver)
					giver.stored_ammo -= AC
					giver.update_icon()
					giver.special_check()
				return 1
	return 0

/obj/item/ammo_container/attackby(obj/item/A, mob/user)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_container))
		var/obj/item/ammo_container/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC, user, AM)
			if(did_load)
				num_loaded++
			if(!did_load || !multiload || user.a_intent != "hurt")
				break
	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC, user))
			num_loaded++
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		return num_loaded
	return 0

/obj/item/ammo_container/attack_self(mob/user)
	var/obj/item/ammo_casing/AC = get_round()
	if(AC)
		AC.loc = get_turf(loc)
		if(user.a_intent != "hurt")
			if(!user.put_in_hands(AC))
				var/obj/item/O = user.get_inactive_hand()
				if(istype(O, /obj/item/ammo_container) || istype(O, /obj/item/ammo_casing))
					O.attackby(AC,user)
		user << "<span class='notice'>You remove a [AC] from \the [src]!</span>"

/obj/item/ammo_container/update_icon()
	desc = "[initial(desc)] There are [stored_ammo.len] round\s left!"

//Behavior for magazines
/obj/item/ammo_container/magazine/proc/ammo_count()
	return stored_ammo.len

/obj/item/ammo_container/magazine/internal
	name = "internal magazine"
	desc = ""
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7

/obj/item/ammo_container/magazine/internal/New()
	if(isturf(loc))
		qdel(src)
		return
	..()

/obj/item/ammo_container/magazine/external/New()
	..()
	name = "[max_ammo]-rnd [caliber] magazine"

/obj/item/ammo_container/magazine/external/m9mm
	name = "7-rnd 9mm mag"
	icon_state = "basemag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 7

/obj/item/ammo_container/magazine/external/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon/gun/projectile))
		var/obj/item/weapon/gun/projectile/G = A
		G.insert_ammo_container(src, user)
		return 1
	else
		..()

/obj/item/ammo_container/casing_holder
	name = "rounds stack"
	icon = null
	icon_state = null
	ammo_type = null
	var/stored_limit = 10
	var/spawned = 1

/obj/item/ammo_container/casing_holder/New(loc,AC,AC2)
	if(AC && AC2)
		give_round(AC)
		give_round(AC2)
	else
		qdel(src)
		return
	..()

/obj/item/ammo_container/casing_holder/Destroy()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_from_inventory(src)
		var/obj/item/ammo_casing/AC = locate() in contents
		if(AC)
			stored_ammo -= AC
			M.put_in_hands(AC)
	return ..()

/obj/item/ammo_container/casing_holder/give_round(obj/item/ammo_casing/AC, mob/user, obj/item/ammo_container/giver)
	if (AC)
		if (stored_ammo.len < stored_limit)
			stored_ammo += AC
			if(user)
				user.remove_from_mob(AC)
			AC.loc = src
			update_icon()
			if(giver)
				giver.stored_ammo -= AC
				giver.update_icon()
			special_check()
			return 1
	return 0

/obj/item/ammo_container/casing_holder/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_container/casing_holder))
		var/obj/item/ammo_container/CH = A
		for(var/obj/item/ammo_casing/AC in CH.stored_ammo)
			if(!give_round(AC, user, CH))
				special_check()
				break
			else if (user.a_intent != "hurt")
				break
	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		give_round(AC, user)

/obj/item/ammo_container/casing_holder/get_round()
	var/AC = stored_ammo[stored_ammo.len]
	stored_ammo -= AC
	update_icon()
	special_check()
	return AC

/obj/item/ammo_container/casing_holder/special_check()
	if(spawned)
		spawned = 0
	else if(!qdeleted() && stored_ammo.len < 2)
		qdel(src)

/obj/item/ammo_container/casing_holder/update_icon()
	overlays.Cut()
	var/count = 0
	for(var/obj/o in stored_ammo)
		count++
		var/image/I = image("icon"=o.icon,"icon_state"=o.icon_state,"dir"=SOUTHWEST)
		I.pixel_x = -12 + count*2
		overlays += I

/obj/item/ammo_container/box
	name = "box of ammo"
	desc = "A box of rounds."
	icon = 'code/modules/projectiles/guns/base.dmi'
	icon_state = "base_box"
	spawn_with_ammo = 1
//	var/open = 0

/obj/item/ammo_container/box/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_container/magazine))
		A.attackby(src,user)
	else
		..()

/obj/item/ammo_container/box/pistol
	desc = "A box of pistol rounds."
	ammo_type = /obj/item/ammo_casing/pistol
	max_ammo = 20
	caliber = "pistol"

//obj/item/ammo_container/box/attack_self_ctrl(mob/living/user)
//	open = !(open)
//	update_icon()

//obj/item/ammo_container/box/update_icon()
//	icon_state = "[initial(icon_state)]_[open ? "open" : "closed"]"
