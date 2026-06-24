var/global/const/SLEEPER_WIRE_MEDBAY_ACC = 1
var/global/const/SLEEPER_WIRE_ACCESS     = 2

/datum/wires/sleeper
	holder_type = /obj/machinery/sleeper
	wire_count = 2

/datum/wires/sleeper/can_use()
	var/obj/machinery/sleeper/S = holder
	return S.panel_open

/datum/wires/sleeper/additional_checks_and_effects(mob/living/user)
	var/obj/machinery/sleeper/S = holder

	if(S.stat & (BROKEN|NOPOWER))
		return FALSE

/datum/wires/sleeper/get_status()
	var/obj/machinery/sleeper/S = holder
	. += ..()
	. += "The blue light is [S.medical_access ? "off" : "on"]."
	. += "The purple light is [(S.seller_account_number == global.department_accounts["Medical"].account_number) ? "blinking" : "off"]."

/datum/wires/sleeper/update_cut(index, mended, mob/user)
	var/obj/machinery/sleeper/S = holder

	switch(index)
		if(SLEEPER_WIRE_ACCESS)
			S.medical_access = mended

/datum/wires/sleeper/update_pulsed(index)
	var/obj/machinery/sleeper/S = holder

	switch(index)
		if(SLEEPER_WIRE_ACCESS)
			S.medical_access = !S.medical_access

		if(SLEEPER_WIRE_MEDBAY_ACC)
			if(S.seller_account_number != global.department_accounts["Medical"].account_number)
				S.seller_account_number = global.department_accounts["Medical"].account_number
			else
				S.seller_account_number = null
