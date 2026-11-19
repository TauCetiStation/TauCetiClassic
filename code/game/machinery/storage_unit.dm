/obj/effect/object_door
	name = "door"
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE

/obj/machinery/storage_unit
	name = "Storage Unit"
	cases = list("личный шкафчик", "личного шкафчика", "личному шкафчику", "личный шкафчик", "личным шкафчиком", "личном шкафчике")
	desc = "Личный шкафчик работника, в котором хранится рабочая и повседневная одежда."
	icon = 'icons/obj/dressers/storage_unit.dmi'
	var/overlays_file = 'icons/obj/dressers/storage_unit_overlays.dmi'
	icon_state = "civilian"
	damage_deflection = 15
	idle_power_usage = 5
	active_power_usage = 10
	anchored = TRUE

	var/opened = FALSE
	var/locked = TRUE
	allowed_checks = ALLOWED_CHECK_NONE //disable allowed() check on parent attack_hand, we check allowed on toggle_lock()

	var/alist/contents_by_slot = alist(
		SLOT_BACK = null,
		SLOT_BELT = null,
		SLOT_WEAR_ID = null,
		SLOT_L_STORE = null,
		SLOT_R_STORE = null,
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = null,
		SLOT_L_EAR = null,
		SLOT_R_EAR = null,
		SLOT_GLASSES = null,
		SLOT_NECK = null,
		SLOT_GLOVES = null,
		SLOT_W_UNIFORM = null,
		SLOT_SHOES = null
	)

	var/obj/effect/object_door/door
	var/door_animated = FALSE

	var/list/options = list()

/obj/machinery/storage_unit/atom_init(mapload)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 3)

	RefreshParts()
	if(mapload)
		make_full()

	options += list(
		list("Переодеться" = mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_swap")) = PROC_REF(fast_dress)
	)

	set_power_use(IDLE_POWER_USE)
	update_icon()

/obj/machinery/storage_unit/proc/make_full()
	for(var/storage_slot in contents_by_slot)
		if(!ispath(contents_by_slot[storage_slot]))
			continue

		var/item_path = contents_by_slot[storage_slot]

		contents_by_slot[storage_slot] = new item_path(src)


/obj/machinery/storage_unit/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(50))
				drop_from_contents() //So suits dont survive all the time
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				drop_from_contents()
				qdel(src)

/obj/machinery/storage_unit/power_change()
	if(stat & BROKEN)
		return
	else if(powered())
		stat &= ~NOPOWER
		update_power_use()
	else
		stat |= NOPOWER
		locked = FALSE
		update_icon()

	update_power_use()

/obj/machinery/storage_unit/proc/open(mob/user)
	if(opened)
		return
	if(locked)
		return

	opened = TRUE
	toggle_door(opening = TRUE)
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/storage_unit/proc/close(mob/user)
	if(!opened)
		return

	opened = FALSE
	toggle_door(opening = FALSE)
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/storage_unit/proc/toggle_lock(mob/user)
	if(opened)
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='warning'>The [src] appears to be broken.</span>")
		return

	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return

	if(!allowed(user))
		allowed_fail(user)
		return

	locked = !locked
	visible_message("<span class='notice'>The [src] been [locked ? null : "un"]locked by [user].</span>")
	update_icon()
	return

/obj/machinery/storage_unit/proc/fast_dress(mob/living/operator)
	if(!ishuman(operator))
		return

	var/mob/living/target = operator
	if(occupant && ishuman(occupant))
		target = occupant

	var/alist/contents_holder = alist()
	for(var/slot_name in contents_by_slot)
		contents_holder[slot_name] = null

	//fast undress
	for(var/slot_name in global.undress_sequence)
		var/obj/item/I = target.get_equipped_item(slot_name)
		if(!I || !I.canremove)
			continue

		if(!target.drop_from_inventory(I, src))
			continue
		contents_holder[slot_name] = I

	//fast dress
	for(var/i in global.undress_sequence.len to 1 step -1)
		var/slot_name = global.undress_sequence[i]
		if(!slot_name || !contents_by_slot[slot_name])
			continue

		if(!do_after(operator, 0.1 SECONDS, FALSE, src))
			continue

		var/obj/item/I = contents_by_slot[slot_name]

		if(!target?.equip_to_slot_if_possible(I, slot_name, disable_warning = TRUE))
			if(isturf(target?.loc))
				I.forceMove(target.loc)
			else
				I.forceMove(loc)

		contents_by_slot[slot_name] = null

	for(var/slot_name in contents_holder)
		if(contents_by_slot[slot_name])
			var/atom/movable/A = contents_holder[slot_name]
			A.forceMove(loc)
		else
			contents_by_slot[slot_name] = contents_holder[slot_name]

	update_icon()

/obj/machinery/storage_unit/update_icon()
	cut_overlays()
	if(!door)
		door = new
		door.icon = overlays_file
		door.icon_state = "door_[icon_state]"

	door.cut_overlays()
	door.add_overlay(mutable_appearance(door.icon, "lock_[locked]"))

	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_broken"
		door.icon_state = "door_[icon_state]"
		door.transform = matrix().Turn(-20)
		door.pixel_x = 10

	if(contents_by_slot[SLOT_WEAR_SUIT] || contents_by_slot[SLOT_W_UNIFORM])
		add_overlay(mutable_appearance(overlays_file, "uniform"))

	if(!door_animated)
		add_overlay(door)

/obj/machinery/storage_unit/proc/toggle_door(opening = TRUE)
	cut_overlay(door)
	vis_contents += door
	if(opening)
		animate(door, pixel_x = 10, time = 10, easing = CUBIC_EASING|EASE_IN)
	else
		animate(door, pixel_x = 0, time = 10, easing = CUBIC_EASING|EASE_OUT)

	addtimer(CALLBACK(src, PROC_REF(toggle_door_end)), 10)

/obj/machinery/storage_unit/proc/toggle_door_end()
	vis_contents -= door
	add_overlay(door)

/obj/machinery/storage_unit/container_resist()
	var/mob/living/user = usr
	if(locked)
		if(user.is_busy())
			return
		user.next_move = world.time + 100
		user.last_special = world.time + 100
		to_chat(user, "<span class='notice'>You start kicking against the doors to escape!</span>")
		visible_message("You see [user] kicking against the doors of the [src]!")
		if(do_after(user, 2 MINUTE, target = src))
			visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
	locked = FALSE // anyway it may be unlocked
	open()
	eject_occupant(user)
	add_fingerprint(user)
	return

/obj/machinery/storage_unit/MouseDrop_T(atom/something, mob/user)
	add_fingerprint(user)
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return FALSE
	if(opened)
		if(!ishuman(something))
			load_something(something, user)
		else
			place_occupant(something, user)
		return TRUE

/obj/machinery/storage_unit/CtrlClick(mob/user, proximity)
	add_fingerprint(user)
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(!Adjacent(user))
		return
	opened ? close() : open(user)

/obj/machinery/storage_unit/interact(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "<span class ='danger'>The unit is not operational.</span>")
		return

	if(opened)
		if(ishuman(user))
			var/list/options_ui
			var/list/options_back
			for(var/list/option in options)
				options_ui += option
				options_back[option[1]] = options[option]
			var/chosen_option = show_radial_menu(user, src, options_ui, require_near = TRUE, tooltips = TRUE)

			if(options_back[chosen_option])
				INVOKE_ASYNC(src, options_back[chosen_option], user)

			if(emagged)
				place_occupant(usr, usr)
				return

		if(length(contents))
			var/list/suit_storage = list()
			for(var/atom/movable/target in contents_by_slot)
				suit_storage[target] = target.appearance
			var/atom/movable/to_dispense = show_radial_menu(user, src, suit_storage, require_near = TRUE, tooltips = TRUE)

			if(!to_dispense)
				return

			to_dispense.forceMove(loc)
			user.put_in_hands(to_dispense)

		return

	if(!locked && !(stat & BROKEN))
		opened ? close() : open(user)
		return
	if(!opened)
		toggle_lock(user)
		return

/obj/machinery/storage_unit/attackby(obj/item/I, mob/user)
	if(user.loc == src)
		return FALSE
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return FALSE
	if(!opened)
		toggle_lock(user)
		return

	if(occupant)
		return

	if(isscrewing(I))
		if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
			update_icon()
			return TRUE
	if(isprying(I))
		if(default_deconstruction_crowbar(I))
			return TRUE

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/grab = I
		if(!ismob(grab.affecting) || grab.state < GRAB_AGGRESSIVE)
			return
		var/mob/M = grab.affecting
		place_occupant(M, user, grab)
	else
		load_something(I, user)
	update_icon()
	return

/obj/machinery/storage_unit/proc/load_something(atom/movable/something, mob/user, obj/grab = null)
	if(!isitem(something))
		return

	var/obj/item/I = something
	for(var/slot_name in slot_flags_to_possible_slots_list(I.slot_flags))
		if(contents_by_slot[slot_name])
			continue

		if(do_after(user, 0.1 SECONDS, FALSE, src))
			to_chat(user, "You load the [something.name] into the storage compartment.")
			user.drop_from_inventory(something, src)
			playsound(src, 'sound/misc/robot_close.ogg', VOL_EFFECTS_MASTER, 15)

			contents_by_slot[slot_name] = something

		break

	update_icon()
	return TRUE

/obj/machinery/storage_unit/place_occupant(mob/living/target, mob/user, obj/grab = null)
	if(user != target)
		if(do_after(user, 3 SECOND, target = src))
			..()
	else
		..()

	if(target.loc != src)
		return

	update_icon()

/obj/machinery/storage_unit/deconstruct(disassembled = TRUE)
	drop_from_contents()
	..()

/obj/machinery/storage_unit/surgery
	name = "Surgery Storage Unit"
	cases = list("хирургический шкафчик", "хирургического шкафчика", "хирургическому шкафчику", "хирургический шкафчик", "хирургическим шкафчиком", "хирургическом шкафчике")
	desc = "Шкафчик в хирургии для быстрого переодевания пациента."
	icon_state = "surgery"

	locked = FALSE

	contents_by_slot = alist(
		SLOT_BACK = null,
		SLOT_BELT = null,
		SLOT_WEAR_ID = null,
		SLOT_L_STORE = null,
		SLOT_R_STORE = null,
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = null,
		SLOT_L_EAR = null,
		SLOT_R_EAR = null,
		SLOT_GLASSES = null,
		SLOT_NECK = null,
		SLOT_GLOVES = null,
		SLOT_W_UNIFORM = /obj/item/clothing/under/patient_gown,
		SLOT_SHOES = /obj/item/clothing/shoes/white
	)

/obj/machinery/storage_unit/surgery/toggle_lock(mob/user)
	return


/obj/machinery/storage_unit/personal
	name = "Personal Storage Unit"
	cases = list("личный шкафчик", "личного шкафчика", "личному шкафчику", "личный шкафчик", "личным шкафчиком", "личном шкафчике")
	desc = "Личный шкафчик с электронным замком."
	icon_state = "civilian"

	locked = FALSE

	contents_by_slot = alist(
		SLOT_BACK = /obj/item/weapon/storage/backpack,
		SLOT_BELT = null,
		SLOT_WEAR_ID = null,
		SLOT_L_STORE = null,
		SLOT_R_STORE = null,
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = null,
		SLOT_L_EAR = /obj/item/device/radio/headset,
		SLOT_R_EAR = null,
		SLOT_GLASSES = null,
		SLOT_NECK = null,
		SLOT_GLOVES = null,
		SLOT_W_UNIFORM = null,
		SLOT_SHOES = null
	)

	req_access = list(access_all_personal_lockers)

	var/personal_name

/obj/machinery/storage_unit/personal/atom_init()
	. = ..()

	options += list(
		list("Сброс замка" = mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_delet")) = PROC_REF(reset_lock)
	)

/obj/machinery/storage_unit/personal/proc/reset_lock(mob/user)
	personal_name = null

/obj/machinery/storage_unit/personal/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/weapon/card/id) && !istype(I, /obj/item/device/pda))
		return ..()

	if(opened)
		return ..()

	if(personal_name)
		return

	var/obj/item/weapon/card/id/card

	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = I
		if(!PDA.id)
			return
		card = PDA.id
	else
		card = I

	personal_name = card.registered_name

/obj/machinery/storage_unit/personal/allowed(atom/movable/AM)
	for(var/obj/item/weapon/card/id/card in AM.contents)
		if(card.registered_name != personal_name)
			continue
		return TRUE
	return ..()

/obj/machinery/storage_unit/personal/patient
	name = "Personal Patient Storage Unit"
	cases = list("личный шкафчик пациента", "личного шкафчика пациента", "личному шкафчику пациента", "личный шкафчик пациента", "личным шкафчиком пациента", "личном шкафчике пациента")
	desc = "Личный шкафчик пациента с электронным замком."
	icon_state = "surgery"

	contents_by_slot = alist(
		SLOT_BACK = null,
		SLOT_BELT = null,
		SLOT_WEAR_ID = null,
		SLOT_L_STORE = null,
		SLOT_R_STORE = null,
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = null,
		SLOT_L_EAR = /obj/item/device/radio/headset,
		SLOT_R_EAR = null,
		SLOT_GLASSES = null,
		SLOT_NECK = null,
		SLOT_GLOVES = null,
		SLOT_W_UNIFORM = /obj/item/clothing/under/patient_gown,
		SLOT_SHOES = /obj/item/clothing/shoes/white
	)
