/obj/screen/corgi/ability
	name = "toggle licking or sniffing"
	icon_state = "ability0"

/obj/screen/corgi/ability/Click()
	var/mob/living/carbon/ian/IAN = usr //shouldn't be in anywhere else, so no type check.
	if(IAN.stat)
		return

	switch(alert("Do you want to lick or sniff something?",,"Nothing","Tongue","Nose"))
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

/obj/screen/corgi/stamina_bar
	name = "stamina"
	icon = 'icons/effects/staminabar.dmi'
	icon_state = "stam_bar_100"

/obj/screen/corgi/sit_lie
	name = "pose selector"
	icon_state = "sit_lie"

/obj/screen/corgi/sit_lie/Click(location, control,params)
	var/mob/living/carbon/ian/IAN = usr //shouldn't be in anywhere else, so no type check.
	if(IAN.stat)
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])

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

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	var/mob/living/carbon/ian/IAN = mymob //shouldn't be in anywhere else, so no type check.

	using = new
	using.name = "act_intent"
	using.icon = ui_style
	using.icon_state = "intent_" + mymob.a_intent
	using.screen_loc = ui_acti
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = new /obj/screen( src )
	using.name = INTENT_HELP
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	help_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = new /obj/screen( src )
	using.name = INTENT_PUSH
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	push_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = new /obj/screen( src )
	using.name = INTENT_GRAB
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	grab_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = new /obj/screen( src )
	using.name = INTENT_HARM
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	harm_intent = using

	using = new
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.hotkeybuttons += using

	using = new
	using.name = "mov_intent"
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	src.adding += using
	move_intent = using

	using = new /obj/screen/corgi/stamina_bar()
	using.icon_state = "stam_bar_[round(((IAN.stamina / 100) * 100), 5)]"
	using.screen_loc = ui_stamina
	src.adding += using
	staminadisplay = using

	using = new /obj/screen/corgi/sit_lie()
	using.icon = ui_style
	using.screen_loc = ui_ian_pselect
	src.adding += using

	using = new
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	inv_box = new
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_ian_head
	inv_box.slot_id = SLOT_HEAD
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	src.other += inv_box

	using = new /obj/screen/corgi/ability()
	using.icon = ui_style
	using.icon_state = "ability[IAN.ian_action]"
	using.screen_loc = ui_ian_ability
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	inv_box = new
	inv_box.name = "mouth"
	inv_box.icon = ui_style
	inv_box.icon_state = "mouth"
	inv_box.screen_loc = ui_ian_mouth
	inv_box.slot_id = SLOT_MOUTH
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_ian_neck
	inv_box.slot_id = SLOT_NECK
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	src.adding += inv_box

	inv_box = new
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_ian_back
	inv_box.slot_id = SLOT_BACK
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	src.adding += inv_box

	mymob.healths = new
	mymob.healths.icon = ui_style
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = new
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.cut_overlays()
	mymob.zone_sel.add_overlay(image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]"))

	mymob.client.screen = list(mymob.zone_sel, mymob.healths, mymob.pullin)
	mymob.client.screen += adding + other + hotkeybuttons
