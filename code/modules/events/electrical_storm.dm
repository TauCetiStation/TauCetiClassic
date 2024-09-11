/datum/event/electrical_storm
	announcement = new /datum/announcement/centcomm/estorm

	var/lightsoutRange	= 25

/datum/event/electrical_storm/start()
	var/list/possibleEpicentres = landmarks_list["lightsout"]
	if(!length(possibleEpicentres))
		return
	var/obj/effect/landmark/epicentre = pick(possibleEpicentres)
	for(var/obj/machinery/power/apc/apc in range(epicentre, lightsoutRange))
		apc.overload_lighting()
