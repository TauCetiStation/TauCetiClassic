var/const/AUTOLATHE_WIRE_HACK    = 1
var/const/AUTOLATHE_WIRE_SHOCK   = 2
var/const/AUTOLATHE_WIRE_DISABLE = 4

/datum/wires/autolathe
	holder_type = /obj/machinery/autolathe
	wire_count = 6

/datum/wires/autolathe/get_interact_window()
	var/obj/machinery/autolathe/A = holder
	. += ..()
	. += "<br>The red light is [A.disabled ? "off" : "on"]."
	. += "<br>The green light is [A.shocked ? "off" : "on"]."
	. += "<br>The blue light is [A.hacked ? "off" : "on"]."

/datum/wires/autolathe/can_use()
	var/obj/machinery/autolathe/A = holder
	return A.panel_open

/datum/wires/autolathe/update_cut(index, mended)
	var/obj/machinery/autolathe/A = holder

	switch(index)
		if(AUTOLATHE_WIRE_HACK)
			A.hacked = !mended

		if(AUTOLATHE_WIRE_SHOCK)
			A.shocked = !mended

		if(AUTOLATHE_WIRE_DISABLE)
			A.disabled = !mended

/datum/wires/autolathe/update_pulsed(index)
	var/obj/machinery/autolathe/A = holder

	switch(index)
		if(AUTOLATHE_WIRE_HACK)
			A.hacked = !A.hacked
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

		if(AUTOLATHE_WIRE_SHOCK)
			A.shocked = !A.shocked
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

		if(AUTOLATHE_WIRE_DISABLE)
			A.disabled = !A.disabled
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

/datum/wires/autolathe/proc/pulse_reaction(index)
	var/obj/machinery/autolathe/A = holder

	if(A && !is_index_cut(index))
		switch(index)
			if(AUTOLATHE_WIRE_HACK)
				A.hacked = FALSE

			if(AUTOLATHE_WIRE_SHOCK)
				A.shocked = FALSE

			if(AUTOLATHE_WIRE_DISABLE)
				A.disabled = FALSE