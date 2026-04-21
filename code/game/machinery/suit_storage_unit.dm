//////////////////////////////////////
// SUIT STORAGE UNIT /////////////////
//////////////////////////////////////
/obj/machinery/suit_storage_unit
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\"."
	icon = 'icons/obj/suitstorage.dmi'
	icon_state = "suitholder"
	damage_deflection = 25
	var/ignore = FALSE
	anchored = TRUE
	density = TRUE
	var/syndie = FALSE
	var/powered = TRUE //starts powered
	var/opened = FALSE
	var/locked = TRUE
	var/broken = FALSE
	var/overlay_color = null
//ultra violet stat
	var/UV = FALSE
	var/superUV = FALSE
	var/cycletime_left = null

/*
Erro's idea on standarising SSUs whle keeping creation of other SSU types easy:
Make a child SSU, name it something then set the TYPE vars to your desired suit output. New() should take it from there by itself.
*/
	var/fulled = FALSE
	var/helmet_type = null
	var/mask_type   = null
	var/suit_type   = null
	var/boot_type  = null
	var/tank_type   = null
/*
All the stuff that's gonna be stored insiiiiiiiiiiiiiiiiiiide, nyoro~n
*/
	var/obj/item/clothing/suit/space/SUIT = null
	var/obj/item/clothing/head/helmet/space/HELMET = null
	var/obj/item/clothing/mask/MASK = null
	var/obj/item/clothing/shoes/magboots/BOOTS = null
	var/obj/item/weapon/tank/oxygen/TANK = null

/obj/machinery/suit_storage_unit/atom_init()
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/circuitboard/suit_storage(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 3)

	RefreshParts()

	if(fulled)
		if(suit_type)
			SUIT   = new suit_type(src)
		if(helmet_type)
			HELMET = new helmet_type(src)
		if(mask_type)
			MASK   = new mask_type(src)
		if(boot_type)
			BOOTS  = new boot_type(src)
		if(tank_type)
			TANK   = new tank_type(src)
	set_power_use(IDLE_POWER_USE)
	update_icon()

/obj/machinery/suit_storage_unit/update_icon()
	cut_overlays()
	if(locate(/obj/machinery/suit_storage_unit) in get_step(src, WEST))
		var/image/connector_color = image('icons/obj/suitstorage.dmi',icon_state = "left_connect")
		if(overlay_color)
			connector_color.color = overlay_color
		add_overlay(connector_color)
	if(locate(/obj/machinery/suit_storage_unit) in get_step(src, EAST))
		var/image/connector_color = image('icons/obj/suitstorage.dmi',icon_state = "right_connect")
		if(overlay_color)
			connector_color.color = overlay_color
		add_overlay(connector_color)

	if(!ishardsuit(SUIT))
		if(SUIT)
			add_overlay("suit")
		if(HELMET)
			add_overlay("helmet")
		if(BOOTS)
			add_overlay("boots")
	else
		var/obj/item/clothing/suit/space/rig/RIG_SUIT = SUIT
		if(RIG_SUIT?.helmet)
			add_overlay("suit&helmet")
		else
			if(SUIT)
				add_overlay("suit")
			if(HELMET)
				add_overlay("helmet")
		if(RIG_SUIT?.boots)
			add_overlay("boots")
		else if(BOOTS)
			add_overlay("boots")

	var/image/door_I = image('icons/obj/suitstorage.dmi',icon_state = "[opened ? "door_open" : "door_closed"]")
	var/image/unit_color = image('icons/obj/suitstorage.dmi',icon_state = "[broken ? "suitholder_broken_color" : "suitholder_color"]")
	if(overlay_color)
		door_I.color = overlay_color
		unit_color.color = overlay_color
		add_overlay(unit_color)
	if(!opened && !broken)
		add_overlay(door_I)
		if(locked && !emagged && !UV)
			add_overlay("lock_closed")
		else
			add_overlay("lock_open")
	else
		add_overlay(door_I)
	if(broken)
		icon_state = "suitholder_broken"

	if(UV && !superUV)
		add_overlay(door_I)
		add_overlay("lock_closed")
		add_overlay("termalclean")
		return
	else if(UV && superUV)
		add_overlay(door_I)
		add_overlay("lock_closed")
		add_overlay("termalclean_emag")
		return
	if(panel_open)
		add_overlay("panel_open")

/obj/machinery/suit_storage_unit/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			if(prob(50))
				dump_everything() //So suits dont survive all the time
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				dump_everything()
				qdel(src)

/obj/machinery/suit_storage_unit/proc/dispense_helmet()
	if(!HELMET)

		return
	else
		HELMET.forceMove(get_turf(src))
		HELMET = null
		return

/obj/machinery/suit_storage_unit/proc/dispense_suit()
	if(!SUIT)
		return
	else
		SUIT.forceMove(get_turf(src))
		SUIT = null
		return

/obj/machinery/suit_storage_unit/proc/dispense_boots()
	if(!BOOTS)
		return
	else
		BOOTS.forceMove(get_turf(src))
		BOOTS = null
		return

/obj/machinery/suit_storage_unit/proc/dispense_mask()
	if(!MASK)
		return
	else
		MASK.forceMove(get_turf(src))
		MASK = null
		return

/obj/machinery/suit_storage_unit/proc/dispense_tank()
	if(!TANK)
		return
	else
		TANK.forceMove(get_turf(src))
		TANK = null
		return

/obj/machinery/suit_storage_unit/proc/dump_everything()
	dispense_suit()
	dispense_boots()
	dispense_helmet()
	dispense_tank()
	dispense_mask()
	eject_occupant(occupant)
	return

/obj/machinery/suit_storage_unit/proc/open(mob/user)
	if(opened)
		return
	if(locked || UV)
		to_chat(user, "<span class ='danger'>Unable to opened unit.</span>")
		return
	opened = TRUE
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/close()
	if(!opened)
		return
	opened = FALSE
	playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/toggle_lock(mob/user)
	if(occupant && !superUV)
		to_chat(user, "<span class ='danger'>The Unit's safety protocols disallow locking when a biological form is detected inside its compartments.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The [src] appears to be broken.</span>")
		return
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return
	if(allowed(user))
		locked = !locked
		visible_message("<span class='notice'>The [src] been [locked ? null : "un"]locked by [user].</span>")
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")
	return

/obj/machinery/suit_storage_unit/proc/start_UV(mob/user)
	if(occupant && !superUV)
		to_chat(user, "<span class = 'danger'><B>WARNING:</B> Biological entity detected in the confines of the Unit's storage. Cannot initiate cycle.</span>")
		return
	if(!HELMET && !MASK && !SUIT && !BOOTS && !TANK && !occupant)
		to_chat(user, "<span class ='danger'>Unit storage bays empty. Nothing to disinfect -- Aborting.</span>")
		return
	to_chat(user, "You start the Unit's cauterisation cycle.")
	if(opened)
		opened = FALSE
	if(!locked)
		locked = TRUE
	UV = TRUE
	update_icon()
	UV_cleaning()

/obj/machinery/suit_storage_unit/proc/UV_cleaning()
	if(!superUV)
		cycletime_left = 5
	else
		cycletime_left = 25
	while(cycletime_left)
		cycletime_left--
		sleep(10)

		if(occupant)
			if(superUV)
				occupant.adjustFireLoss(rand(5, 15))
		if(!cycletime_left)
			if(!superUV)
				if(HELMET)
					HELMET.clean_blood()
				if(SUIT)
					SUIT.clean_blood()
				if(MASK)
					MASK.clean_blood()
				if(TANK)
					TANK.clean_blood()
				if(BOOTS)
					BOOTS.clean_blood()
			else
				if(occupant)
					occupant.dust()
					occupant = null
				else
					if(HELMET)
						HELMET = null
					if(SUIT)
						SUIT   = null
					if(MASK)
						MASK   = null
					if(TANK)
						TANK   = null
					if(BOOTS)
						BOOTS  = null
				broken = TRUE
				visible_message("<span class ='danger'>With a loud whining noise, the Suit Storage Unit's door grinds opened. Puffs of ashen smoke come out of its chamber.</span>", 3)

	opened = TRUE
	locked = FALSE
	UV = FALSE //Cycle ends
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/eject_occupant()
	if(locked)
		return
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant = null
	if(!opened)
		opened = TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	return

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
			opened = TRUE
			locked = FALSE
			visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
	eject_occupant(user)
	add_fingerprint(user)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/move_into_unit(mob/mobToMove, mob/user, obj/item/G)
	if(!opened)
		to_chat(user, "<span class ='danger'>The unit's doors are shut.</span>")
		return
	if(occupant || HELMET || SUIT || TANK || BOOTS)
		to_chat(user, "<span class ='danger'>It's too cluttered inside for you to fit in!</span>")
		return
	if(user.is_busy())
		return
	visible_message("[user] starts squeezing into the suit storage unit!", 3)
	if(do_after(user, 5 SECOND, target = src))
		mobToMove.stop_pulling()
		mobToMove.loc = src
		occupant = mobToMove
		G ? qdel(G) : null
		add_fingerprint(user)
		update_icon()
		return

/obj/machinery/suit_storage_unit/MouseDrop_T(atom/dropping, mob/user)
	add_fingerprint(user)
	if(opened)
		if(dropping != user)
			return
		move_into_unit(dropping, user)
		return

/obj/machinery/suit_storage_unit/AltClick(mob/user)
	add_fingerprint(user)
	if(UV)
		return
	if(!allowed(user))
		to_chat(user, "<span class='notice'>Access Denied</span>")
		return
	if(!opened && !locked)
		start_UV(user)

/obj/machinery/suit_storage_unit/CtrlClick(mob/user)
	add_fingerprint(user)
	if(!powered || broken)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(UV)
		return
	opened ? close() : open(user)
	update_icon()

/obj/machinery/suit_storage_unit/attack_hand(mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if(!powered || broken)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return
	if(UV)
		return

	if(opened)
		var/list/suit_storage = list()
		if(!occupant)
			if(HELMET)
				suit_storage += list("Helmet" = image(icon = HELMET.icon, icon_state = HELMET.icon_state))
			if(SUIT)
				suit_storage += list("Suit" = image(icon = SUIT.icon, icon_state = SUIT.icon_state))
			if(BOOTS)
				suit_storage += list("Boots" = image(icon = BOOTS.icon, icon_state = BOOTS.icon_state))
			if(TANK)
				suit_storage += list("Tank" = image(icon = TANK.icon, icon_state = TANK.icon_state))
			if(MASK)
				suit_storage += list("Mask" = image(icon = MASK.icon, icon_state = MASK.icon_state))
		else
			suit_storage += list("Somebody" = image(getFlatIcon(occupant)))

		var/to_dispense = show_radial_menu(user, src, suit_storage, require_near = TRUE, tooltips = TRUE)
		if(to_dispense)
			switch(to_dispense)
				if("Helmet")
					dispense_helmet()
				if("Suit")
					dispense_suit()
				if("Boots")
					dispense_boots()
				if("Tank")
					dispense_tank()
				if("Mask")
					dispense_mask()
				if("Somebody")
					eject_occupant()
			update_icon()
			return

	if(!locked)
		opened ? close() : open(user)
		update_icon()
		return

/obj/machinery/suit_storage_unit/attackby(obj/item/I, mob/user)
	if(UV)
		return
	if(!powered || broken)
		to_chat(usr, "<span class ='danger'>The unit is not operational.</span>")
		return

	if(opened && !occupant)
		if(isscrewing(I))
			if(default_deconstruction_screwdriver(user, "suitholder_o", "suitholder", I))
				return
		if(isprying(I))
			if(default_deconstruction_crowbar(I))
				return
	if(!opened)
		if(istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
			if(allowed(usr))
				toggle_lock(user)
	if(opened)
		if(istype(I, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = I
			if(!ismob(G.affecting) || G.state < GRAB_AGGRESSIVE)
				return
			var/mob/M = G.affecting
			move_into_unit(M, user, G)
			return
		if(isspacesuit(I) || isspacehelmet(I) || isbreathmask(I) || ismagboots(I) || istank(I))
			load_something(I, user)
	update_icon()
	return

/obj/machinery/suit_storage_unit/proc/load_something(obj/something, mob/user)
	if(occupant)
		to_chat(usr, "<span class ='danger'>It's too cluttered inside for add something else!</span>")
		return
	if(isspacesuit(something))
		var/obj/item/clothing/suit/space/S = something
		if(SUIT)
			to_chat(user, "<span class ='succsess'>The unit already contains a suit.</span>")
			return
		to_chat(user, "You load the [S.name] into the storage compartment.")
		user.drop_from_inventory(S, src)
		SUIT = S
	if(isspacehelmet(something))
		var/obj/item/clothing/head/helmet/H = something
		if(HELMET)
			to_chat(user, "<span class ='succsess'>The unit already contains a helmet.</span>")
			return
		to_chat(user, "You load the [H.name] into the storage compartment.")
		user.drop_from_inventory(H, src)
		HELMET = H
	if(isbreathmask(something))
		var/obj/item/clothing/mask/M = something
		if(MASK)
			to_chat(user, "<span class ='succsess'>The unit already contains a mask.</span>")
			return
		to_chat(user, "You load the [M.name] into the storage compartment.")
		user.drop_from_inventory(M, src)
		MASK = M
	if(ismagboots(something))
		var/obj/item/clothing/shoes/magboots/B = something
		if(BOOTS)
			to_chat(user, "<span class ='succsess'>The unit already contains a magboots.</span>")
			return
		to_chat(user, "You load the [B.name] into the storage compartment.")
		user.drop_from_inventory(B, src)
		BOOTS = B
	if(istank(something))
		var/obj/item/weapon/tank/T = something
		if(TANK)
			to_chat(user, "<span class ='succsess'>The unit already contains a mask.</span>")
			return
		to_chat(user, "You load the [T.name] into the storage compartment.")
		user.drop_from_inventory(T, src)
		TANK = T
	update_icon()
	return

/obj/machinery/suit_storage_unit/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	if(HELMET)
		HELMET.forceMove(loc)
		HELMET = null
	if(SUIT)
		SUIT.forceMove(loc)
		SUIT = null
	if(MASK)
		MASK.forceMove(loc)
		MASK = null
	if(BOOTS)
		BOOTS.forceMove(loc)
		BOOTS = null
	if(TANK)
		TANK.forceMove(loc)
		TANK = null
	eject_occupant(occupant)

	..()

/obj/machinery/suit_storage_unit/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The console controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/suit_storage_unit/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	emagged = TRUE
	superUV = TRUE
	locked = FALSE
	update_icon()
	return TRUE

//The units themselves
//Abandoned
/obj/machinery/suit_storage_unit/abandoned
	name = "Abandoned Storage Unit"
	ignore = TRUE

/obj/machinery/suit_storage_unit/abandoned/atom_init()

	if(prob(50))
		occupant = new /mob/living/simple_animal/hostile/xenomorph/queen(src)
	else
		var/choose = pick(1,2)
		switch(choose)
			if(1)
				suit_type = /obj/item/clothing/suit/space/rig/syndi
				mask_type = /obj/item/clothing/mask/gas/syndicate
				tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
				boot_type = /obj/item/clothing/shoes/magboots/syndie
			if(2)
				suit_type = /obj/item/clothing/suit/space/rig/wizard
				mask_type = /obj/item/clothing/mask/gas/coloured
				tank_type = /obj/item/weapon/tank/emergency_oxygen/double
	return ..()

//Syndicate
/obj/machinery/suit_storage_unit/syndicate_unit
	name = "Syndicate Suit Storage Unit"
	req_access = list(access_syndicate)
	syndie = TRUE
	emagged = TRUE

	overlay_color = COLOR_DARK_GUNMETAL

/obj/machinery/suit_storage_unit/syndicate_unit/gorlex/light
	name = "Syndicate Hardsuit Storage Unit"
	ignore = TRUE
	suit_type = /obj/item/clothing/suit/space/rig/syndi
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/gorlex/heavy
	name = "Syndicate Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/heavy
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/heavy
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/gorlex/chem
	name = "Hazmat Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/syndi/hazmat
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/hazmat
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/striker
	name = "Syndicate Striker Suit Storage Unit"
	ignore = TRUE
	suit_type = /obj/item/clothing/suit/space/syndicate/elite
	helmet_type = /obj/item/clothing/suit/space/syndicate/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
	boot_type = /obj/item/clothing/shoes/magboots/syndie

/obj/machinery/suit_storage_unit/syndicate_unit/elite
	name = "Elite Syndicate Hardsuit Storage Unit"
	ignore = TRUE
	suit_type = /obj/item/clothing/suit/space/rig/syndi/elite
	helmet_type = /obj/item/clothing/head/helmet/space/rig/syndi/elite
	mask_type = /obj/item/clothing/mask/gas/syndicate
	tank_type = /obj/item/weapon/tank/jetpack/oxygen/harness
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
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_VIOLET

/obj/machinery/suit_storage_unit/science/rd
	name = "Researh Director Hardsuit Storage Unit"
	req_access = list(access_rd)
	suit_type = /obj/item/clothing/suit/space/rig/science/rd
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_DARK_PURPLE

//Engine
/obj/machinery/suit_storage_unit/engine
	name = "Engineer Hardsuit Storage Unit"
	req_access = list(access_engine)
	suit_type  = /obj/item/clothing/suit/space/rig/engineering
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/engine/atmos
	name = "Atmospheric Hardsuit Storage Unit"
	req_access = list(access_atmospherics)
	suit_type = /obj/item/clothing/suit/space/rig/atmos
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_TEAL
/obj/machinery/suit_storage_unit/engine/chief
	name = "Chief Engineer Hardsuit Storage Unit"
	req_access = list(access_ce)
	suit_type = /obj/item/clothing/suit/space/rig/engineering/chief
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_TITANIUM

//Security
/obj/machinery/suit_storage_unit/security
	name = "Security Officer Hardsuit Storage Unit"
	req_access = list(access_security)
	suit_type = /obj/item/clothing/suit/space/rig/security
	mask_type = /obj/item/clothing/mask/gas/sechailer
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_CRIMSON

/obj/machinery/suit_storage_unit/security/hos
	name = "Head of Security Hardsuit Storage Unit"
	req_access = list(access_hos)
	suit_type = /obj/item/clothing/suit/space/rig/security/hos
	mask_type = /obj/item/clothing/mask/gas/sechailer
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_CRIMSON_RED

//Medical
/obj/machinery/suit_storage_unit/medical
	name = "Medical Hardsuit Storage Unit"
	req_access = list(access_medbay_storage)
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_CYAN

/obj/machinery/suit_storage_unit/medical/paramedic
	name = "Paremedic Hardsuit Storage Unit"
	req_access = list(access_paramedic)
	suit_type = /obj/item/clothing/suit/space/rig/medical
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/medical/cmo
	name = "Chief Medical Officer Hardsuit Storage Unit"
	req_access = list(access_cmo)
	suit_type = /obj/item/clothing/suit/space/rig/medical/cmo
	mask_type = /obj/item/clothing/mask/gas/coloured
	boot_type = /obj/item/clothing/shoes/magboots

	overlay_color = COLOR_CYAN_BLUE

//Other
/obj/machinery/suit_storage_unit/globose
	suit_type = /obj/item/clothing/suit/space/globose
	helmet_type = /obj/item/clothing/head/helmet/space/globose
	mask_type = /obj/item/clothing/mask/breath
	tank_type = /obj/item/weapon/tank/oxygen
	boot_type = /obj/item/clothing/shoes/magboots

/obj/machinery/suit_storage_unit/globose/civil
	tank_type = /obj/item/weapon/tank/jetpack/carbondioxide
	overlay_color = COLOR_SILVER

/obj/machinery/suit_storage_unit/globose/science
	name = "Science Space Suit Storage Unit"
	req_access = list(access_research)
	suit_type = /obj/item/clothing/suit/space/globose/science
	helmet_type = /obj/item/clothing/head/helmet/space/globose/science

	overlay_color = COLOR_PINK

/obj/machinery/suit_storage_unit/globose/science/xenoarchaeologist
	name = "Xenoarchaeologist Space Suit Storage Unit"

/obj/machinery/suit_storage_unit/globose/mining
	name = "Mining Space Suit Storage Unit"
	req_access = list(access_mining)
	suit_type = /obj/item/clothing/suit/space/globose/mining
	helmet_type = /obj/item/clothing/head/helmet/space/globose/mining

	overlay_color = COLOR_BROWN

/obj/machinery/suit_storage_unit/skrell
	ignore = TRUE
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
	ignore = TRUE
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
	ignore = TRUE
	name = "Strange Hardsuit Storage Unit"
	suit_type = /obj/item/clothing/suit/space/rig/wizard
	mask_type = /obj/item/clothing/mask/gas/coloured
	tank_type = /obj/item/weapon/tank/emergency_oxygen/double
	req_access = list(access_syndicate)

	overlay_color = COLOR_DARK_PURPLE

/obj/machinery/suit_storage_unit/vox
	ignore = TRUE
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
