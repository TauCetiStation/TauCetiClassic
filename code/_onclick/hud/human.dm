/datum/hud/proc/human_hud(ui_color = "#ffffff", ui_alpha = 255)

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/atom/movable/screen/using
	var/mob/living/carbon/human/H = mymob

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

	using = new /atom/movable/screen/drop()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = new /atom/movable/screen/inventory/uniform()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/suit()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

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

	using = new /atom/movable/screen/inventory/swap/first()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/swap/second()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/id()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/mask()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/back()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/pocket1()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/pocket2()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/suit_storage()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new/atom/movable/screen/resist()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = new /atom/movable/screen/toggle()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/equip()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /atom/movable/screen/inventory/gloves()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/eyes()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/l_ear()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/r_ear()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/head()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/shoes()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.other += using

	using = new /atom/movable/screen/inventory/belt()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	mymob.throw_icon = new /atom/movable/screen/throw()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.throw_icon

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

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.healthdoll, mymob.nutrition_icon, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	mymob.client.screen += mymob.client.void
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
