/datum/pref/player/ui
	category = PREF_PLAYER_UI

/datum/pref/player/ui/auto_fit_viewport
	name = "Fit viewport"
	description = "Автоматически подстраивать размер правой колонки под окно игры (убирает черные полосы)."
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/auto_fit_viewport/on_update(client/client, old_value)
	if(value && client) // if new value requires to fit
		client.fit_viewport()

/datum/pref/player/ui/runechat
	name = "Runechat"
	description = "Чат над головой персонажей"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/ui_style
	name = "ui style"
	description = "Стиль интерфейса игры"
	value_type = PREF_TYPE_SELECT
	value = UI_STYLE_WHITE
	value_parameters = list(UI_STYLE_WHITE, UI_STYLE_MIDNIGHT, UI_STYLE_OLD, UI_STYLE_ORANGE)

/datum/pref/player/ui/ui_style/on_update(client/client, old_value)
	client.mob.hud_used.ui_style = value

	var/list/screens = client.mob.hud_used.main + client.mob.hud_used.adding + client.mob.hud_used.hotkeybuttons // todo hud method 
	for(var/atom/movable/screen/complex/complex as anything in client.mob.hud_used.complex)
		screens += complex.screens

	for(var/atom/movable/screen/screen as anything in screens)
		screen.update_by_hud(client.mob.hud_used)

/datum/pref/player/ui/ui_style_color
	name = "ui style color"
	description = "Цвет интерфейса игры (рекомендуется для белого стиля)"
	value_type = PREF_TYPE_HEX
	value = "#ffffff"

/datum/pref/player/ui/ui_style_color/on_update(client/client, old_value)
	client.mob.hud_used.ui_color = value
	var/list/screens = client.mob.hud_used.main + client.mob.hud_used.adding + client.mob.hud_used.hotkeybuttons
	for(var/atom/movable/screen/complex/complex as anything in client.mob.hud_used.complex)
		screens += complex.screens

	for(var/atom/movable/screen/screen as anything in screens)
		screen.update_by_hud(client.mob.hud_used)

/datum/pref/player/ui/ui_style_opacity
	name = "ui style alpha"
	description = "Прозрачность интерфейса игры"
	value_type = PREF_TYPE_RANGE
	value = 0
	value_parameters = list(0, 100)

/datum/pref/player/ui/ui_style_opacity/on_update(client/client, old_value)
	client.mob.hud_used.ui_alpha = 255 - floor(255*value/100) // todo 100 not works for some reason
	var/list/screens = client.mob.hud_used.main + client.mob.hud_used.adding + client.mob.hud_used.hotkeybuttons
	for(var/atom/movable/screen/complex/complex as anything in client.mob.hud_used.complex)
		screens += complex.screens

	for(var/atom/movable/screen/screen as anything in screens)
		screen.update_by_hud(client.mob.hud_used)

/datum/pref/player/ui/outline
	name = "outline"
	description = "Подсветка предметов по наведению мышью"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/outline_color
	name = "outline color"
	description = "Цвет подсветки"
	value_type = PREF_TYPE_HEX
	value = "#33ccff"

/datum/pref/player/ui/tooltip
	name = "tooltip"
	description = "Всплывающая подсказка для предметов"
	value_type = PREF_TYPE_BOOLEAN
	value = TRUE

/datum/pref/player/ui/tooltip/on_update(client/client, old_value)
	client.tooltip.set_state(value)

/datum/pref/player/ui/tooltip_font
	name = "tooltip font"
	description = "Шрифт всплывающей подсказки"
	value_type = PREF_TYPE_SELECT
	value = "Small Fonts" // define it
	value_parameters = list(
		"System", 
		"Fixedsys", 
		"Small Fonts", 
		"Times New Roman", 
		"Serif", 
		"Verdana", 
		"Custom Font"
	)

/datum/pref/player/ui/tooltip_size
	name = "tooltip font"
	description = "Размер всплывающей подсказки"
	value_type = PREF_TYPE_RANGE
	value = 8
	value_parameters = list(1, 15)

/datum/pref/player/ui/tgui_lock
	name = "TGUI только на основном мониторе"
	description = "..."
	value_type = PREF_TYPE_BOOLEAN
	value = FALSE
