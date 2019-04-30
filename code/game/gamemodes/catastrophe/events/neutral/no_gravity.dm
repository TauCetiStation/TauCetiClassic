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
			announce("Îáíàðóæåíû íåïîëàäêè â ñòàöèîííîì ãåíåðàòîðå ãðàâèòàöèè. Ãåíåðàòîð îòêëþ÷¸í íà íåîïðåäåëåííûé ïðîìåæóòîê âðåìåíè")

			for(var/area/A in all_areas)
				A.gravitychange(FALSE, A)

			var/time_diff = director.end_time - world.time

			if(time_diff < 2 MINUTES) // if everything is gonna end soon dont bother about bringing gravity back
				stop()
				return

			var/timer = time_diff * rand(30, 70) / 100

			addtimer(CALLBACK(src, .proc/turn_gravity_on), timer)

/datum/catastrophe_event/no_gravity/proc/turn_gravity_on()
	announce("Ãåíåðàòîð ãðàâèòàöèè ñíîâà çàðàáîòàë")

	for(var/area/A in all_areas)
		A.gravitychange(TRUE, A)

	stop()
