var/global/const/AUTOLATHE_WIRE_HACK    = 1
var/global/const/AUTOLATHE_WIRE_SHOCK   = 2
var/global/const/AUTOLATHE_WIRE_DISABLE = 4

/datum/wires/autolathe
	holder_type = /obj/machinery/autolathe
	wire_count = 6

/datum/wires/autolathe/get_status()
	var/obj/machinery/autolathe/A = holder
	. += ..()
	. += "The red light is [A.disabled ? "off" : "on"]."
	. += "The green light is [A.shocked ? "off" : "on"]."
	. += "The blue light is [A.hacked ? "off" : "on"]."

/datum/wires/autolathe/can_use()
	var/obj/machinery/autolathe/A = holder
	return A.panel_open

/datum/wires/autolathe/update_cut(index, mended, mob/user)
	var/obj/machinery/autolathe/A = holder

	switch(index)
		if(AUTOLATHE_WIRE_HACK)
			A.hacked = !mended
			if(user)
				A.update_static_data(user)

		if(AUTOLATHE_WIRE_SHOCK)
			A.shocked = !mended

		if(AUTOLATHE_WIRE_DISABLE)
			A.disabled = !mended

/datum/wires/autolathe/update_pulsed(index)
	var/obj/machinery/autolathe/A = holder

	switch(index)
		if(AUTOLATHE_WIRE_HACK)
			A.hacked = !A.hacked
			A.update_static_data(usr)
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 50)

		if(AUTOLATHE_WIRE_SHOCK)
			A.shocked = !A.shocked
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 50)

		if(AUTOLATHE_WIRE_DISABLE)
			A.disabled = !A.disabled
			addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 50)

/datum/wires/autolathe/proc/pulse_reaction(index)
	var/obj/machinery/autolathe/A = holder

	if(A && !is_index_cut(index))
		switch(index)
			if(AUTOLATHE_WIRE_HACK)
				A.hacked = FALSE
				A.update_static_data(usr)

			if(AUTOLATHE_WIRE_SHOCK)
				A.shocked = FALSE

			if(AUTOLATHE_WIRE_DISABLE)
				A.disabled = FALSE
