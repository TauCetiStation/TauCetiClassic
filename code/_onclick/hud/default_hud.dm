/datum/hud/proc/default_hud(ui_color = "#ffffff", ui_alpha = 255)
	add_intents(ui_style)
	add_move_intent(ui_style, ui_color, ui_alpha)
	adding += new /atom/movable/screen/inventory/craft

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.update_icon()

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	src.hotkeybuttons += mymob.pullin

	lingchemdisplay = new /atom/movable/screen/chemical_display()

	mymob.client.screen += list(mymob.zone_sel, lingchemdisplay)
	inventory_shown = 0
