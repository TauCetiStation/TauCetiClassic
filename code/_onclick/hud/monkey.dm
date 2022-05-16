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
	
	mymob.internals = new /atom/movable/screen/internal()
	mymob.internals.icon = ui_style

	mymob.healths = new /atom/movable/screen/health()
	mymob.healths.icon = ui_style

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)

	lingchemdisplay = new /atom/movable/screen/chemical_display()

	lingstingdisplay = new /atom/movable/screen/current_sting()

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.update_icon()

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	mymob.gun_setting_icon.update_icon(mymob.client)

	if(mymob.client.gun_mode)
		mymob.client.add_gun_icons()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
