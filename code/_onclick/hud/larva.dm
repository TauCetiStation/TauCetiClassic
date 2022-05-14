/datum/hud/proc/larva_hud()

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

	using = new /atom/movable/screen/move_intent/alien()
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "mouth"
	inv_box.set_dir(WEST)
	inv_box.icon = style
	inv_box.icon_state = "hand_larva_active"
	inv_box.screen_loc = ui_rhand
	inv_box.plane = HUD_PLANE
	inv_box.slot_id = SLOT_R_HAND
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	mymob.healths = new /atom/movable/screen/health/alien()

	mymob.pullin = new /atom/movable/screen/pull/alien()
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.update_icon()
	mymob.client.screen = list()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
