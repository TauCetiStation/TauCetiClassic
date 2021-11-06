/datum/event/gravity
	announceWhen = 5
	endWhen = 100
	announcement = new /datum/announcement/station/gravity_off
	announcement_end = new /datum/announcement/station/gravity_on

	var/affecting_z = 2

/datum/event/gravity/setup()
	endWhen = rand(30, 90)
	affecting_z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))

/datum/event/gravity/start()
	for(var/area/A in world)
		if(A.z == affecting_z)
			A.gravitychange(FALSE)

/datum/event/gravity/end()
	for(var/area/A in world)
		if((A.z == affecting_z) && initial(A.has_gravity))
			A.gravitychange(TRUE)
	..()
