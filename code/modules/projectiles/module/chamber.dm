/obj/item/weapon/gun_module/chamber
	name = "gun chamber"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	attackbying = CONTINUED
	attackself = IGNORING
	var/obj/item/ammo_casing/chambered = null
	var/caliber
	var/gun_type
	var/pellets = 0
	var/fire_delay = 10
	var/last_fired = 0
	var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
	var/point_blank
	var/silenced = FALSE

/obj/item/weapon/gun_module/chamber/attach(obj/item/weapon/gunmodule/gun)
	if(..(gun, condition_check(gun)))
		gun.chamber = src
		gun.gun_type = gun_type
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/chamber/condition_check(obj/item/weapon/gunmodule/gun)
	if(!gun.chamber && !gun.collected)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/chamber/eject(obj/item/weapon/gunmodule/gun)
	gun.chamber = null
	gun.gun_type = null
	..()

/obj/item/weapon/gun_module/chamber/proc/chamber_round()
	if(chambered)
		return FALSE
	if(!parent.magazine_supply)
		return FALSE
	return TRUE

/obj/item/weapon/gun_module/chamber/proc/process_chamber()
	chambered = null

/obj/item/weapon/gun_module/chamber/proc/Fire(atom/target, mob/living/user, params, reflex = 0, point_blank = FALSE)
	if (!ready_to_fire())
		if (world.time % 3) //to prevent spam
			to_chat(user, "<span class='warning'>[src] is not ready to fire again!</span>")
		return
	if(parent.magazine_supply.magazine)
		chamber_round()
	if(chambered)
		if(point_blank)
			user.visible_message("<span class='red'><b> \The [user] fires \the [src] point blank at [target]!</b></span>")
			chambered.BB.damage *= 1.3
		if(parent.barrel)
			silenced = parent.barrel.silenced
		else
			chambered.BB.dispersion = 4

		chambered.BB.lessdamage = parent.lessdamage
		chambered.BB.dispersion -= lessdispersion

		if(!chambered.fire(target, user, params, , silenced))
			shoot_with_empty_chamber(user)
		else
			shoot_live_shot(user)
			user.newtonian_move(get_dir(target, user))
	else
		shoot_with_empty_chamber(user)
	process_chamber()
	update_icon()

	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()

/obj/item/weapon/gun_module/chamber/proc/ready_to_fire()
	if(world.time >= last_fired + fire_delay)
		last_fired = world.time
		return TRUE
	else
		return FALSE

/obj/item/weapon/gun_module/chamber/attack_self(mob/user)
	return

/obj/item/weapon/gun_module/chamber/proc/shoot_live_shot(mob/user, var/recoil = 1, var/silenced = FALSE)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(silenced)
		playsound(user, fire_sound, VOL_EFFECTS_MASTER, 30, null, -4)
	else
		playsound(user, fire_sound, VOL_EFFECTS_MASTER)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [parent]!</span>", "You hear a [gun_type == "energy" ? "laser blast" : "gunshot"]!")

/obj/item/weapon/gun_module/chamber/proc/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>*click*</span>")
	playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	return

/obj/item/weapon/gun_module/chamber/proc/click_empty(mob/user = null)
	if (user)
		user.visible_message("*click click*", "<span class='red'><b>*click*</b></span>")
		playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	else
		src.visible_message("*click click*")
		playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)

//////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/gun_module/chamber/bullet
	name = "gun chamber bullet"
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	caliber = "9mm"
	gun_type = BULLET

/obj/item/weapon/gun_module/chamber/bullet/condition_check(obj/item/weapon/gunmodule/gun)
	if(..(gun))
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/chamber/bullet/chamber_round()
	if(!..() && !parent.magazine_supply.ammo_count())
		return FALSE
	chambered = parent.magazine_supply.get_round()
	if(chambered)
		chambered.loc = src
	if(chambered.BB)
		if(chambered.reagents && chambered.BB.reagents)
			var/datum/reagents/casting_reagents = chambered.reagents
			casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
			casting_reagents.delete()

/obj/item/weapon/gun_module/chamber/bullet/process_chamber(var/eject_casing = 1, var/empty_chamber = 1, var/no_casing = 0)
	if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
		last_fired += pick(20,40,60)
		return
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
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
	return

//////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun_module/chamber/energy
	name = "gun chamber energy"
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	caliber = "energy"
	gun_type = ENERGY
	var/modifystate = 0
	var/list/obj/item/ammo_casing/energy/lens = list()
	var/max_lens = 2
	var/select = 1

/obj/item/weapon/gun_module/chamber/energy/condition_check(obj/item/weapon/gunmodule/gun)
	if(..(gun) && lens.len > 0)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/chamber/energy/chamber_round(var/obj/item/ammo_casing/energy/lense = lens[select])
	if(!..() && !parent.magazine_supply.ammo_count(lense))
		return FALSE
	chambered = parent.magazine_supply.get_round(lense)
	if(chambered)
		chambered.loc = src

/obj/item/weapon/gun_module/chamber/energy/process_chamber()
	if(chambered)
		var/obj/item/ammo_casing/energy/lense = chambered
		chambered = null
		qdel(lense)

/obj/item/weapon/gun_module/chamber/energy/verb/activate_self()
	set category = "Gun"
	set name = "Select Fire"

	if(usr.get_active_hand() == parent)
		select_fire(usr)

/obj/item/weapon/gun_module/chamber/energy/proc/select_fire(mob/user)
	select++
	if(select > lens.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = lens[select]
	fire_sound = shot.fire_sound
	if (shot.select_name)
		to_chat(user, "\red [src] is now set to [shot.select_name].")
	update_icon()

/obj/item/weapon/gun_module/chamber/energy/attackby(obj/item/A, mob/user = null)
	if(istype(A, /obj/item/ammo_casing/energy) && lens.len < max_lens)
		var/obj/item/ammo_casing/energy/lense = A
		lens += lense
		if(user)
			user.drop_item()
		lense.loc = src
		select = lens.len
		fire_sound = lense.fire_sound


