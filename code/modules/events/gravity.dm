/datum/event/gravity
	announceWhen = 5
	endWhen = 100
	var/affecting_z = 2

/datum/event/gravity/setup()
	endWhen = rand(30, 90)
	affecting_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))

/datum/event/gravity/announce()
	command_alert("Feedback surge detected in mass-distributions systems. Artificial gravity has been disabled whilst the system reinitializes.", "[station_name()] Gravity Subsystem", "gravoff")

/datum/event/gravity/start()
	for(var/area/A in world)
		if(A.z == affecting_z)
			A.gravitychange(FALSE)

/datum/event/gravity/end()
	for(var/area/A in world)
		if((A.z == affecting_z) && initial(A.has_gravity))
			A.gravitychange(TRUE)

	command_alert("Gravity generators are again functioning within normal parameters. Sorry for any inconvenience.", "[station_name()] Gravity Subsystem", "gravon")
