/datum/hud/proc/default_hud(ui_color = "#ffffff", ui_alpha = 255)
	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/atom/movable/screen/using

	add_intents(ui_style)

	using = new /atom/movable/screen/inventory/craft
	src.adding += using

	using = new /atom/movable/screen/move_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

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

	mymob.client.screen = list()

	mymob.client.screen += list(mymob.zone_sel)
	mymob.client.screen += src.adding + src.hotkeybuttons
	inventory_shown = 0
