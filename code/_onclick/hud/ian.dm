/atom/movable/screen/corgi/ability
	name = "toggle licking or sniffing"
	icon_state = "ability0"

/atom/movable/screen/corgi/ability/Click()
	var/mob/living/carbon/ian/IAN = usr //shouldn't be in anywhere else, so no type check.
	if(IAN.stat)
		return

	switch(tgui_alert(usr, "Do you want to lick or sniff something?",, list("Nothing","Tongue","Nose")))
		if("Nothing")
			if(IAN.ian_action == IAN_STANDARD) // Do nothing, if we already using this mode.
				return
			IAN.nose_memory = null
			to_chat(IAN, "<span class='notice'>Click action is now back to normal.</span>")
			IAN.ian_action = IAN_STANDARD
		if("Tongue")
			if(IAN.ian_action == IAN_LICK)
				return
			to_chat(IAN, "<span class='notice'>I want lick something!</span>") //>_<, you dummy!
			IAN.ian_action = IAN_LICK
		if("Nose")
			if(IAN.ian_action == IAN_SNIFF)
				return
			to_chat(IAN, "<span class='notice'>I want sniff something! (Click yourself to drop current smell)</span>")
			IAN.ian_action = IAN_SNIFF
	icon_state = "ability[IAN.ian_action]"

/atom/movable/screen/corgi/stamina_bar
	name = "stamina"
	icon = 'icons/effects/staminabar.dmi'
	icon_state = "stam_bar_100"

/atom/movable/screen/corgi/sit_lie
	name = "pose selector"
	icon_state = "sit_lie"

/atom/movable/screen/corgi/sit_lie/Click(location, control,params)
	var/mob/living/carbon/ian/IAN = usr //shouldn't be in anywhere else, so no type check.
	if(IAN.stat)
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])

	switch(icon_x)
		if(4 to 29)
			switch(icon_y)
				if(4 to 16)  // lie
					IAN.crawl()
				if(17 to 29) // sit
					IAN.lay_down()


/datum/hud/proc/ian_hud()
	if(!(is_alien_whitelisted(mymob, "ian") || (mymob.client.supporter && !is_alien_whitelisted_banned(mymob, "ian"))))
		return

	var/ui_style = 'icons/mob/screen_corgi.dmi'
	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	var/mob/living/carbon/ian/IAN = mymob //shouldn't be in anywhere else, so no type check.

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

	using = new /atom/movable/screen/resist/ian
	using.icon = ui_style
	src.hotkeybuttons += using

	using = new /atom/movable/screen/move_intent
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/corgi/stamina_bar()
	using.icon_state = "stam_bar_[round(((IAN.stamina / 100) * 100), 5)]"
	using.screen_loc = ui_stamina
	src.adding += using
	staminadisplay = using

	using = new /atom/movable/screen/corgi/sit_lie()
	using.icon = ui_style
	using.screen_loc = ui_ian_pselect
	src.adding += using

	using = new /atom/movable/screen/drop
	using.icon = ui_style
	src.adding += using

	inv_box = new
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_ian_head
	inv_box.slot_id = SLOT_HEAD
	inv_box.plane = HUD_PLANE
	src.other += inv_box

	using = new /atom/movable/screen/corgi/ability()
	using.icon = ui_style
	using.icon_state = "ability[IAN.ian_action]"
	using.screen_loc = ui_ian_ability
	using.plane = HUD_PLANE
	src.adding += using

	inv_box = new
	inv_box.name = "mouth"
	inv_box.icon = ui_style
	inv_box.icon_state = "mouth"
	inv_box.screen_loc = ui_ian_mouth
	inv_box.slot_id = SLOT_MOUTH
	inv_box.plane = HUD_PLANE
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_ian_neck
	inv_box.slot_id = SLOT_NECK
	inv_box.plane = HUD_PLANE
	src.adding += inv_box

	inv_box = new
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_ian_back
	inv_box.slot_id = SLOT_BACK
	inv_box.plane = HUD_PLANE
	src.adding += inv_box

	mymob.healths = new
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.cut_overlays()
	mymob.zone_sel.add_overlay(image('icons/mob/zone_sel.dmi', "[mymob.get_targetzone()]"))

	mymob.client.screen = list(mymob.zone_sel, mymob.healths, mymob.pullin)
	mymob.client.screen += adding + other + hotkeybuttons
