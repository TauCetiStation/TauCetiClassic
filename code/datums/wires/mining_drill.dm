var/global/const/MINING_DRILL_WIRES_SHOCK = 1
var/global/const/MINING_DRILL_WIRES_OVERLOAD = 2
var/global/const/MINING_DRILL_WIRES_RADIO_DISABLE = 4
var/global/const/MINING_DRILL_WIRES_POWER_DISABLE = 8
var/global/const/MINING_DRILL_WIRES_PROTECTOR_DISABLE = 16

/datum/wires/mining_drill
	holder_type = /obj/machinery/mining/drill
	wire_count = 9

/datum/wires/mining_drill/get_status()
	var/obj/machinery/mining/drill/D = holder
	. += ..()
	if(D.cell && !D.wires_power_disable )
		. += "The red light is [D.wires_shocked ? "off" : "on"]."
		. += "The yellow light is [D.wires_overload && D.wires_protector_disable ? "flashing!" : "on." ]"
		. += "The purpure light is [D.wires_radio_disable ? "off" : "on"]."
		. += "The blue light is [D.wires_power_disable ? "off" : "on"]."
		. += "The green light is [D.wires_protector_disable ? "off" : "on"]."
	else
		. += "The red light is off."
		. += "The yellow light is off."
		. += "The purpure light is off."
		. += "The blue light is off."
		. += "The green light is off."


/datum/wires/mining_drill/can_use()
	var/obj/machinery/mining/drill/D = holder
	return D.panel_open

/datum/wires/mining_drill/update_cut(index, mended, mob/user)
	var/obj/machinery/mining/drill/D = holder

	switch(index)
		if(MINING_DRILL_WIRES_SHOCK)
			D.wires_shocked = !mended

		if(MINING_DRILL_WIRES_OVERLOAD)
			D.wires_overload = !mended
			D.RefreshParts()

		if(MINING_DRILL_WIRES_RADIO_DISABLE)
			D.wires_radio_disable = !mended

		if(MINING_DRILL_WIRES_POWER_DISABLE)
			D.wires_power_disable = !mended

		if(MINING_DRILL_WIRES_PROTECTOR_DISABLE)
			D.wires_protector_disable = !mended
			D.RefreshParts()


/datum/wires/mining_drill/update_pulsed(index)
	var/obj/machinery/mining/drill/D = holder

	switch(index)
		if(MINING_DRILL_WIRES_SHOCK)
			D.wires_shocked = !D.wires_shocked

		if(MINING_DRILL_WIRES_OVERLOAD)
			D.wires_overload = !D.wires_overload
			D.RefreshParts()

		if(MINING_DRILL_WIRES_RADIO_DISABLE)
			D.wires_radio_disable = !D.wires_radio_disable

		if(MINING_DRILL_WIRES_POWER_DISABLE)
			D.wires_power_disable = !D.wires_power_disable

		if(MINING_DRILL_WIRES_PROTECTOR_DISABLE)
			D.wires_protector_disable = !D.wires_protector_disable
			D.RefreshParts()

	addtimer(CALLBACK(src, PROC_REF(pulse_reaction), index), 50)

/datum/wires/mining_drill/proc/pulse_reaction(index)
	var/obj/machinery/mining/drill/D = holder

	if(D && !is_index_cut(index))
		switch(index)

			if(MINING_DRILL_WIRES_SHOCK)
				D.wires_shocked = FALSE

			if(MINING_DRILL_WIRES_OVERLOAD)
				D.wires_overload = FALSE
				D.RefreshParts()

			if(MINING_DRILL_WIRES_RADIO_DISABLE)
				D.wires_radio_disable = FALSE

			if(MINING_DRILL_WIRES_POWER_DISABLE)
				D.wires_power_disable = FALSE

			if(MINING_DRILL_WIRES_PROTECTOR_DISABLE)
				D.wires_protector_disable = FALSE
				D.RefreshParts()
