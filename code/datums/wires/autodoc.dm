var/global/const/AUTODOC_WIRE_MEDBAY_ACC = 1
var/global/const/AUTODOC_WIRE_ACCESS     = 2

/datum/wires/autodoc
	holder_type = /obj/machinery/autodoc
	wire_count = 2

/datum/wires/autodoc/can_use()
	var/obj/machinery/sleeper/S = holder
	return S.panel_open

/datum/wires/autodoc/additional_checks_and_effects(mob/living/user)
	var/obj/machinery/sleeper/S = holder

	if(S.stat & (BROKEN|NOPOWER))
		return FALSE

/datum/wires/autodoc/get_status()
	var/obj/machinery/autodoc/A = holder
	. += ..()
	. += "The blue light is [A.medical_access ? "off" : "on"]."
	. += "The purple light is [(A.seller_account_number == global.department_accounts["Medical"].account_number) ? "blinking" : "off"]."

/datum/wires/autodoc/update_cut(index, mended, mob/user)
	var/obj/machinery/autodoc/A = holder

	switch(index)
		if(AUTODOC_WIRE_ACCESS)
			A.medical_access = mended

/datum/wires/autodoc/update_pulsed(index)
	var/obj/machinery/autodoc/A = holder

	switch(index)
		if(AUTODOC_WIRE_ACCESS)
			A.medical_access = !A.medical_access

		if(AUTODOC_WIRE_MEDBAY_ACC)
			if(A.seller_account_number != global.department_accounts["Medical"].account_number)
				A.seller_account_number = global.department_accounts["Medical"].account_number
			else
				A.seller_account_number = null
