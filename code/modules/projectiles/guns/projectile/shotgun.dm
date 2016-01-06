/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	var/recentpump = 0 // to prevent spammage
	var/pumped = 0
	fire_sound = 'sound/weapons/guns/shotgun_shot.ogg'

/obj/item/weapon/gun/projectile/shotgun/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/shotgun/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()

/obj/item/weapon/gun/projectile/shotgun/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/shotgun/chamber_round()
	return

/obj/item/weapon/gun/projectile/shotgun/attack_self(mob/living/user)
	if(recentpump)	return
	pump(user)
	recentpump = 1
	spawn(10)
		recentpump = 0
	return


/obj/item/weapon/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pumped = 0
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	if(!magazine.ammo_count())	return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/weapon/gun/projectile/shotgun/examine()
	..()
	if (chambered)
		usr << "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	origin_tech = "combat=5;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shotcom
	w_class = 5

/obj/item/weapon/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BACK
	origin_tech = "combat=3;materials=1"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/dualshot
	var/open = 0
	var/short = 0
	fire_sound = 'sound/weapons/guns/shotgun_shot.ogg'

/obj/item/weapon/gun/projectile/revolver/doublebarrel/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/revolver/doublebarrel/update_icon()
	if(short)
		icon_state = "sawnshotgun[open ? "-o" : ""]"
	else
		icon_state = "dshotgun[open ? "-o" : ""]"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if (istype(A,/obj/item/ammo_box) || istype(A,/obj/item/ammo_casing))
		if(open)
			chamber_round()
		else
			user << "<span class='notice'>You can't load shell while [src] is closed!</span>"
	if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
		if(short) return
		user << "<span class='notice'>You begin to shorten the barrel of \the [src].</span>"
		if(get_ammo())
			afterattack(user, user)	//will this work?
			afterattack(user, user)	//it will. we call it twice, for twice the FUN
			playsound(user, fire_sound, 50, 1)
			user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
			return
		if(do_after(user, 30, target = src))	//SHIT IS STEALTHY EYYYYY
			icon_state = "sawnshotgun[open ? "-o" : ""]"
			w_class = 3.0
			item_state = "gun"
			slot_flags &= ~SLOT_BACK	//you can't sling it on your back
			slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
			user << "<span class='warning'>You shorten the barrel of \the [src]!</span>"
			name = "sawn-off shotgun"
			desc = "Omar's coming!"
			short = 1

/obj/item/weapon/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user as mob)
	add_fingerprint(user)
	open = !open
	if(open)
		//playsound(src.loc, 'sound/weapons/heavybolt_out.ogg', 50, 1)
		var/num_unloaded = 0
		while (get_ammo() > 0)
			spawn(3)
				playsound(src.loc, 'sound/weapons/shell_drop.ogg', 50, 1)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.update_icon()
			num_unloaded++
		if (num_unloaded)
			user << "<span class = 'notice'>You break open \the [src] and unload [num_unloaded] shell\s.</span>"
			//chambered.loc = get_turf(src)//Eject casing
			//chambered.SpinAnimation(5, 1)
			//chambered = null
		else
			user << "<span class = 'notice'>You break open \the [src].</span>"

	update_icon()
//	var/num_unloaded = 0
//	while (get_ammo() > 0)
//		var/obj/item/ammo_casing/CB
//		CB = magazine.get_round(0)
//		chambered = null
//		CB.loc = get_turf(src.loc)
//		CB.update_icon()
//		num_unloaded++
//	if (num_unloaded)
//		user << "<span class = 'notice'>You unload [num_unloaded] shell\s.</span>"
//	else
//		user << "<span class='notice'>[src] is empty.</span>"

/obj/item/weapon/gun/projectile/revolver/doublebarrel/special_check(mob/user)
	if(open)
		user << "<span class='warning'>You can't fire [src] while its open!</span>"
		return 0
	return ..()