/datum/hud/proc/monkey_hud()

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using

	add_intents(ui_style)

	using = new /atom/movable/screen/move_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	src.adding += using

	using = new /atom/movable/screen/inventory/hand/r()
	using.icon = ui_style
	using.update_icon(mymob)
	src.r_hand_hud_object = using
	src.adding += using

	using = new /atom/movable/screen/inventory/hand/l()
	using.icon = ui_style
	using.update_icon(mymob)
	src.l_hand_hud_object = using
	src.adding += using

	using = new /atom/movable/screen/inventory/swap/first()
	using.icon = ui_style
	src.adding += using

	using = new /atom/movable/screen/inventory/swap/second()
	using.icon = ui_style
	src.adding += using

	using = new /atom/movable/screen/inventory/mask/monkey()
	using.icon = ui_style
	src.adding += using

	using = new /atom/movable/screen/inventory/back()
	using.icon = ui_style
	src.adding += using

	mymob.throw_icon = new /atom/movable/screen/throw()
	mymob.throw_icon.icon = ui_style

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

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
