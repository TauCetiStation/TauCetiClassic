/obj/item/weapon/gun/projectile/m79
	name = "\improper m79 grenade launcher"
	desc = "m79 grenade launcher.."
	icon = 'icons/obj/gun.dmi'
	icon_state = "m79"
	item_state = "riotgun"
	w_class = 5
	force = 10
	slot_flags = SLOT_BACK
	origin_tech = "combat=5;materials=3"
	recoil = 0 //extra kickback
	mag_type = /obj/item/ammo_box/magazine/internal/m79
	fire_sound = 'sound/weapons/guns/m79_shot.ogg'
	var/open = 0

/obj/item/weapon/gun/projectile/m79/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/m79/update_icon()
	if(open)
		icon_state = "m79-open"
	else
		icon_state = "m79"

/obj/item/weapon/gun/projectile/m79/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/m79/attackby(var/obj/item/A as obj, mob/user as mob)
	if(!open)
		return
	if(chambered)
		user << "<span class='warning'>There is a shell inside \the [src]!</span>"
		return
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		playsound(src.loc, 'sound/weapons/guns/m79_reload.ogg', 50, 1)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		A.update_icon()

/obj/item/weapon/gun/projectile/m79/attack_self(mob/user as mob)
	open = !open
	if(open)
		playsound(src.loc, 'sound/weapons/guns/m79_out.ogg', 50, 1)
		if(chambered)
			spawn(3)
				playsound(src.loc, 'sound/weapons/shell_drop.ogg', 50, 1)
			chambered.loc = get_turf(src)//Eject casing
			chambered.SpinAnimation(5, 1)
			chambered = null
		else
	else
		playsound(src.loc, 'sound/weapons/guns/m79_in.ogg', 50, 1)
		open = 0
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/m79/special_check(mob/user)
	if(open)
		user << "<span class='warning'>You can't fire [src] while it is open!</span>"
		return 0
	return ..()
