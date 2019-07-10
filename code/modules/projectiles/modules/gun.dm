/obj/item/weapon/gun_modular
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'code/modules/projectiles/modules/modular.dmi'
	icon_state = "base"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 2000
	w_class = ITEM_SIZE_NORMAL
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"
	attack_verb = list("struck", "hit", "bashed")
	action_button_name = "Switch Gun"
	var/obj/item/ammo_casing/chambered = null
	var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
	var/silenced = 0
	var/recoil = 0
	var/clumsy_check = 1
	var/can_suicide_with = TRUE
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/lock_time = -100
	var/automatic = 0 //Used to determine if you can target multiple people.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate = 0 	//0 for keep shooting until aim is lowered
						// 1 for one bullet after tarrget moves and aim is lowered
	var/fire_delay = 0
	var/last_fired = 0

	var/mob/user_parent = null

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	var/obj/item/weapon/modul_gun/grip/grip = null
	var/obj/item/weapon/modul_gun/barrel/barrel = null
	var/obj/item/weapon/modul_gun/chamber/chamber = null
	var/obj/item/weapon/modul_gun/magazine/magazine = null
	var/list/accessory = list()
	var/list/accessory_type = list()
	var/max_accessory = 3
	var/obj/item/weapon/modul_gun/selected_module = null

	var/lessdamage = 0
	var/lessdispersion = 0
	var/lessfiredelay = 0
	var/lessrecoil = 0
	var/size = 0
	var/collected = FALSE

/obj/item/weapon/gun_modular/attackby(obj/item/A, mob/user)
	if(MODULE)
		var/obj/item/weapon/modul_gun/modul = A
		user.drop_item()
		modul.attach(src)
		return
	if(selected_module)
		selected_module.attackby(A, user)
	else if(magazine)
		magazine.attackby(A, user)
	if(isscrewdriver(A))
		collected = !collected
		if(collected)
			icon_state = ""
			icon = getFlatIcon(src)
			for(var/obj/item/weapon/modul_gun/i in contents)
				i.delete_overlays(src)
			return
		else
			icon = 'code/modules/projectiles/modules/modular.dmi'
			icon_state = "base"
			for(var/obj/item/weapon/modul_gun/i in contents)
				i.eject(src)

/obj/item/weapon/gun_modular/attack_self(mob/user)
	..()
	if(magazine)
		magazine.attack_self(user)

/obj/item/weapon/gun_modular/attack_hand(mob/user)
	..()
	user_parent = user
	for(var/obj/item/weapon/modul_gun/accessory/action/i in accessory)
		i.user_parent = user
		i.action_button(user, src, TRUE)

/obj/item/weapon/gun_modular/dropped(mob/user)
	..()
	user_parent = null
	for(var/obj/item/weapon/modul_gun/accessory/action/i in accessory)
		i.user_parent = null
		i.action_button(user, src, FALSE)

/obj/item/weapon/gun_modular/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return TRUE
	else
		return FALSE

/obj/item/weapon/gun_modular/proc/special_check(mob/M, atom/target) //Placeholder for any special checks, like detective's revolver. or wizards
	if(M.mind.special_role == "Wizard")
		return FALSE
	return TRUE

/obj/item/weapon/gun_modular/proc/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>*click*</span>")
	playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	return

/obj/item/weapon/gun_modular/proc/shoot_live_shot(mob/living/user)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, VOL_EFFECTS_MASTER, 30, null, -4)
	else
		playsound(user, fire_sound, VOL_EFFECTS_MASTER)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a [istype(src, /obj/item/weapon/gun/energy) ? "laser blast" : "gunshot"]!")

/obj/item/weapon/gun_modular/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun_modular/Destroy()
	qdel(chambered)
	chambered = null
	return ..()

/obj/item/weapon/gun_modular/afterattack(atom/A, mob/living/user, flag, params)
	if(!collected)
		return
	if(flag)	return //It's adjacent, is the user, or is on the user's person
	if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))	return//Shouldnt flag take care of this?
	if(user && user.client && user.client.gun_mode && !(A in target))
		PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else
		Fire(A,user,params) //Otherwise, fire normally.

/obj/item/weapon/gun_modular/proc/Fire(atom/target, mob/living/user, params, reflex = 0, point_blank = FALSE)//TODO: go over this
	//Exclude lasertag guns from the CLUMSY check.
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
		return

	if(grip)
		if(grip.check_uses(user))
			return
	else
		return

	add_fingerprint(user)

	if(!special_check(user, target))
		return

	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!</span>")
		return
	if(chamber)
		chamber.chamber_round()
		chamber.Fire(A,user,params)
		chamber.process_chamber()
	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()


/obj/item/weapon/gun_modular/proc/can_fire()
	return

/obj/item/weapon/gun_modular/proc/can_hit(mob/living/target, mob/living/user)
	return chambered.BB.check_fire(target,user)

/obj/item/weapon/gun_modular/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "<span class='red'><b>*click*</b></span>")
		playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	else
		src.visible_message("*click click*")
		playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/gun_modular/proc/isHandgun()
	return 1

/obj/item/weapon/gun_modular/attack(mob/living/M, mob/living/user, def_zone)
	//Suicide handling.
	if (M == user && def_zone == O_MOUTH)
		if(user.is_busy())
			return
		if(!can_suicide_with)
			to_chat(user, "<span class='notice'>You have tried to commit suicide, but couldn't do it with [src].</span>")
			return
		if(isrobot(user))
			to_chat(user, "<span class='notice'>You have tried to commit suicide, but couldn't do it.</span>")
			return
		M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger...</span>")
		if(!use_tool(user, user, 40))
			M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			return
		if (can_fire())
			user.visible_message("<span class = 'warning'>[user] pulls the trigger.</span>")
			if(silenced)
				playsound(user, fire_sound, VOL_EFFECTS_MASTER, 10)
			else
				playsound(user, fire_sound, VOL_EFFECTS_MASTER)
			if(istype(chambered.BB, /obj/item/projectile/beam/lastertag) || istype(chambered.BB, /obj/item/projectile/beam/practice))
				user.visible_message("<span class = 'notice'>Nothing happens.</span>",\
									"<span class = 'notice'>You feel rather silly, trying to commit suicide with a toy.</span>")
				return
			if(istype(chambered.BB, /obj/item/projectile/bullet/chameleon))
				user.visible_message("<span class = 'notice'>Nothing happens.</span>",\
									"<span class = 'notice'>You feel weakness and the taste of gunpowder, but no more.</span>")
				user.apply_effect(5,WEAKEN,0)
				return

			chambered.BB.on_hit(M)
			if (chambered.BB.damage_type != HALLOSS)
				user.apply_damage(chambered.BB.damage * 2.5, chambered.BB.damage_type, BP_HEAD, null, chambered.BB.damage_flags(), "Point blank shot in the mouth with \a [chambered.BB]")
				user.death()
			else
				to_chat(user, "<span class = 'notice'>Ow...</span>")
				user.apply_effect(110,AGONY,0)
			chambered.BB = null
			chambered.update_icon()
			update_icon()
			chamber.process_chamber()
			return
		else
			click_empty(user)
			return

	if (can_fire())
		//Point blank shooting if on harm intent or target we were targeting.
		if(user.a_intent == "hurt")
			Fire(M, user, null, null, TRUE)
			return
		else if(target && M in target)
			Fire(M,user) ///Otherwise, shoot!
			return
	else
		return ..()
