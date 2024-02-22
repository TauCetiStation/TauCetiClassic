// Areas.dm



// ===
/area
	name = "Space"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	//Keeping this on the default plane, GAME_PLANE, will make area overlays fail to render on FLOOR_PLANE.
	plane = AREA_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	luminosity = 0
	var/dynamic_lighting = TRUE

	var/static/global_uid = 0
	var/uid

	var/parallax_movedir = 0

	var/fire = null
	var/atmos = 1
	var/atmosalm = 0
	var/poweralm = FALSE
	var/party = null
	var/lightswitch = 1
	var/valid_territory = 1 //If it's a valid territory for gangs to claim or religion capture

	var/eject = null

	var/requires_power = 1
	var/always_unpowered = 0	//this gets overriden to 1 for space in area/New()

	var/power_equip = 1
	var/power_light = 1
	var/power_environ = 1

	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0
	var/static_equip
	var/static_light = 0
	var/static_environ

	var/datum/religion/religion

	var/has_gravity = 1
	var/obj/machinery/power/apc/apc = null
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = 0

	var/list/canSmoothWithAreas //typecache to limit the areas that atoms in this area can smooth with

	var/sound_environment = SOUND_AREA_DEFAULT // Used to decide what kind of reverb the area makes sound have

	var/looped_ambience = null
	var/is_force_ambience = FALSE
	var/ambience = list(
		'sound/ambience/general_1.ogg',
		'sound/ambience/general_2.ogg',
		'sound/ambience/general_3.ogg',
		'sound/ambience/general_4.ogg',
		'sound/ambience/general_5.ogg',
		'sound/ambience/general_6.ogg',
		'sound/ambience/general_7.ogg',
		'sound/ambience/general_8.ogg',
		'sound/ambience/general_9.ogg',
		'sound/ambience/general_10.ogg',
		'sound/ambience/general_11.ogg',
		'sound/ambience/general_12.ogg'
	)

	/// All beauty in this area combined, only includes indoor area.
	var/totalbeauty = 0
	/// Beauty average per open turf in the area
	var/beauty = 0
	/// If a room is too big it doesn't have beauty.
	var/beauty_threshold = BEAUTY_MAX_AREA_SIZE

	/// For space, the asteroid, lavaland, etc. Used with blueprints or with weather to determine if we are adding a new area (vs editing a station room)
	var/outdoors = FALSE

	/// Size of the area in open turfs, only calculated for indoors areas.
	var/areasize = 0

	/// Bonus mood for being in this area
	var/mood_bonus = 0
	/// Mood message for being here, only shows up if mood_bonus != 0
	var/mood_message = "<span class='nicegreen'>This area is pretty nice!</span>\n"
	/// Does the mood bonus require a trait?
	var/mood_trait

/*Adding a wizard area teleport list because motherfucking lag -- Urist*/
/*I am far too lazy to make it a proper list of areas so I'll just make it run the usual telepot routine at the start of the game*/
var/global/list/teleportlocs = list()

/proc/process_teleport_locs()
	for(var/area/AR in all_areas)
		if(istype(AR, /area/shuttle) || istype(AR, /area/shuttle/syndicate) || istype(AR, /area/custom/wizard_station) || istype(AR, /area/station/engineering/singularity))
			continue
		if(teleportlocs.Find(AR.name))
			continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (is_station_level(picked.z))
			teleportlocs += AR.name
			teleportlocs[AR.name] = AR
	teleportlocs = sortAssoc(teleportlocs)


var/global/list/ghostteleportlocs = list()

/proc/process_ghost_teleport_locs()
	for(var/area/AR in all_areas)
		if(ghostteleportlocs.Find(AR.name))
			continue
		if(istype(AR, /area/station/aisat/antechamber) || istype(AR, /area/space_structures/derelict) || istype(AR, /area/centcom/tdome) || istype(AR, /area/custom/cult))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (is_station_level(picked.z) || is_mining_level(picked.z))
			ghostteleportlocs += AR.name
			ghostteleportlocs[AR.name] = AR
	ghostteleportlocs = sortAssoc(ghostteleportlocs)

/area/New() // not ready for transfer, problems with alarms raises if this part moved into init (requires more time)
	icon_state = ""
	uid = ++global_uid
	all_areas += src
	areas_by_type[type] = src

	if(!requires_power)
		power_light = 0
		power_equip = 0
		power_environ = 0

	..()

/area/atom_init()
	canSmoothWithAreas = typecacheof(canSmoothWithAreas)

	..()

	if(!dynamic_lighting)
		luminosity = 1
		add_overlay(area_unsimulated_light_mask)

	update_areasize()
	power_change() // all machines set to current power level, also updates lighting icon

	return INITIALIZE_HINT_LATELOAD

/area/atom_init_late()
	update_beauty()

/**
 * Set the area size of the area
 *
 * This is the number of open turfs in the area contents, or FALSE if the outdoors var is set
 *
 */
/area/proc/update_areasize()
	if(outdoors)
		return FALSE
	areasize = 0
	for(var/turf/simulated/floor/F in contents)
		areasize++

/// Divides total beauty in the room by roomsize to allow us to get an average beauty per tile.
/area/proc/update_beauty()
	if(!areasize)
		beauty = 0
		return FALSE

	if(areasize >= beauty_threshold)
		beauty = 0
		return FALSE

	beauty = totalbeauty / areasize

/area/proc/poweralert(state, obj/source)
	if (state != poweralm)
		poweralm = state
		// Only report power alarms on the z-level where the source is located.
		if(istype(source))
			var/list/cameras = list()
			for (var/obj/machinery/camera/C in src)
				cameras += C
				if(state)
					C.add_network("Power Alarms")
				else
					C.remove_network("Power Alarms")
			for (var/mob/living/silicon/aiPlayer as anything in silicon_list)
				if(!aiPlayer.client)
					continue
				if(aiPlayer.z == source.z)
					if(state)
						aiPlayer.triggerAlarm("Power", src, cameras, source)
					else
						aiPlayer.cancelAlarm("Power", src, source)
			for(var/obj/machinery/computer/station_alert/a in station_alert_list)
				if(a.z == source.z)
					if(state)
						a.triggerAlarm("Power", src, cameras, source)
					else
						a.cancelAlarm("Power", src, source)

/area/proc/atmosalert(danger_level)
	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for(var/obj/machinery/alarm/AA in src)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
			danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if(danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()

		if(danger_level < 2 && atmosalm >= 2)
			for(var/obj/machinery/camera/C in src)
				C.remove_network("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer as anything in silicon_list)
				if(!aiPlayer.client)
					continue
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in station_alert_list)
				a.cancelAlarm("Atmosphere", src, src)

		if(danger_level >= 2 && atmosalm < 2)
			for(var/obj/machinery/alarm/AA in src)
				if(AA.hidden_from_console)
					continue
				var/list/cameras = list()
				for(var/obj/machinery/camera/C in src)
					cameras += C
					C.add_network("Atmosphere Alarms")
				for(var/mob/living/silicon/aiPlayer as anything in silicon_list)
					if(!aiPlayer.client)
						continue
					aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
				for(var/obj/machinery/computer/station_alert/a in station_alert_list)
					a.triggerAlarm("Atmosphere", src, cameras, src)
			air_doors_close()

		atmosalm = danger_level
		for(var/obj/machinery/alarm/AA in src)
			AA.update_icon()

		return TRUE
	return FALSE

/area/proc/air_doors_close()
	if(!air_doors_activated)
		air_doors_activated = 1
		for(var/obj/machinery/door/firedoor/E in all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = CLOSED
				else if(!E.density)
					INVOKE_ASYNC(E, TYPE_PROC_REF(/obj/machinery/door/firedoor, close))

/area/proc/air_doors_open()
	if(air_doors_activated)
		air_doors_activated = 0
		for(var/obj/machinery/door/firedoor/E in all_doors)
			if(!E.blocked)
				if(E.operating)
					E.nextstate = OPEN
				else if(E.density)
					INVOKE_ASYNC(E, TYPE_PROC_REF(/obj/machinery/door/firedoor, open))

/area/proc/airlocks_close(bolt_after = FALSE)
	for(var/obj/machinery/door/airlock/A in src)
		A.close_unsafe(bolt_after)

/area/proc/firealert()
	if(name == "Space") //no fire alarms in space
		return
	if( !fire )
		fire = 1 // used for firedoor checks
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/firedoor, close))
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras.Add(C)
			C.add_network("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
			if(!aiPlayer.client)
				continue
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in station_alert_list)
			a.triggerAlarm("Fire", src, cameras, src)

/area/proc/firereset()
	if(fire)
		fire = 0 // used for firedoor checks
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/firedoor, open))
		for (var/obj/machinery/camera/C in src)
			C.remove_network("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
			if(!aiPlayer.client)
				continue
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in station_alert_list)
			a.cancelAlarm("Fire", src, src)

/area/proc/partyalert()
	if(name == "Space") //no parties in space!!!
		return
	if(!party)
		party = 1
		updateicon()
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return

/area/proc/partyreset()
	if(party)
		party = 0
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					INVOKE_ASYNC(D, TYPE_PROC_REF(/obj/machinery/door/firedoor, open))
	return

/area/proc/updateicon()
	icon_state = null


/area/proc/powered(chan)		// return true if the area has power to given channel
	if(!requires_power)
		return TRUE
	if(always_unpowered)
		return FALSE
	switch(chan)
		if(STATIC_EQUIP)
			return power_equip
		if(STATIC_LIGHT)
			return power_light
		if(STATIC_ENVIRON)
			return power_environ

	return FALSE

// called when power status changes
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change() // reverify power status (to update icons etc.)
	for(var/obj/item/device/radio/intercom/I in src) // Intercoms are not machinery so we need a different loop
		I.power_change()
	if (fire || eject || party)
		updateicon()

/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(TOTAL)
			used += static_light + static_equip + static_environ + used_equip + used_light + used_environ
		if(STATIC_EQUIP)
			used += static_equip + used_equip
		if(STATIC_LIGHT)
			used += static_light + used_light
		if(STATIC_ENVIRON)
			used += static_environ + used_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/removeStaticPower(value, powerchannel)
	addStaticPower(-value, powerchannel)

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(amount, chan)
	switch(chan)
		if(STATIC_EQUIP)
			used_equip += amount
		if(STATIC_LIGHT)
			used_light += amount
		if(STATIC_ENVIRON)
			used_environ += amount

/**
 * Call back when an atom enters an area
 *
 * Sends signals COMSIG_AREA_ENTERED and COMSIG_ENTER_AREA (to the atom)
 * Sends signals COMSIG_AREA_ENTERED and COMSIG_ENTER_AREA (to a list of atoms)
 *
 * If the area has ambience, then it plays some ambience music to the ambience channel
 */
/area/Entered(atom/movable/A, atom/OldLoc)
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, A, OldLoc)
	for(var/atom/movable/recipient in A.area_sensitive_contents)
		SEND_SIGNAL(recipient, COMSIG_ENTER_AREA, src, OldLoc)

	if (!isliving(A))
		return

	var/mob/living/L = A
	if (!L.ckey)
		return

	if (!L.lastarea)
		L.lastarea = get_area(L.loc)

	var/area/new_area = get_area(L.loc)
	var/area/old_area = L.lastarea

	//Jukebox
	if (new_area != old_area)
		if (L.client)
			L.update_music()

	L.lastarea = new_area

	// Being ready when you change areas gives you a chance to avoid falling all together.
	if ((old_area.has_gravity == FALSE) && (new_area.has_gravity == TRUE) && (L.m_intent == MOVE_INTENT_RUN))
		thunk(L)

	if (!L.client || old_area == src)
		return

	if (looped_ambience == null)
		L.client.sound_old_looped_ambience = null
		L.playsound_stop(CHANNEL_AMBIENT_LOOP)
	else if (L.client.sound_old_looped_ambience != looped_ambience)
		L.client.sound_old_looped_ambience = looped_ambience
		L.playsound_music(looped_ambience, VOL_AMBIENT, TRUE, null, CHANNEL_AMBIENT_LOOP)

	if (!compare_list(old_area.ambience, new_area.ambience))
		L.playsound_stop(CHANNEL_AMBIENT)

	if (ambience != null && (is_force_ambience || (prob(50) && L.client.sound_next_ambience_play <= world.time)))
		L.client.sound_next_ambience_play = world.time + rand(3, 6) MINUTES
		L.playsound_music(pick(ambience), VOL_AMBIENT, null, null, CHANNEL_AMBIENT)

/**
  * Called when an atom exits an area
  *
  * Sends signals COMSIG_AREA_EXITED and COMSIG_EXIT_AREA (to the atom)
  * Sends signals COMSIG_AREA_EXITED and COMSIG_EXIT_AREA (to a list of atoms)
  */
/area/Exited(atom/movable/A, atom/NewLoc)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, A, NewLoc)
	for(var/atom/movable/recipient in A.area_sensitive_contents)
		SEND_SIGNAL(recipient, COMSIG_EXIT_AREA, src, NewLoc)

/area/proc/gravitychange(gravitystate = FALSE)
	has_gravity = gravitystate
	if(gravitystate)
		for(var/mob/living/carbon/human/H in src)
			thunk(H)

/area/proc/thunk(mob)
	if(isspaceturf(get_turf(mob))) // Can't fall onto nothing.
		return

	if(ishuman(mob))  // Only humans can wear magboots, so we give them a chance to.
		var/mob/living/carbon/human/H = mob
		if((istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP)))
			return
		if((istype(H.wear_suit, /obj/item/clothing/suit/space/rig) && (H.wear_suit.flags & NOSLIP))) //Humans in rig with turn on magboots
			return

		if(H.m_intent == "run")
			H.AdjustStunned(2)
			H.AdjustWeakened(2)
		else
			H.AdjustStunned(1)
			H.AdjustWeakened(1)
		to_chat(mob, "<span class='notice'>The sudden appearance of gravity makes you fall to the floor!</span>")

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	if(isspaceturf(T)) // Turf never has gravity
		return FALSE
	var/area/A = get_area(T)
	return A?.has_gravity // Areas which always has gravity
