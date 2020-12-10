/datum/event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 120

/datum/event/anomaly/anomaly_grav/announce()
	command_alert("На сканерах дальнего действия обнаружена гравитационная аномалия. Ожидаемое местоположение: [impact_area.name].", "Оповещение Об Аномалии", sound = "gravanom")

/datum/event/anomaly/anomaly_grav/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T)
