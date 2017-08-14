var/const/SMARTFRIDGE_WIRE_ELECTRIFY = 1
var/const/SMARTFRIDGE_WIRE_THROW     = 2
var/const/SMARTFRIDGE_WIRE_IDSCAN    = 4

/datum/wires/smartfridge
	holder_type = /obj/machinery/smartfridge
	wire_count = 3

/datum/wires/smartfridge/can_use()
	var/obj/machinery/smartfridge/S = holder
	return S.panel_open

/datum/wires/vending/additional_checks_and_effects(mob/living/user)
	var/obj/machinery/smartfridge/S = holder

	if(!S.ispowered)
		return FALSE

	if(S.seconds_electrified && !issilicon(user))
		if(S.shock(user, 100))
			return TRUE

/datum/wires/smartfridge/get_interact_window()
	var/obj/machinery/smartfridge/S = holder
	. += ..()
	. += "<br>The orange light is [S.seconds_electrified ? "off" : "on"]."
	. += "<br>The red light is [S.shoot_inventory ? "off" : "blinking"]."
	. += "<br>A [S.locked ? "purple" : "yellow"] light is on."

/datum/wires/smartfridge/update_cut(index, mended)
	var/obj/machinery/smartfridge/S = holder

	switch(index)
		if(SMARTFRIDGE_WIRE_THROW)
			S.shoot_inventory = !mended

		if(SMARTFRIDGE_WIRE_ELECTRIFY)
			if(mended)
				S.seconds_electrified = 0
			else
				S.seconds_electrified = -1

		if(SMARTFRIDGE_WIRE_IDSCAN)
			S.locked = !mended

/datum/wires/smartfridge/update_pulsed(index)
	var/obj/machinery/smartfridge/S = holder

	switch(index)
		if(SMARTFRIDGE_WIRE_THROW)
			S.shoot_inventory = !S.shoot_inventory

		if(SMARTFRIDGE_WIRE_ELECTRIFY)
			S.seconds_electrified = 30

		if(SMARTFRIDGE_WIRE_IDSCAN)
			S.locked = -1