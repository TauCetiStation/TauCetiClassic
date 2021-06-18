var/const/AIRLOCK_WIRE_IDSCAN        = 1
var/const/AIRLOCK_WIRE_MAIN_POWER1   = 2
var/const/AIRLOCK_WIRE_MAIN_POWER2   = 4
var/const/AIRLOCK_WIRE_DOOR_BOLTS    = 8
var/const/AIRLOCK_WIRE_BACKUP_POWER1 = 16
var/const/AIRLOCK_WIRE_BACKUP_POWER2 = 32
var/const/AIRLOCK_WIRE_OPEN_DOOR     = 64
var/const/AIRLOCK_WIRE_AI_CONTROL    = 128
var/const/AIRLOCK_WIRE_ELECTRIFY     = 256
var/const/AIRLOCK_WIRE_SAFETY        = 512
var/const/AIRLOCK_WIRE_SPEED         = 1024
var/const/AIRLOCK_WIRE_LIGHT         = 2048

/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	wire_count = 12
	window_y = 570

/datum/wires/airlock/can_use()
	var/obj/machinery/door/airlock/A = holder
	return A.p_open

/datum/wires/airlock/additional_checks_and_effects(mob/living/user)
	if(HULK in user.mutations)
		return TRUE
	var/obj/machinery/door/airlock/A = holder
	if(A.isElectrified() && !issilicon(user) && !isobserver(user))
		if(A.shock(user, 100))
			return TRUE

/datum/wires/airlock/get_status()
	var/obj/machinery/door/airlock/A = holder
	. += ..()
	. += "[A.locked ? "The door bolts have fallen!" : "The door bolts look up."]"
	. += "[A.lights ? "The door bolt lights are on." : "The door bolt lights are off!"]"
	. += "[A.hasPower() ? "The test light is on." : "The test light is off!"]"
	. += "[!A.aiControlDisabled ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."]"
	. += "[!A.safe ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."]"
	. += "[!A.normalspeed ? "The 'Check Timing Mechanism' light is on." : "The 'Check Timing Mechanism' light is off."]"
	. += "[!A.emergency ? "The emergency lights are off." : "The emergency lights are on."]"
	. += list(list(
		"label" = "Save to the buffer of your multitool",
		"act" = "buffer",
		"act_params" = null
	))

/datum/wires/airlock/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return
	if(action == "buffer")
		var/obj/item/I = usr.get_active_hand()
		if(ismultitool(I))
			var/obj/item/device/multitool/M = I
			if(holder in M.airlocks_buffer)
				to_chat(usr, "<span class='warning'>This airlock is already in the buffer!</span>")
			else if(M.airlocks_buffer.len >= M.buffer_limit)
				to_chat(usr, "<span class='warning'>The multitool's buffer is full!</span>")
			else
				M.airlocks_buffer += holder
				to_chat(usr, "<span class='notice'>You save this airlock to the buffer of your multitool.</span>")
			. = TRUE
		else
			to_chat(usr, "<span class='warning'>You need a multitool!</span>")
	if(.)
		holder.add_fingerprint(usr)

/datum/wires/airlock/update_cut(index, mended)
	var/obj/machinery/door/airlock/A = holder

	switch(index)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			if(!mended)
				A.loseMainPower()
				A.shock(usr, 50)
			else
				if(!is_index_cut(AIRLOCK_WIRE_MAIN_POWER1) && !is_index_cut(AIRLOCK_WIRE_MAIN_POWER2))
					A.regainMainPower()
					A.shock(usr, 50)

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			if(!mended)
				A.loseBackupPower()
				A.shock(usr, 50)
			else
				if(!is_index_cut(AIRLOCK_WIRE_BACKUP_POWER1) && !is_index_cut(AIRLOCK_WIRE_BACKUP_POWER2))
					A.regainBackupPower()
					A.shock(usr, 50)

		if(AIRLOCK_WIRE_DOOR_BOLTS)
			if(!mended)
				if(A.locked != 1)
					A.bolt()

		if(AIRLOCK_WIRE_AI_CONTROL)
			if(!mended)
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
			else
				if(A.aiControlDisabled == 1)
					A.aiControlDisabled = 0

		if(AIRLOCK_WIRE_ELECTRIFY)
			if(!mended)
				if(A.secondsElectrified != -1)
					A.shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
					usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [A.name] at [COORD(A)]</font>"
					A.secondsElectrified = -1
			else
				if(A.secondsElectrified == -1)
					A.secondsElectrified = 0
			A.diag_hud_set_electrified()

		if (AIRLOCK_WIRE_SAFETY)
			A.safe = mended

		if(AIRLOCK_WIRE_SPEED)
			A.autoclose = mended
			if(mended)
				A.close()

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = mended

	A.update_icon()

/datum/wires/airlock/update_pulsed(index)
	var/obj/machinery/door/airlock/A = holder

	switch(index)
		if(AIRLOCK_WIRE_IDSCAN)
			if(A.hasPower() && A.density)
				A.do_animate("deny")
				if(A.emergency)
					A.emergency = FALSE
					A.update_icon()

		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			A.loseMainPower()

		if(AIRLOCK_WIRE_DOOR_BOLTS)
			if(!A.locked)
				A.bolt()
				A.audible_message("You hear a click from the bottom of the door.", hearing_distance = 1)
			else
				if(A.hasPower())
					A.unbolt()
					A.audible_message("You hear a click from the bottom of the door.", hearing_distance = 1)

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			A.loseBackupPower()

		if(AIRLOCK_WIRE_AI_CONTROL)
			if(!A.pulseProof)
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2

		if(AIRLOCK_WIRE_ELECTRIFY)
			if(A.secondsElectrified == 0)
				if(ismob(usr)) // EMP can do this
					A.shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
					usr.attack_log += "\[[time_stamp()]\] <font color='red'>Electrified the [A.name] at [COORD(A)]</font>"
				else
					A.shockedby += "\[[time_stamp()]\]EMP or smth else"
				A.secondsElectrified = 30
				A.diag_hud_set_electrified()
				START_PROCESSING(SSmachines, A)

		if(AIRLOCK_WIRE_OPEN_DOOR)
			if(!A.requiresID() || A.check_access(null))
				if(A.density)
					A.open()
				else
					A.close()

		if(AIRLOCK_WIRE_SAFETY)
			A.safe = !A.safe
			if(!A.density)
				A.close()

		if(AIRLOCK_WIRE_SPEED)
			A.normalspeed = !A.normalspeed

		if(AIRLOCK_WIRE_LIGHT)
			A.lights = !A.lights

	A.update_icon()
