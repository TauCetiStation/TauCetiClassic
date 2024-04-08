var/global/const/APC_WIRE_IDSCAN      = 1
var/global/const/APC_WIRE_MAIN_POWER1 = 2
var/global/const/APC_WIRE_MAIN_POWER2 = 4
var/global/const/APC_WIRE_AI_CONTROL  = 8

/datum/wires/apc
	holder_type = /obj/machinery/power/apc
	wire_count = 4

/datum/wires/apc/get_status()
	var/obj/machinery/power/apc/A = holder
	. += ..()
	. += "[(A.locked ? "The APC is locked." : "The APC is unlocked.")]"
	. += "[(A.shorted ? "The APCs power has been shorted." : "The APC is working properly!")]"
	. += "[(A.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]"

/datum/wires/apc/can_use()
	var/obj/machinery/power/apc/A = holder
	return A.wiresexposed

/datum/wires/apc/update_cut(index, mended, mob/user)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(!mended)
				if(user)
					A.shock(user, 50)
				A.shorted = TRUE
			else if(!is_index_cut(APC_WIRE_MAIN_POWER1) && !is_index_cut(APC_WIRE_MAIN_POWER2))
				A.shorted = FALSE
				if(user)
					A.shock(user, 50)

		if(APC_WIRE_AI_CONTROL)
			if(!mended)
				if (!A.aidisabled)
					A.aidisabled = TRUE
			else
				if (A.aidisabled)
					A.aidisabled = FALSE

/datum/wires/apc/update_pulsed(index)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_IDSCAN)
			A.locked = FALSE
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 300)

		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(!A.shorted)
				A.shorted = TRUE
				addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 1200)

		if(APC_WIRE_AI_CONTROL)
			if(!A.aidisabled)
				A.aidisabled = TRUE
				addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 10)

/datum/wires/apc/proc/pulse_reaction(index)
	var/obj/machinery/power/apc/A = holder

	switch(index)
		if(APC_WIRE_IDSCAN)
			if(A)
				A.locked = TRUE

		if(APC_WIRE_MAIN_POWER1, APC_WIRE_MAIN_POWER2)
			if(A && !is_index_cut(APC_WIRE_MAIN_POWER1) && !is_index_cut(APC_WIRE_MAIN_POWER2))
				A.shorted = FALSE

		if(APC_WIRE_AI_CONTROL)
			if(A && !is_index_cut(APC_WIRE_AI_CONTROL))
				A.aidisabled = FALSE
