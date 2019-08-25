/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

	var/obj/effect/blob/core/Blob


/datum/event/blob/announce()
	command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak. The station crew isolation protocols are now active.", "Biohazard Alert", "outbreak5")


/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return
	Blob = new /obj/effect/blob/core(T, 120)
	for(var/i = 1; i < rand(3, 4), i++)
		Blob.process()


/datum/event/blob/tick()
	if(!Blob)
		kill()
		return
	if(IS_MULTIPLE(activeFor, 3))
		Blob.process()
