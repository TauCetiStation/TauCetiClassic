var/const/VENDING_WIRE_THROW      = 1
var/const/VENDING_WIRE_CONTRABAND = 2
var/const/VENDING_WIRE_ELECTRIFY  = 4
var/const/VENDING_WIRE_IDSCAN     = 8
var/const/VENDING_WIRE_SHUT_UP    = 16

/datum/wires/vending
	holder_type = /obj/machinery/vending
	wire_count = 5

/datum/wires/vending/can_use()
	var/obj/machinery/vending/V = holder
	return V.panel_open

/datum/wires/vending/additional_checks_and_effects(mob/living/user)
	var/obj/machinery/vending/V = holder

	if(V.stat & (BROKEN|NOPOWER))
		return FALSE

	if((world.time < V.electrified_until || V.electrified_until < 0) && !issilicon(user))
		if(V.shock(user, 100))
			return TRUE

/datum/wires/vending/get_interact_window()
	var/obj/machinery/vending/V = holder
	. += ..()
	. += "<br>The orange light is [(world.time < V.electrified_until || V.electrified_until < 0) ? "off" : "on"]."
	. += "<br>The red light is [V.shoot_inventory ? "off" : "blinking"]."
	. += "<br>The green light is [V.extended_inventory ? "on" : "off"]."
	. += "<br>The [V.scan_id ? "purple" : "yellow"] light is on."
	. += "<br>The blue light is [V.shut_up ? "off" : "on"]."

/datum/wires/vending/update_cut(index, mended)
	var/obj/machinery/vending/V = holder

	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !mended
			V.update_wires_check()

		if(VENDING_WIRE_CONTRABAND)
			V.set_extended_inventory(!mended)

		if(VENDING_WIRE_ELECTRIFY)
			if(mended)
				V.electrified_until = 0
			else
				V.electrified_until = -1

		if(VENDING_WIRE_IDSCAN)
			V.scan_id = TRUE

		if(VENDING_WIRE_SHUT_UP)
			V.shut_up = !mended
			V.update_wires_check()

/datum/wires/vending/update_pulsed(index)
	var/obj/machinery/vending/V = holder

	switch(index)
		if(VENDING_WIRE_THROW)
			V.shoot_inventory = !V.shoot_inventory
			V.update_wires_check()

		if(VENDING_WIRE_CONTRABAND)
			V.set_extended_inventory(!V.extended_inventory)

		if(VENDING_WIRE_ELECTRIFY)
			V.electrified_until = world.time + 30 SECONDS

		if(VENDING_WIRE_IDSCAN)
			V.scan_id = !V.scan_id

		if(VENDING_WIRE_SHUT_UP)
			V.shut_up = !V.shut_up
			V.update_wires_check()