/datum/pref/player/ui
	category = PREF_PLAYER_UI

/datum/pref/player/ui/runechat
	name = "Runechat"
	description = "Чат над головой персонажей"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/ui_style
	name = "Стиль UI"
	description = "Стиль интерфейса игры"
	value_type = PREF_TYPE_SELECT
	value = UI_STYLE_WHITE
	value_parameters = list(UI_STYLE_WHITE, UI_STYLE_MIDNIGHT, UI_STYLE_OLD, UI_STYLE_ORANGE)

/datum/pref/player/ui/ui_style/on_update(client/client, old_value)
	client.mob.hud_used.ui_style = global.available_ui_styles[value]
	client.mob.refresh_hud()

/datum/pref/player/ui/ui_style_color
	name = "Цвет UI"
	description = "Цвет интерфейса игры, опция лучше всего работает с белым стилем"
	value_type = PREF_TYPE_HEX
	value = "#ffffff"

/datum/pref/player/ui/ui_style_color/on_update(client/client, old_value)
	client.mob.hud_used.ui_color = value
	client.mob.refresh_hud()

/datum/pref/player/ui/ui_style_opacity
	name = "Прозрачность UI"
	description = "Прозрачность интерфейса игры"
	value_type = PREF_TYPE_RANGE
	value = 0
	value_parameters = list(0, 100)

/datum/pref/player/ui/ui_style_opacity/on_update(client/client, old_value)
	client.mob.hud_used.ui_alpha = 255 - floor(255*value/100)
	client.mob.refresh_hud()

/datum/pref/player/ui/outline
	name = "Подсветка предметов"
	description = "По наведению мышью на предмет в игре, у него появится соответствующий контур."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/outline_color
	name = "Цвет подсветки"
	value_type = PREF_TYPE_HEX
	value = "#33ccff"

/datum/pref/player/ui/tooltip
	name = "Всплывающая подсказка"
	description = "Подсказку в верхней части экрана, появляющаяся по наведению мышью на предмет в игре."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/tooltip/on_update(client/client, old_value)
	client.tooltip.set_state(value)

// i don't understand why we need it in preferences, pls don't add more fonts or styles preferences like this
/datum/pref/player/ui/tooltip_font
	name = "Шрифт подсказки"
	value_type = PREF_TYPE_SELECT
	value = FONT_SMALL_FONTS
	value_parameters = list(
		FONT_SYSTEM,
		FONT_FIXEDSYS,
		FONT_SMALL_FONTS,
		FONT_TIMES_NEW_ROMAN,
		FONT_SERIF,
		FONT_VERDANA
	)

/datum/pref/player/ui/tooltip_size
	name = "Размер подсказки"
	value_type = PREF_TYPE_RANGE
	value = 8
	value_parameters = list(1, 15)

/datum/pref/player/ui/tgui_lock
	name = "TGUI только на основном мониторе"
	description = "Блокирует перемещение окон tgui за пределы экрана"
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE
