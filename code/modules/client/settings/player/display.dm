/datum/pref/player/display
	category = PREF_PLAYER_DISPLAY

/datum/pref/player/display/fps
	name = "Кадры в секунду"
	description = "Может сильно влиять на производительность игры. Выставьте значение меньше, если испытываете проблемы."
	value_type = PREF_TYPE_RANGE
	value = RECOMMENDED_FPS
	value_parameters = list(1, 240)

/datum/pref/player/display/fps/on_update(client/client, old_value)
	if(client)
		client.fps = value

/datum/pref/player/display/fullscreen
	name = "Полноэкранный режим"
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/display/fullscreen/on_update(client/client, old_value)
	client?.update_fullscreen()

/datum/pref/player/display/auto_fit_viewport
	name = "Подгонять область просмотра"
	description = "Убирает вертикальные черные полосы, автоматически подстраивая ширину игровой области под высоту."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/display/auto_fit_viewport/on_update(client/client, old_value)
	if(value && client && !isnewplayer(client.mob)) // if new value requires to fit
		client.fit_viewport()

/datum/pref/player/display/auto_zoom
	name = "Автомасштабирование"
	description = "Подобрать масштаб автоматически, чтобы заполнить весь экран."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/display/auto_zoom/on_update(client/client, old_value)
	client?.update_map_zoom()

/datum/pref/player/display/zoom
	name = "Масштабирование"
	description = {"Масштабирование основного игрового экрана. Значения, кратные 100 (100, 200, 300, 400), дают лучшее качество спрайтов на любых методах масштабирования. В противном случае рекомендуется использовать автомасштабирование.
Эта опция игнорируется, если включено Автомасштабирование!"}
	value_type = PREF_TYPE_RANGE
	value = 100
	value_parameters = list(50, 400, 50, "%")

/datum/pref/player/display/zoom/on_update(client/client, old_value)
	client?.update_map_zoom()

/datum/pref/player/display/zoom_mode
	name = "Метод масштабирования"
	description = {"Метод сглаживания, используемый при масштабировании спрайтов.
Nearest Neighbor - даёт наибольшую четкость изображения, но может вызывать небольшие артефакты на не целом масштабировании (не кратном 100).
Bilinear - работает одинаково хорошо на любом масштабе, но делает изображение менее четким."}
	value_type = PREF_TYPE_SELECT
	value = SCALING_METHOD_DISTORT
	value_parameters = list(
		SCALING_METHOD_DISTORT = "Nearest Neighbor",
		SCALING_METHOD_NORMAL = "Bilinear"
	)

/datum/pref/player/display/zoom_mode/on_update(client/client, old_value)
	client?.update_map_zoom()
