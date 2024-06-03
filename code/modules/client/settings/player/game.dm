/datum/pref/player/game
	category = PREF_PLAYER_GAME

/datum/pref/player/game/melee_animation // todo: not only melee currently
	name = "melee animation"
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
