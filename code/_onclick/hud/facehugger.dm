/atom/movable/screen/inventory/tail
	name = "tail"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "hand_tail_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND


/datum/hud/proc/facehugger_hud()

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/act_intent/alien()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	action_intent = using

	using = new /atom/movable/screen/inventory/craft
	src.adding += using

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

	using = new /atom/movable/screen/move_intent/alien()
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/drop/alien()
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/tail()
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
