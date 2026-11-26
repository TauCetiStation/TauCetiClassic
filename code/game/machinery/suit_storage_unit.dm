/obj/machinery/storage_unit/suit_storage
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a ultra_violet-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/dressers/suit_storage.dmi'
	overlays_file = 'icons/obj/dressers/suit_storage_overlays.dmi'
	icon_state = "civilian"
	damage_deflection = 25
	idle_power_usage = 10
	active_power_usage = 100

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = null,
		SLOT_SHOES = null
	)

	paint_type = /obj/machinery/storage_unit/suit_storage
	prohibited_paint_types = list()

	var/list/connectors_overlays = list()

//ultra violet stat
	var/ultra_violet = FALSE
	var/cycletime_left = null

//overlay connectors stuff
	var/obj/machinery/storage_unit/suit_storage/ssu_left = null
	var/obj/machinery/storage_unit/suit_storage/ssu_right = null

/obj/machinery/storage_unit/suit_storage/atom_init()
	. = ..()
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()

	ssu_left = locate(/obj/machinery/storage_unit/suit_storage) in get_step(src, WEST)
	if(!QDELETED(ssu_left))
		ssu_left?.update_connectors() 			//to add connector sprites for neardy staying Suit Storage Units
	ssu_right = locate(/obj/machinery/storage_unit/suit_storage) in get_step(src, WEST)
	if(!QDELETED(ssu_right))
		ssu_right?.update_connectors()

	options += list(
		list("Process UV", mutable_appearance(icon = "icons/hud/radial.dmi", icon_state = "radial_start"), PROC_REF(start_ultra_violet))
	)

/obj/machinery/storage_unit/suit_storage/place_occupant(mob/living/target, mob/user, obj/grab = null)
	..()

	if((occupant == target) && emagged)
		to_chat(target, "<span class ='danger'>You feel like a terrible manipulators pulls you into [name].</span>")
		start_ultra_violet(user)
		update_icon()


/obj/machinery/storage_unit/suit_storage/proc/update_connectors()
	if(length(connectors_overlays))
		cut_overlay(connectors_overlays)
		LAZYCLEARLIST(connectors_overlays)
	if(QDELETED(src))
		return

	var/mutable_appearance/I
	ssu_left = locate(/obj/machinery/storage_unit/suit_storage) in get_step(src, WEST)
	if(!QDELETED(ssu_left))
		if(ssu_left)
			if(ssu_left.icon == src.icon)
				I = mutable_appearance(icon = overlays_file, icon_state = "left_connect_[icon_state]")
			else
				I = mutable_appearance(icon = overlays_file, icon_state = "left_connect_civilian")
			I.layer = layer
			connectors_overlays += I

	ssu_right = locate(/obj/machinery/storage_unit/suit_storage) in get_step(src, EAST)
	if(!QDELETED(ssu_right))
		if(ssu_right)
			if(ssu_right.icon == src.icon)
				I = mutable_appearance(icon = overlays_file, icon_state = "right_connect_[icon_state]")
			else
				I = mutable_appearance(icon = overlays_file, icon_state = "right_connect_civilian")
			I.layer = layer
			connectors_overlays += I

	add_overlay(connectors_overlays)

/obj/machinery/storage_unit/suit_storage/update_icon()
	..()

	update_connectors()

	if(ultra_violet)
		var/mutable_appearance/I = mutable_appearance(icon = overlays_file, icon_state = "[emagged ? "termalclean_emag" : "termalclean"]")
		I.layer = layer + 0.02
		add_overlay(I)

/obj/machinery/storage_unit/suit_storage/update_insides()
	if(contents_by_slot[SLOT_SHOES])
		add_overlay(mutable_appearance(overlays_file, "boots"))

	if(contents_by_slot[SLOT_WEAR_SUIT])
		add_overlay(mutable_appearance(overlays_file, "suit"))

	if(contents_by_slot[SLOT_HEAD])
		add_overlay(mutable_appearance(overlays_file, "helmet"))

/obj/machinery/storage_unit/suit_storage/power_change()
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

/obj/machinery/storage_unit/suit_storage/Destroy()
	ssu_left?.update_connectors()
	ssu_left = null
	ssu_right?.update_connectors()
	ssu_right = null
	..()

/obj/machinery/storage_unit/suit_storage/open(mob/user)
	if(ultra_violet)
		to_chat(user, "<span class ='danger'>Unable to opened unit.</span>")
		return

	..()

/obj/machinery/storage_unit/suit_storage/toggle_lock(mob/user)
	if(ultra_violet)
		return

	..()

/obj/machinery/storage_unit/suit_storage/proc/start_ultra_violet(mob/user)
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
	addtimer(CALLBACK(src, PROC_REF(ultra_violet_cleaning)), 10)
	set_power_use(ACTIVE_POWER_USE)


/obj/machinery/storage_unit/suit_storage/proc/ultra_violet_cleaning()
	update_icon()
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

/obj/machinery/storage_unit/suit_storage/proc/default_ultra_violet_cleaning()
	for(var/slot_name in contents_by_slot)
		if(!contents_by_slot[slot_name])
			continue

		var/obj/item/target = contents_by_slot[slot_name]
		target.clean_blood()
		target.decontaminate()

/obj/machinery/storage_unit/suit_storage/proc/super_ultra_violet_cleaning()
	for(var/atom/target as anything in contents)
		QDEL_NULL(target)

	for(var/slot_name in contents_by_slot)
		contents_by_slot[slot_name] = null

	playsound(src, 'sound/weapons/sear.ogg', VOL_EFFECTS_MASTER)
	stat |= BROKEN
	visible_message("<span class ='danger'>With a loud whining noise, the Suit Storage Unit's door grinds opened. Puffs of ashen smoke come out of its chamber.</span>", 3)

/obj/machinery/storage_unit/suit_storage/container_resist()
	if(ultra_violet)
		return

	..()

/obj/machinery/storage_unit/suit_storage/MiddleShiftClick(mob/user)
	if(ultra_violet || !Adjacent(user))
		return
	start_ultra_violet(user)

/obj/machinery/storage_unit/suit_storage/CtrlClick(mob/user, proximity)
	if(ultra_violet)
		return

	..()

/obj/machinery/storage_unit/suit_storage/interact(mob/user)
	if(ultra_violet)
		return FALSE
	..()


/obj/machinery/storage_unit/suit_storage/attackby(obj/item/I, mob/user)
	if(ultra_violet)
		return FALSE

	return ..()

/obj/machinery/storage_unit/suit_storage/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return ..()

/obj/machinery/storage_unit/suit_storage/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	emagged = TRUE
	locked = FALSE
	update_icon()
	return TRUE

/obj/machinery/storage_unit/suit_storage/toggle_door(opening = TRUE)
	if(door_animated)
		return

	door_animated = TRUE
	cut_overlay(door)
	vis_contents += door
	if(opening)
		new /obj/effect/abstract/particle_holder(get_turf(src), /particles/mist/suit_storage, PARTICLE_FADEOUT|PARTICLE_FLICK)
		animate(door, pixel_y = -1, time = 10, easing = JUMP_EASING|EASE_OUT, flags = ANIMATION_PARALLEL, tag="door_animation")
		animate(pixel_x = 10, time = 10, easing = CUBIC_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	else
		animate(door, pixel_y = 0, time = 10, easing = JUMP_EASING|EASE_IN, flags = ANIMATION_PARALLEL, tag="door_animation")
		animate(pixel_x = 0, time = 10, easing = CUBIC_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(toggle_door_end)), 10)

//The units themselves
//unit for unit tests
/obj/machinery/storage_unit/suit_storage/test_unit
	name = "Test Storage Unit"

	contents_by_slot = alist(
		SLOT_BACK = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	filled = TRUE

	can_build = FALSE

//Syndicate
/obj/machinery/storage_unit/suit_storage/syndicate_unit
	name = "Suit Storega Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/syndicate,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = null
	)

	req_access = list(access_syndicate)
	can_build = FALSE
	icon_state = "syndicate"

//Abandoned
/obj/machinery/storage_unit/suit_storage/syndicate_unit/abandoned
	name = "Abandoned Storage Unit"

/obj/machinery/storage_unit/suit_storage/syndicate_unit/abandoned/atom_init(mapload)
	if(!mapload)
		return ..()

	if(prob(50))
		occupant = new /mob/living/simple_animal/hostile/xenomorph/queen(src)
	else
		var/choose = pick(1,2)
		switch(choose)
			if(1)
				contents_by_slot = alist(
					SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
					SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi,
					SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
					SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
					SLOT_SHOES = null
				)
			if(2)
				contents_by_slot = alist(
					SLOT_S_STORE = /obj/item/weapon/tank/emergency_oxygen/double,
					SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/wizard,
					SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
					SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
					SLOT_SHOES = null
				)
	return ..()

/obj/machinery/storage_unit/suit_storage/syndicate_unit/light
	name = "Syndicate Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = null
	)

/obj/machinery/storage_unit/suit_storage/syndicate_unit/light/heavy
	name = "Syndicate Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi/heavy,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = null
	)

/obj/machinery/storage_unit/suit_storage/syndicate_unit/light/chem
	name = "Hazmat Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi/hazmat,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = null
	)

/obj/machinery/storage_unit/suit_storage/syndicate_unit/striker
	name = "Syndicate Striker Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/syndicate/elite,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/syndicate/elite,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/syndie
	)

/obj/machinery/storage_unit/suit_storage/syndicate_unit/elite
	name = "Elite Syndicate Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi/elite,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/rig/syndi/elite,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/syndie
	)

/obj/machinery/storage_unit/suit_storage/syndicate_unit/elite/comander
	name = "Comander Syndicate Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen/harness,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/syndi/elite/comander,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/rig/syndi/elite/comander,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/syndicate,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/syndie
	)

	req_access = list(access_syndicate_commander)

//Sience
/obj/machinery/storage_unit/suit_storage/science
	name = "Science Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/carbondioxide,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/science,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	req_access = list(access_research)
	icon_state = "science"

/obj/machinery/storage_unit/suit_storage/science/rd
	name = "Research Director Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/carbondioxide,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/science/rd,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	req_access = list(access_rd)
	icon_state = "RD"

//Engine
/obj/machinery/storage_unit/suit_storage/engine
	name = "Engineer Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/engineering,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	req_access = list(access_engine)
	icon_state = "engineer"

/obj/machinery/storage_unit/suit_storage/engine/atmos
	name = "Atmospheric Hardsuit Storage Unit"
	req_access = list(access_atmospherics)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/atmos,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	icon_state = "atmos"

/obj/machinery/storage_unit/suit_storage/engine/chief
	name = "Chief Engineer Hardsuit Storage Unit"
	req_access = list(access_ce)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/engineering/chief,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	icon_state = "CE"

//Security
/obj/machinery/storage_unit/suit_storage/security
	name = "Security Officer Hardsuit Storage Unit"
	req_access = list(access_security)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/security,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/sechailer,
		SLOT_SHOES = null
	)

	icon_state = "security"

/obj/machinery/storage_unit/suit_storage/security/hos
	name = "Head of Security Hardsuit Storage Unit"
	req_access = list(access_hos)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/security/hos,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/sechailer,
		SLOT_SHOES = null
	)
	icon_state = "HOS"

//Medical
/obj/machinery/storage_unit/suit_storage/medical
	name = "Medical Hardsuit Storage Unit"
	req_access = list(access_medbay_storage)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/medical,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	icon_state = "med"

/obj/machinery/storage_unit/suit_storage/medical/paramedic
	name = "Paremedic Hardsuit Storage Unit"
	req_access = list(access_paramedic)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/medical,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

/obj/machinery/storage_unit/suit_storage/medical/cmo
	name = "Chief Medical Officer Hardsuit Storage Unit"
	req_access = list(access_cmo)

	contents_by_slot = alist(
		SLOT_S_STORE = null,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/medical/cmo,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	icon_state = "CMO"

//Other
/obj/machinery/storage_unit/suit_storage/globose
	name = "Civil Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/carbondioxide,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/globose,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/globose,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

/obj/machinery/storage_unit/suit_storage/globose/science
	name = "Science Space Suit Storage Unit"
	req_access = list(access_research)

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/globose/science,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/globose/science,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

/obj/machinery/storage_unit/suit_storage/globose/science/xenoarchaeologist
	name = "Xenoarchaeologist Space Suit Storage Unit"

/obj/machinery/storage_unit/suit_storage/globose/mining
	name = "Mining Space Suit Storage Unit"
	req_access = list(access_mining)

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/globose/mining,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/globose/mining,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	icon_state = "miner"

/obj/machinery/storage_unit/suit_storage/globose/skrell
	can_build = FALSE

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = null,
		SLOT_HEAD =  /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

/obj/machinery/storage_unit/suit_storage/globose/skrell/white
	name = "White Skrellian Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/skrell/white,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/skrell/white,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

/obj/machinery/storage_unit/suit_storage/globose/skrell/black
	name = "Black Skrellian Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/skrell/black,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/skrell/black,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

/obj/machinery/storage_unit/suit_storage/unathi
	name = "NT Unathi Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/unathi/rig_cheap,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/unathi/helmet_cheap,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	icon_state = "unathi"

/obj/machinery/storage_unit/suit_storage/unathi/breacher
	name = "Breacher Unathi Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/unathi/breacher,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/unathi/breacher,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	can_build = FALSE
	req_access = list(access_captain)

/obj/machinery/storage_unit/suit_storage/captain
	name = "Captain Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/oxygen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/armor/captain,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/capspace,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	req_access = list(access_captain)
	icon_state = "captain"

/obj/machinery/storage_unit/suit_storage/nasa
	name = "NASA Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/jetpack/void,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/nasavoid,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/nasavoid,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots
	)

	req_access = list(access_minisat)
	icon_state = "NASA"

/obj/machinery/storage_unit/suit_storage/wizard
	can_build = FALSE
	name = "Strange Hardsuit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/emergency_oxygen/double,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/rig/wizard,
		SLOT_HEAD = null,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/coloured,
		SLOT_SHOES = null
	)

	req_access = list(access_syndicate)

	icon_state = "mage"

/obj/machinery/storage_unit/suit_storage/vox
	can_build = FALSE
	req_access = list(access_syndicate)

/obj/machinery/storage_unit/suit_storage/vox/carapace
	name = "Vox Carapace Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/nitrogen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/vox/carapace,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/vox/carapace,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/vox,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/vox
	)

/obj/machinery/storage_unit/suit_storage/vox/medic
	name = "Vox Alien Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/nitrogen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/vox/medic,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/vox/medic,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/vox,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/vox
	)

/obj/machinery/storage_unit/suit_storage/vox/stealth
	name = "Vox Stealth Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/nitrogen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/vox/stealth,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/vox/stealth,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/vox,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/vox
	)

/obj/machinery/storage_unit/suit_storage/vox/engine
	name = "Vox Engineer Suit Storage Unit"

	contents_by_slot = alist(
		SLOT_S_STORE = /obj/item/weapon/tank/nitrogen,
		SLOT_WEAR_SUIT = /obj/item/clothing/suit/space/vox/pressure,
		SLOT_HEAD = /obj/item/clothing/head/helmet/space/vox/pressure,
		SLOT_WEAR_MASK = /obj/item/clothing/mask/breath/gas/vox,
		SLOT_SHOES = /obj/item/clothing/shoes/magboots/vox
	)
