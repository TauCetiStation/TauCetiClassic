/obj/item/weapon/gun/projectile/revolver
	desc = "A classic revolver. Uses 357 ammo."
	name = "revolver"
	icon_state = "revolver"
	item_state = "revolver"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder
	fire_sound = 'sound/weapons/guns/gunshot_heavy.ogg'

/obj/item/weapon/gun/projectile/revolver/chamber_round()
	if(chambered || !magazine)
		return
	else if(magazine.ammo_count())
		chambered = magazine.get_round(1)
	return

/obj/item/weapon/gun/projectile/revolver/process_chamber()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(istype(C))
		C.reset_spin()
	return ..(0, 1)

/obj/item/weapon/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user)
	..()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(istype(C) && C.spin_chambers >= 0)
		C.advance()
	chamber_round()

/obj/item/weapon/gun/projectile/revolver/atom_init()
	. = ..()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(istype(C) && C.can_spin)
		verbs += /obj/item/weapon/gun/projectile/revolver/verb/spin

/obj/item/weapon/gun/projectile/revolver/proc/do_spin(mob/user)
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(!istype(C))
		return FALSE
	chambered = null
	C.spin()
	chamber_round()
	playsound(user, 'sound/weapons/guns/chamber_spin.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='notice'>[user] spins the cylinder of \the [src].</span>","<span class='notice'>You spin the cylinder of \the [src].</span>")

	return TRUE

/obj/item/weapon/gun/projectile/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Spin the revolver's cylinder."

	if(usr.incapacitated())
		return

	do_spin(usr)

/obj/item/weapon/gun/projectile/revolver/AltClick(mob/user)
	if(user.incapacitated())
		return
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(!istype(C) || !C.can_spin)
		return
	do_spin(user)

/obj/item/weapon/gun/projectile/revolver/attackby(obj/item/I, mob/user, params)
	var/num_loaded = magazine.attackby(I, user, 1)
	if(num_loaded)
		var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
		if(istype(C))
			C.reset_spin()
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src].</span>")
		I.update_icon()
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/living/user)
	if(chambered)
		chambered.loc = get_turf(src.loc)
		chambered.SpinAnimation(10, 1)
		chambered.update_icon()
		chambered = null
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(istype(C))
		C.reset_spin()
	var/num_unloaded = 0
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from \the [src].</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/projectile/revolver/examine(mob/user)
	..()
	to_chat(user, "[get_ammo(0,0)] of those are live rounds.")

/obj/item/weapon/gun/projectile/revolver/traitor
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"

/obj/item/weapon/gun/projectile/revolver/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "S&W Model 10"
	icon_state = "detective"
	origin_tech = "combat=2;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	w_class = SIZE_TINY

/obj/item/weapon/gun/projectile/revolver/detective/special_check(mob/living/carbon/human/M)
	if(magazine.caliber == initial(magazine.caliber))
		return ..()
	if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
		explosion(M.loc, 0, 0, 1, 1)
		to_chat(M, "<span class='danger'>[src] blows up in your face!</span>")
		M.take_bodypart_damage(0, 20)
		qdel(src)
		return 0
	return ..()

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun."

	var/mob/M = usr
	var/input = sanitize_safe(input(M,"What do you want to name the gun?"), MAX_NAME_LEN)

	if(input && M.stat == CONSCIOUS && Adjacent(M))
		name = input
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		if(magazine.caliber == "38")
			to_chat(user, "<span class='notice'>You begin to reinforce the barrel of [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(!user.is_busy() && I.use_tool(src, user, 30, volume = 50, quality = QUALITY_SCREWING))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				magazine.caliber = "357"
				desc = "The barrel and chamber assembly seems to have been modified."
				to_chat(user, "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>")
		else
			to_chat(user, "<span class='notice'>You begin to revert the modifications to [src].</span>")
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(!user.is_busy() && I.use_tool(src, user, 30, volume = 50, quality = QUALITY_SCREWING))
				if(magazine.ammo_count())
					to_chat(user, "<span class='notice'>You can't modify it!</span>")
					return
				magazine.caliber = "38"
				desc = initial(desc)
				to_chat(user, "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>")

	else
		return ..()

/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	item_state = "mateba"
	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/projectile/revolver/peacemaker
	name = "Colt SAA"
	desc = "A legend of Wild West."
	icon_state = "peacemaker"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rev45

/obj/item/weapon/gun/projectile/revolver/peacemaker/attack_self(mob/living/user)
	if(chambered)
		chambered.loc = get_turf(src.loc)
		chambered.SpinAnimation(10, 1)
		chambered.update_icon()
		chambered = null
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	if(istype(C))
		C.reset_spin()
	var/num_unloaded = 0
	if(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if(num_unloaded)
		to_chat(user, "<span class='notice'>You unload [num_unloaded] shell\s from \the [src].</span>")
	else
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")

/obj/item/weapon/gun/projectile/revolver/peacemaker/detective
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rev45/rubber

/obj/item/weapon/gun/projectile/revolver/detective/dungeon
	desc = "A six-shot double-action revolver."
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off
	icon_state = "dshotgun"
	item_state = "shotgun-short"
	w_class = SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	name = "sawn-off shotgun"
	desc = "Omar's coming!"
	can_be_holstered = TRUE
	short = 1

/obj/item/weapon/gun/projectile/revolver/doublebarrel/dungeon/sawn_off/beanbag
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/dualshot


/obj/item/weapon/gun/projectile/revolver/syndie
	name = "revolver"
	desc = "A powerful revolver, very popular among mercenaries and pirates. Uses .357 ammo."
	icon_state = "synd_revolver"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder
