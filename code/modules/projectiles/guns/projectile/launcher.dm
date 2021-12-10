/obj/item/weapon/gun/projectile/grenade_launcher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "m79"
	mag_type = /obj/item/ammo_box/magazine/internal/m79
	can_be_holstered = FALSE

/obj/item/weapon/gun/projectile/grenade_launcher/attackby(obj/item/I, mob/user, params)
	if(chambered)
		to_chat(user, "<span class='warning'>There is a shell inside \the [src]!</span>")
		return
	var/num_loaded = magazine.attackby(I, user, 1)
	if(num_loaded)
		playsound(src, 'sound/weapons/guns/reload_m79.ogg', VOL_EFFECTS_MASTER)
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		I.update_icon()

/obj/item/weapon/gun/projectile/grenade_launcher/attack_self(mob/user)
	playsound(src, 'sound/weapons/guns/m79_out.ogg', VOL_EFFECTS_MASTER)
	if(chambered)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, loc, 'sound/weapons/guns/shell_drop.ogg', 50, 1), 3)
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		chambered = null
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/grenade_launcher/m79
	name = "m79 grenade launcher"
	desc = "Uses 40x46 ammunition."
	icon = 'icons/obj/gun.dmi'
	icon_state = "m79"
	item_state = "m79"
	w_class = SIZE_NORMAL
	force = 10
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "combat=5;materials=3"
	recoil = 0 //extra kickback
	fire_sound = 'sound/weapons/guns/gunshot_m79.ogg'
	var/open

/obj/item/weapon/gun/projectile/grenade_launcher/m79/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/grenade_launcher/m79/update_icon()
	icon_state = "[initial(icon_state)][open ? "-open" : ""]"

/obj/item/weapon/gun/projectile/grenade_launcher/m79/attack_self(mob/user)
	open = !open
	if(open)
		..()
	else
		playsound(src, 'sound/weapons/guns/m79_in.ogg', VOL_EFFECTS_MASTER)
		add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/grenade_launcher/m79/attackby(obj/item/I, mob/user, params)
	if(open)
		..()

/obj/item/weapon/gun/projectile/grenade_launcher/m79/special_check(mob/user)
	if(open)
		to_chat(user, "<span class='warning'>You can't fire [src] while it is open!</span>")
		return FALSE
	return ..()

/obj/item/weapon/gun/projectile/grenade_launcher/underslung
	name = "underslung grenade launcher"
	desc = "It's a little tiny launcher. You shouldn't be seeing this."
	mag_type = /obj/item/ammo_box/magazine/internal/m79/underslung
	fire_sound = 'sound/weapons/guns/gunshot_m79.ogg'
