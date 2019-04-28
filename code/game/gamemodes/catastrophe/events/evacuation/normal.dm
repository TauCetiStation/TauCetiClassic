/datum/catastrophe_event/normal_evacuation
	name = "Normal evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

/datum/catastrophe_event/normal_evacuation/on_step()
	switch(step)
		if(1)
			announce("Исход, ситуаци[JA_PLACEHOLDER] достигла критического уровн[JA_PLACEHOLDER], мы высылаем эвакуационный шатл. Готовьтесь к абсолютной эвакуации, ваша станци[JA_PLACEHOLDER] объ[JA_PLACEHOLDER]вл[JA_PLACEHOLDER]етс[JA_PLACEHOLDER] дереликтом. Забирайте все, что можете унести и попытайтесь продержатьс[JA_PLACEHOLDER] до прибыти[JA_PLACEHOLDER] шатла.")

			if(SSshuttle)
				SSshuttle.always_fake_recall = FALSE
				SSshuttle.fake_recall = 0

				SSshuttle.incall()