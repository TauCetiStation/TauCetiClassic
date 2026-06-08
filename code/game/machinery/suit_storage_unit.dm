#define POSSIBLE_TO_LOAD(something) something && (isspacesuit(something)\
											||(isspacehelmet(something) && !ishardhelmet(something))\
											||isbreathmask(something)\
											||ismagboots(something)\
											||istank(something)||iscarbon(something))
#define IS_LOAD(something, target) (something && target) \
										&& ((isbreathmask(something) && isbreathmask(target)) \
										|| (isspacesuit(something) && isspacesuit(target)) \
										|| (isspacehelmet(something) && isspacehelmet(target))\
										|| (ismagboots(something) && ismagboots(target)) \
										|| (istank(something) && istank(target)))

/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a ultra_violet-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suit_storage/civilian.dmi'
	var/overlays_file = 'icons/obj/suit_storage/overlays.dmi'
	icon_state = "civilian"
	damage_deflection = 25
	idle_power_usage = 10
	active_power_usage = 100
	anchored = TRUE

	var/build_type = SUIT_STORAGE_BUILD_DEFAULT
	var/opened = FALSE
	var/locked = TRUE

	var/overlay_color = null

	var/list/connectors_overlays = list()
	var/list/suit_storage_overlays = list()

//ultra violet stat
	var/ultra_violet = FALSE
	var/cycletime_left = null

	var/filled = FALSE // For map placeing suit storages, when false, create empty suit storage

	var/helmet_type = null
	var/mask_type   = null
	var/suit_type   = null
	var/boot_type   = null
	var/tank_type   = null
	var/obj/item/weapon/circuitboard/suit_storage/ssu_type = null

//overlay connectors stuff
	var/obj/machinery/suit_storage_unit/ssu_left = null
	var/obj/machinery/suit_storage_unit/ssu_right = null

/obj/machinery/suit_storage_unit/atom_init()
	. = ..()

	ssu_type = new /obj/item/weapon/circuitboard/suit_storage(null)
	ssu_type.update_circut(type)

	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += ssu_type
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 3)

	RefreshParts()
	filled ? make_full() : FALSE
	set_power_use(IDLE_POWER_USE)
	update_icon()						//in update icon, we add src connectors icons and search neardy Suit Storage Units
	ssu_left?.update_connectors() 			//to add connector sprites for neardy staying Suit Storage Units
	ssu_right?.update_connectors()

/obj/machinery/suit_storage_unit/proc/make_full()
	if(!length(contents))
		if(suit_type)
			new suit_type(src)
		if(helmet_type)
			new helmet_type(src)
		if(mask_type)
			new mask_type(src)
		if(boot_type)
			new boot_type(src)
		if(tank_type)
			new tank_type(src)

/obj/machinery/suit_storage_unit/place_occupant(mob/living/target, mob/user, obj/grab = null)
	if(user != target)
		if(do_after(user, 3 SECOND, target = src))
			..()
	else
		..()

	if(target.loc != src)
		return
	if((length(contents) - 1) <= 0) // - 1 because in content we place human, they couted too in content
		to_chat(target, "<span class ='danger'>There are nothing here for you.</span>")
	if(emagged)
		to_chat(target, "<span class ='danger'>You feel like a terrible manipulators pulls you into [name].</span>")
		start_ultra_violet(user)
	update_icon()

/obj/machinery/suit_storage_unit/proc/fast_equip(mob/living/target)
	for(var/obj/item/something in contents)
		if(do_after(target, 0.1 SECONDS, FALSE, src))
			switch(something.slot_flags)
				if(SLOT_FLAGS_MASK)
					target?.equip_to_slot_if_possible(something, SLOT_WEAR_MASK, disable_warning = TRUE)
				if(SLOT_FLAGS_FEET)
					target?.equip_to_slot_if_possible(something, SLOT_SHOES, disable_warning = TRUE)
				if(SLOT_FLAGS_BACK)
					if(!target?.equip_to_slot_if_possible(something, SLOT_S_STORE, disable_warning = TRUE))
						target?.equip_to_slot_if_possible(something, SLOT_BACK)
				if(SLOT_FLAGS_OCLOTHING)
					target?.equip_to_slot_if_possible(something, SLOT_WEAR_SUIT, disable_warning = TRUE)
				if(SLOT_FLAGS_HEAD)
					target?.equip_to_slot_if_possible(something, SLOT_HEAD, disable_warning = TRUE)
			playsound(src, 'sound/misc/riginternaloff.ogg', VOL_EFFECTS_MASTER, 15)
	for(var/atom/movable/something in contents) // if something didn`t equiped, drop it and set free occupant
		dispense(something)

	if(locked)
		locked = FALSE
	if(!opened)
		open()

	update_icon()

/obj/machinery/suit_storage_unit/proc/fast_unequip(mob/living/target)
	for(var/obj/item/something in target.contents)
		if(POSSIBLE_TO_LOAD(something))
			load_something(something, target)


/obj/machinery/suit_storage_unit/proc/update_connectors()
	if(length(connectors_overlays))
		cut_overlay(connectors_overlays)
		LAZYCLEARLIST(connectors_overlays)
	if(QDELETED(src))
		return

	var/mutable_appearance/I
	ssu_left = locate(/obj/machinery/suit_storage_unit) in get_step(src, WEST)
	if(!QDELETED(ssu_left))
		if(ssu_left)
			if(ssu_left.icon == src.icon)
				I = mutable_appearance(icon = overlays_file, icon_state = "left_connect_[initial(icon_state)]")
			else
				I = mutable_appearance(icon = overlays_file, icon_state = "left_connect_civilian")
			if(overlay_color)
				I.color = overlay_color
			connectors_overlays += I

	ssu_right = locate(/obj/machinery/suit_storage_unit) in get_step(src, EAST)
	if(!QDELETED(ssu_right))
		if(ssu_right)
			if(ssu_right.icon == src.icon)
				I = mutable_appearance(icon = overlays_file, icon_state = "right_connect_[initial(icon_state)]")
			else
				I = mutable_appearance(icon = overlays_file, icon_state = "right_connect_civilian")
			if(overlay_color)
				I.color = overlay_color
			connectors_overlays += I

	add_overlay(connectors_overlays)

/obj/machinery/suit_storage_unit/update_icon()
	if(length(suit_storage_overlays))
		cut_overlay(suit_storage_overlays)
		LAZYCLEARLIST(suit_storage_overlays)
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]_broken"
	update_connectors(suit_storage_overlays)

	for(var/atom/target in contents)
		if(ishardsuit(target))
			var/obj/item/clothing/suit/space/rig/rig_suit = target
			if(rig_suit?.helmet)
				suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "suit&helmet")
			if(rig_suit?.boots)
				suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "boots")
		else if(ismagboots(target))
			suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "boots")
		else if(isspacehelmet(target))
			suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "helmet")
		else if(isspacesuit(target))
			suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "suit")

	var/mutable_appearance/door_I = null
	if(!(stat & BROKEN))
		door_I = mutable_appearance(icon = overlays_file, icon_state = "[opened ? "door_open_[icon_state]" : "door_closed_[icon_state]"]")
	if(overlay_color)
		var/mutable_appearance/unit_color = mutable_appearance(icon = overlays_file, icon_state = "[stat & BROKEN ? "suitholder_broken_color" : "suitholder_color"]")
		door_I?.color = overlay_color
		unit_color.color = overlay_color
		suit_storage_overlays += unit_color
	if(door_I)
		suit_storage_overlays += door_I
	if(!opened)
		suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "[locked ? "lock_closed" : "lock_open"]")
	if(ultra_violet)
		suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "lock_closed")
		suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "[emagged ? "termalclean_emag" : "termalclean"]")
	if(panel_open)
		suit_storage_overlays += mutable_appearance(icon = overlays_file, icon_state = "panel_open")
	add_overlay(suit_storage_overlays)

/obj/machinery/suit_storage_unit/power_change()
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

/obj/machinery/suit_storage_unit/Destroy()
	QDEL_NULL(occupant)
	QDEL_LIST(contents)
	QDEL_NULL(ssu_type)
	ssu_left?.update_connectors()
	ssu_left = null
	ssu_right?.update_connectors()
	ssu_right = null
	..()

/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(50))
				drop_from_contents() //So suits dont survive all the time
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				drop_from_contents()
				qdel(src)

/obj/machinery/suit_storage_unit/proc/open(mob/user)
	if(opened)
		return
	if(locked || ultra_violet)
		to_chat(user, "<span class ='danger'>Unable to opened unit.</span>")
		return
	opened = TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/close(mob/user)
	if(!opened)
		return
	opened = FALSE
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(opened)
		return FALSE
	if(ultra_violet)
		return FALSE
	if(!allowed(user))
		to_chat(user, "<span class='notice'>Access Denied</span>")
		return FALSE
	if(stat & (NOPOWER))
		to_chat(user, "<span class='warning'>The [src] appears to be broken.</span>")
		return FALSE
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return FALSE

	locked = !locked
	visible_message("<span class='notice'>The [src] been [locked ? null : "un"]locked by [user].</span>")
	update_icon()
	return TRUE

/obj/machinery/suit_storage_unit/proc/start_ultra_violet(mob/user)
	if(ultra_violet)
		return
	if(stat & (BROKEN | NOPOWER))
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(!allowed(user))
		to_chat(user, "<span class='notice'>Access Denied</span>")
		return
	if(occupant && !emagged)
		to_chat(user, "<span class = 'danger'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</span>")
		return
	if(!length(contents))
		to_chat(user, "<span class ='danger'>Unit storage bays empty. Nothing to disinfect -- Aborting.</span>")
		return

	to_chat(user, "You start the Unit's cauterisation cycle.")
	if(opened)
		close()
	locked = TRUE
	ultra_violet = TRUE
	if(!emagged)
		cycletime_left = 1
	else
		cycletime_left = 5
	update_icon()
	ultra_violet_cleaning()
	set_power_use(ACTIVE_POWER_USE)

/obj/machinery/suit_storage_unit/proc/ultra_violet_cleaning()
	if(cycletime_left)
		cycletime_left--
		if(occupant && emagged)
			occupant.adjustFireLoss(rand(15, 30))
		addtimer(CALLBACK(src, PROC_REF(ultra_violet_cleaning)), 5 SECONDS)
	else
		if(!emagged)
			default_ultra_violet_cleaning()
		else
			super_ultra_violet_cleaning()

		ultra_violet = FALSE //Cycle ends
		locked = FALSE // anyway it may be unlocked
		open() // open() call`s update_icon
		set_power_use(IDLE_POWER_USE)
		return TRUE

/obj/machinery/suit_storage_unit/proc/default_ultra_violet_cleaning()
	for(var/obj/item/target in contents) // we cand ultra_violeting only items
		target.clean_blood()
		target.decontaminate()

/obj/machinery/suit_storage_unit/proc/super_ultra_violet_cleaning()
	for(var/atom/target as anything in contents)
		QDEL_NULL(target)
	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	stat |= BROKEN
	visible_message("<span class ='danger'>With a loud whining noise, the Suit Storage Unit's door grinds opened. Puffs of ashen smoke come out of its chamber.</span>", 3)

/obj/machinery/suit_storage_unit/container_resist()
	if(ultra_violet)
		return
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

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/something, mob/user)
	add_fingerprint(user)
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return FALSE
	if(opened)
		if(POSSIBLE_TO_LOAD(something))
			if(!ishuman(something))
				load_something(something, user)
			else
				place_occupant(something, user)
			return TRUE

/obj/machinery/suit_storage_unit/AltClick(mob/user, proximity)
	add_fingerprint(user)
	if(ultra_violet || !Adjacent(user))
		return
	start_ultra_violet(user)

/obj/machinery/suit_storage_unit/CtrlClick(mob/user, proximity)
	add_fingerprint(user)
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(ultra_violet || !Adjacent(user))
		return
	opened ? close() : open(user)

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if(ultra_violet)
		return FALSE
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return

	if(opened)
		if(ishuman(user))
			var/list/options = list("Procces UV" = mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_start"),
									"Fast Uneqip" = mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_use"),
									"Fast Eqip" = mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_pickup")
									)
			var/choosen_option = show_radial_menu(user, src, options, require_near = TRUE, tooltips = TRUE)
			switch(choosen_option)
				if("Procces UV")
					start_ultra_violet(user)
					return
				if("Fast Uneqip")
					fast_unequip(user)
				if("Fast Eqip")
					fast_equip(user)
			if(emagged)
				place_occupant(usr, usr)
				return

		if(length(contents))
			var/list/suit_storage = list()
			for(var/atom/movable/target in contents)
				suit_storage[target] = target.appearance
			var/atom/movable/to_dispense = show_radial_menu(user, src, suit_storage, require_near = TRUE, tooltips = TRUE)
			if(to_dispense)
				dispense(to_dispense)
		return

	if(!locked && !(stat & BROKEN))
		opened ? close() : open(user)
		return
	if(!opened)
		toggle_lock(user)
		return


/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user)
	if(user.loc == src || ultra_violet)
		return FALSE
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return FALSE

	if(!opened)
		toggle_lock(user)
	else if(POSSIBLE_TO_LOAD(I) || istype(I, /obj/item/weapon/grab))
		if(istype(I, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/grab = I
			if(!ismob(grab.affecting) || grab.state < GRAB_AGGRESSIVE)
				return
			var/mob/M = grab.affecting
			place_occupant(M, user, grab)
		else
			load_something(I, user)
	else if(opened && !occupant)
		if(isscrewing(I))
			if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
				update_icon()
				return TRUE
		if(isprying(I))
			if(default_deconstruction_crowbar(I))
				return TRUE
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/load_something(atom/movable/something, mob/user, obj/grab = null)
	if(length(contents))
		for(var/atom/target in contents)
			if(IS_LOAD(something, target))
				to_chat(user, "<span class ='warning'>The unit already contains something like [something.name].</span>")
				return FALSE

	if(POSSIBLE_TO_LOAD(something))
		if(do_after(user, 0.1 SECONDS, FALSE, src))
			to_chat(user, "You load the [something.name] into the storage compartment.")
			if(something.loc == user)
				user.drop_from_inventory(something, src)
				something.forceMove(src)
			else
				something.forceMove(src)
			playsound(src, 'sound/misc/robot_close.ogg', VOL_EFFECTS_MASTER, 15)
	update_icon()
	return TRUE

/obj/machinery/suit_storage_unit/proc/dispense(atom/movable/selected)
	for(var/atom/movable/target in contents)
		if(target == selected)
			if(!iscarbon(selected))
				selected.forceMove(get_turf(src))
			else
				eject_occupant(target)
		playsound(src, 'sound/misc/robot_open.ogg', VOL_EFFECTS_MASTER, 15)
	update_icon()
	return TRUE

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	drop_from_contents()
	..()

/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return ..()

/obj/machinery/suit_storage_unit/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	emagged = TRUE
	locked = FALSE
	update_icon()
	return TRUE

/obj/machinery/suit_storage_unit/verb/toggle_open_unit()
	set category = "Object"
	set name = "Toggle Open SSU"
	set src in view(1)

	if(isliving(usr))
		opened ? close() : open()

/obj/machinery/suit_storage_unit/verb/toggle_ultra_violet_cylce()
	set category = "Object"
	set name = "Toggle SSU Ultra violet Cylce"
	set src in view(1)

	if(isliving(usr))
		start_ultra_violet()

/obj/machinery/suit_storage_unit/verb/fast_move()
	set category = "Object"
	set name = "Fast Equip/Unequip"
	set src in view(1)

	if(ishuman(usr) && opened && !ultra_violet)
		length(contents) ? fast_equip(usr) : fast_unequip(usr)
		if(emagged)
			place_occupant(usr, usr)

#undef POSSIBLE_TO_LOAD

//The units themselves
//unit for unit tests
/obj/machinery/suit_storage_unit/test_unit
	name = "Test Storage Unit"
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/gas
	tank_type = /obj/item/weapon/tank/oxygen
	boot_type = /obj/item/clothing/shoes/magboots

	build_type =  SUIT_STORAGE_BUILD_NONE

//Syndicate
/obj/machinery/suit_storage_unit/syndicate_unit
	name = "Suit Storega Unit"
	suit_type = /obj/item/clothing/suit/space/syndicate
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness

	req_access = list(access_syndicate)
	build_type =  SUIT_STORAGE_BUILD_NONE
	icon_state = "syndicate"
	icon = 'icons/obj/suit_storage/syndicate.dmi'

//Abandoned
/obj/machinery/suit_storage_unit/syndicate_unit/abandoned
	name = "Abandoned Storage Unit"

/obj/machinery/suit_storage_unit/syndicate_unit/abandoned/atom_init()
	if(!filled)
		return ..()

	if(prob(50))
		occupant = new /mob/living/simple_animal/hostile/xenomorph/queen(src)
	else
		var/choose = pick(1,2)
		switch(choose)
			if(1)
				suit_type = /obj/item/clothing/suit/space/rig/syndi
				mask_type = /obj/item/clothing/mask/gas/syndicate
				tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
			if(2)
				suit_type = /obj/item/clothing/suit/space/rig/wizard
				mask_type = /obj/item/clothing/mask/gas/coloured
				tank_type = /obj/item/weapon/tank/emergency_oxygen/double
	return ..()

/obj/machinery/suit_storage_unit/syndicate_unit/light
	name = "Syndicate Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/syndicate_unit/light/heavy
	name = "Syndicate Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/heavy
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/syndicate_unit/light/chem
	name = "Hazmat Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/hazmat
	mask_type = /obj/item/clothing/mask/gas/syndicate

/obj/machinery/suit_storage_unit/syndicate_unit/striker
	name = "Syndicate Striker Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/syndicate/elite
	helmet_type = /obj/item/clothing/suit/space/syndicate/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/elite
	name = "Elite Syndicate Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/elite
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/elite/comander
	name = "Comander Syndicate Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/elite/comander
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/elite/comander
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

	req_access = list(access_syndicate_commander)

//Sience
/obj/machinery/suit_storage_unit/science
	name = "Science Hardsuit Storage Unit"

	suit_type = /obj/item/clothing/suit/space/rig/science
	mask_type = /obj/item/clothing/mask/gas/coloured
	tank_type = /obj/item/weapon/tank/jetpack/carbondioxide

	req_access = list(access_research)
	icon_state = "science"
	icon = 'icons/obj/suit_storage/science.dmi'

/obj/machinery/suit_storage_unit/science/rd
	name = "Research Director Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/science/rd
	mask_type = /obj/item/clothing/mask/gas/coloured

	req_access = list(access_rd)
	icon_state = "RD"
	icon = 'icons/obj/suit_storage/rd.dmi'

//Engine
/obj/machinery/suit_storage_unit/engine
	name = "Engineer Hardsuit Storage Unit"
	suit_type  = /obj/item/clothing/suit/space/rig/engineering
	mask_type = /obj/item/clothing/mask/gas/coloured

	req_access = list(access_engine)
	icon_state = "engineer"
	icon = 'icons/obj/suit_storage/engine.dmi'

/obj/machinery/suit_storage_unit/engine/atmos
	name = "Atmospheric Hardsuit Storage Unit"
	req_access = list(access_atmospherics)
	suit_type = /obj/item/clothing/suit/space/rig/atmos
	mask_type = /obj/item/clothing/mask/gas/coloured

	icon_state = "atmos"
	icon = 'icons/obj/suit_storage/atmos.dmi'

/obj/machinery/suit_storage_unit/engine/chief
	name = "Chief Engineer Hardsuit Storage Unit"
	req_access = list(access_ce)
	suit_type = /obj/item/clothing/suit/space/rig/engineering/chief
	mask_type = /obj/item/clothing/mask/gas/coloured

	icon_state = "CE"
	icon = 'icons/obj/suit_storage/chief.dmi'

//Security
/obj/machinery/suit_storage_unit/security
	name = "Security Officer Hardsuit Storage Unit"
	req_access = list(access_security)
	suit_type = /obj/item/clothing/suit/space/rig/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

	icon_state = "security"
	icon = 'icons/obj/suit_storage/security.dmi'

/obj/machinery/suit_storage_unit/security/hos
	name = "Head of Security Hardsuit Storage Unit"
	req_access = list(access_hos)
	suit_type = /obj/item/clothing/suit/space/rig/security/hos
	mask_type = /obj/item/clothing/mask/gas/sechailer
	icon_state = "HOS"
	icon = 'icons/obj/suit_storage/hos.dmi'

//Medical
/obj/machinery/suit_storage_unit/medical
	name = "Medical Hardsuit Storage Unit"
	req_access = list(access_medbay_storage)
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/gas/coloured

	icon_state = "med"
	icon = 'icons/obj/suit_storage/medical.dmi'

/obj/machinery/suit_storage_unit/medical/paramedic
	name = "Paremedic Hardsuit Storage Unit"
	req_access = list(access_paramedic)
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/gas/coloured

/obj/machinery/suit_storage_unit/medical/cmo
	name = "Chief Medical Officer Hardsuit Storage Unit"
	req_access = list(access_cmo)
	suit_type = /obj/item/clothing/suit/space/rig/medical/cmo
	mask_type = /obj/item/clothing/mask/gas/coloured

	icon_state = "CMO"
	icon = 'icons/obj/suit_storage/cmo.dmi'

//Other
/obj/machinery/suit_storage_unit/globose
	name = "Civil Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/globose
	helmet_type = /obj/item/clothing/head/helmet/space/globose
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/carbondioxide

/obj/machinery/suit_storage_unit/globose/science
	name = "Science Space Suit Storage Unit"
	req_access = list(access_research)
	suit_type = /obj/item/clothing/suit/space/globose/science
	helmet_type = /obj/item/clothing/head/helmet/space/globose/science
	tank_type = /obj/item/weapon/tank/oxygen

/obj/machinery/suit_storage_unit/globose/science/xenoarchaeologist
	name = "Xenoarchaeologist Space Suit Storage Unit"

/obj/machinery/suit_storage_unit/globose/mining
	name = "Mining Space Suit Storage Unit"
	req_access = list(access_mining)
	suit_type = /obj/item/clothing/suit/space/globose/mining
	helmet_type = /obj/item/clothing/head/helmet/space/globose/mining
	tank_type = /obj/item/weapon/tank/oxygen

	icon_state = "miner"
	icon = 'icons/obj/suit_storage/mining.dmi'

/obj/machinery/suit_storage_unit/globose/skrell
	build_type =  SUIT_STORAGE_BUILD_NONE
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/oxygen

/obj/machinery/suit_storage_unit/globose/skrell/white
	name = "White Skrellian Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/skrell/white
	helmet_type = /obj/item/clothing/head/helmet/space/skrell/white

/obj/machinery/suit_storage_unit/globose/skrell/black
	name = "Black Skrellian Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/skrell/black
	helmet_type = /obj/item/clothing/head/helmet/space/skrell/black

/obj/machinery/suit_storage_unit/unathi
	name = "NT Unathi Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/unathi/rig_cheap
	helmet_type = /obj/item/clothing/head/helmet/space/unathi/helmet_cheap
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/oxygen

	icon_state = "unathi"
	icon = 'icons/obj/suit_storage/unathi.dmi'

/obj/machinery/suit_storage_unit/unathi/breacher
	name = "Breacher Unathi Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/unathi/breacher
	helmet_type = /obj/item/clothing/head/helmet/space/unathi/breacher

	build_type =  SUIT_STORAGE_BUILD_NONE
	req_access = list(access_captain)

/obj/machinery/suit_storage_unit/captain
	name = "Captain Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/armor/captain
	helmet_type = /obj/item/clothing/head/helmet/space/capspace
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/oxygen

	req_access = list(access_captain)
	icon_state = "captain"
	icon = 'icons/obj/suit_storage/captain.dmi'

/obj/machinery/suit_storage_unit/nasa
	name = "NASA Suit Storage Unit"

	suit_type = /obj/item/clothing/suit/space/nasavoid
	helmet_type = /obj/item/clothing/head/helmet/space/nasavoid
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/void

	req_access = list(access_minisat)
	icon_state = "NASA"
	icon = 'icons/obj/suit_storage/nasa.dmi'

/obj/machinery/suit_storage_unit/wizard
	build_type =  SUIT_STORAGE_BUILD_NONE
	name = "Strange Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/wizard
	mask_type = /obj/item/clothing/mask/gas/coloured
	tank_type = /obj/item/weapon/tank/emergency_oxygen/double
	req_access = list(access_syndicate)

	icon_state = "mage"
	icon = 'icons/obj/suit_storage/wizard.dmi'

/obj/machinery/suit_storage_unit/vox
	build_type =  SUIT_STORAGE_BUILD_NONE
	mask_type = /obj/item/clothing/mask/gas/vox
	boot_type = /obj/item/clothing/shoes/magboots/vox
	tank_type = /obj/item/weapon/tank/nitrogen

	req_access = list(access_syndicate)

/obj/machinery/suit_storage_unit/vox/atom_init()
	var/list/icon_types_option = list()
	for(var/obj/machinery/suit_storage_unit/typepath as anything in typesof(/obj/machinery/suit_storage_unit))
		if(!(typepath::icon in icon_types_option))
			icon_types_option[typepath::icon] += typepath::icon_state
	if(length(icon_types_option))
		for(var/new_icon in icon_types_option)
			if(prob(50)) // try to take some random appearance, or stay default if always false
				icon = new_icon
				icon_state = icon_types_option[new_icon]

	return ..()

/obj/machinery/suit_storage_unit/vox/carapace
	name = "Vox Carapace Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/vox/carapace
	helmet_type = /obj/item/clothing/head/helmet/space/vox/carapace

/obj/machinery/suit_storage_unit/vox/medic
	name = "Vox Alien Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/vox/medic
	helmet_type = /obj/item/clothing/head/helmet/space/vox/medic

/obj/machinery/suit_storage_unit/vox/stealth
	name = "Vox Stealth Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/vox/stealth
	helmet_type = /obj/item/clothing/head/helmet/space/vox/stealth

/obj/machinery/suit_storage_unit/vox/engine
	name = "Vox Engineer Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/vox/pressure
	helmet_type = /obj/item/clothing/head/helmet/space/vox/pressure
