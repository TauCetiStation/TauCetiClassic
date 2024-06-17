#define AIRLOCK_DEFAULT  0
#define AIRLOCK_CLOSED   1
#define AIRLOCK_CLOSING  2
#define AIRLOCK_OPEN     3
#define AIRLOCK_OPENING  4
#define AIRLOCK_DENY     5
#define AIRLOCK_EMAG     6

#define AIRLOCK_FRAME_CLOSED "closed"
#define AIRLOCK_FRAME_CLOSING "closing"
#define AIRLOCK_FRAME_OPEN "open"
#define AIRLOCK_FRAME_OPENING "opening"

#define AIRLOCK_LIGHT_BOLTS "bolts"
#define AIRLOCK_LIGHT_EMERGENCY "emergency"
#define AIRLOCK_LIGHT_DENIED "denied"
#define AIRLOCK_LIGHT_CLOSED "poweron"
#define AIRLOCK_LIGHT_CLOSING "closing"
#define AIRLOCK_LIGHT_OPEN "poweron_open"
#define AIRLOCK_LIGHT_OPENING "opening"

#define AIRLOCK_LIGHT_POWER 2
#define AIRLOCK_LIGHT_RANGE 1.5
#define AIRLOCK_POWERON_LIGHT_COLOR "#3aa7c2"
#define AIRLOCK_BOLTS_LIGHT_COLOR "#c23b23"
#define AIRLOCK_ACCESS_LIGHT_COLOR "#57e69c"
#define AIRLOCK_EMERGENCY_LIGHT_COLOR "#d1d11d"
#define AIRLOCK_DENY_LIGHT_COLOR "#c23b23"

var/global/list/airlock_overlays = list()

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	explosive_resistance = 2
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/welded = FALSE
	var/locked = 0
	var/lights = 1 // bolt lights show by default
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/pulseProof = 0 //#Z1 AI hacked this door after previous pulse?
	var/shockedby = list()
	var/close_timer_id = null
	var/datum/wires/airlock/wires = null
	var/denying = FALSE

	var/inner_material = null //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'

	door_open_sound             = 'sound/machines/airlock/open.ogg'
	door_close_sound            = 'sound/machines/airlock/close.ogg'
	var/door_open_forced_sound  = 'sound/machines/airlock/open_force.ogg'
	var/door_close_forced_sound = 'sound/machines/airlock/close_force.ogg'

	var/door_deni_sound         = 'sound/machines/airlock/access_denied.ogg'
	var/door_bolt_up_sound      = 'sound/machines/airlock/bolts_up_1.ogg'
	var/door_bolt_down_sound    = 'sound/machines/airlock/bolts_down_1.ogg'

	max_integrity = 300
	integrity_failure = 0.25
	damage_deflection = 21

/obj/machinery/door/airlock/atom_init(mapload, dir = null)
	..()
	airlock_list += src
	wires = new(src)
	if(glass && !inner_material)
		inner_material = "glass"
	if(dir)
		set_dir(dir)

	update_icon()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/atom_init_late()
	if(closeOtherId != null)
		for (var/obj/machinery/door/airlock/A in airlock_list)
			if(A.closeOtherId == closeOtherId && A != src)
				closeOther = A
				break

/obj/machinery/door/airlock/Destroy()
	airlock_list -= src
	QDEL_NULL(wires)
	QDEL_NULL(electronics)
	closeOther = null
	var/datum/atom_hud/data/diagnostic/diag_hud = global.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/process()
	if(secondsElectrified > 0)
		secondsElectrified--
	else
		diag_hud_set_electrified()
		return PROCESS_KILL

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(issilicon(usr) || !iscarbon(user))
		return ..()

	if(isElectrified() && !justzap && shock(user, 100))
		justzap = TRUE
		spawn (10)
			justzap = FALSE
		return
	//needs rewriting all hallucination += num to one proc/adjust_hallucination(num)
	//so directly call status_effect for now
	if(user.hallucination > 50)
		user.apply_status_effect(/datum/status_effect/hallucination, 2 SECONDS)

	if(SEND_SIGNAL(user, COMSIG_CARBON_BUMPED_AIRLOCK_OPEN, src) & STOP_BUMP)
		return

	return ..(user)

/obj/machinery/door/airlock/finish_crush_wedge_animation()
	playsound(src, door_deni_sound, VOL_EFFECTS_MASTER, 50, FALSE, 3)
	..()

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)

/obj/machinery/door/airlock/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	return !density || (check_access(ID) && !locked && hasPower())

/obj/machinery/door/airlock/proc/isElectrified()
	if(secondsElectrified)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/isWireCut(wireIndex)
	return wires?.is_index_cut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((aiControlDisabled != 1) && !isAllPowerCut());

/obj/machinery/door/airlock/proc/canAIHack()
	return (aiControlDisabled && !hackProof && !isAllPowerCut());

/obj/machinery/door/airlock/hasPower()
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if(isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if(isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(secondsMainPowerLost > 0)
		secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if(secondsMainPowerLost <= 0)
		secondsMainPowerLost = 60
		if(secondsBackupPowerLost < 10)
			secondsBackupPowerLost = 10
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
		spawn(0)
			var/cont = TRUE
			while (cont)
				sleep(10)
				if(QDELETED(src))
					return
				cont = FALSE
				if(secondsMainPowerLost > 0)
					if(!isWireCut(AIRLOCK_WIRE_MAIN_POWER1) && !isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
						secondsMainPowerLost -= 1
						updateDialog()
					cont = TRUE

				if(secondsBackupPowerLost>0)
					if(!isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) && !isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
						secondsBackupPowerLost -= 1
						updateDialog()
					cont = TRUE
			spawnPowerRestoreRunning = FALSE
			updateDialog()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(secondsBackupPowerLost < 60)
		secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(secondsBackupPowerLost > 0)
		secondsBackupPowerLost = 0

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = 1
	playsound(src, door_bolt_down_sound, VOL_EFFECTS_MASTER, 40, FALSE, null, -4)
	update_icon()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = 0
	playsound(src, door_bolt_up_sound, VOL_EFFECTS_MASTER, 40, FALSE, null, -4)
	update_icon()

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!Adjacent(user))
		return 0
	if(!hasPower())		// unpowered, no shock
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if(electrocute_mob(user, get_area(src), src))
		hasShocked = 1
		sleep(10)
		hasShocked = 0
		return 1
	else
		return 0

// So icons update in case of cutting off power via APC
/obj/machinery/door/airlock/power_change()
	..()
	update_icon()

/obj/machinery/door/airlock/update_icon(state = AIRLOCK_DEFAULT)
	switch(state)
		if(AIRLOCK_DEFAULT)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate"
	set_airlock_overlays(state)

	if(underlays.len)
		underlays.Cut()

	if(wedged_item)
		generate_wedge_overlay()

	SSdemo.mark_dirty(src)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	. = list()

	var/frame_state
	var/light_state
	switch(state)
		if(AIRLOCK_CLOSED)
			frame_state = AIRLOCK_FRAME_CLOSED
			if(locked)
				light_state = AIRLOCK_LIGHT_BOLTS
			else if(emergency)
				light_state = AIRLOCK_LIGHT_EMERGENCY
			else
				light_state = AIRLOCK_LIGHT_CLOSED
		if(AIRLOCK_DENY)
			frame_state = AIRLOCK_FRAME_CLOSED
			light_state = AIRLOCK_LIGHT_DENIED
		if(AIRLOCK_EMAG)
			frame_state = AIRLOCK_FRAME_CLOSED
		if(AIRLOCK_CLOSING)
			frame_state = AIRLOCK_FRAME_CLOSING
			light_state = AIRLOCK_LIGHT_CLOSING
		if(AIRLOCK_OPEN)
			frame_state = AIRLOCK_FRAME_OPEN
			if(locked)
				light_state = AIRLOCK_LIGHT_BOLTS
			else if(emergency)
				light_state = AIRLOCK_LIGHT_EMERGENCY
			else
				light_state = AIRLOCK_LIGHT_OPEN
		if(AIRLOCK_OPENING)
			frame_state = AIRLOCK_FRAME_OPENING
			light_state = AIRLOCK_LIGHT_OPENING

	. += get_airlock_overlay(frame_state, icon)
	if(inner_material)
		. += get_airlock_overlay("[inner_material]_[frame_state]", overlays_file)
	else
		. += get_airlock_overlay("fill_[frame_state]", icon)

	var/has_power = hasPower()
	if(light_state && lights && has_power)
		. += get_airlock_overlay("lights_[light_state]", overlays_file, TRUE)

		var/light_color
		switch(state)
			if(OPEN, CLOSED)
				if(locked)
					light_color = AIRLOCK_BOLTS_LIGHT_COLOR
				else if(emergency)
					light_color = AIRLOCK_EMERGENCY_LIGHT_COLOR
				else
					light_color = AIRLOCK_POWERON_LIGHT_COLOR
			if(AIRLOCK_DENY)
				light_color = AIRLOCK_DENY_LIGHT_COLOR
			if(AIRLOCK_CLOSING, AIRLOCK_OPENING)
				light_color = AIRLOCK_ACCESS_LIGHT_COLOR
		set_light(AIRLOCK_LIGHT_RANGE, AIRLOCK_LIGHT_POWER, light_color)
	else
		set_light(0, 0)

	if(p_open)
		. += get_airlock_overlay("panel_[frame_state]", overlays_file)
	if(frame_state == AIRLOCK_FRAME_CLOSED && welded)
		. += get_airlock_overlay("welded", overlays_file)

	if(state == AIRLOCK_EMAG)
		. += get_airlock_overlay("sparks", overlays_file, TRUE)

	if(has_power)
		switch(frame_state) // TODO ADD SPARKS OVERLAYS to files // why the fuck it sould be in every file????
			if(AIRLOCK_FRAME_CLOSED)
				if(stat & BROKEN)
					. += get_airlock_overlay("sparks_broken", overlays_file, TRUE)
				else if(atom_integrity < (0.75 * max_integrity))
					. += get_airlock_overlay("sparks_damaged", overlays_file, TRUE)
			if(AIRLOCK_FRAME_OPEN)
				if(atom_integrity < (0.75 * max_integrity))
					. += get_airlock_overlay("sparks_open", overlays_file, TRUE)

	if(hasPower() && unres_sides)
		for(var/heading in list(NORTH,SOUTH,EAST,WEST))
			if(!(unres_sides & heading))
				continue
			var/mutable_appearance/floorlight = mutable_appearance('icons/obj/doors/airlocks/station/overlays.dmi', "unres_[heading]", FLOAT_LAYER)
			switch (heading)
				if (NORTH)
					floorlight.pixel_y = 32
				if (SOUTH)
					floorlight.pixel_y = -32
				if (EAST)
					floorlight.pixel_x = 32
				if (WEST)
					floorlight.pixel_x = -32
			. += floorlight

	cut_overlays()
	add_overlay(.)

/proc/get_airlock_overlay(icon_state, icon_file, light_source=FALSE)
	var/iconkey = "[icon_state][icon_file]"
	if(!(. = airlock_overlays[iconkey]))
		var/mutable_appearance/MA
		if(light_source)
			MA = mutable_appearance(icon_file, icon_state, 1, LIGHTING_LAMPS_PLANE)
		else
			MA = mutable_appearance(icon_file, icon_state)
		. = airlock_overlays[iconkey] = MA

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(deny_animation_check())
				denying = TRUE
				update_icon(AIRLOCK_DENY)
				playsound(src, door_deni_sound, VOL_EFFECTS_MASTER, 40, FALSE, null, 3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)
				icon_state = "closed"
				denying = FALSE

/obj/machinery/door/airlock/attack_ghost(mob/user)
	//Separate interface for ghosts.
	if(user.client.machine_interactive_ghost)
		show_unified_command_interface(user)

/obj/machinery/door/airlock/attack_ai(mob/user)
//#Z1
	if(isWireCut(AIRLOCK_WIRE_AI_CONTROL))
		to_chat(user, "Airlock AI control wire is cut. Please call the engineer or engiborg to fix this problem.")
		return
//##Z1
	if(!canAIControl())
		if(canAIHack())
			hack(user)
			return
		else
			to_chat(user, "Airlock AI control has been blocked with a firewall. Unable to hack.")

	show_unified_command_interface(user)

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 11 lift access override
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 11 lift access override

/obj/machinery/door/airlock/proc/show_unified_command_interface(mob/user)
	user.set_machine(src)
	var/t1 = ""
	if(secondsMainPowerLost > 0)
		if(!isWireCut(AIRLOCK_WIRE_MAIN_POWER1) && !isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
			t1 += text("Main power is <span class='bad'>offline</span> for [] seconds.<br>\n", secondsMainPowerLost)
		else
			t1 += text("Main power is <span class='bad'>offline</span> indefinitely.<br>\n")
	else
		t1 += text("Main power is <span class='green'>online</span>.<br>")

	if(secondsBackupPowerLost > 0)
		if(!isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) && !isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			t1 += text("Backup power is <span class='bad'>offline</span> for [] seconds.<br>\n", secondsBackupPowerLost)
		else
			t1 += text("Backup power is <span class='bad'>offline</span> indefinitely.<br>\n")
	else if(secondsMainPowerLost > 0)
		t1 += text("Backup power is <span class='green'>online</span>.<br>")
	else
		t1 += text("Backup power is <span class='bad'>offline</span>, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(isWireCut(AIRLOCK_WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(emergency)
		t1 += text("Emergency access override is enabled. <A href='?src=\ref[];aiDisable=11'>Disable?</a><br>\n", src)
	else
		t1 += text("Emergency access override is disabled. <A href='?src=\ref[];aiEnable=11'>Enable?</a><br>\n", src)

	if(isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(!secondsMainPowerLost)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(!secondsBackupPowerLost)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(hasPower())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		t1 += text("Electrification wire is cut.<br>\n")
	if(secondsElectrified == -1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify</a><br>\n", src)
	else if(secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([]s). <A href='?src=\ref[];aiDisable=5'>Un-electrify</a><br>\n", secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify temporarily (30s)</a> <A href='?src=\ref[];aiEnable=6'>Electrify indefinitely</a><br>\n", src, src)

	if(isWireCut(AIRLOCK_WIRE_SAFETY))
		t1 += text("Door force sensors not responding</a><br>\n")
	else if(safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding</a><br>\n")
	else if(normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)

	if(welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!locked)
		if(density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	var/datum/browser/popup = new(user, "airlock", "Airlock Control")
	popup.set_content(t1)
	popup.open()


/obj/machinery/door/airlock/proc/hack(mob/user)
	if(!aiHacking)
		aiHacking = TRUE
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(!hack_can_continue(user))
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled.")//#Z1
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(!hack_can_continue(user))
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(!hack_can_continue(user))
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
//#Z1
			//aiControlDisabled = 2
			aiControlDisabled = FALSE
			pulseProof = TRUE
//##Z1
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			aiHacking = FALSE
			if (user)
				attack_ai(user)

/obj/machinery/door/airlock/proc/hack_can_continue(mob/user)
	if(canAIControl())
		to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
		aiHacking = FALSE
		return FALSE
	else if(!canAIHack())
		to_chat(user, "We've lost our connection! Unable to hack airlock.")
		aiHacking = FALSE
		return FALSE
	return TRUE

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target, height=0)
	if (isElectrified())
		if (isitem(mover))
			var/obj/item/i = mover
			if (i.m_amt)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/attack_paw(mob/user)
	if(isxenoadult(user))
		if(welded || locked)
			to_chat(user, "<span class='warning'>The door is sealed, it cannot be pried open.</span>")
			return
		else if(!density)
			return
		else if(!user.is_busy(src))
			to_chat(user, "<span class='red'>You force your claws between the doors and begin to pry them open...</span>")
			playsound(src, 'sound/machines/airlock/creaking.ogg', VOL_EFFECTS_MASTER, 30, FALSE, null, -4)
			if(do_after(user,40, target = src) && src)
				open(1)
	return

/obj/machinery/door/airlock/attack_hulk(mob/living/user)
	. = ..()

	if(.)
		return .

	user.SetNextMove(CLICK_CD_INTERACT)

	if(welded || locked)
		if(user.hulk_scream(src, 75))
			door_rupture(user)
		return

	if(density)
		to_chat(user, "<span class='userdanger'>You force your fingers between \
		 the doors and begin to pry them open...</span>")
		playsound(src, 'sound/machines/firedoor_open.ogg', VOL_EFFECTS_MASTER, 30, FALSE, null, -4)
		if (!user.is_busy() && do_after(user, 4 SECONDS, target = src) && !QDELETED(src))
			open(1)

/obj/machinery/door/airlock/proc/door_rupture(mob/user)
	take_out_wedged_item()
	var/obj/structure/door_assembly/da = new assembly_type(loc)
	da.anchored = FALSE
	var/target = da.loc
	if(user)
		for(var/i in 1 to 4)
			target = get_turf(get_step(target,user.dir))
	da.throw_at(target, 200, 100, spin = FALSE)
	if(mineral)
		da.change_mineral_airlock_type(mineral)
	if(glass && da.can_insert_glass)
		da.set_glass(TRUE)
	da.state = ASSEMBLY_WIRED
	da.created_name = name
	da.update_state()

	if(electronics)
		electronics.loc = da
		da.electronics = electronics
		electronics = null
	else
		da.electronics = new (da)

	qdel(src)

/obj/machinery/door/airlock/proc/hulk_break_reaction(mob/living/carbon/user)
	if(!density)
		return
	user.SetNextMove(CLICK_CD_MELEE)
	if(user.a_intent == INTENT_HARM)
		if(user.hulk_scream(src, 90))
			door_rupture(user)
		return
	else if(locked)
		to_chat(user, "<span class='userdanger'> The door is bolted and you need more aggressive force to get thru!</span>")
		return
	var/passed = FALSE
	for(var/I in get_step(user,user.dir))
		if(I == src)
			passed = TRUE
			break
	if(!passed)
		return
	if(user.is_busy(src)) return
	var/cur_dir = user.dir
	user.visible_message("<span class='userdanger'>The [user] starts to force the [src] open with a bare hands!</span>",\
			"<span class='userdanger'>You start forcing the [src] open with a bare hands!</span>",\
			"You hear metal strain.")
	if(do_after(user, 30, target = src) && density && user.dir == cur_dir)
		user.canmove = 0
		var/turf/target = user.loc
		open()
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(isfloorturf(target))
			var/turf/simulated/floor/tile = target
			tile.break_tile()
		for(var/i in 1 to 2)
			if(!step(user,cur_dir))
				for(var/mob/living/L in get_step(user,cur_dir))
					L.adjustBruteLoss(rand(20,60))
				break
		playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<span class='userdanger'>The [user] forces the [src] open with a bare hands!</span>",\
				"<span class='userdanger'>You force the [src] open with a bare hands!</span>",\
				"You hear metal strain, and a door open.")
		user.canmove = 1
		close()

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(wires.interact(user))
		return

	if(HULK in user.mutations)
		hulk_break_reaction(user)
		return

	return ..()


/obj/machinery/door/airlock/Topic(href, href_list, no_window = 0)
	. = ..(href, href_list)
	if(!.)
		return

	if((issilicon(usr) && canAIControl()) || isobserver(usr))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed, 11 lift access override
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed, 11 lift access override
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					// Disable idscan
					if(isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
					else if(aiDisabledIdScanner)
						to_chat(usr, "You've already disabled the IdScan feature.")
					else
						aiDisabledIdScanner = 1

				if(2)
					// Disrupt main power
					if(!secondsMainPowerLost)
						loseMainPower()
						update_icon()
					else
						to_chat(usr, "Main power is already offline.")

				if(3)
					// Disrupt backup power
					if(!secondsBackupPowerLost)
						loseBackupPower()
					else
						to_chat(usr, "Backup power is already offline.")

				if(4)
					// Drop door bolts
					if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "You can't drop the door bolts - The door bolt dropping wire has been cut.")
					else if(!locked)
						bolt()

				if(5)
					// Un-electrify door
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "Can't un-electrify the airlock - The electrification wire is cut.")
					else if(secondsElectrified == -1)
						secondsElectrified = 0
					else if(secondsElectrified > 0)
						secondsElectrified = 0
					diag_hud_set_electrified()

				if(7)
					// Close door
					if(welded)
						to_chat(usr, "The airlock has been welded shut!")
					else if(locked)
						to_chat(usr, "The door bolts are down!")
					else
						close()

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if(isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, "Control to door sensors is disabled.")
					else if(safe)
						safe = 0
					else
						to_chat(usr, "Firmware reports safeties already overriden.")

				if(9)
					// Door speed control
					if(isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, "Control to door timing circuitry has been severed.")
					else if(normalspeed)
						normalspeed = 0
					else
						to_chat(usr, "Door timing circurity already accellerated.")

				if(10)
					// Bolt lights
					if(isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "Control to door bolt lights has been severed.")
					else if (lights)
						lights = 0
						update_icon()
					else
						to_chat(usr, "Door bolt lights are already disabled!")

				if(11)
					// Emergency access
					if(emergency)
						emergency = 0
						update_icon()
					else
						to_chat(usr, "Emergency access is already disabled!")

		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					// Enable idscan
					if(isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "You can't enable IdScan - The IdScan wire has been cut.")
					else if(aiDisabledIdScanner)
						aiDisabledIdScanner = 0
					else
						to_chat(usr, "The IdScan feature is not disabled.")

				if(4)
					// Raise door bolts
					if(isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "The door bolt drop wire is cut - you can't raise the door bolts.<br>\n")
					else if(!locked)
						to_chat(usr, "The door bolts are already up.<br>\n")
					else
						if(hasPower())
							unbolt()
						else
							to_chat(usr, "Cannot raise door bolts due to power failure.<br>\n")

				if(5)
					// Electrify door for 30 seconds
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "The electrification wire has been cut.<br>\n")
					else if(secondsElectrified == -1)
						to_chat(usr, "The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n")
					else if(secondsElectrified)
						to_chat(usr, "The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [name] at [COORD(src)]</font>"
						secondsElectrified = 30
						diag_hud_set_electrified()
						START_PROCESSING(SSmachines, src)

				if(6)
					// Electrify door indefinitely
					if(isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, "The electrification wire has been cut.<br>\n")
					else if(secondsElectrified == -1)
						to_chat(usr, "The door is already indefinitely electrified.<br>\n")
					else if(secondsElectrified)
						to_chat(usr, "The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n")
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [name] at [COORD(src)]</font>"
						secondsElectrified = -1
						diag_hud_set_electrified()

				if(7)
					// Open door
					if(welded)
						to_chat(usr, "The airlock has been welded shut!")
					else if(locked)
						to_chat(usr, "The door bolts are down!")
					else
						open()

				if (8)
					// Safeties!  Maybe we do need some stinking safeties!
					if (isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, "Control to door sensors is disabled.")
					else if (!safe)
						safe = 1
					else
						to_chat(usr, "Firmware reports safeties already in place.")

				if(9)
					// Door speed control
					if(isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, "Control to door timing circuitry has been severed.")
					else if (!normalspeed)
						normalspeed = 1
					else
						to_chat(usr, "Door timing circurity currently operating normally.")

				if(10)
					// Bolt lights
					if(isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "Control to door bolt lights has been severed.")
					else if (!lights)
						lights = 1
						update_icon()
					else
						to_chat(usr, "Door bolt lights are already enabled!")

				if(11)
					// Emergency access
					if(!emergency)
						emergency = 1
						update_icon()
					else
						to_chat(usr, "Emergency access is already disabled!")

	if(!no_window)
		updateUsrDialog()

/obj/machinery/door/airlock/try_open(mob/user, obj/item/tool = null)
	if(isElectrified() && !issilicon(user) && !isobserver(user))
		if(shock(user, tool ? 75 : 100))
			add_fingerprint(user)
			return
	..()

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	if(iswelding(C) && !(operating > 0))
		var/obj/item/weapon/weldingtool/W = C
		if(W.use(0, user))
			if(!handle_fumbling(user, src, SKILL_TASK_EASY , list(/datum/skill/engineering = SKILL_LEVEL_NOVICE), message_self = "<span class='notice'>You fumble around, figuring out how to [welded? "remove welding from":"welding"] [src]'s shutters with [W]... </span>"))
				return
			user.visible_message("[user] begins [welded? "unwelding":"welding"] [src]'s shutters with [W].",
			                     "<span class='notice'>You begin [welded? "remove welding from":"welding"] [src]'s shutters with [W]...</span>")
			if(W.use_tool(src, user, SKILL_TASK_EASY, volume = 100))
				welded = !welded
				update_icon()
				user.visible_message("[user] [welded ? "welds" : "unwelds"] [src]'s shutters with [W].",
				                     "<span class='notice'>You [welded ? "weld" : "remove welding from"] [src]'s shutters with [W].</span>")
				return
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
	else if(isscrewing(C))
		p_open = !p_open
		update_icon()
	else if(iscutter(C) && p_open)
		return attack_hand(user)
	else if(ispulsing(C))
		return attack_hand(user)
	else if(issignaling(C))
		return attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.afterattack(src, user)
	else if(isprying(C))
		var/beingcrowbarred = null
		if(isprying(C))
			beingcrowbarred = 1 //derp, Agouri
		else
			beingcrowbarred = 0
		if(beingcrowbarred && (operating == -1 || density && welded && operating != 1 && p_open && !hasPower() && !locked) )
			if(user.is_busy(src)) return
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(C.use_tool(src, user, SKILL_TASK_AVERAGE, volume = 100))
				deconstruct(TRUE, user)
				return
		else if(hasPower())
			to_chat(user, "<span class='notice'>The airlock's motors resist your efforts to force it.</span>")
		else if(locked)
			to_chat(user, "<span class='notice'>The airlock's bolts prevent it from being forced.</span>")
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/fireaxe/F = C
					if(HAS_TRAIT(F, TRAIT_DOUBLE_WIELDED))
						spawn(0)	open(1)
					else
						to_chat(user, "<span class='warning'>You need to be wielding the Fire axe to do that.</span>")
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/fireaxe/F = C
					if(HAS_TRAIT(F, TRAIT_DOUBLE_WIELDED))
						spawn(0)	close(1)
					else
						to_chat(user, "<span class='warning'>You need to be wielding the Fire axe to do that.</span>")
				else
					spawn(0)	close(1)

	else if(istype(C, /obj/item/weapon/airlock_painter)) 		//airlock painter
		change_paintjob(C, user)
	else
		return ..()

/obj/machinery/door/airlock/phoron/attackby(obj/item/I, mob/user)
	ignite(I.get_current_temperature())
	..()

/obj/machinery/door/airlock/proc/close_unsafe(bolt_after = FALSE)
	var/temp = safe

	safe = FALSE

	if(close())
		if(bolt_after)
			bolt()

	safe = temp

/obj/machinery/door/airlock/open_checks()
	if(..() && !welded && !locked)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/close_checks()
	if(..() && !welded && !locked)
		if(safe)
			for(var/turf/T in locs)
				if(locate(/mob/living) in T)
					autoclose()
					return FALSE
				if(locate(/obj/mecha) in T)
					autoclose()
					return FALSE
		return TRUE
	return FALSE

/obj/machinery/door/airlock/normal_open_checks()
	if(hasPower() && !isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/normal_close_checks()
	if(hasPower() && !isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/deny_animation_check()
	if(!denying && !welded && !locked && hasPower() && !isWireCut(AIRLOCK_WIRE_OPEN_DOOR))
		return TRUE
	return FALSE

/obj/machinery/door/airlock/do_open()
	send_status_if_allowed()
	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock) && !closeOther.density)
		closeOther.close()
	if(hasPower())
		use_power(50)
		door_open_sound = initial(door_open_sound)
	else
		door_open_sound = door_open_forced_sound
	..()
	autoclose()

/obj/machinery/door/airlock/do_close()
	send_status_if_allowed()
	if(hasPower())
		use_power(50)
		door_close_sound = initial(door_close_sound)
	else
		door_close_sound = door_close_forced_sound
	..()

/obj/machinery/door/airlock/do_afterclose()
	for(var/atom/A in orange(0, src))
		A.airlock_crush_act()
	..()

/obj/machinery/door/airlock/proc/autoclose()
	if(autoclose)
		if(close_timer_id)
			deltimer(close_timer_id)
		close_timer_id = addtimer(CALLBACK(src, PROC_REF(do_autoclose)), normalspeed ? 150 : 5, TIMER_STOPPABLE)

/obj/machinery/door/airlock/proc/do_autoclose()
	close_timer_id = null
	close()

/obj/machinery/door/airlock/proc/prison_open()
	unbolt()
	open()
	bolt()
	return

/obj/machinery/door/airlock/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!istype(W))
		to_chat(user, "If you see this, it means airlock/change_paintjob() was called with something other than an airlock painter. Check your code!")
		return

	if(!W.can_use(user, 1))
		return

	var/list/optionlist
	if(inner_material == "glass")
		optionlist = list("Public", "Public2", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance")
	else
		optionlist = list("Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")

	var/paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
	if(!W.use_tool(src, user, 50, 1))
		return
	switch(paintjob)
		if("Public")
			icon          = 'icons/obj/doors/airlocks/station/public.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Public2")
			icon          = 'icons/obj/doors/airlocks/station2/glass.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
		if("Engineering")
			icon          = 'icons/obj/doors/airlocks/station/engineering.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Atmospherics")
			icon          = 'icons/obj/doors/airlocks/station/atmos.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Security")
			icon          = 'icons/obj/doors/airlocks/station/security.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Command")
			icon          = 'icons/obj/doors/airlocks/station/command.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Medical")
			icon          = 'icons/obj/doors/airlocks/station/medical.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Research")
			icon          = 'icons/obj/doors/airlocks/station/research.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			heat_proof    = glass
		if("Mining")
			icon          = 'icons/obj/doors/airlocks/station/mining.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("Maintenance")
			icon          = 'icons/obj/doors/airlocks/station/maintenance.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
		if("External")
			icon          = 'icons/obj/doors/airlocks/external/external.dmi'
			overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
		if("High Security")
			icon          = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
			overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	update_icon()

/obj/machinery/door/airlock/proc/on_break()
	if(!panel_open)
		panel_open = TRUE
	wires.cut_all()

/obj/machinery/door/airlock/emp_act(severity)
	if(!wires)
		return
	for(var/i in 1 to severity)
		if(!prob(50 / severity))
			continue
		var/wire = 1 << rand(0, wires.wire_count - 1)
		wires.pulse_index(wire)

/obj/machinery/door/airlock/atom_break(damage_flag)
	. = ..()
	if(.)
		on_break()

/obj/machinery/door/airlock/atom_destruction(damage_flag)
	if(damage_flag == BOMB) //If an explosive took us out, don't drop the assembly
		flags |= NODECONSTRUCT
	return ..()

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(.)
		update_icon()

/obj/machinery/door/airlock/proc/prepare_deconstruction_assembly(obj/structure/door_assembly/assembly)
	assembly.anchored = TRUE
	if(mineral)
		assembly.change_mineral_airlock_type(mineral)
	if(glass && assembly.can_insert_glass)
		assembly.set_glass(TRUE)
	assembly.state = ASSEMBLY_WIRED
	assembly.set_dir(dir)
	assembly.created_name = name
	assembly.update_state()

/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(flags & NODECONSTRUCT)
		return ..()
	take_out_wedged_item()
	var/obj/structure/door_assembly/A = new assembly_type(loc)
	prepare_deconstruction_assembly(A)

	if(!disassembled)
		A.update_integrity(A.max_integrity * 0.5)
		return ..()

	if(user)
		to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

	var/obj/item/weapon/airlock_electronics/ae
	if(electronics)
		ae = electronics
		electronics = null
		ae.loc = loc
	else
		ae = new /obj/item/weapon/airlock_electronics(loc)
		if(!req_access)
			check_access()
		if(req_access.len)
			ae.conf_access = req_access
		else if (req_one_access.len)
			ae.conf_access = req_one_access
			ae.one_access = 1

	if(operating == -1)
		ae.icon_state = "door_electronics_smoked"
		ae.broken = TRUE
		operating = 0
	..()

/obj/structure/door_scrap
	name = "Door Scrap"
	desc = "Just a bunch of garbage."
	var/ticker = 0
	var/icon/door = icon('icons/effects/effects.dmi',"Sliced")
	//light_power = 1
	//light_color = "#cc0000"


/obj/structure/door_scrap/attackby(obj/item/O, mob/user)
	if(iswrenching(O))
		if(ticker >= 300)
			user.visible_message("[user] has disassemble these scrap...")
			new /obj/item/stack/sheet/metal(loc)
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
		else
			to_chat(user,"<span=userdanger>This is too hot to dismantle it</span>")
			if(prob(10))
				to_chat(user,"<span=userdanger>You accidentally drop your wrench in the flame</span>")
				qdel(O)

/obj/structure/door_scrap/atom_init()
	. = ..()
	var/image/fire_overlay = image(icon = 'icons/effects/effects.dmi', icon_state = "s_fire", layer = 1)
	fire_overlay.plane = LIGHTING_LAMPS_PLANE
	add_overlay(fire_overlay)
	START_PROCESSING(SSobj, src)

/obj/structure/door_scrap/process()
	if(ticker >= 300)
		cut_overlays()
		STOP_PROCESSING(SSobj, src)
		return
	ticker++
	var/spot = locate(/obj/effect/fluid) in loc
	if(spot)
		ticker +=10

#undef AIRLOCK_POWERON_LIGHT_COLOR
#undef AIRLOCK_BOLTS_LIGHT_COLOR
#undef AIRLOCK_ACCESS_LIGHT_COLOR
#undef AIRLOCK_EMERGENCY_LIGHT_COLOR
#undef AIRLOCK_DENY_LIGHT_COLOR
#undef AIRLOCK_LIGHT_POWER
#undef AIRLOCK_LIGHT_RANGE

///Mapping helper. Just place it on the map on the airlock and select side, in the round this side will be unrestricted
/obj/effect/unrestricted_side
	name = "airlock unrestricted side helper"
	icon = 'icons/obj/doors/airlocks/station/overlays.dmi'
	icon_state = "unres_1"
	dir = NORTH
	pixel_y = 16
	pixel_x = 16

/obj/effect/unrestricted_side/atom_init()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/unrestricted_side/atom_init_late()
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	airlock.unres_sides ^= dir
	airlock.update_icon()
	qdel(src)

//Also, you can set the value to 5 (3, 6, 7, etc), and have unrestricted access to both north and east sides, but who cares
/obj/effect/unrestricted_side/north
	icon_state = "unres_1"
	dir = NORTH
	pixel_y = 32
	pixel_x = 0

/obj/effect/unrestricted_side/east
	icon_state = "unres_4"
	dir = EAST
	pixel_x = 32
	pixel_y = 0

/obj/effect/unrestricted_side/south
	icon_state = "unres_2"
	dir = SOUTH
	pixel_y = -32
	pixel_x = 0

/obj/effect/unrestricted_side/west
	icon_state = "unres_8"
	dir = WEST
	pixel_x = -32
	pixel_y = 0
