/datum/component/serialNumber
	var/serialNumber

/datum/component/serialNumber/Initialize(atom/target)
	serialNumber = generateSerialNumber()
	global.withSerialNumber += target 	//Need to add this object in global list
	updateDescription(target)

/datum/component/serialNumber/proc/generateSerialNumber()
	serialNumber = "[rand(0, 999999)]"
	while(length(serialNumber) < 6)
		serialNumber = "0" + serialNumber

	return serialNumber

/datum/component/serialNumber/proc/updateDescription(atom/target)
	target.desc += "\nСерийный номер: [serialNumber]"

/datum/component/serialNumber/Destroy(atom/target)
	. = ..()

	global.withSerialNumber -= target
