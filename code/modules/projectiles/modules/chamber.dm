/obj/item/weapon/modul_gun/chamber
	name = "chamber"
	icon_state = "chamber_bullet_icon"
	var/fire_delay = 12
	var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
	var/recoil = 1
	var/list/ammo_type = list()
	var/caliber = "9mm"
	var/select = 1

/obj/item/weapon/modul_gun/chamber/attach(obj/item/weapon/gun_modular/gun)
	.=..()
	if(caliber == "energy" && !ammo_type.len > 0)
		return
	if(!gun.chamber)
		parent = gun
		src.loc = gun
		parent.chamber = src
		parent.recoil += recoil
	else
		return

/obj/item/weapon/modul_gun/chamber/proc/chamber_round()
	return

/obj/item/weapon/modul_gun/chamber/proc/process_chamber()
	return

/obj/item/weapon/modul_gun/chamber/energy
	name = "energy chamber"
	caliber = "energy"
	var/list/obj/item/ammo_casing/energy/lens = list()
	var/max_lens = 2

/obj/item/weapon/modul_gun/chamber/energy/attackby(obj/item/A, mob/user)
	if(LENS && lens.len < max_lens)
		var/obj/item/ammo_casing/energy/lense = A
		lens.Add(lense)
		ammo_type.Add(lense.type)
		user.drop_item()
		lense.loc = src

/obj/item/weapon/modul_gun/chamber/bullet
	name = "bullet chamber"


/obj/item/weapon/modul_gun/chamber/bullet/chamber_round()
	if (parent.chambered || !parent.magazine)
		return
	else if (parent.magazine.ammo_count())
		var/obj/item/ammo_casing/chambered = parent.magazine.get_round()
		chambered.loc = src
		if(chambered.BB)
			if(chambered.reagents && chambered.BB.reagents)
				var/datum/reagents/casting_reagents = chambered.reagents
				casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
				casting_reagents.delete()
		return chambered
	return null

/obj/item/weapon/modul_gun/chamber/energy/chamber_round()
	if(parent.chambered || !parent.magazine)
		return
	var/obj/item/ammo_casing/energy/chambered = parent.magazine.get_round()
	chambered.loc = src
	return chambered

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
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
		spawn(3) //next gen sound effects
			playsound(src, 'sound/weapons/guns/shell_drop.ogg', VOL_EFFECTS_MASTER, 25)
	if(empty_chamber)
		parent.chambered = null
	if(no_casing)
		qdel(AC)
	return

/obj/item/weapon/modul_gun/chamber/energy/process_chamber()
	if (parent.chambered) // incase its out of energy - since then this will be null.
		var/obj/item/ammo_casing/energy/shot = parent.chambered
		parent.magazine.power_supply.use(shot.e_cost)
	parent.chambered = null
	return