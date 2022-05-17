/datum/hud/proc/default_hud(ui_color = "#ffffff", ui_alpha = 255)
	add_intents(ui_style)
	add_move_intent(ui_style, ui_color, ui_alpha)
	adding += new /atom/movable/screen/inventory/craft

	add_zone_sel(ui_style, ui_color, ui_alpha)
	add_pullin(ui_style)

	lingchemdisplay = new /atom/movable/screen/chemical_display()

	mymob.client.screen += list(lingchemdisplay)
	inventory_shown = 0
