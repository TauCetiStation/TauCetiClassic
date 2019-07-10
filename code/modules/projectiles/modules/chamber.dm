/obj/item/weapon/modul_gun/chamber
	name = "chamber"
	icon_state = "chamber_bullet_icon"
	var/obj/item/ammo_casing/chambered_fire
	var/obj/item/ammo_casing/storage
	var/obj/item/weapon/modul_gun/magazine/magazine
	var/obj/item/weapon/modul_gun/grip/grip = null
	var/obj/item/weapon/modul_gun/barrel/barrel = null
	var/obj/item/weapon/gun_modular/parent
	var/fire_delay = 12
	var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
	var/recoil = 1
	var/list/ammo_type = list()
	var/caliber = "9mm"
	var/select = 1
	var/pellets = 0
	var/silenced = FALSE
	var/collected = FALSE

/obj/item/weapon/modul_gun/chamber/proc/chamber_round()
	return	magazine.get_round()

/obj/item/weapon/modul_gun/chamber/proc/process_chamber()
	return

/obj/item/weapon/modul_gun/chamber/proc/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>*click*</span>")
	playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	return

/obj/item/weapon/modul_gun/chamber/proc/shoot_live_shot(mob/living/user)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, VOL_EFFECTS_MASTER, 30, null, -4)
	else
		playsound(user, fire_sound, VOL_EFFECTS_MASTER)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")


/obj/item/weapon/modul_gun/chamber/proc/Fire(atom/A, mob/living/user, flag, params)
	if(chambered)
		if(point_blank)
			user.visible_message("<span class='red'><b> \The [user] fires \the [src] point blank at [target]!</b></span>")
			chambered.BB.damage *= 1.3
		if(!barrel)
			chambered.BB.dispersion += 4
		else
			silenced = barrel.silenced

		if(!chambered.fire(target, user, params, , silenced))
			shoot_with_empty_chamber(user)
		else
			shoot_live_shot(user)
			user.newtonian_move(get_dir(target, user))
	else
		shoot_with_empty_chamber(user)
	update_icon()


//////////////////////////////////////////////ENERGY

/obj/item/weapon/modul_gun/chamber/energy
	name = "energy chamber"
	caliber = "energy"
	icon_state = "cha1_icon"
	icon_overlay = "cha1"
	var/list/obj/item/ammo_casing/energy/lens = list()
	var/max_lens = 2

/obj/item/weapon/modul_gun/chamber/energy/attackby(obj/item/A, mob/user)
	if(LENS && lens.len < max_lens)
		var/obj/item/ammo_casing/energy/lense = A
		lens.Add(lense)
		ammo_type.Add(lense.type)
		user.drop_item()
		lense.loc = src
		fire_sound = lense.fire_sound
	if(isscrewdriver(A))
		for(var/obj/item/ammo_casing/energy/I in lens)
			I.loc = get_turf(src.loc)
			ammo_type.Remove(I.type)
			lens.Remove(I)

/obj/item/weapon/modul_gun/chamber/energy/chamber_round()
	if(magazine)
		return magazine.get_round(lens[select])
	return FALSE

/obj/item/weapon/modul_gun/chamber/proc/process_chamber()
	parent.chambered = null
	return

//////////////////////////////////////////////BULLET

/obj/item/weapon/modul_gun/chamber/bullet
	name = "bullet chamber"
	icon_state = "cha2_icon"
	icon_overlay = "cha2"

/obj/item/weapon/modul_gun/chamber/bullet/chamber_round()
	.=..()
	if(parent.magazine.ammo_count())
		var/obj/item/ammo_casing/chambered = parent.magazine.get_round()
		chambered.loc = src
		if(chambered.BB)
			if(chambered.reagents && chambered.BB.reagents)
				var/datum/reagents/casting_reagents = chambered.reagents
				casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
				casting_reagents.delete()
		return chambered
	return null

/obj/item/weapon/modul_gun/chamber/bullet/process_chamber(var/eject_casing = 1, var/empty_chamber = 1, var/no_casing = 0)
//	if(chambered)
//		return 1
	if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
		parent.last_fired += pick(20,40,60)
		return
	var/obj/item/ammo_casing/AC = parent.chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		chamber_round()
		return
	if(parent.magazine.eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
		spawn(3) //next gen sound effects
			playsound(src, 'sound/weapons/guns/shell_drop.ogg', VOL_EFFECTS_MASTER, 25)
	else
		AC.loc = parent.magazine
	if(empty_chamber)
		parent.chambered = null
	if(no_casing)
		qdel(AC)
	return



//////////////////////////////////////////////MODULES BULLET
/obj/item/weapon/modul_gun/chamber/bullet/shotgun
	name = "chamber bullet shotgun"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	pellets = 7
	lessdamage = 7
	lessdispersion = -3
	size = 2
	recoil = 3
	fire_delay = 12
	caliber = "shotgun"

/obj/item/weapon/modul_gun/chamber/bullet/rus357
	name = "chamber bullet 357"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	pellets = 0
	lessdamage = 3
	lessdispersion = -3
	size = 2
	recoil = 1
	fire_delay = 8
	caliber = "357"

/obj/item/weapon/modul_gun/chamber/bullet/m9mm
	name = "chamber bullet 9mm"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	pellets = 0
	lessdamage = 3
	lessdispersion = -2
	size = 2
	recoil = 1
	fire_delay = 7
	caliber = "9mm"

/obj/item/weapon/modul_gun/chamber/bullet/heavyrifle
	name = "chamber bullet 14.5mm"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	pellets = 0
	lessdamage = 0
	lessdispersion = -2
	size = 3
	recoil = 6
	fire_delay = 20
	caliber = "14.5mm"
//////////////////////////////////////////////MODULES ENERGY
/obj/item/weapon/modul_gun/chamber/energy/shotgun
	name = "chamber laser shotgun"
	icon_state = "chamber_laser1"
	icon_overlay = "chamber_laser1"
	pellets = 7
	lessdamage = 7
	lessdispersion = -3
	size = 2
	recoil = -10
	fire_delay = 16
	max_lens = 1
	caliber = "energy"

/obj/item/weapon/modul_gun/chamber/energy/laser
	name = "chamber laser one"
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
	pellets = 0
	lessdamage = 3
	lessdispersion = -2
	size = 2
	recoil = -10
	fire_delay = 8
	max_lens = 1
	caliber = "energy"

/obj/item/weapon/modul_gun/chamber/energy/duolaser
	name = "chamber laser duo"
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
	pellets = 0
	lessdamage = 4
	lessdispersion = -2
	size = 2
	recoil = -10
	fire_delay = 8
	max_lens = 2
	caliber = "energy"

/obj/item/weapon/modul_gun/chamber/energy/triolaser
	name = "chamber laser trio"
	icon_state = "chamber_energy"
	icon_overlay = "chamber_energy"
	pellets = 0
	lessdamage = 5
	lessdispersion = -2
	size = 2
	recoil = -10
	fire_delay = 8
	max_lens = 3
	caliber = "energy"