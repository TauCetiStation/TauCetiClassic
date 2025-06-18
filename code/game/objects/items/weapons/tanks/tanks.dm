#define TANK_MIN_RELEASE_PRESSURE 0
#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	w_class = SIZE_SMALL

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	max_integrity = 200
	resistance_flags = CAN_BE_HIT

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	var/internal_switch = 0
						//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.

	var/reaction_in_progress = FALSE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_internals)

/obj/item/weapon/tank/atom_init()
	. = ..()

	air_contents = new
	air_contents.volume = volume //liters
	air_contents.temperature = T20C

	START_PROCESSING(SSobj, src)

/obj/item/weapon/tank/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(air_contents)
	return ..()

/datum/action/item_action/hands_free/toggle_internals
	name = "Toggle internals"

/datum/action/item_action/hands_free/toggle_internals/Activate()
	var/obj/item/weapon/tank/T = target
	T.toggle_internals()

/obj/item/weapon/tank/examine(mob/user)
	..()
	var/obj/O = src
	if (istype(src.loc, /obj/item/assembly))
		O = src.loc
	if (!in_range(src, usr))
		if (O == src)
			to_chat(user, "<span class='notice'>If you want any more information you'll need to get closer.</span>")
		return

	var/celsius_temperature = src.air_contents.temperature-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	to_chat(user, "<span class='notice'>[bicon(src)] \The [src] feels [descriptive].</span>")

/obj/item/weapon/tank/blob_act()
	if(prob(50))
		var/turf/location = loc
		if(!isturf(location))
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/weapon/tank/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/analyzer))
		return

	else if (istype(I,/obj/item/latexballon))
		var/obj/item/latexballon/LB = I
		LB.blow(src)
		add_fingerprint(user)

	else if(istype(I, /obj/item/device/assembly_holder))
		bomb_assemble(I, user)
		return

	else
		return ..()

/obj/item/weapon/tank/attack_self(mob/user)
	if (!(src.air_contents))
		return

	ui_interact(user)

/obj/item/weapon/tank/ui_interact(mob/user)
	tgui_interact(user)

/obj/item/weapon/tank/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()


/obj/item/weapon/tank/tgui_data(mob/user)
	var/list/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(TANK_MIN_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["connected"] = FALSE

	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(!istype(C))
		return data

	if(C.internal == src)
		data["connected"] = TRUE

	return data

/obj/item/weapon/tank/tgui_state(mob/user)
	return global.physical_state

/obj/item/weapon/tank/tgui_act(action, params)
	. = ..()
	if(.)
		return
	add_fingerprint(usr)
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)
		if("internal")
			toggle_internals()

/obj/item/weapon/tank/proc/toggle_internals()
	if(!iscarbon(loc))
		return
	if(internal_switch > world.time)
		return
	var/internalsound
	var/mob/living/carbon/C = loc
	if(C.internal == src)
		C.internal = null
		to_chat(usr, "<span class='notice'>You close the tank release valve.</span>")
		internalsound = 'sound/misc/internaloff.ogg'
		if(ishuman(C)) // Because only human can wear a spacesuit
			var/mob/living/carbon/human/H = C
			if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
				internalsound = 'sound/misc/riginternaloff.ogg'
		playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)
	else
		if(istype(C.wear_mask, /obj/item/clothing/mask/breath))
			var/obj/item/clothing/mask/breath/M = C.wear_mask
			if(M.hanging) // if mask on face but pushed down
				M.attack_self() // adjust it back
		if(C.wear_mask && (C.wear_mask.flags & MASKINTERNALS))
			C.internal = src
			to_chat(usr, "<span class='notice'>You open \the [src] valve.</span>")
			internalsound = 'sound/misc/internalon.ogg'
			if(ishuman(C)) // Because only human can wear a spacesuit
				var/mob/living/carbon/human/H = C
				if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
					internalsound = 'sound/misc/riginternalon.ogg'
			playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)
		else
			to_chat(usr, "<span class='notice'>You need something to connect to \the [src].</span>")
	internal_switch = world.time + 16
	update_actions_icons(C)

/obj/item/weapon/tank/proc/update_actions_icons(mob/living/carbon/T)
	for(var/datum/action/item_action/hands_free/toggle_internals/TI in T.actions)
		if(T.internal == src)
			TI.background_icon_state = "bg_active"
		else
			TI.background_icon_state = "bg_default"

/obj/item/weapon/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/weapon/tank/return_air()
	return air_contents

/obj/item/weapon/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/weapon/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	return remove_air(moles_needed)

/obj/item/weapon/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()

/obj/item/weapon/tank/deconstruct(disassembled)
	var/turf/location = get_turf(loc)
	if(!isturf(location))
		return ..()

	if(air_contents)
		location.assume_air(air_contents)

	return ..()

/obj/item/weapon/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
		reaction_in_progress = TRUE

		if(!istype(src.loc,/obj/item/device/transfer_valve))
			message_admins("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast]. [ADMIN_JMP(src)]")
			log_game("Explosive tank rupture! last key to touch the tank was [src.fingerprintslast].")
		//world << "<span class='notice'>[x],[y] tank is exploding: [pressure] kPa</span>"
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react()
		air_contents.react()
		air_contents.react()
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)

		//world << "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>"

		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range))

		reaction_in_progress = FALSE
		if(istype(loc, /obj/item/device/transfer_valve)) // bomb, valve should handle deletion
			var/obj/item/device/transfer_valve/TV = loc
			qdel(TV)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE)
		//world << "<span class='notice'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>"
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src, 'sound/effects/spray.ogg', VOL_EFFECTS_MASTER, 10, FALSE, null, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		//world << "<span class='notice'>[x],[y] tank is leaking: [pressure] kPa, integrity [integrity]</span>"
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++

// todo, need to add detonation/gas release. currently /obj/item/ex_act explosion just deletes things
/obj/item/weapon/tank/ex_act(severity)
	if(reaction_in_progress) // give it time to explode
		return

	return ..()

#undef TANK_MIN_RELEASE_PRESSURE
#undef TANK_MAX_RELEASE_PRESSURE
#undef TANK_DEFAULT_RELEASE_PRESSURE
