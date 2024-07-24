/datum/pref/player/chat
	category = PREF_PLAYER_CHAT

/* ooc chat settings */

/datum/pref/player/chat/show_ckey
	name = "Показывать Ckey в LOOC/Ghost"
	description = "Показать или скрыть ваш сикей (имя Byond-аккаунта), когда вы общаетесь в LOOC и Ghost чатах."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/ooccolor
	name = "ooccolor"
	description = "Цвет никнейма в OOC чате. Не даст поставить слишком темные и не читаемые цвета."
	value_type = PREF_TYPE_HEX
	value = DEFAULT_OOC_COLOR

	supporters_only = TRUE

/datum/pref/player/chat/ooccolor/sanitize_value(new_value)
	. = ..()
	if(.)
		. = normalize_color(.) // so people don't abuse unreadable colors

/datum/pref/player/chat/aooccolor
	name = "aooccolor"
	description = "Цвет теста в OOC чате. Не даст поставить слишком темные и не читаемые цвета."
	value_type = PREF_TYPE_HEX
	value = "#b82e00"

	admins_only = TRUE

/datum/pref/player/chat/aooccolor/sanitize_value(new_value)
	. = ..()
	if(.)
		. = normalize_color(.) // so people don't abuse unreadable colors

/datum/pref/player/chat/ooc
	name = "OOC чат"
	description = "Out of Character чат - общий серверный не игровой чат."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/looc
	name = "LOOC чат"
	description = "Local OOC чат - как и общий серверный не игровой чат, но действует в пределах экрана."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/dead
	name = "Чат мертвых"
	description = "Показывать или скрыть общий чат мертвых и обсерверов."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/* ghost chat settings */

/datum/pref/player/chat/ghostears
	name = "Призрачные уши"
	description = "Включить слышимость всех разговоров от других мобов и персонажей в игре, когда вы призрак. Если выключено - вы будете слышать только в пределах экрана."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/ghostsight //+
	name = "Призрачное зрение"
	description = "Включить видимость всех эмоутов от других мобов и персонажей в игре, когда вы призрак. Если выключено - вы будете видеть только в пределах экрана."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/ghostradio
	name = "Призрачное радио"
	description = "Включить слышимость всех разговоров по радио на станции будучи призраком. Если выключено - вы будете слышать только те источники радио, которые в пределах экрана."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/chat/ghostantispam
	name = "Призрачный антиспам"
	description = "Включите, если вы хотите подавить незначительные автоматические сообщения за пределами экрана, будь то эмоуты или разговоры, если их инициатор не игрок."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

/* admin chat settings */

/datum/pref/player/chat/attack_log
	name = "Логи атак"
	description = "."
	value_type = PREF_TYPE_SELECT
	value = ATTACK_LOG_BY_CLIENT
	value_parameters = list(
		ATTACK_LOG_DISABLED = "Выключены", 
		ATTACK_LOG_BY_CLIENT = "Только на клиентов", 
		ATTACK_LOG_ALL = "Все"
	)

	admins_only = TRUE

/datum/pref/player/chat/debug_log
	name = "Дебаг-логи"
	description = "."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE

	admins_only = TRUE

/datum/pref/player/chat/radio // how is it different with ghostradio???
	name = "Радио чат"
	description = "Toggle seeing radiochatter from radios and speakers"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

	admins_only = TRUE

/datum/pref/player/chat/prayers
	name = "Молитвы"
	description = "Показать/скрыть молитвы игроков"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

	admins_only = TRUE
