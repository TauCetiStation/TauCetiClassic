/datum/catastrophe_event/normal_evacuation
	name = "Normal evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

/datum/catastrophe_event/normal_evacuation/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_NORMAL_EVAC_1)

			if(SSshuttle)
				SSshuttle.always_fake_recall = FALSE
				SSshuttle.fake_recall = 0

				SSshuttle.incall()