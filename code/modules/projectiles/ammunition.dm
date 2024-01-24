#define MANY_STATES 1
#define TWO_STATES 2

//TG-stuff
/obj/item/ammo_casing
	name = "bullet casing"
	desc = "Гильза от пули."
	icon = 'icons/obj/ammo/casings.dmi'
	icon_state = "casing_normal"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 1
	w_class = SIZE_MINUSCULE
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 0								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing

/obj/item/ammo_casing/atom_init()
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	transform = turn(transform,rand(0,360))
	update_icon()

/obj/item/ammo_casing/Destroy()
	QDEL_NULL(BB)
	return ..()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "" : "-spent"]"
	desc = "[initial(desc)][BB ? "" : " Этот патрон использован."]"

/obj/item/ammo_casing/proc/newshot() //For energy weapons and shotgun shells.
	if (!BB)
		BB = new projectile_type(src)
	return

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		if(BB)
			if(initial(BB.name) == "bullet")
				var/label_text = sanitize_safe(input(user, "Нанести надпись на [initial(BB.name)]","Надпись"), MAX_NAME_LEN)
				if(length(label_text) > 20)
					to_chat(user, "<span class='warning'>Надпись может состоять не более чем из 20 символов.</span>")
				else
					if(label_text == "")
						to_chat(user, "<span class='notice'>Вы стираете надпись с [initial(BB)].</span>")
						BB.name = initial(BB.name)
					else
						to_chat(user, "<span class='notice'>Вы вписываете \"[label_text]\" на [initial(BB.name)].</span>")
						BB.name = "[initial(BB.name)] \"[label_text]\""
			else
				to_chat(user, "<span class='notice'>Вы можете нанести надпись только на металлическую пулю</span>")//because inscribing beanbags is silly
		else
			to_chat(user, "<span class='notice'>В гильзе нет пули, на которой можно было бы сделать какую-либо надпись.</span>")
		return

	if(istype(I, /obj/item/ammo_box) && isturf(loc))
		var/obj/item/ammo_box/B = I
		if(B.ammo_type == type)
			for(var/obj/item/ammo_casing/AC in loc)
				if(!do_after(user, 2, target = AC))
					break
				if(!B.give_round(AC))
					break
				B.update_icon()
				playsound(B, 'sound/weapons/guns/ammo_insert.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
		return

	return ..()

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "Коробка с патронами"
	icon_state = "357"
	icon = 'icons/obj/ammo/boxes.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	item_state = "syringe_kit"
	m_amt = 500
	throwforce = 2
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = TWO_STATES
	var/caliber
	var/multiload = TRUE

/obj/item/ammo_box/atom_init()
	. = ..()
	for (var/i in 1 to max_ammo)
		stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(keep = FALSE)
	if (!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if (keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/r)
	var/obj/item/ammo_casing/rb = r
	if (rb)
		if (stored_ammo.len < max_ammo && rb.caliber == caliber)
			stored_ammo += rb
			rb.loc = src
			return TRUE
	return FALSE

/obj/item/ammo_box/proc/make_empty(deleting = TRUE)
	if(deleting)
		stored_ammo = list()
		update_icon()
	else
		var/turf/T = get_turf(src)
		for(var/obj/ammo in stored_ammo)
			stored_ammo -= ammo
			ammo.forceMove(T)

/obj/item/ammo_box/attackby(obj/item/I, mob/user, params)
	var/num_loaded = 0
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = I
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
			if(!did_load || !multiload)
				break
	if(istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = I
		if(give_round(AC))
			user.drop_from_inventory(AC, src)
			num_loaded++
	if(num_loaded)
		playsound(src, 'sound/weapons/guns/ammo_insert.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
		I.update_icon()
		update_icon()
		return num_loaded
	return ..()

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		A.loc = get_turf(src.loc)
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>Вы снимаете оболочку с [src]!</span>")
		update_icon()

/obj/item/ammo_box/update_icon()
	switch(multiple_sprites)
		if(MANY_STATES)
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
			desc = "[initial(desc)] Осталось снарядов: [stored_ammo.len]"
		if(TWO_STATES)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
			desc = "[initial(desc)] [get_ammo_count_description()]."

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len

/obj/item/ammo_box/proc/get_ammo_count_description(message)
	if(stored_ammo.len == max_ammo)
		message = "Кажется, магазин полон"
	if(stored_ammo.len < max_ammo)
		message = "Кажется, магазин почти полон"
	if(stored_ammo.len <= max_ammo*0.5)
		message = "Кажется, магазин наполовину полон"
	if(stored_ammo.len <= max_ammo*0.25)
		message = "Кажется, магазин почти пуст"
	if(!stored_ammo.len)
		message = "Магазин пуст"
	return (message)
