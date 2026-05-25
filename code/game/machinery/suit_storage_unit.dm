
#define POSSIBLE_TO_LOAD(something) something && (istype(something, /obj/item/weapon/grab) || isspacesuit(something)||(isspacehelmet(something) && !ishardhelmet(something))||isbreathmask(something)||ismagboots(something)||istank(something)||iscarbon(something))

/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a ultra_violet-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitholder"
	damage_deflection = 25
	idle_power_usage = 10
	anchored = TRUE
	density = TRUE

	var/build_type = SUIT_STORAGE_BUILD_DEFAULT
	var/opened = FALSE
	var/locked = TRUE

	var/overlay_color = null

	var/list/connectors_overlays = list()
	var/list/suit_storage_overlays = list()

//ultra violet stat
	var/ultra_violet = FALSE
	var/super_ultra_violet = FALSE
	var/cycletime_left = null

	var/fulled = FALSE // For map placeing suit storages, when false, create empty suit storage

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
	fulled ? make_full() : FALSE
	set_power_use(IDLE_POWER_USE)
	update_icon()						//in update icon, we add src connectors icons and search neardy Suit Storage Units
	ssu_left?.update_connectors() 			//to add connector sprites for neardy staying Suit Storage Units
	ssu_right?.update_connectors()

/obj/machinery/suit_storage_unit/proc/make_full()
	if(!contents?.len)
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
	if(!(contents?.len - 1)) // - 1 тк в родителе мы помещаем хумана внутрь шкафа и он тоже считается в контентс
		to_chat(target, "<span class ='danger'>There are nothing here for you.</span>")
	if(emagged)
		start_ultra_violet(user)
	update_icon()

/obj/machinery/suit_storage_unit/proc/fast_equip(mob/living/target)
	for(var/obj/item/something in contents)
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

/obj/machinery/suit_storage_unit/proc/update_connectors()
	if(length(connectors_overlays))
		cut_overlay(connectors_overlays)
		LAZYCLEARLIST(connectors_overlays)
	if(QDELETED(src))
		return

	var/mutable_appearance/I
	ssu_left = locate(/obj/machinery/suit_storage_unit) in get_step(src, WEST)
	if(!QDELETED(ssu_left))
		I = mutable_appearance(icon_state = "left_connect")
		if(overlay_color)
			I.color = overlay_color
		connectors_overlays += I

	ssu_right = locate(/obj/machinery/suit_storage_unit) in get_step(src, EAST)
	if(!QDELETED(ssu_right))
		I = mutable_appearance(icon_state = "right_connect")
		if(overlay_color)
			I.color = overlay_color
		connectors_overlays += I

	add_overlay(connectors_overlays)

/obj/machinery/suit_storage_unit/update_icon()
	if(length(suit_storage_overlays))
		cut_overlay(suit_storage_overlays)
		LAZYCLEARLIST(suit_storage_overlays)
	update_connectors(suit_storage_overlays)
	if(contents?.len)
		for(var/atom/target in contents)
			if(ishardsuit(target))
				var/obj/item/clothing/suit/space/rig/rig_suit = target
				if(rig_suit?.helmet)
					suit_storage_overlays += mutable_appearance(icon_state = "suit&helmet")
				if(rig_suit?.boots)
					suit_storage_overlays += mutable_appearance(icon_state = "boots")
			else if(ismagboots(target))
				suit_storage_overlays += mutable_appearance(icon_state = "boots")
			else if(isspacehelmet(target))
				suit_storage_overlays += mutable_appearance(icon_state = "helmet")
			else if(isspacesuit(target))
				suit_storage_overlays += mutable_appearance(icon_state = "suit")

	var/mutable_appearance/door_I = mutable_appearance(icon_state = "[opened ? "door_open" : "door_closed"]")
	var/mutable_appearance/unit_color = mutable_appearance(icon_state = "[stat & BROKEN ? "suitholder_broken_color" : "suitholder_color"]")
	if(overlay_color)
		door_I.color = overlay_color
		unit_color.color = overlay_color
		suit_storage_overlays += unit_color
	if(!opened && !(stat & BROKEN))
		suit_storage_overlays += door_I
		if(locked && !emagged && !ultra_violet)
			suit_storage_overlays += mutable_appearance(icon_state = "lock_closed")
		else
			suit_storage_overlays += mutable_appearance(icon_state = "lock_open")
	else
		suit_storage_overlays += door_I
	if(stat & BROKEN)
		icon_state = "suitholder_broken"
	if(ultra_violet && !super_ultra_violet)
		suit_storage_overlays += door_I
		suit_storage_overlays += mutable_appearance(icon_state = "lock_closed")
		suit_storage_overlays += mutable_appearance(icon_state = "termalclean")
		add_overlay(suit_storage_overlays)
		return
	else if(ultra_violet && super_ultra_violet)
		suit_storage_overlays += door_I
		suit_storage_overlays += mutable_appearance(icon_state = "lock_closed")
		suit_storage_overlays += mutable_appearance(icon_state = "termalclean_emag")
		add_overlay(suit_storage_overlays)
		return
	if(panel_open)
		suit_storage_overlays += mutable_appearance(icon_state = "panel_open")
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
	if(super_ultra_violet)
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
	if(occupant && !super_ultra_violet)
		to_chat(user, "<span class = 'danger'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</span>")
		return
	if(!contents?.len)
		to_chat(user, "<span class ='danger'>Unit storage bays empty. Nothing to disinfect -- Aborting.</span>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	if(opened)
		close()
	if(!locked)
		toggle_lock()
	ultra_violet = TRUE
	if(!super_ultra_violet)
		cycletime_left = 1
	else
		cycletime_left = 5
	update_icon()
	ultra_violet_cleaning()

/obj/machinery/suit_storage_unit/proc/ultra_violet_cleaning()
	if(cycletime_left)
		cycletime_left--
		if(occupant)
			if(super_ultra_violet)
				occupant.adjustFireLoss(rand(15, 30))
		addtimer(CALLBACK(src, PROC_REF(ultra_violet_cleaning)), 5 SECONDS)
	else
		if(!super_ultra_violet)
			default_ultra_violet_cleaning()
		else
			super_ultra_violet_cleaning()

		locked ? toggle_lock() : FALSE // anyway it may be unlocked
		open()
		ultra_violet = FALSE //Cycle ends
		update_icon()
		return TRUE

/obj/machinery/suit_storage_unit/proc/default_ultra_violet_cleaning()
	if(contents?.len)
		for(var/obj/item/target in contents) // we cand ultra_violeting only items
			target.clean_blood()
			target.decontaminate()

/obj/machinery/suit_storage_unit/proc/super_ultra_violet_cleaning()
	if(contents?.len)
		for(var/atom/target as anything in contents)
			QDEL_NULL(target)
	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	stat |= BROKEN
	visible_message("<span class ='danger'>With a loud whining noise, the Suit Storage Unit's door grinds opened. Puffs of ashen smoke come out of its chamber.</span>", 3)

/obj/machinery/suit_storage_unit/container_resist()
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
	locked ? toggle_lock() : FALSE // anyway it may be unlocked
	open()
	eject_occupant(user)
	add_fingerprint(user)
	update_icon()
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

/obj/machinery/suit_storage_unit/AltClick(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN | NOPOWER))
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(ultra_violet)
		return
	if(!allowed(user))
		to_chat(user, "<span class='notice'>Access Denied</span>")
		return
	if((!opened && !locked) || emagged)
		start_ultra_violet(user)

/obj/machinery/suit_storage_unit/CtrlClick(mob/user)
	add_fingerprint(user)
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(ultra_violet)
		return
	opened ? close() : open(user)
	update_icon()

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if(ultra_violet)
		return FALSE
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(user.loc == src && ishuman(user))
		var/list/options = list()
		if(!(contents?.len - 1))
			options += "Fast Uneqip"
		else
			options += "Fast Eqip"
		if(length(options))
			var/choosen_option = show_radial_menu(user, src, options, require_near = TRUE, tooltips = TRUE)
			switch(choosen_option)
				if("Fast Uneqip")
					for(var/obj/item/something in user.contents)
						load_something(something, user)
				if("Fast Eqip")
					fast_equip(user)
					for(var/atom/movable/something in contents)
						dispense(something)
					update_icon()
			return
	if(!opened)
		toggle_lock(user)
	else if(contents?.len)
		var/list/suit_storage = list()
		for(var/atom/movable/target in contents)
			suit_storage[target] = image(getFlatIcon(target))
		var/atom/movable/to_dispense = show_radial_menu(user, src, suit_storage, require_near = TRUE, tooltips = TRUE)
		if(to_dispense)
			dispense(to_dispense)
			update_icon()
		return

	if(!locked && !(stat & BROKEN))
		opened ? close() : open(user)
		update_icon()
		return

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user)
	if(user.loc == src || ultra_violet)
		return FALSE
	if(stat & BROKEN)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return FALSE

	if(!opened)
		toggle_lock(user)
	else if(POSSIBLE_TO_LOAD(I))
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
			if(default_deconstruction_screwdriver(user, "suitholder_o", "suitholder", I))
				return TRUE
		if(isprying(I))
			if(default_deconstruction_crowbar(I))
				return TRUE
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/load_something(atom/movable/something, mob/user, obj/grab = null)
	if(contents?.len)
		for(var/atom/target in contents)
			if(istype(something, target))
				to_chat(user, "<span class ='warning'>The unit already contains something like [something.name].</span>")
				return FALSE

	if(POSSIBLE_TO_LOAD(something))
		to_chat(user, "You load the [something.name] into the storage compartment.")
		user.drop_from_inventory(something, src)
	update_icon()
	return TRUE

/obj/machinery/suit_storage_unit/proc/dispense(atom/movable/selected)
	if(!contents?.len)
		return FALSE
	for(var/atom/movable/target in contents)
		if(target == selected)
			if(!iscarbon(selected))
				selected.forceMove(get_turf(src))
			else
				eject_occupant(target)
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
	super_ultra_violet = TRUE
	locked = FALSE
	update_icon()
	return TRUE

//The units themselves
//unit for unit tests
/obj/machinery/suit_storage_unit/test_unit
	name = "Test Storage Unit"
	build_type =  SUIT_STORAGE_BUILD_NONE
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask
	tank_type = /obj/item/weapon/tank
	boot_type = /obj/item/clothing/shoes/magboots

//Abandoned
/obj/machinery/suit_storage_unit/abandoned
	name = "Abandoned Storage Unit"
	build_type =  SUIT_STORAGE_BUILD_NONE

/obj/machinery/suit_storage_unit/abandoned/atom_init()
	if(!fulled)
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

//Syndicate
/obj/machinery/suit_storage_unit/syndicate_unit
	name = "Suit Storega Unit"
	suit_type = /obj/item/clothing/suit/space/syndicate
	helmet_type = /obj/item/clothing/head/helmet/space/syndicate
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	req_access = list(access_syndicate)
	build_type =  SUIT_STORAGE_BUILD_SYNDIE
	emagged = TRUE

	overlay_color = COLOR_DARK_GUNMETAL

/obj/machinery/suit_storage_unit/syndicate_unit/light
	name = "Syndicate Hardsuit Storage Unit"
	build_type =  SUIT_STORAGE_BUILD_NONE
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
	build_type =  SUIT_STORAGE_BUILD_NONE
	suit_type = /obj/item/clothing/suit/space/syndicate/elite
	helmet_type = /obj/item/clothing/suit/space/syndicate/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/elite
	name = "Elite Syndicate Hardsuit Storage Unit"
	build_type =  SUIT_STORAGE_BUILD_NONE
	suit_type = /obj/item/clothing/suit/space/rig/syndi/elite
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/elite/comander
	name = "Comander Syndicate Hardsuit Storage Unit"
	req_access = list(access_syndicate_commander)
	suit_type = /obj/item/clothing/suit/space/rig/syndi/elite/comander
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/elite/comander
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

//Sience
/obj/machinery/suit_storage_unit/science
	name = "Sience Hardsuit Storage Unit"
	req_access = list(access_research)
	suit_type = /obj/item/clothing/suit/space/rig/science
	mask_type = /obj/item/clothing/mask/gas/coloured
	tank_type = /obj/item/weapon/tank/jetpack/carbondioxide

	overlay_color = COLOR_VIOLET

/obj/machinery/suit_storage_unit/science/rd
	name = "Researh Director Hardsuit Storage Unit"
	req_access = list(access_rd)
	suit_type = /obj/item/clothing/suit/space/rig/science/rd
	mask_type = /obj/item/clothing/mask/gas/coloured

	overlay_color = COLOR_DARK_PURPLE

//Engine
/obj/machinery/suit_storage_unit/engine
	name = "Engineer Hardsuit Storage Unit"
	req_access = list(access_engine)
	suit_type  = /obj/item/clothing/suit/space/rig/engineering
	mask_type = /obj/item/clothing/mask/gas/coloured

/obj/machinery/suit_storage_unit/engine/atmos
	name = "Atmospheric Hardsuit Storage Unit"
	req_access = list(access_atmospherics)
	suit_type = /obj/item/clothing/suit/space/rig/atmos
	mask_type = /obj/item/clothing/mask/gas/coloured

	overlay_color = COLOR_TEAL

/obj/machinery/suit_storage_unit/engine/chief
	name = "Chief Engineer Hardsuit Storage Unit"
	req_access = list(access_ce)
	suit_type = /obj/item/clothing/suit/space/rig/engineering/chief
	mask_type = /obj/item/clothing/mask/gas/coloured

	overlay_color = COLOR_TITANIUM

//Security
/obj/machinery/suit_storage_unit/security
	name = "Security Officer Hardsuit Storage Unit"
	req_access = list(access_security)
	suit_type = /obj/item/clothing/suit/space/rig/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

	overlay_color = COLOR_CRIMSON

/obj/machinery/suit_storage_unit/security/hos
	name = "Head of Security Hardsuit Storage Unit"
	req_access = list(access_hos)
	suit_type = /obj/item/clothing/suit/space/rig/security/hos
	mask_type = /obj/item/clothing/mask/gas/sechailer

	overlay_color = COLOR_CRIMSON_RED

//Medical
/obj/machinery/suit_storage_unit/medical
	name = "Medical Hardsuit Storage Unit"
	req_access = list(access_medbay_storage)
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/gas/coloured

	overlay_color = COLOR_CYAN

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

	overlay_color = COLOR_CYAN_BLUE

//Other
/obj/machinery/suit_storage_unit/globose
	name = "Civil Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/globose
	helmet_type = /obj/item/clothing/head/helmet/space/globose
	mask_type = /obj/item/clothing/mask/breath
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/carbondioxide
	overlay_color = COLOR_SILVER

/obj/machinery/suit_storage_unit/globose/science
	name = "Science Space Suit Storage Unit"
	req_access = list(access_research)
	suit_type = /obj/item/clothing/suit/space/globose/science
	helmet_type = /obj/item/clothing/head/helmet/space/globose/science
	tank_type = /obj/item/weapon/tank/oxygen

	overlay_color = COLOR_PINK

/obj/machinery/suit_storage_unit/globose/science/xenoarchaeologist
	name = "Xenoarchaeologist Space Suit Storage Unit"

/obj/machinery/suit_storage_unit/globose/mining
	name = "Mining Space Suit Storage Unit"
	req_access = list(access_mining)
	suit_type = /obj/item/clothing/suit/space/globose/mining
	helmet_type = /obj/item/clothing/head/helmet/space/globose/mining
	tank_type = /obj/item/weapon/tank/oxygen

	overlay_color = COLOR_BROWN

/obj/machinery/suit_storage_unit/skrell
	build_type =  SUIT_STORAGE_BUILD_NONE
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/oxygen

	overlay_color = COLOR_BLUE_LIGHT

/obj/machinery/suit_storage_unit/skrell/white
	name = "White Skrellian Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/skrell/white
	helmet_type = /obj/item/clothing/head/helmet/space/skrell/white

/obj/machinery/suit_storage_unit/skrell/black
	name = "Black Skrellian Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/skrell/black
	helmet_type = /obj/item/clothing/head/helmet/space/skrell/black

/obj/machinery/suit_storage_unit/unathi
	build_type =  SUIT_STORAGE_BUILD_NONE
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/oxygen
	overlay_color = COLOR_SEAWEED

/obj/machinery/suit_storage_unit/unathi/nt
	name = "NT Unathi Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/unathi/rig_cheap
	helmet_type = /obj/item/clothing/head/helmet/space/unathi/helmet_cheap

/obj/machinery/suit_storage_unit/unathi/breacher
	name = "Breacher Unathi Suit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/unathi/breacher
	helmet_type = /obj/item/clothing/head/helmet/space/unathi/breacher
	req_access = list(access_captain)

/obj/machinery/suit_storage_unit/captain
	name = "Captain Suit Storage Unit"
	req_access = list(access_captain)
	overlay_color = COLOR_COMMAND_BLUE

/obj/machinery/suit_storage_unit/captain
	suit_type = /obj/item/clothing/suit/armor/captain
	helmet_type = /obj/item/clothing/head/helmet/space/capspace
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/oxygen

/obj/machinery/suit_storage_unit/nasa
	name = "NASA Suit Storage Unit"
	req_access = list(access_minisat)
	suit_type = /obj/item/clothing/suit/space/nasavoid
	helmet_type = /obj/item/clothing/head/helmet/space/nasavoid
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots
	tank_type = /obj/item/weapon/tank/jetpack/void

	overlay_color = COLOR_GUNMETAL

/obj/machinery/suit_storage_unit/wizard
	build_type =  SUIT_STORAGE_BUILD_NONE
	name = "Strange Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/wizard
	mask_type = /obj/item/clothing/mask/gas/coloured
	tank_type = /obj/item/weapon/tank/emergency_oxygen/double
	req_access = list(access_syndicate)

	overlay_color = COLOR_DARK_PURPLE

/obj/machinery/suit_storage_unit/vox
	build_type =  SUIT_STORAGE_BUILD_NONE
	mask_type = /obj/item/clothing/mask/gas/vox
	boot_type = /obj/item/clothing/shoes/magboots/vox
	tank_type = /obj/item/weapon/tank/nitrogen
	req_access = list(access_syndicate)

/obj/machinery/suit_storage_unit/vox/atom_init()
	overlay_color = pick(COLOR_BLUE, COLOR_BROWN, COLOR_DARK_GRAY, COLOR_ADMIRAL_BLUE, COLOR_CRIMSON, COLOR_CYAN_BLUE)
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
