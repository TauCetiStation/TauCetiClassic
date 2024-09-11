/datum/component/cell_selfrecharge
	var/charge_add = 0

/datum/component/cell_selfrecharge/Initialize(_charge_per_tick = 2)
	if(!istype(parent, /obj/item/weapon/stock_parts/cell))
		return COMPONENT_INCOMPATIBLE

	//default is 1 energy per second
	charge_add = _charge_per_tick // SSobj tick is 2 second

	RegisterSignal(parent, list(COMSIG_CELL_CHARGE_CHANGED), PROC_REF(check_status))

/datum/component/cell_selfrecharge/proc/check_status(datum/source, charge, maxcharge)
	SIGNAL_HANDLER
	if(charge != maxcharge)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/datum/component/cell_selfrecharge/process()
	var/obj/item/weapon/stock_parts/cell/cell = parent
	cell.give(charge_add)

/datum/component/cell_selfrecharge/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, list(COMSIG_CELL_CHARGE_CHANGED))
	return ..()
