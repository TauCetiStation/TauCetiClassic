/datum/component/serialNumber
	var/serialNumber

/datum/component/serialNumber/Initialize(obj/item/I)
	I.serialNumber = generateSerialNumber()
	global.withSerialNumber += I 	//Need to add this object in global list
	updateDescription(I)

/datum/component/serialNumber/proc/generateSerialNumber()
	var/list/activeSerialNumber = list()

	for(var/obj/item/I in global.withSerialNumber)
		activeSerialNumber += I.serialNumber

	var/processNumber
	do
		processNumber = "[rand(0, 999999)]"
		while(length(processNumber) < 6)
			processNumber = "0" + processNumber

	while(processNumber in activeSerialNumber)
	serialNumber = processNumber

	return serialNumber

/datum/component/serialNumber/proc/updateDescription(obj/item/I)
	I.desc += "\nСерийный номер: [serialNumber]"

/datum/component/serialNumber/Destroy(obj/item/I)
	. = ..()

	withSerialNumber -= I

/datum/component/serialNumber/proc/onAdd(obj/item/I)
	Initialize(I)
