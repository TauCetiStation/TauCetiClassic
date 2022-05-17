/datum/hud/proc/monkey_hud()
	add_intents(ui_style)
	add_move_intent(ui_style)
	add_hands(ui_style)

	// hotkeys
	var/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
	)
	init_screens(types, ui_style, list_to = hotkeybuttons)

	// inventory
	types = list(
		/atom/movable/screen/inventory/mask/monkey,
		/atom/movable/screen/inventory/back,
	)
	init_screens(types, ui_style, list_to = adding)

	add_throw_icon(ui_style)
	add_internals(ui_style)
	add_healths(ui_style)
	add_pullin(ui_style)

	lingchemdisplay = new /atom/movable/screen/chemical_display()

	lingstingdisplay = new /atom/movable/screen/current_sting()

	add_zone_sel(ui_style)

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	mymob.gun_setting_icon.update_icon(mymob.client)

	if(mymob.client.gun_mode)
		mymob.client.add_gun_icons()

	mymob.client.screen += list(mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
