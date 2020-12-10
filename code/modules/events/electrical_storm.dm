/datum/event/electrical_storm
	var/lightsoutAmount	= 1
	var/lightsoutRange	= 25


/datum/event/electrical_storm/announce()
	command_alert("В вашем секторе обнаружен электростатический шторм. Пожалуйста, устраните потенциальные проблемы из-за перегрузки электронных систем.", "Система Оповещения [station_name()]", "estorm")


/datum/event/electrical_storm/start()
	var/list/epicentreList = list()

	for(var/i=1, i <= lightsoutAmount, i++)
		var/list/possibleEpicentres = list()
		for(var/obj/effect/landmark/newEpicentre in landmarks_list)
			if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
				possibleEpicentres += newEpicentre
		if(possibleEpicentres.len)
			epicentreList += pick(possibleEpicentres)
		else
			break

	if(!epicentreList.len)
		return

	for(var/obj/effect/landmark/epicentre in epicentreList)
		for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
			apc.overload_lighting()
