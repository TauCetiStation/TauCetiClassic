/obj/item/weapon/gun/projectile/heavyrifle
	name = "\improper PTR-7 rifle"
	desc = "A portable anti-armour rifle. Originally designed to used against armoured exosuits, it is capable of punching through windows with ease. Fires armor piercing 14.5mm shells."
	icon_state = "heavyrifle"
	item_state = "l6closednomag"
	w_class = 5
	force = 10
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "combat=8;materials=2;syndicate=8"
	recoil = 3 //extra kickback
	mag_type = /obj/item/ammo_box/magazine/internal/heavyrifle
	fire_sound = 'sound/weapons/cannon.ogg'
	var/bolt_open = 0

/obj/item/weapon/gun/projectile/heavyrifle/isHandgun()
	return 0

/obj/item/weapon/gun/projectile/heavyrifle/update_icon()
	if(bolt_open)
		icon_state = "heavyrifle-open"
	else
		icon_state = "heavyrifle"

/obj/item/weapon/gun/projectile/heavyrifle/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/heavyrifle/attackby(obj/item/A, mob/user)
	if(!bolt_open)
		return
	if(chambered)
		to_chat(user, "<span class='warning'>There is a shell inside \the [src]!</span>")
		return
	var/num_loaded = magazine.attackby(A, user, 1)
	if(num_loaded)
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src.loc, 'sound/weapons/heavybolt_in.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		A.update_icon()

/obj/item/weapon/gun/projectile/heavyrifle/attack_self(mob/user)
	bolt_open = !bolt_open
	if(bolt_open)
		playsound(src.loc, 'sound/weapons/heavybolt_out.ogg', 50, 1)
		if(chambered)
			spawn(3)
				playsound(src.loc, 'sound/weapons/shell_drop.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You work the bolt open, ejecting [chambered]!</span>")
			chambered.loc = get_turf(src)//Eject casing
			chambered.SpinAnimation(5, 1)
			chambered = null
		else
			to_chat(user, "<span class='notice'>You work the bolt open.</span>")

	else
		playsound(src.loc, 'sound/weapons/heavybolt_reload.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You work the bolt closed.</span>")
		bolt_open = 0
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/heavyrifle/special_check(mob/user)
	if(bolt_open)
		to_chat(user, "<span class='warning'>You can't fire [src] while the bolt is open!</span>")
		return 0
	return ..()
