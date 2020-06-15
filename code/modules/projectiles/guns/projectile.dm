/obj/item/weapon/gun/projectile
	desc = "Now comes in flavors like GUN. Uses 9mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	origin_tech = "combat=2;materials=2"
	w_class = ITEM_SIZE_NORMAL
	m_amt = 1000
	fire_delay = 0
	recoil = 1
	var/bolt_slide_sound = 'sound/weapons/guns/TargetOn.ogg'
	var/mag_type = /obj/item/ammo_box/magazine/m9mm //Removes the need for max_ammo and caliber info
	var/mag_type2
	var/obj/item/ammo_box/magazine/magazine

/obj/item/weapon/gun/projectile/atom_init()
	. = ..()
	magazine = new mag_type(src)
	chamber_round()
	update_icon()

/obj/item/weapon/gun/projectile/process_chamber(var/eject_casing = 1, var/empty_chamber = 1, var/no_casing = 0)
//	if(chambered)
//		return 1
	if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
		last_fired += pick(20,40,60)
		return
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		chamber_round()
		return
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
		spawn(3) //next gen sound effects
			playsound(src, 'sound/weapons/guns/shell_drop.ogg', VOL_EFFECTS_MASTER, 25)
	if(empty_chamber)
		chambered = null
	if(no_casing)
		qdel(AC)
	chamber_round()
	return

/obj/item/weapon/gun/projectile/proc/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
		if(chambered.BB)
			if(chambered.reagents && chambered.BB.reagents)
				var/datum/reagents/casting_reagents = chambered.reagents
				casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
				casting_reagents.delete()
	return

/obj/item/weapon/gun/projectile/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = I
		if (!magazine && (istype(AM, mag_type) || (istype(AM, mag_type2) && mag_type != null)))
			user.drop_from_inventory(AM, src)
			magazine = AM
			playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
			chamber_round()
			I.update_icon()
			update_icon()
			return TRUE

		else if (magazine)
			to_chat(user, "<span class='notice'>There's already a magazine in \the [src].</span>")
			return

	return ..()

/obj/item/weapon/gun/projectile/can_fire()
	if(chambered && chambered.BB)
		return 1

/obj/item/weapon/gun/projectile/attack_self(mob/living/user)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		update_icon()
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
		return 1
	else if(chambered)
		playsound(src, bolt_slide_sound, VOL_EFFECTS_MASTER)
		process_chamber()
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()
	return 0

/obj/item/weapon/gun/projectile/Destroy()
	qdel(magazine)
	magazine = null
	return ..()

/obj/item/weapon/gun/projectile/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "Has [get_ammo()] round\s remaining.")

/obj/item/weapon/gun/projectile/proc/get_ammo(countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets
