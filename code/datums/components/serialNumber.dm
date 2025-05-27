/datum/component/serialNumber
	var/serialNumber

/datum/component/serialNumber/Initialize(atom/target)
	serialNumber = generateSerialNumber()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(onExamine))
	var/area/A = get_area(target)
	if(A)
		var/obj/item/weapon/paper/P = A.inventoryPaper
		P?.info += "<hr><b>[target.name]</b><br><u>Серийный номер: [serialNumber]</u><br>"

/datum/component/serialNumber/proc/generateSerialNumber()
	serialNumber = "[rand(0, 999999)]"
	while(length(serialNumber) < 6)
		serialNumber = "0" + serialNumber

	return serialNumber

/datum/component/serialNumber/proc/onExamine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class = 'notice'>\nСерийный номер: [serialNumber]</span>")
