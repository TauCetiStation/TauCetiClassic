/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	can_be_holstered = FALSE

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/cell_type = /obj/item/weapon/stock_parts/cell
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.

/obj/item/weapon/gun/energy/emp_act(severity)
	power_supply.use(round(power_supply.maxcharge / severity))
	update_icon()
	..()

/obj/item/weapon/gun/energy/atom_init()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
		power_supply.give(power_supply.maxcharge)

	var/obj/item/ammo_casing/energy/shot
	for (var/i in 1 to ammo_type.len)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	update_icon()

/obj/item/weapon/gun/energy/Fire(atom/target, mob/living/user, params, reflex = 0)
	newshot()
	..()

/obj/item/weapon/gun/energy/announce_shot(mob/living/user)
	user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a laser blast!")

/obj/item/weapon/gun/energy/proc/newshot()
	if (!ammo_type || !power_supply)
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if (power_supply.charge < shot.e_cost)
		return
	chambered = shot
	chambered.newshot()
	return

/obj/item/weapon/gun/energy/process_chamber()
	if (chambered) // incase its out of energy - since then this will be null.
		var/obj/item/ammo_casing/energy/shot = chambered
		power_supply.use(shot.e_cost)
	chambered = null
	return

/obj/item/weapon/gun/energy/can_fire()
	newshot()
	if(chambered && chambered.BB)
		return 1

/obj/item/weapon/gun/energy/proc/select_fire(mob/living/user)
	if(ammo_type.len <= 1)
		return

	if(ammo_type.len == 2)
		select++
		if(select > ammo_type.len)
			select = 1
	else
		var/list/pos_selections = list()
		for(var/i in 1 to ammo_type.len)
			var/obj/item/ammo_casing/energy/E = ammo_type[i]
			pos_selections[E.select_name] = i

		var/choice = input("Please choose firing mode", "Firing Mode Selection") as null|anything in pos_selections
		if(user.get_active_hand() != src)
			return

		if(choice)
			select = pos_selections[choice]

	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	if (shot.select_name)
		to_chat(user, "<span class='warning'>[src] is now set to [shot.select_name].</span>")
	update_icon()

/obj/item/weapon/gun/energy/update_icon()
	var/ratio = 0
	if(power_supply.maxcharge)
		ratio = power_supply.charge / power_supply.maxcharge
		ratio = CEIL(ratio * 4) * 25
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	switch(modifystate)
		if (0)
			if(ratio > 100)
				icon_state = "[initial(icon_state)]100"
			else
				icon_state = "[initial(icon_state)][ratio]"
		if (1)
			if(ratio > 100)
				icon_state = "[initial(icon_state)][shot.mod_name]100"
			else
				icon_state = "[initial(icon_state)][shot.mod_name][ratio]"
		if (2)
			if(ratio > 100)
				icon_state = "[initial(icon_state)][shot.select_name]100"
			else
				icon_state = "[initial(icon_state)][shot.select_name][ratio]"
	return

/obj/item/weapon/gun/energy/verb/choose_firing_mode()
	set name = "Choose firing mode"
	set category = "Object"
	set src in usr

	select_fire(usr)

/obj/item/weapon/gun/energy/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	select_fire(user)

/obj/item/weapon/gun/energy/attack_self(mob/living/user)
	select_fire(user)
