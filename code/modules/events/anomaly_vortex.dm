/datum/event/anomaly/anomaly_vortex
	startWhen = 10
	announceWhen = 3
	endWhen = 95

/datum/event/anomaly/anomaly_vortex/announce()
	command_alert("На сканерах дальнего действия локализованна высокоинтенсивная вихревая аномалия. Ожидаемое местоположение: [impact_area.name]", "Оповещение Об Аномалии", sound = "vortexanom")

/datum/event/anomaly/anomaly_vortex/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bhole(T)
