/datum/hud/proc/monkey_hud()

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/act_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	action_intent = using

//intent small hud objects
	using = new /atom/movable/screen/intent/help()
	using.update_icon(ui_style)
	src.adding += using
	help_intent = using

	using = new /atom/movable/screen/intent/push()
	using.update_icon(ui_style)
	src.adding += using
	push_intent = using

	using = new /atom/movable/screen/intent/grab()
	using.update_icon(ui_style)
	src.adding += using
	grab_intent = using

	using = new /atom/movable/screen/intent/harm()
	using.update_icon(ui_style)
	src.adding += using
	harm_intent = using

//end intent small hud objects

	using = new /atom/movable/screen/move_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/hand/r()
	inv_box.icon = ui_style
	inv_box.update_icon(mymob)
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/hand/l()
	inv_box.icon = ui_style
	inv_box.update_icon(mymob)
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /atom/movable/screen/inventory/swap/first()
	using.icon = ui_style
	src.adding += using

	using = new /atom/movable/screen/inventory/swap/second()
	using.icon = ui_style
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/mask/monkey()
	inv_box.icon = ui_style
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/back()
	inv_box.icon = ui_style
	src.adding += inv_box

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
