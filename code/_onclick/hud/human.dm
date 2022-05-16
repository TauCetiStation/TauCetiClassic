/datum/hud/proc/human_hud(ui_color = "#ffffff", ui_alpha = 255)
	var/atom/movable/screen/using
	var/mob/living/carbon/human/H = mymob

	add_intents(ui_style)

	using = new /atom/movable/screen/move_intent()
	using.icon = ui_style
	using.update_icon(mymob)
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

	// hiddable inventory
	var/list/types = list(
		/atom/movable/screen/inventory/uniform,
		/atom/movable/screen/inventory/suit,
		/atom/movable/screen/inventory/id,
		/atom/movable/screen/inventory/mask,
		/atom/movable/screen/inventory/gloves,
		/atom/movable/screen/inventory/eyes,
		/atom/movable/screen/inventory/l_ear,
		/atom/movable/screen/inventory/r_ear,
		/atom/movable/screen/inventory/head,
		/atom/movable/screen/inventory/shoes,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, other)

	using = new /atom/movable/screen/inventory/hand/r()
	using.update_icon(mymob)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.r_hand_hud_object = using
	src.adding += using

	using = new /atom/movable/screen/inventory/hand/l()
	using.update_icon(mymob)
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.l_hand_hud_object = using
	src.adding += using

	// simple hotkeys
	types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
		/atom/movable/screen/throw,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, hotkeybuttons)

	// visible inventory, inventory toggle and craft
	types = list(
		/atom/movable/screen/inventory/craft,
		/atom/movable/screen/toggle,
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/inventory/pocket1,
		/atom/movable/screen/inventory/pocket2,
		/atom/movable/screen/inventory/suit_storage,
		/atom/movable/screen/inventory/belt,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, adding)

	mymob.internals = new /atom/movable/screen/internal()
	mymob.internals.icon = ui_style
	mymob.internals.update_icon(mymob)

	mymob.healths = new /atom/movable/screen/health()

	mymob.healthdoll = new /atom/movable/screen/health_doll()

	mymob.nutrition_icon = new  /atom/movable/screen/nutrition()
	mymob.nutrition_icon.update_icon(mymob)

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	src.hotkeybuttons += mymob.pullin

	lingchemdisplay = new /atom/movable/screen/chemical_display()

	lingstingdisplay = new /atom/movable/screen/current_sting()

	mymob.pain = new /atom/movable/screen( null )

	mymob.zone_sel = new /atom/movable/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.update_icon()

	if(isanycop(H) || isanygangster(H))
		wanted_lvl = new /atom/movable/screen/wanted()
		adding += wanted_lvl

	if(mymob.leap_icon)
		src.adding += mymob.leap_icon

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	mymob.gun_setting_icon.update_icon(mymob.client)

	if(mymob.client.gun_mode)
		mymob.client.add_gun_icons()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.healthdoll, mymob.nutrition_icon, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	inventory_shown = 0


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1
