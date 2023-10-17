/obj/item/weapon/gun/projectile
	desc = "Now comes in flavors like GUN. Uses 9mm ammo, for some reason."
	name = "projectile gun"
	icon_state = "pistol"
	origin_tech = "combat=2;materials=2"
	w_class = SIZE_SMALL
	m_amt = 1000
	fire_delay = 4
	recoil = 1
	var/bolt_slide_sound = 'sound/weapons/guns/TargetOn.ogg'
	var/initial_mag = /obj/item/ammo_box/magazine/stechkin
	var/list/suitable_mags = list()
	var/has_cover = FALSE //does this gun has cover
	var/cover_open = FALSE //does gun cover is open
	var/obj/item/ammo_box/magazine/magazine
	var/has_ammo_counter = FALSE

/obj/item/weapon/gun/projectile/atom_init()
	. = ..()
	magazine = new initial_mag(src)
	if(!suitable_mags.len)
		suitable_mags += initial_mag
	chamber_round()
	update_icon()

/obj/item/weapon/gun/projectile/process_chamber(eject_casing = 1, empty_chamber = 1, no_casing = 0)
//	if(chambered)
//		return 1
	if(crit_fail && prob(50))  // IT JAMMED GODDAMIT
		last_fired += pick(20,40,60)
		return
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		chamber_round()
		update_icon()
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
	update_icon()
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
		if (!magazine && (AM.type in suitable_mags))
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
	if(has_cover)
		if(cover_open)
			cover_open = !cover_open
			to_chat(user, "<span class='notice'>You close [src]'s cover.</span>")
			update_icon()
			return
		return ..()
	else if(magazine)
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
	else if(chambered)
		playsound(src, bolt_slide_sound, VOL_EFFECTS_MASTER)
		process_chamber()
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()

/obj/item/weapon/gun/projectile/Destroy()
	qdel(magazine)
	magazine = null
	return ..()

/obj/item/weapon/gun/projectile/examine(mob/user)
	..()
	if(src in view(1, user) && has_ammo_counter)
		to_chat(user, "Has [get_ammo()] round\s remaining.")

/obj/item/weapon/gun/projectile/proc/get_ammo(countchambered = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count()
	return boolets

/obj/item/weapon/gun/projectile/MouseDrop_T(atom/dropping, mob/living/user)
	if(istype(dropping, /obj/item/ammo_box/magazine))
		tactical_reload(dropping, user)
	return ..()

/obj/item/weapon/gun/projectile/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine) && magazine)
		tactical_reload(I, user)
		return
	return ..()

/obj/item/weapon/gun/projectile/proc/tactical_reload(obj/item/ammo_box/magazine/new_magazine, mob/living/user)
	if(!istype(user) || user.incapacitated())
		return
	if(!is_skill_competent(user, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED)))
		return
	if(!user.is_in_hands(src))
		to_chat(user, "<span class='warning'>[src] must be in your hand to do that.</span>")
		return
	if(!(new_magazine.type in suitable_mags) || initial_mag == null)
		return

	to_chat(user, "<span class='notice'>You start a tactical reload.</span>")
	var/tac_reload_time = apply_skill_bonus(user, SKILL_TASK_TRIVIAL, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED), multiplier = -0.2)
	if(!do_after(user, tac_reload_time, TRUE, new_magazine, can_move = TRUE) && loc == user)
		return
	var/old_magazine = magazine
	if(magazine)
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		if (istype(new_magazine.loc,/obj/item/weapon/storage))
			var/obj/item/weapon/storage/storage = new_magazine.loc
			storage.remove_from_storage(new_magazine,src)
		magazine.forceMove(src.loc)
		magazine.update_icon()
		user.drop_from_inventory(new_magazine, src)
		magazine = new_magazine
		playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
		user.put_in_hands(old_magazine)
		chamber_round()
	else
		user.drop_from_inventory(new_magazine, src)
		magazine = new_magazine
		playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You load a new magazine into \the [src].</span>")
		chamber_round()
	update_icon()
