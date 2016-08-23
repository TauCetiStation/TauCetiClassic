/obj/item/weapon/gun/projectile
	name = "projectile gun"
	desc = ""
	origin_tech = "combat=2;materials=2"
	w_class = 3.0
	m_amt = 1000
	recoil = 1
	var/spawn_with_mag = 1
	var/caliber// = "pistol"
	var/mag_type// = /obj/item/ammo_container/magazine/external
	var/obj/item/ammo_container/magazine/magazine
	var/slide_state = 0 //1 = open

	//Delays
	fire_delay = 10
	var/mag_in_delay = 9 //how much time it takes to insert a magazine (based on sound).
	var/mag_out_delay = 0 //mostly this is just ejection, so there is no point in delay.
	var/ammo_in_delay = 4 //direct shell insertion.

	//Icons
	united_dmi = 1
	icon = 'code/modules/projectiles/guns/base.dmi'
	icon_state = "base"
	item_state = "base"

	//Misc
	gas_firearm = 1

/obj/item/weapon/gun/projectile/special_check(mob/user)
	if(slide_state)
		user << "<span class='warning'>*click*</span>"
		playsound(user, 'sound/weapons/guns/generic_click.ogg', action_volume, 1)
		return 0
	return 1

/obj/item/weapon/gun/projectile/update_icon()
	var/silencer = (locate(/obj/item/weapon_parts/silencer) in installed_mods)
	icon_state = "[initial(icon_state)][silencer ? "-s" : ""][slide_state ? "-b" : ""]"

/obj/item/weapon/gun/projectile/New()
	..()
	if(spawn_with_mag)
		magazine = new mag_type(src)
	update_icon()

/obj/item/weapon/gun/projectile/Destroy()
	qdel(magazine)
	magazine = null
	..()

/obj/item/weapon/gun/projectile/process_chamber(eject_casing = 1, empty_chamber = 1, caseless = 0)
	if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
		last_fired += pick(20,40,60)
		return

	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		chamber_round()
		return

	if(eject_casing)
		eject_casing()

	if(empty_chamber)
		chambered = null

	if(caseless)
		qdel(AC)

	chamber_round()

/obj/item/weapon/gun/projectile/proc/eject_casing(mob/user, in_hands = 0)
	if(chambered)
		var/do_animation = 1
		chambered.loc = get_turf(src) //Eject casing onto ground.
		if(in_hands && user && user.a_intent != I_HURT && user.put_in_hands(chambered))
			do_animation = 0
		if(do_animation)
			chambered.SpinAnimation(10, 1) //next gen special effects
			spawn(3) //next gen sound effects
				playsound(loc, 'sound/weapons/shell_drop.ogg', 50, 1)
		chambered = null

/obj/item/weapon/gun/projectile/proc/chamber_round(manual = 0)
	if (chambered)
		return
	else if (magazine && magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
		if(chambered.BB)
			if(chambered.reagents && chambered.BB.reagents)
				var/datum/reagents/casting_reagents = chambered.reagents
				casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
				casting_reagents.delete()
	else if(!manual)
		slide_state = 1
		update_icon()

/obj/item/weapon/gun/projectile/attackby(obj/item/A, mob/user)
	if(insert_ammo_container(A,user))
		return 1
	else if(..())
		return 1
	return 0

/obj/item/weapon/gun/projectile/proc/insert_ammo_container(obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_container))
		if(istype(A, /obj/item/ammo_container/magazine))
			if(magazine)
				user << "<span class='notice'>There's already a [magazine] in \the [src].</span>"
			else
				var/obj/item/ammo_container/magazine/mag = A
				if(istype(mag, mag_type))
					playsound(loc, s_magazine_in, action_volume)
					if(do_after_in_action(user,mag_in_delay,src,mag))
						user.remove_from_mob(mag)
						magazine = mag
						magazine.loc = src
						magazine.update_icon()
						update_icon()
						//chamber_round()
						user << "<span class='notice'>You load a new [mag] into \the [src].</span>"
						return 1
				else
					user << "<span class='notice'>[mag] does not fit into \the [src].</span>"
		else if(istype(A, /obj/item/ammo_container/box))
			var/obj/item/ammo_container/box/B = A
			if(B.caliber == caliber)
				if(slide_state)
					if(chambered)
						user << "<span class='notice'>There's already a [chambered] in \the [src].</span>"
					else
						var/obj/item/ammo_casing/AC = B.get_round()
						if(AC)
							playsound(loc, s_ammo_in, action_volume)
							if(do_after_in_action(user,ammo_in_delay,src,B))
								user.remove_from_mob(AC)
								chambered = AC
								chambered.loc = src
								update_icon()
								user << "<span class='notice'>You load a new [AC] into \the [src].</span>"
								return 1
				else
					user << "<span class='notice'>To load [A] directly into the chamber pull slide first.</span>"
			else
				user << "<span class='notice'>This ammo caliber does not fit into \the [src].</span>"
		else if(istype(A, /obj/item/ammo_container/casing_holder))
			if(slide_state)
				if(chambered)
					user << "<span class='notice'>There's already a [chambered] in \the [src].</span>"
				else
					var/obj/item/ammo_container/casing_holder/CH = A
					var/obj/item/ammo_casing/AC = null
					for(var/obj/item/ammo_casing/found in CH.stored_ammo)
						if(found.caliber == caliber)
							AC = found
							break
					if(AC)
						playsound(loc, s_ammo_in, action_volume)
						if(do_after_in_action(user,ammo_in_delay,src,CH))
							CH.stored_ammo -= AC
							CH.update_icon()
							CH.special_check()
							chambered = AC
							chambered.loc = src
							update_icon()
							user << "<span class='notice'>You load a new [AC] into \the [src].</span>"
							return 1
					else
						user << "<span class='notice'>No suitable bullet caliber found in [A].</span>"
			else
				user << "<span class='notice'>To load [A] directly into the chamber pull slide first.</span>"
	else if(istype(A, /obj/item/ammo_casing))
		if(slide_state)
			if(chambered)
				user << "<span class='notice'>There's already a [chambered] in \the [src].</span>"
			else
				var/obj/item/ammo_casing/AC = A
				if(AC.caliber == caliber)
					playsound(loc, s_ammo_in, action_volume)
					if(do_after_in_action(user,ammo_in_delay,src,AC))
						user.remove_from_mob(AC)
						chambered = AC
						chambered.loc = src
						update_icon()
						user << "<span class='notice'>You load a new [AC] into \the [src].</span>"
						return 1
				else
					user << "<span class='notice'>[AC] does not fit into \the [src].</span>"
		else
			user << "<span class='notice'>To load [A] directly into the chamber pull slide first.</span>"
	return 0

/obj/item/weapon/gun/projectile/attack_self_ctrl(mob/living/user)
	slide_state = !(slide_state)
	if(slide_state)
		eject_casing(user, 1)
		playsound(loc, s_slide_out, action_volume)
	else
		chamber_round(1)
		playsound(loc, s_slide_in, action_volume)
	update_icon()
	user.next_click = world.time + 3

/obj/item/weapon/gun/projectile/can_fire()
	if(chambered && chambered.BB)
		return 1
	return 0

/obj/item/weapon/gun/projectile/attack_self(mob/living/user)
	remove_magazine(user)

/obj/item/weapon/gun/projectile/proc/remove_magazine(mob/living/user)
	if (magazine)
		playsound(loc, s_magazine_out, action_volume, 1)
		if(mag_out_delay && !do_after_in_action(user,mag_out_delay,src))
			return
		magazine.loc = get_turf(src.loc)
		if(user.a_intent != I_HURT)
			user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		user << "<span class='notice'>You pull the magazine out of \the [src]!</span>"
	else
		user << "<span class='notice'>There's no magazine in \the [src].</span>"
	update_icon()

/obj/item/weapon/gun/projectile/examine()
	..()
	if(slide_state && chambered)
		usr << "<span class='notice'>You see a casing in chamber.</span>"

/obj/item/weapon/gun/projectile/proc/get_ammo(var/countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets
