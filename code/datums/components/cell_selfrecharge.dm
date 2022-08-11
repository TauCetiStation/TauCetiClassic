/datum/component/cell_selfrecharge
	var/charge_add = 0

/datum/component/cell_selfrecharge/Initialize(_charge_per_second = 2, _charge_speed = 1.0)
	if(!istype(parent, /obj/item/weapon/stock_parts/cell))
		return COMPONENT_INCOMPATIBLE
	//default is 1 energy per second
	charge_add = _charge_per_second / _charge_speed
	RegisterSignal(parent, list(COMSIG_I_NEED_CHARGE), .proc/begin_charging)
	RegisterSignal(parent, list(COMSIG_I_AM_CHARGED), .proc/fullcharged)

/datum/component/cell_selfrecharge/proc/begin_charging(charge, maxcharge)
	SIGNAL_HANDLER
	if(charge != maxcharge)
		START_PROCESSING(SSobj, src)

/datum/component/cell_selfrecharge/process()
	var/obj/item/weapon/stock_parts/cell/cell = parent
	cell.give(charge_add)
	for(var/mob/living/silicon/robot/borg in get_turf(cell))
		borg.use_power(charge_add*2)
	for(var/obj/item/weapon/gun/energy/laser/selfcharging/gun in get_turf(cell))
		gun.update_icon()

/datum/component/cell_selfrecharge/proc/fullcharged()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)

/datum/component/cell_selfrecharge/Destroy()
	STOP_PROCESSING(SSobj, src)
	UnregisterSignal(parent, list(COMSIG_I_AM_CHARGED))
	return ..()
