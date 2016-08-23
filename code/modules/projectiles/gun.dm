/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."

	flags =  FPRINT | TABLEPASS | CONDUCT
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 5

	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	action_button_name = "Switch Gun"

	//Targeting
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/tmp/mouthshoot = 0 ///To stop people from suiciding twice... >.>
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 0 	//0 for keep shooting until aim is lowered
						// 1 for one bullet after tarrget moves and aim is lowered

	//Icons
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	//Inventory
	w_class = 3
	slot_flags = 0

	//Chamber
	var/obj/item/ammo_casing/chambered = null

	//Misc
	var/silenced = 0
	var/recoil = 0
	var/clumsy_check = 1
	var/gas_firearm = 0 //if next round should only load after successfull shot.

	//Firemode & modificators
	var/datum/firemode/firemode
	var/datum/w_modificator/w_mod = new()

	//Sounds
	var/s_fire = 'sound/weapons/Gunshot.ogg'
	var/fire_volume = 100
	var/s_magazine_in = 'sound/weapons/guns/generic_mag_in.ogg'
	var/s_magazine_out = 'sound/weapons/guns/generic_mag_out.ogg'
	var/s_ammo_in = 'sound/weapons/guns/generic_bullet_in.ogg'
	var/s_slide_in = 'sound/weapons/guns/generic_slide_in.ogg'
	var/s_slide_out = 'sound/weapons/guns/generic_slide_out.ogg'
	var/action_volume = 100

	var/fire_delay = 6
	var/last_fired = 0

	//Stock
	force = 5

	//Mods/accessory
	var/list/acceptable_mods = list()
	var/list/installed_mods = list()

/obj/item/weapon/gun/proc/can_mod_with(obj/item/weapon_parts/WP)
	if(istype(WP) && (WP.type in acceptable_mods) && !(WP in installed_mods))
		return 1
	return 0

/obj/item/weapon/gun/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/weapon_parts) && can_mod_with(A))
		var/obj/item/weapon_parts/WP = A
		playsound(user, WP.s_add, action_volume, 1)
		if(do_after_in_action(user,WP.add_delay,src,A))
			WP.add_modification(src,user)
			return 1
	if(istype(A, /obj/item/weapon/screwdriver) && installed_mods.len)
		if(installed_mods.len > 1)
			var/obj/item/weapon_parts/WP = input("Select a mod to remove", "Remove a mod", null) as obj in installed_mods
			if(WP)
				playsound(user, WP.s_remove, action_volume, 1)
				if(do_after_in_action(user,WP.remove_delay,src,A))
					WP.remove_modification(src,user)
					return 1
		else
			var/obj/item/weapon_parts/WP = installed_mods[1]
			playsound(user, WP.s_remove, action_volume, 1)
			if(do_after_in_action(user,WP.remove_delay,src,A))
				WP.remove_modification(src,user)
				return 1
	return 0

/obj/item/weapon/gun/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return 1
	else
		return 0

/obj/item/weapon/gun/proc/process_chamber()
	return 0

/obj/item/weapon/gun/proc/special_check(mob/M, atom/target) //Placeholder for any special checks, like detective's revolver.
	return 1

/obj/item/weapon/gun/proc/shoot_with_empty_chamber(mob/living/user)
	if(!gas_firearm)
		process_chamber()
	user << "<span class='warning'>*click*</span>"
	playsound(user, 'sound/weapons/guns/generic_click.ogg', action_volume, 1)

/obj/item/weapon/gun/proc/shoot_live_shot(mob/living/user as mob|obj)
	//if(recoil)
	//	spawn()
	//		shake_camera(user, recoil + 1, recoil)
	process_chamber()

	if(silenced)
		playsound(user, s_fire, fire_volume/10, 1)
	else
		playsound(user, s_fire, fire_volume, 0)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/Destroy()
	qdel(chambered)
	chambered = null
	..()

/obj/item/weapon/gun/afterattack(atom/A, mob/living/user, flag, params)
	if(flag)	return //It's adjacent, is the user, or is on the user's person
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?

	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
		return

	if(user && user.a_intent == I_HELP)
		user << "<span class='warning'>You refrain from firing your [src] as your intent is set to help.</span>"
	else
		Fire(A,user,params) //Otherwise, fire normally.

/obj/item/weapon/gun/proc/Fire(atom/target, mob/living/user, params, reflex = 0)//TODO: go over this
	//Exclude lasertag guns from the CLUMSY check.
	if (!user.IsAdvancedToolUser())
		user << "<span class='red'>You don't have the dexterity to do this!</span>"
		return
	if(istype(user, /mob/living))
		var/mob/living/M = user
		if (HULK in M.mutations)
			M << "<span class='red'>Your meaty finger is much too large for the trigger guard!</span>"
			return
		if(istype(user, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = user
			if(H.species.name == "Shadowling")
				H << "<span class='notice'>Your fingers don't fit in the trigger guard!</span>"
				return
	if(ishuman(user))
		if(user.dna && user.dna.mutantrace == "adamantine")
			user << "<span class='red'>Your metal fingers don't fit in the trigger guard!</span>"
			return
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/armor/abductor/vest))
			for(var/obj/item/clothing/suit/armor/abductor/vest/V in list(H.wear_suit))
				if(V.stealth_active)
					V.DeactivateStealth()

		if(clumsy_check) //it should be AFTER hulk or monkey check.
			var/going_to_explode = 0
			if ((CLUMSY in H.mutations) && prob(50))
				going_to_explode = 1
			if(chambered && chambered.crit_fail && prob(10))
				going_to_explode = 1
			if(going_to_explode)
				explosion(user.loc, 0, 0, 1, 1)
				H << "<span class='danger'>[src] blows up in your face.</span>"
				H.take_organ_damage(0,20)
				H.drop_item()
				qdel(src)
				return

	add_fingerprint(user)

	if(!special_check(user, target))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			user << "<span class='warning'>[src] is not ready to fire again!</span>"
		return

	if(chambered)
		if(firemode && firemode.burst_fire)
			for(var/i=1 to firemode.burst_this_many)
				if(!user)
					break
				if(src != user.get_active_hand())
					break
				if(!chambered)
					break
				if(!chambered.fire(target, user, params, silenced, src))
					shoot_with_empty_chamber(user)
					break
				else
					user.next_move = world.time + (firemode.burst_delay * 2)
					shoot_live_shot(user)
				sleep(firemode.burst_delay)
		else
			if(!chambered.fire(target, user, params, silenced, src))
				shoot_with_empty_chamber(user)
			else
				user.next_move = world.time + fire_delay
				shoot_live_shot(user)
	else
		shoot_with_empty_chamber(user)

	update_icon()

	if(user)
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()


/obj/item/weapon/gun/proc/can_fire()
	return

/obj/item/weapon/gun/proc/can_hit(var/mob/living/target as mob, var/mob/living/user as mob)
	return chambered.BB.check_fire(target,user)

/obj/item/weapon/gun/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "<span class='red'><b>*click*</b></span>")
		playsound(user, 'sound/weapons/guns/generic_click.ogg', 100, 1)
	else
		src.visible_message("*click click*")
		playsound(src.loc, 'sound/weapons/guns/generic_click.ogg', 100, 1)

/obj/item/weapon/gun/proc/isHandgun()
	return 1

/obj/item/weapon/gun/attack_self_alt(mob/user)
	if(firemode)
		firemode.switch_firemode(user)

/obj/item/weapon/gun/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	//Suicide handling.
	if (M == user && user.zone_sel.selecting == "mouth" && !mouthshoot)
		mouthshoot = 1
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!do_after(user, 40, target = user))
			M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			mouthshoot = 0
			return
		if (can_fire())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				playsound(user, s_fire, fire_volume/10, 1)
			else
				playsound(user, s_fire, fire_volume, 1)
			if(istype(chambered.BB, /obj/item/projectile/beam/lastertag) || istype(chambered.BB, /obj/item/projectile/beam/practice))
				user.visible_message("<span class = 'notice'>Nothing happens.</span>",\
									"<span class = 'notice'>You feel rather silly, trying to commit suicide with a toy.</span>")
				mouthshoot = 0
				return
			if(istype(chambered.BB, /obj/item/projectile/bullet/chameleon))
				user.visible_message("<span class = 'notice'>Nothing happens.</span>",\
									"<span class = 'notice'>You feel weakness and the taste of gunpowder, but no more.</span>")
				user.apply_effect(5,WEAKEN,0)
				mouthshoot = 0
				return

			chambered.BB.on_hit(M)
			if (chambered.BB.damage_type != HALLOSS)
				user.apply_damage(chambered.BB.damage*2.5, chambered.BB.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [chambered.BB]", sharp=1)
				user.death()
			else
				user << "<span class = 'notice'>Ow...</span>"
				user.apply_effect(110,AGONY,0)
			chambered.BB = null
			chambered.update_icon()
			update_icon()
			mouthshoot = 0
			process_chamber()
			return
		else
			click_empty(user)
			mouthshoot = 0
			return

	if (can_fire())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == "hurt")
			user.visible_message("<span class='red'><b> \The [user] fires \the [src] point blank at [M]!</b></span>")
			chambered.BB.damage *= 1.3
			Fire(M,user)
			return
		else if(target && M in target)
			Fire(M,user) ///Otherwise, shoot!
			return
	else
		return ..()
