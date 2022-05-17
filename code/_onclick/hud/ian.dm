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
	screen_loc = ui_ian_pselect

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

	ui_style = 'icons/mob/screen_corgi.dmi'

	add_intents(ui_style)

	var/types = list(
		/atom/movable/screen/resist/ian,
		/atom/movable/screen/corgi/sit_lie,
		/atom/movable/screen/drop,
	)
	init_screens(types, ui_style, list_to = hotkeybuttons)

	add_move_intent(ui_style)

	add_stamina_display()

	adding += get_screen(/atom/movable/screen/inventory/head/ian, ui_style)

	add_corgi_ability(ui_style)

	add_hands(ui_style, r_type = /atom/movable/screen/inventory/corgi_mouth, l_type = null)

	var/list/types = list(
		/atom/movable/screen/inventory/corgi_neck,
		/atom/movable/screen/inventory/back/ian
	)
	init_screens(types, ui_style, list_to = adding)

	add_healths(ui_style)
	add_pullin(ui_style)
	add_zone_sel(ui_style)
