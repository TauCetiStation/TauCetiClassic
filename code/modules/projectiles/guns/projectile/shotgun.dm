/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = SIZE_NORMAL
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "combat=4;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/internal/shot
	var/recentpump = FALSE // to prevent spammage
	fire_sound = 'sound/weapons/guns/gunshot_shotgun.ogg'
	can_be_holstered = FALSE
	two_hand_weapon = ONLY_TWOHAND
	var/pump_cooldown = 10
	var/pump_sound = list('sound/weapons/guns/shotgun_pump1.ogg', 'sound/weapons/guns/shotgun_pump2.ogg', 'sound/weapons/guns/shotgun_pump3.ogg')

/obj/item/weapon/gun/projectile/shotgun/attackby(obj/item/I, mob/user, params)
	var/num_loaded = magazine.attackby(I, user, 1)
	if(num_loaded)
		playsound(src, 'sound/weapons/guns/reload_shotgun.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		I.update_icon()
		update_icon()

/obj/item/weapon/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)
		return
	pump(user)
	recentpump = TRUE
	VARSET_IN(src, recentpump, FALSE, pump_cooldown)

/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, pick(pump_sound), VOL_EFFECTS_MASTER, null, FALSE)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	if(!magazine.ammo_count())
		return FALSE
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC
	update_icon()	//I.E. fix the desc
	return TRUE

/obj/item/weapon/gun/projectile/shotgun/examine(mob/user)
	..()
	if (chambered)
		to_chat(user, "A [chambered.BB ? "live" : "spent"] one is in the chamber.")

/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	item_state = "cshotgun"
	origin_tech = "combat=5;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/internal/shotcom
	w_class = SIZE_BIG

/obj/item/weapon/gun/projectile/shotgun/combat/nonlethal
	initial_mag = /obj/item/ammo_box/magazine/internal/shotcom/nonlethal

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "dshotgun"
	w_class = SIZE_NORMAL
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	two_hand_weapon = DESIRABLE_TWOHAND
	origin_tech = "combat=3;materials=1"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/dualshot
	can_be_holstered = FALSE
	var/open = FALSE
	var/short = FALSE
	var/can_be_shortened = TRUE
	fire_sound = 'sound/weapons/guns/gunshot_shotgun.ogg'

/obj/item/weapon/gun/projectile/revolver/doublebarrel/update_icon()
	if(short)
		icon_state = "[initial(icon_state)][short ? "-short" : ""][open ? "-o" : ""]"
	else
		icon_state = "[initial(icon_state)][open ? "-o" : ""]"
	cut_overlays()
	if(open)
		add_overlay("[initial(icon_state)]shell-[magazine.ammo_count()]")

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/circular_saw) || istype(I, /obj/item/weapon/melee/energy))
		if(short || !can_be_shortened)
			return
		if(get_ammo())
			to_chat(user, "<span class='notice'>You try to shorten the barrel of \the [src].</span>")
			if(chambered.BB)
				playsound(user, fire_sound, VOL_EFFECTS_MASTER)
				user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			else
				to_chat(user, "<span class='danger'>You hear a clicking sound and thank God that bullet casing was empty.</span>")
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			return

		to_chat(user, "<span class='notice'>You begin to shorten the barrel of \the [src].</span>")
		if(!user.is_busy() && I.use_tool(src, user, 30, volume = 50, required_skills_override = list(/datum/skill/firearms = SKILL_LEVEL_TRAINED)))
			icon_state = "dshotgun"
			item_state = "shotgun-short"
			w_class = SIZE_SMALL
			slot_flags &= ~SLOT_FLAGS_BACK	//you can't sling it on your back
			slot_flags |= SLOT_FLAGS_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			to_chat(user, "<span class='warning'>You shorten the barrel of \the [src]!</span>")
			name = "sawn-off shotgun"
			desc = "Omar's coming!"
			short = TRUE
			can_be_holstered = TRUE
			update_icon()
		return

	else if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
		if(open)
			return ..()
		else
			to_chat(user, "<span class='notice'>You can't load shell while [src] is closed!</span>")

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user)
	add_fingerprint(user)
	open = !open
	if(open)
		//playsound(src, 'sound/weapons/heavybolt_out.ogg', VOL_EFFECTS_MASTER)
		var/num_unloaded = 0
		while (get_ammo() > 0)
			spawn(3)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), loc, 'sound/weapons/guns/shell_drop.ogg', 50, 1), 3)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(FALSE)
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.update_icon()
			num_unloaded++
		if (num_unloaded)
			to_chat(user, "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>")
			//chambered.loc = get_turf(src)//Eject casing
			//chambered.SpinAnimation(5, 1)
			//chambered = null
		else
			to_chat(user, "<span class = 'notice'>You break open \the [src].</span>")

	update_icon()

/obj/item/weapon/gun/projectile/revolver/doublebarrel/special_check(mob/user)
	if(open)
		to_chat(user, "<span class='warning'>You can't fire [src] while its open!</span>")
		return FALSE
	return ..()

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
	short = TRUE

/obj/item/weapon/gun/projectile/shotgun/repeater
	name = "repeater rifle"
	desc = "Winchester Model 1894."
	icon_state = "repeater"
	item_state = "repeater"
	origin_tech = "combat=5;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/internal/repeater
	w_class = SIZE_BIG
	slot_flags = null
	pump_sound = list('sound/weapons/guns/reload_repeater.ogg')
	pump_cooldown = 6

/obj/item/weapon/gun/projectile/shotgun/bolt_action
	name = "Mosin-Nagant"
	desc = "Produced by the same group of shady space-soviet people that scrapped together A74 for Gorlex Marauders, this ancient bolt-action rifle uses same 7.74 ammo in clips and is perfectly fit to arm human waves in the name of Revolution."
	icon_state = "bolt-action"
	item_state = "bolt-action"
	origin_tech = "combat=5;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/a774clip
	w_class = SIZE_BIG
	slot_flags = SLOT_FLAGS_BACK
	pump_sound = list('sound/weapons/guns/reload_bolt.ogg')

/obj/item/weapon/gun/projectile/shotgun/bolt_action/pump(mob/M)
	..()
	if(magazine && !magazine.ammo_count())
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		return FALSE

/obj/item/weapon/gun/projectile/shotgun/bolt_action/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = I
		if(!magazine && istype(AM, initial_mag))
			user.remove_from_mob(AM)
			magazine = AM
			magazine.forceMove(src)
			to_chat(user, "<span class='notice'>You load a new clip into \the [src].</span>")
			chamber_round()
			I.update_icon()
			update_icon()
			return TRUE

		else if (magazine)
			to_chat(user, "<span class='notice'>There's already a clip in \the [src].</span>")
			return

	return ..()

/obj/item/weapon/gun/projectile/shotgun/dungeon
	initial_mag = /obj/item/ammo_box/magazine/internal/shot/dungeon
