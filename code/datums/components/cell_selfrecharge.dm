/datum/component/cell_selfrecharge
	var/charge_add = 0

/datum/component/cell_selfrecharge/Initialize(_charge_per_second = 2, _charge_speed = 1.0)
	if(!istype(parent, /obj/item/weapon/stock_parts/cell))
		return COMPONENT_INCOMPATIBLE
	//default is 1 energy per second
	charge_add = _charge_per_second / _charge_speed
	START_PROCESSING(SSobj, src)
	RegisterSignal(parent, list(COMSIG_I_AM_CHARGED), .proc/fullcharged)

/datum/component/cell_selfrecharge/process()
	var/obj/item/weapon/stock_parts/cell/cell = parent
	cell.give(charge_add)
	var/borg_cell_charge = charge_add * 2	//charge_per_second * process's tick
	SEND_SIGNAL(cell, COMSIG_TAKE_CYBORG_CHARGE, borg_cell_charge)
	SEND_SIGNAL(cell, COMSIG_UPDATE_MY_ICON)

/datum/component/cell_selfrecharge/proc/fullcharged()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)

/datum/component/cell_selfrecharge/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, list(COMSIG_I_AM_CHARGED))
	return ..()
