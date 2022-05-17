/datum/hud/proc/default_hud(ui_color = "#ffffff", ui_alpha = 255)
	add_intents(ui_style)
	add_move_intent(ui_style, ui_color, ui_alpha)
	adding += new /atom/movable/screen/inventory/craft

	add_zone_sel(ui_style, ui_color, ui_alpha)
	add_pullin(ui_style)

	add_changeling()

	inventory_shown = 0
