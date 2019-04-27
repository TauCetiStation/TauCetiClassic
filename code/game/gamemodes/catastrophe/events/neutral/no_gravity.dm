/datum/catastrophe_event/no_gravity
	name = "No gravity"

	one_time_event = FALSE
	manual_stop = TRUE

	weight = 100

	event_type = "neutral"
	steps = 1

/datum/catastrophe_event/no_gravity/on_step()
	switch(step)
		if(1)
			announce("Обнаружены неполадки в стационном генераторе гравитации. Генератор отключён на неопределенный промежуток времени")

			for(var/area/A in all_areas)
				A.gravitychange(FALSE, A)

			var/time_diff = director.end_time - world.time

			if(time_diff < 10*60*2) // if everything is gonna end soon dont bother about bringing gravity back
				stop()
				return

			var/timer = time_diff * rand(30,70) / 100

			addtimer(CALLBACK(src, .proc/turn_gravity_on), timer)

/datum/catastrophe_event/no_gravity/proc/turn_gravity_on()
	announce("Генератор гравитации снова заработал")

	for(var/area/A in all_areas)
		A.gravitychange(TRUE, A)

	stop()