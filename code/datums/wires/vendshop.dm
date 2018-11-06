var/const/VENDSHOP_WIRE_THROW        = 1
var/const/VENDSHOP_WIRE_ELECTRIFY    = 2
var/const/VENDSHOP_WIRE_IDSCAN       = 4
var/const/VENDSHOP_WIRE_PRODUCTCHECK = 8

/datum/wires/vendshop
	holder_type = /obj/machinery/vendshop
	wire_count = 4

/datum/wires/vendshop/can_use()
	var/obj/machinery/vendshop/V = holder
	return V.panel_open

/datum/wires/vendshop/additional_checks_and_effects(mob/living/user)
	var/obj/machinery/vendshop/V = holder

	if(V.stat & (BROKEN|NOPOWER))
		return FALSE

	if(V.seconds_electrified && !issilicon(user))
		if(V.shock(user, 100))
			return TRUE

/datum/wires/vendshop/get_interact_window()
	var/obj/machinery/vendshop/V = holder
	. += ..()
	. += "<br>The orange light is [V.seconds_electrified ? "off" : "on"]."
	. += "<br>The red light is [V.shoot_inventory ? "off" : "blinking"]."
	. += "<br>The [V.scan_id ? "purple" : "yellow"] light is on."
	. += "<br>The green light is [V.productcheck ? "on" : "off"]."

/datum/wires/vendshop/update_cut(index, mended)
	var/obj/machinery/vendshop/V = holder

	switch(index)
		if(VENDSHOP_WIRE_THROW)
			V.shoot_inventory = !mended

		if(VENDSHOP_WIRE_ELECTRIFY)
			if(mended)
				V.seconds_electrified = 0
			else
				V.seconds_electrified = -1

		if(VENDSHOP_WIRE_IDSCAN)
			V.scan_id = TRUE

		if(VENDSHOP_WIRE_PRODUCTCHECK)
			V.productcheck = TRUE

/datum/wires/vendshop/update_pulsed(index)
	var/obj/machinery/vendshop/V = holder

	switch(index)
		if(VENDSHOP_WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory

		if(VENDSHOP_WIRE_ELECTRIFY)
			V.seconds_electrified = 30

		if(VENDSHOP_WIRE_IDSCAN)
			V.scan_id = !V.scan_id

		if(VENDSHOP_WIRE_PRODUCTCHECK)
			V.productcheck = !V.productcheck