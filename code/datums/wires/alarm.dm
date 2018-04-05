var/const/AALARM_WIRE_IDSCAN     = 1
var/const/AALARM_WIRE_POWER      = 2
var/const/AALARM_WIRE_SYPHON     = 4
var/const/AALARM_WIRE_AI_CONTROL = 8
var/const/AALARM_WIRE_AALARM     = 16

/datum/wires/alarm
	holder_type = /obj/machinery/alarm
	wire_count = 5

/datum/wires/alarm/can_use()
	var/obj/machinery/alarm/A = holder
	return A.wiresexposed

/datum/wires/alarm/get_interact_window()
	var/obj/machinery/alarm/A = holder
	. += ..()
	. += "<br>[A.locked ? "The Air Alarm is locked." : "The Air Alarm is unlocked."]"
	. += "<br>[(A.shorted || (A.stat & (NOPOWER|BROKEN))) ? "The Air Alarm is offline." : "The Air Alarm is working properly!"]"
	. += "<br>[A.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on."]"

/datum/wires/alarm/update_cut(index, mended)
	var/obj/machinery/alarm/A = holder

	switch(index)
		if(AALARM_WIRE_IDSCAN)
			if(!mended)
				A.locked = TRUE

		if(AALARM_WIRE_POWER)
			A.shock(usr, 50)
			A.shorted = !mended
			A.update_icon()

		if (AALARM_WIRE_AI_CONTROL)
			if (A.aidisabled == !mended)
				A.aidisabled = mended

		if(AALARM_WIRE_SYPHON)
			if(!mended)
				A.mode = AALARM_MODE_PANIC
				A.apply_mode()

		if(AALARM_WIRE_AALARM)
			if(A.alarm_area.atmosalert(2))
				A.post_alert(2)
				A.update_icon()

/datum/wires/alarm/update_pulsed(index)
	var/obj/machinery/alarm/A = holder

	switch(index)
		if(AALARM_WIRE_IDSCAN)
			A.locked = !A.locked

		if (AALARM_WIRE_POWER)
			if(!A.shorted)
				A.shorted = TRUE
				A.update_icon()
				addtimer(CALLBACK(src, .proc/pulse_reaction, index), 1200)

		if (AALARM_WIRE_AI_CONTROL)
			if(!A.aidisabled)
				A.aidisabled = TRUE
				addtimer(CALLBACK(src, .proc/pulse_reaction, index), 100)

		if(AALARM_WIRE_SYPHON)
			A.mode = AALARM_MODE_REPLACEMENT
			A.apply_mode()

		if(AALARM_WIRE_AALARM)
			if(A.alarm_area.atmosalert(0))
				A.post_alert(0)
				A.update_icon()

/datum/wires/alarm/proc/pulse_reaction(index)
	var/obj/machinery/alarm/A = holder

	switch(index)
		if(AALARM_WIRE_POWER)
			if(A.shorted)
				A.shorted = FALSE
				A.update_icon()

		if(AALARM_WIRE_AI_CONTROL)
			if(A.aidisabled)
				A.aidisabled = FALSE