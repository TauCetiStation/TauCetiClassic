/datum/catastrophe_event/lastchance_evacuation
	name = "Last Chance evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

/datum/catastrophe_event/lastchance_evacuation/on_step()
	switch(step)
		if(1)
			announce("Исход, ситуаци[JA_PLACEHOLDER] полностью вышла из-под контрол[JA_PLACEHOLDER]. Начинаетс[JA_PLACEHOLDER] эвакуаци[JA_PLACEHOLDER] по всей системе. Вашей станции с огромным трудом был выделен эвакуационный шатл, это  ваш последний шанс свалить. Пакуйте чемоданы, космическа[JA_PLACEHOLDER] научна[JA_PLACEHOLDER] станци[JA_PLACEHOLDER] Исход закрываетс[JA_PLACEHOLDER]")

			if(SSshuttle)
				SSshuttle.always_fake_recall = FALSE
				SSshuttle.fake_recall = 0

				SSshuttle.incall()