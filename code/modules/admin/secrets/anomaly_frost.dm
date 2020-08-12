/datum/anomaly_frost
	var/list/impactedAreas
	var/Zlevel = 1
	var/Anounce = 0
	var/Temperature = 0
	var/Time = 110
	var/Speed = 1

/datum/anomaly_frost/proc/set_params(user)
	Zlevel = input(user, "Choose Z level to freeze.", "Z level number: ", 1) as num
	Temperature = input(user, "Choose target temperature in kelvins", "Temp: ", 170) as num
	Speed = input(user, "Choose freeze speed. 1 - slow, 100 - fast", "Speed: ", 2) as num
	Time = input(user, "Choose amount of frost ticks 1t = 1s.", "Ticks: ", 100) as num

	switch(alert(user, "Show frost alert to crew?",,"Yes","No"))
		if("Yes")
			command_alert("Atmospheric anomaly detected on long range scanners. Prepare for station temperature drop.", "Anomaly Alert")

	START_PROCESSING(SSobj, src)
	message_admins("Station freezing started!")

/datum/anomaly_frost/process()
	spawn(0)
		if(prob(Speed))
			for(var/zone/Z in SSair.zones)
				if(Z.air != null && Z.contents.len > 0)
					var/turf/T =pick(Z.contents)
					if(T.z == Zlevel)
						if(T.air.total_moles < 300)
							if(Z.air.temperature > Temperature + 1)
								Z.air.temperature -= 1
								sleep(1)
								Z.needs_update = TRUE
							if(Z.air.temperature < Temperature - 1)
								Z.air.temperature += 1
								sleep(1)
								Z.needs_update = TRUE

		Time -= 1
		if(Time < 0)
			STOP_PROCESSING(SSobj, src)
			message_admins("Station freezing stopped!")
			qdel(src)
