/datum/pref/player/graphics
	category = PREF_PLAYER_GRAPHICS

/datum/pref/player/graphics/fps
	name = "Кадры в секунду"
	description = "Может сильно влиять на производительность игры. Выставьте значение меньше, если испытываете проблемы."
	value_type = PREF_TYPE_RANGE
	value = RECOMMENDED_FPS
	value_parameters = list(1, 240)

/datum/pref/player/graphics/fps/on_update(client/client, old_value)
	if(client)
		client.fps = value

/datum/pref/player/graphics/zoom
	name = "Масштабирование"
	description = "Масштабирование основного игрового экрана."
	value_type = PREF_TYPE_SELECT
	value = ICON_SCALE_AUTO
	value_parameters = list(
		ICON_SCALE_AUTO = "Авто",
		ICON_SCALE_16 = "x"+ICON_SCALE_16,
		ICON_SCALE_32 = "x"+ICON_SCALE_32,
		ICON_SCALE_48 = "x"+ICON_SCALE_48,
		ICON_SCALE_64 = "x"+ICON_SCALE_64,
		ICON_SCALE_80 = "x"+ICON_SCALE_80,
		ICON_SCALE_96 = "x"+ICON_SCALE_96,
		ICON_SCALE_112 = "x"+ICON_SCALE_112,
		ICON_SCALE_128 = "x"+ICON_SCALE_128
	)

/datum/pref/player/graphics/zoom/on_update(client/client, old_value)
	winset(client, "mapwindow.map", "zoom=[value]")

/datum/pref/player/graphics/zoom_mode
	name = "Метод масштабирования"
	description = "."
	value_type = PREF_TYPE_SELECT
	value = SCALING_METHOD_DISTORT
	value_parameters = list(
		SCALING_METHOD_BLUR = "Point Sampling",
		SCALING_METHOD_NORMAL = "Bilinear",
		SCALING_METHOD_DISTORT = "Nearest Neighbor"
	)

/datum/pref/player/graphics/zoom_mode/on_update(client/client, old_value)
	winset(client, "mapwindow.map", "zoom-mode=[value]")

/datum/pref/player/graphics/ambientocclusion
	name = "Ambient Occlusion"
	description = "Добавляет затенение для объектов в игре."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/graphics/ambientocclusion/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/game_world)

/datum/pref/player/graphics/parallax
	name = "Качество параллакса"
	description = "Качество анимации фонов в космосе. На высоких настройках может негативно влиять на производительность."
	value_type = PREF_TYPE_SELECT
	value = PARALLAX_HIGH
	value_parameters = list(
		PARALLAX_DISABLE = "Выключено", 
		PARALLAX_LOW = "Низкое", 
		PARALLAX_MED = "Среднее", 
		PARALLAX_HIGH = "Высокое", 
		PARALLAX_INSANE = "Безумное"
	)

/datum/pref/player/graphics/parallax/on_update(client/client, old_value)
	if(client?.mob?.hud_used)
		client.mob.hud_used.update_parallax_pref()

/datum/pref/player/graphics/glowlevel // aka light sources bloom
	name = "Уровень свечения"
	description = "Добавляет легкий блюр источникам свет. Подберите значение на свой вкус."
	value_type = PREF_TYPE_SELECT
	value = GLOW_MED
	value_parameters = list(
		GLOW_DISABLE = "Выключено", 
		GLOW_LOW = "Низкое", 
		GLOW_MED = "Среднее", 
		GLOW_HIGH = "Высокое"
	)

/datum/pref/player/graphics/glowlevel/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/lamps_selfglow)

/datum/pref/player/graphics/lampsexposure // still idk how to name it properly, spot light effect?
	name = "Направленный свет от ламп"
	description = "Визуально улучшает свет от ламп. Может влиять на производительность."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/graphics/lampsexposure/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/exposure)

/datum/pref/player/graphics/lampsglare
	name = "Блик от ламп"
	description = "..."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/graphics/lampsglare/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/lamps_glare)

/datum/pref/player/graphics/legacy_blur
	name = "Старый блюр зрения"
	description = "Использовать старый, менее затратный для производительности, эффект для повреждения/помех зрения персонажа."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/graphics/legacy_blur/on_update(client/client, old_value)
	client?.update_plane_masters(/atom/movable/screen/plane_master/game_world)

/datum/pref/player/graphics/lobbyanimation
	name = "Анимация экрана лобби"
	description = "Включает анимированное лобби. На некоторых системах работает плохо."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/graphics/lobbyanimation/on_update(client/client, old_value)
	if(client && isnewplayer(client.mob))
		var/mob/dead/new_player/M = client.mob
		M.show_titlescreen()
