/obj/item/weapon/gun/projectile/heavyrifle
	name = "PTR-7 rifle"
	desc = "Бронебойное ружьё. Предназначалось для поражения бронированных мехов. С лёгкостью пробивает стекло пулей калибра 14.5мм."
	icon_state = "heavyrifle"
	item_state = "l6closednomag"
	w_class = SIZE_NORMAL
	force = 10
	slot_flags = SLOT_FLAGS_BACK
	origin_tech = "combat=8;materials=2;syndicate=8"
	recoil = 3 //extra kickback
	initial_mag = /obj/item/ammo_box/magazine/internal/heavyrifle
	fire_sound = 'sound/weapons/guns/gunshot_cannon.ogg'
	can_be_holstered = FALSE
	two_hand_weapon = ONLY_TWOHAND
	var/bolt_open = FALSE
	two_hand_weapon = TRUE

/obj/item/weapon/gun/projectile/heavyrifle/update_icon()
	icon_state = "[initial(icon_state)][bolt_open ? "-open" : ""]"

/obj/item/weapon/gun/projectile/heavyrifle/process_chamber()
	return ..(0, 0)

/obj/item/weapon/gun/projectile/heavyrifle/attackby(obj/item/I, mob/user, params)
	if(!bolt_open)
		return
	if(chambered)
		to_chat(user, "<span class='warning'>В патроннике уже есть патрон!</span>")
		return
	var/num_loaded = magazine.attackby(I, user, 1)
	if(num_loaded)
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/weapons/guns/heavybolt_in.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы загружаете [num_loaded] патрон(-а) в ружьё!</span>")
		var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
		chambered = AC
		update_icon()	//I.E. fix the desc
		I.update_icon()

/obj/item/weapon/gun/projectile/heavyrifle/attack_self(mob/user)
	bolt_open = !bolt_open
	if(bolt_open)
		playsound(src, 'sound/weapons/guns/heavybolt_out.ogg', VOL_EFFECTS_MASTER)
		if(chambered)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), loc, 'sound/weapons/guns/shell_drop.ogg', 50, 1), 3)
			to_chat(user, "<span class='notice'>Вы отпираете затвор, извлекая [chambered]!</span>")
			chambered.loc = get_turf(src)//Eject casing
			chambered.SpinAnimation(5, 1)
			chambered = null
		else
			to_chat(user, "<span class='notice'>Вы отпираете затвор.</span>")

	else
		playsound(src, 'sound/weapons/guns/heavybolt_reload.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы запираете затвор.</span>")
		bolt_open = FALSE
	add_fingerprint(user)
	update_icon()

/obj/item/weapon/gun/projectile/heavyrifle/special_check(mob/user)
	if(bolt_open)
		to_chat(user, "<span class='warning'>Заприте затвор!</span>")
		return FALSE
	return ..()

/obj/item/weapon/gun/projectile/heavyrifle/atom_init()
	. = ..()
	AddComponent(/datum/component/zoom, 9, TRUE)
