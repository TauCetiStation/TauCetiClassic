/atom/movable/screen/corgi/ability
	name = "toggle licking or sniffing"
	icon_state = "ability0"
	screen_loc = ui_ian_ability

/atom/movable/screen/corgi/ability/update_icon(mob/mymob)
	var/mob/living/carbon/ian/IAN = mymob
	icon_state = "ability[IAN.ian_action]"

/atom/movable/screen/corgi/ability/action()
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
	update_icon(IAN)

/atom/movable/screen/corgi/stamina_bar
	name = "stamina"
	icon = 'icons/effects/staminabar.dmi'
	icon_state = "stam_bar_100"
	screen_loc = ui_stamina

/atom/movable/screen/corgi/stamina_bar/update_icon(mob/mymob)
	var/mob/living/carbon/ian/IAN = mymob
	icon_state = "stam_bar_[round(IAN.stamina, 5)]"

/atom/movable/screen/corgi/sit_lie
	name = "pose selector"
	icon_state = "sit_lie"

/atom/movable/screen/corgi/sit_lie/action(location, control,params)
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
					IAN.ian_sit()

/atom/movable/screen/inventory/corgi_mouth
	name = "mouth"
	icon_state = "mouth"
	screen_loc = ui_ian_mouth
	slot_id = SLOT_MOUTH

/atom/movable/screen/inventory/corgi_neck
	name = "neck"
	icon_state = "id"
	screen_loc = ui_ian_neck
	slot_id = SLOT_NECK


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
	using.update_icon(mymob)
	src.adding += using
	staminadisplay = using

	using = new /atom/movable/screen/corgi/sit_lie()
	using.icon = ui_style
	using.screen_loc = ui_ian_pselect
	src.adding += using

	using = new /atom/movable/screen/drop
	using.icon = ui_style
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/head/ian
	inv_box.icon = ui_style
	src.other += inv_box

	using = new /atom/movable/screen/corgi/ability()
	using.icon = ui_style
	using.update_icon(mymob)
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/corgi_mouth
	inv_box.icon = ui_style
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/corgi_neck
	inv_box.icon = ui_style
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/back/ian
	inv_box.icon = ui_style
	src.adding += inv_box

	mymob.healths = new /atom/movable/screen/health
	mymob.healths.icon = ui_style

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.update_icon()

	mymob.client.screen = list(mymob.zone_sel, mymob.healths, mymob.pullin)
	mymob.client.screen += adding + other + hotkeybuttons
