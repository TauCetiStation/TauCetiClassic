#define TANK_MAX_RELEASE_PRESSURE (3*ONE_ATMOSPHERE)
#define TANK_DEFAULT_RELEASE_PRESSURE 24

/obj/item/weapon/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	w_class = ITEM_SIZE_NORMAL

	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70
	var/internal_switch = 0
	var/manipulated_by = null		//Used by _onclick/hud/screen_objects.dm internals to determine if someone has messed with our tank or not.
						//If they have and we haven't scanned it with the PDA or gas analyzer then we might just breath whatever they put in it.
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

/obj/item/weapon/tank/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)

	var/using_internal
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal==src)
			using_internal = 1

	// this is the data which will be sent to the ui
	var/data[0]
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)
	data["valveOpen"] = using_internal ? 1 : 0

	data["maskConnected"] = 0
	if(istype(loc,/mob/living/carbon))
		var/mob/living/carbon/location = loc
		if(location.internal == src || (location.wear_mask && (location.wear_mask.flags & MASKINTERNALS)))
			data["maskConnected"] = 1
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "tanks.tmpl", "Tank", 500, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/item/weapon/tank/Topic(href, href_list)
	..()
	if (usr.stat|| usr.restrained())
		return 0
	if (src.loc != usr)
		return 0

	if (href_list["dist_p"])
		if (href_list["dist_p"] == "reset")
			src.distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
		else if (href_list["dist_p"] == "max")
			src.distribute_pressure = TANK_MAX_RELEASE_PRESSURE
		else
			var/cp = text2num(href_list["dist_p"])
			src.distribute_pressure += cp
		src.distribute_pressure = min(max(round(src.distribute_pressure), 0), TANK_MAX_RELEASE_PRESSURE)
	if (href_list["stat"])
		if(iscarbon(loc))
			if(internal_switch > world.time)
				return
			var/internalsound
			var/mob/living/carbon/C = loc
			if(C.internal == src)
				C.internal = null
				C.internals.icon_state = "internal0"
				to_chat(usr, "<span class='notice'>You close the tank release valve.</span>")
				if (C.internals)
					C.internals.icon_state = "internal0"
				internalsound = 'sound/misc/internaloff.ogg'
				if(ishuman(C)) // Because only human can wear a spacesuit
					var/mob/living/carbon/human/H = C
					if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
						internalsound = 'sound/misc/riginternaloff.ogg'
				playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, -5)
			else
				if(C.wear_mask && (C.wear_mask.flags & MASKINTERNALS))
					C.internal = src
					to_chat(usr, "<span class='notice'>You open \the [src] valve.</span>")
					if (C.internals)
						C.internals.icon_state = "internal1"
					internalsound = 'sound/misc/internalon.ogg'
					if(ishuman(C)) // Because only human can wear a spacesuit
						var/mob/living/carbon/human/H = C
						if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
							internalsound = 'sound/misc/riginternalon.ogg'
					playsound(src, internalsound, VOL_EFFECTS_MASTER, null, FALSE, -5)
				else
					to_chat(usr, "<span class='notice'>You need something to connect to \the [src].</span>")
			internal_switch = world.time + 16

	src.add_fingerprint(usr)
	return 1


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

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure
	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	return remove_air(moles_needed)

/obj/item/weapon/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()


/obj/item/weapon/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	if(pressure > TANK_FRAGMENT_PRESSURE)
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
		var/effrange = min(range, MAX_EXPLOSION_RANGE)		// was 8 - - - Changed to a configurable define -- TLE
		var/turf/epicenter = get_turf(loc)

		//world << "<span class='notice'>Exploding Pressure: [pressure] kPa, intensity: [range]</span>"

		explosion(epicenter, round(clamp(range*0.25,effrange*0.25,effrange-2)), round(clamp(range*0.5,effrange*0.5,effrange-1)), round(effrange), round(effrange*1.5))
		qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE)
		//world << "<span class='notice'>[x],[y] tank is rupturing: [pressure] kPa, integrity [integrity]</span>"
		if(integrity <= 0)
			var/turf/simulated/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src, 'sound/effects/spray.ogg', VOL_EFFECTS_MASTER, 10, null, -3)
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
