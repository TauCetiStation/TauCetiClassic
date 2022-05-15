/datum/hud/proc/human_hud(ui_color = "#ffffff", ui_alpha = 255)

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box
	var/mob/living/carbon/human/H = mymob

	using = new /atom/movable/screen/act_intent()
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

	inv_box = new /atom/movable/screen/inventory/uniform()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/suit()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/hand/r()
	inv_box.update_icon(mymob)
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/hand/l()
	inv_box.update_icon(mymob)
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

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

	inv_box = new /atom/movable/screen/inventory/id()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/mask()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/back()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/pocket1()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/pocket2()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/suit_storage()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

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

	inv_box = new /atom/movable/screen/inventory/gloves()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/eyes()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/l_ear()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/r_ear()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/head()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/shoes()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /atom/movable/screen/inventory/belt()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

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
	mymob.update_icon()

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
