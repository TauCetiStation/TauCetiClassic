var/global/const/CHEM_DISPENSER_WIRE_HACK    = 1
var/global/const/CHEM_DISPENSER_WIRE_SHOCK   = 2
var/global/const/CHEM_DISPENSER_WIRE_DISABLE = 4

/datum/wires/chem_dispenser
	holder_type = /obj/machinery/chem_dispenser
	wire_count = 6

/datum/wires/chem_dispenser/get_status()
	var/obj/machinery/chem_dispenser/A = holder
	. += ..()
	. += "The red light is [A.disabled ? "off" : "on"]."
	. += "The green light is [A.shocked ? "off" : "on"]."
	. += "The blue light is [A.hacked ? "off" : "on"]."

/datum/wires/chem_dispenser/can_use()
	var/obj/machinery/chem_dispenser/A = holder
	return A.panel_open

/datum/wires/chem_dispenser/update_cut(index, mended)
	var/obj/machinery/chem_dispenser/A = holder

	switch(index)
		if(CHEM_DISPENSER_WIRE_HACK)
			A.hacked = !mended
			A.update_static_data(usr)

		if(CHEM_DISPENSER_WIRE_SHOCK)
			A.shocked = !mended

		if(CHEM_DISPENSER_WIRE_DISABLE)
			A.disabled = !mended

/datum/wires/chem_dispenser/update_pulsed(index)
	var/obj/machinery/chem_dispenser/A = holder

	switch(index)
		if(CHEM_DISPENSER_WIRE_HACK)
			A.hacked = !A.hacked
			A.update_static_data(usr)
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

		if(CHEM_DISPENSER_WIRE_SHOCK)
			A.shocked = !A.shocked
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

		if(CHEM_DISPENSER_WIRE_DISABLE)
			A.disabled = !A.disabled
			addtimer(CALLBACK(src, .proc/pulse_reaction, index), 50)

/datum/wires/chem_dispenser/proc/pulse_reaction(index)
	var/obj/machinery/chem_dispenser/A = holder

	if(A && !is_index_cut(index))
		switch(index)
			if(CHEM_DISPENSER_WIRE_HACK)
				A.hacked = FALSE
				A.update_static_data(usr)

			if(CHEM_DISPENSER_WIRE_SHOCK)
				A.shocked = FALSE

			if(CHEM_DISPENSER_WIRE_DISABLE)
				A.disabled = FALSE
