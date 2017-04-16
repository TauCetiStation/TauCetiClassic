var/const/APC_WIRE_IDSCAN      = 1
var/const/APC_WIRE_MAIN_POWER1 = 2
var/const/APC_WIRE_MAIN_POWER2 = 4
var/const/APC_WIRE_AI_CONTROL  = 8

/datum/wires/apc
	holder_type = /obj/machinery/power/apc
	wire_count = 4

/datum/wires/apc/get_interact_window()
	var/obj/machinery/power/apc/A = holder
	. += ..()
	. += text("<br>\n[(A.locked ? "The APC is locked." : "The APC is unlocked.")]<br>\n[(A.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]<br>\n[(A.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")


/datum/wires/apc/can_use(mob/living/L)
	var/obj/machinery/power/apc/A = holder
	if(A.wiresexposed)
		return TRUE
	return FALSE

/datum/wires/apc/update_pulsed(index)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_IDSCAN)
			A.locked = FALSE
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 300)

		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(!A.shorted)
				A.shorted = TRUE
				addtimer(CALLBACK(src, .proc/pulse_reaction, index), 1200)

		if(APC_WIRE_AI_CONTROL)
			if(!A.aidisabled)
				A.aidisabled = TRUE
				addtimer(CALLBACK(src, .proc/pulse_reaction, index), 10)

	A.updateDialog()

/datum/wires/apc/proc/pulse_reaction(wire_index_to_react)
	var/obj/machinery/power/apc/A = holder

	switch(wire_index_to_react)
		if(APC_WIRE_IDSCAN)
			if(A)
				A.locked = TRUE
				A.updateDialog()

		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(A && !is_index_cut(APC_WIRE_MAIN_POWER1) && !is_index_cut(APC_WIRE_MAIN_POWER2))
				A.shorted = FALSE
				A.updateDialog()

		if(APC_WIRE_AI_CONTROL)
			if(A && !is_index_cut(APC_WIRE_AI_CONTROL))
				A.aidisabled = FALSE
				A.updateDialog()

/datum/wires/apc/update_cut(index, mended)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(!mended)
				A.shock(usr, 50)
				A.shorted = TRUE
			else if(!is_index_cut(APC_WIRE_MAIN_POWER1) && !is_index_cut(APC_WIRE_MAIN_POWER2))
				A.shorted = FALSE
				A.shock(usr, 50)

		if(APC_WIRE_AI_CONTROL)
			if(!mended)
				if (!A.aidisabled)
					A.aidisabled = TRUE
			else
				if (A.aidisabled)
					A.aidisabled = FALSE

	A.updateDialog()