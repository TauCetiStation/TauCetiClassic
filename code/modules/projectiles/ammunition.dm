//TG-stuff
/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 1
	w_class = ITEM_SIZE_TINY
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 0								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing

/obj/item/ammo_casing/atom_init()
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(alldirs)
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"

/obj/item/ammo_casing/proc/newshot() //For energy weapons and shotgun shells.
	if (!BB)
		BB = new projectile_type(src)
	return

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(BB)
			if(initial(BB.name) == "bullet")
				var/label_text = sanitize_safe(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription"), MAX_NAME_LEN)
				if(length(label_text) > 20)
					to_chat(user, "<span class='warning'>The inscription can be at most 20 characters long.</span>")
				else
					if(label_text == "")
						to_chat(user, "<span class='notice'>You scratch the inscription off of [initial(BB)].</span>")
						BB.name = initial(BB.name)
					else
						to_chat(user, "<span class='notice'>You inscribe \"[label_text]\" into \the [initial(BB.name)].</span>")
						BB.name = "[initial(BB.name)] \"[label_text]\""
			else
				to_chat(user, "<span class='notice'>You can only inscribe a metal bullet.</span>")//because inscribing beanbags is silly
		else
			to_chat(user, "<span class='notice'>There is no bullet in the casing to inscribe anything into.</span>")
	else
		return ..()

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo"
	icon_state = "357"
	icon = 'icons/obj/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	item_state = "syringe_kit"
	m_amt = 500
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	throw_speed = 4
	throw_range = 10
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/caliber
	var/multiload = 1

/obj/item/ammo_box/atom_init()
	. = ..()
	for (var/i in 1 to max_ammo)
		stored_ammo += new ammo_type(src)
	update_icon()

/obj/item/ammo_box/proc/get_round(keep = 0)
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
			return 1
	return 0

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
		to_chat(user, "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>")
		I.update_icon()
		update_icon()
		return num_loaded
	return ..()

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		A.loc = get_turf(src.loc)
		user.put_in_hands(A)
		to_chat(user, "<span class='notice'>You remove a shell from \the [src]!</span>")
		update_icon()

/obj/item/ammo_box/update_icon()
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(2)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
	desc = "[initial(desc)] There are [stored_ammo.len] shell\s left!"

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len
