/datum/hud/proc/default_hud()
	add_intents()
	add_move_intent()
	adding += new /atom/movable/screen/inventory/craft

	add_zone_sel(ui_style, ui_color, ui_alpha)
	add_pullin(ui_style)

	add_changeling()

	inventory_shown = 0
