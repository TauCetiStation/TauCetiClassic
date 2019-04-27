/datum/catastrophe_event/anomaly_alert
	name = "Anomaly alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 4

	var/anomaly_timer = 20
	var/active_timer = 0
	var/timer_speed = 0.5

	manual_stop = TRUE

	var/list/anomaly_list = list(/datum/event/anomaly/anomaly_bluespace = 4, /datum/event/anomaly/anomaly_flux = 4, /datum/event/anomaly/anomaly_pyro = 2, /datum/event/anomaly/anomaly_vortex = 1)

/datum/catastrophe_event/anomaly_alert/on_step()
	switch(step)
		if(1)
			announce("Добрый день, Исход, говорит руководитель отдела исследовани[JA_PLACEHOLDER] аномалий Нанотрейзен. Наши датчики регистрируют необычные энергетические сигнатуры вокруг звезды Тау Кита. Пока что не о чём беспокоитс[JA_PLACEHOLDER], показатели на верхних границах нормы, но количество аномальных [JA_PLACEHOLDER]влений в вашем секторе может увеличитьс[JA_PLACEHOLDER]. Возможно, вам стоит выдать научным сотрудникам больше доступа дл[JA_PLACEHOLDER] своевременного реагировани[JA_PLACEHOLDER] на про[JA_PLACEHOLDER]влени[JA_PLACEHOLDER] аномальной активности.")
		if(2)
			announce("Так, у мен[JA_PLACEHOLDER] плоха[JA_PLACEHOLDER] новость дл[JA_PLACEHOLDER] вас. Аномальное поле не думает пропадать и по нашим расчётам ситуаци[JA_PLACEHOLDER] будет продолжать ухудшатьс[JA_PLACEHOLDER]. Мы никогда такое не видели, происходит что-то очень плохое. Я буду продолжать передавать вам информацию о состо[JA_PLACEHOLDER]нии аномального пол[JA_PLACEHOLDER] вокруг Тау Киты но его признаки начинают про[JA_PLACEHOLDER]вл[JA_PLACEHOLDER]тьс[JA_PLACEHOLDER] и здесь, на ЦК. Будьте осторожны, по всей системе вводитс[JA_PLACEHOLDER] особый фиолетовый код, напомню, что при нём ученые имеют расширенные права и сто[JA_PLACEHOLDER]т на первом месте в цепочке командовани[JA_PLACEHOLDER]")
			timer_speed = 1
		if(3)
			announce("Внимание, по неизвестным причинам ваша звезда Тау Кита начинает увеличиватьс[JA_PLACEHOLDER]. Двигатели станции с трудом удерживают орбиту. Готовьтесь к возможной глобальной эвакуации.")
			addtimer(CALLBACK(src, .proc/spawn_portalstorm), 10*5)
			timer_speed = 2
		if(4)
			announce("Господи, вы это видите, Исход?! Тау Кита только что превратилась в огромную черную дыру. Господи, она зат[JA_PLACEHOLDER]гивает вашу станцию. Мы пон[JA_PLACEHOLDER]ти[JA_PLACEHOLDER] не имеем, какое воздействие окажет на вас черна[JA_PLACEHOLDER] дыра и что вас ждёт. Де..жи…есь, св[JA_PLACEHOLDER]зь про…ает… да… ит…с бог%%##//")
			anomaly_timer = 10
			timer_speed = 3
			parallax_layer_global_override(PARALLAX_THEME_BLACKHOLE)

/datum/catastrophe_event/anomaly_alert/process_event()
	..()

	anomaly_timer -= timer_speed
	if(anomaly_timer <= 0)
		anomaly_timer = 300
		active_timer = rand(11,29) // 1-2 anomaly per 10 minutes


	if(active_timer > 0)
		if(active_timer % 10 == 0)
			var/anomaly_type = pickweight(anomaly_list)
			if(anomaly_type)
				new anomaly_type()
		active_timer -= 1

/datum/catastrophe_event/anomaly_alert/proc/spawn_portalstorm()
	wormhole_event()