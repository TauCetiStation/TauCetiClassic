/datum/pref/player/game
	category = PREF_PLAYER_GAME

// If hotkey mode is enabled, then clicking the map will automatically
// unfocus the text bar. This removes the red color from the text bar
// so that the visual focus indicator matches reality.
/datum/pref/player/game/hotkey_mode
	name = "Hotkey mode"
	description = {"Если включено - фокус клавиатуры будет оставаться на игре. Рекомендуется, если вы используете WASD для движения и горячие клавиши.
Если выключено - фокус будет оставаться на чате. Этот вариант больше подходит тем, кто хочет использовать стрелочки для движения и печатать на ходу."}
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/game/hotkey_mode/on_update(client/client, old_value)
	if(value)
		winset(client, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")
	else
		winset(client, null, "input.focus=true input.background-color=[COLOR_INPUT_DISABLED]")

/datum/pref/player/game/melee_animation // todo: not only melee currently
	name = "Анимация ближнего боя"
	description = "Показывать или нет анимацию рукопашных атак."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/game/progressbar
	name = "Индикатор прогресса"
	description = "Показывать или нет анимированную шкалу для действий."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/game/endroundarena
	name = "Арена конца раунда"
	description = "Если включено - по окончанию раунда и до момента рестарта вы будете телепортированы на специальную гладиаторскую арену, где сможете выпустить весь накопившийся за раунд пар."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/datum/pref/player/game/ghost_skin
	name = "Вид призрака"
	description = {"Вид вашего приведения, если вы умерли или зашли в раунд как обсервер.
Выбор флаффа будет работать только в том случае, если у вас имеется залитый и одобренный флафф соответствующего типа."}
	value_type = PREF_TYPE_SELECT
	value = GHOST_SKIN_CHARACTER
	value_parameters = list(
		GHOST_SKIN_CHARACTER = "Персонаж", 
		GHOST_SKIN_GHOST = "Приведение", 
		GHOST_SKIN_FLUFF = "Флафф"
	)

/datum/pref/player/game/ghost_skin/on_update(client/client, old_value)
	if(client && isobserver(client.mob))
		var/mob/dead/observer/O = client.mob
		O.update_skin()
