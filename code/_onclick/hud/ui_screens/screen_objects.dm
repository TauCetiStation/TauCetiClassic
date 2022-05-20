/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	plane = HUD_PLANE
	flags = ABSTRACT
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/internal_switch = 0 // Cooldown for internal switching
	var/assigned_map
	var/del_on_map_removal = TRUE

	var/hud_slot = "adding"
	var/copy_flags = ALL

/atom/movable/screen/Destroy()
	master = null
	return ..()

/atom/movable/screen/proc/add_to_hud(datum/hud/hud)
	switch(hud_slot)
		if("adding")
			hud.adding += src
		if("hotkeys")
			hud.hotkeybuttons += src
		if("main")
			hud.main += src
		if("other")
			hud.other += src

	if(hud.hud_shown && hud_slot != "other")
		hud.mymob.client.screen += src
	update_by_hud(hud)
	
/atom/movable/screen/proc/update_by_hud(datum/hud/hud)
	if((copy_flags & 1) && hud.ui_style)
		icon = hud.ui_style
	if((copy_flags & 2) && hud.ui_alpha)
		alpha = hud.ui_alpha
	if((copy_flags & 4) && hud.ui_color)
		color = hud.ui_color
	
/atom/movable/screen/proc/remove_from_hud(datum/hud/hud)
	switch(hud_slot)
		if("adding")
			hud.adding -= src
		if("hotkeys")
			hud.hotkeybuttons -= src
		if("main")
			hud.main -= src
		if("other")
			hud.other -= src

	hud.mymob.client?.screen -= src

/atom/movable/screen/proc/action(location, control, params)
	return

/atom/movable/screen/Click(location, control, params)
	if(!usr)
		return

	SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)

	action(location, control, params)

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/close
	name = "close"

/atom/movable/screen/close/action()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)


/atom/movable/screen/grab
	name = "grab"

/atom/movable/screen/grab/action()
	if(master)
		var/obj/item/weapon/grab/G = master
		G.s_click(src)

/atom/movable/screen/grab/attack_hand()
	return

/atom/movable/screen/grab/attackby()
	return FALSE


/atom/movable/screen/storage
	name = "storage"
	var/obj/item/last_outlined // for removing outline from item

/atom/movable/screen/storage/Destroy()
	last_outlined = null
	return ..()

/atom/movable/screen/storage/action(location, control, params)
	if(world.time <= usr.next_move)
		return
	if(usr.incapacitated())
		return
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
			usr.next_move = world.time+2
			return

		var/obj/item/weapon/storage/S = master
		if(!S || !S.storage_ui)
			return
		// Taking something out of the storage screen (including clicking on item border overlay)
		var/list/PM = params2list(params)
		var/list/screen_loc_params = splittext(PM[SCREEN_LOC], ",")
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")
		var/click_x = text2num(screen_loc_X[1])*32+text2num(screen_loc_X[2]) - 144

		for(var/i=1,i<=S.storage_ui.click_border_start.len,i++)
			if (S.storage_ui.click_border_start[i] <= click_x && click_x <= S.storage_ui.click_border_end[i] && i <= S.contents.len)
				I = S.contents[i]
				if (I)
					I.Click(location, control, params)
					return

/atom/movable/screen/storage/MouseEntered(location, control, params)
	. = ..()
	if(!master)
		return
	var/obj/item/weapon/storage/S = master
	if(!S || !S.storage_ui)
		return
	// Taking something out of the storage screen (including clicking on item border overlay)
	var/list/PM = params2list(params)
	var/list/screen_loc_params = splittext(PM[SCREEN_LOC], ",")
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	var/click_x = text2num(screen_loc_X[1])*32+text2num(screen_loc_X[2]) - 144

	var/obj/item/I
	for(var/i in 1 to S.storage_ui.click_border_start.len)
		if (S.storage_ui.click_border_start[i] <= click_x && click_x <= S.storage_ui.click_border_end[i] && i <= S.contents.len)
			I = S.contents[i]
			if (I)
				last_outlined = I
				if(usr.incapacitated() || istype(usr.loc, /obj/mecha))
					I.apply_outline(COLOR_RED_LIGHT)
				else
					I.apply_outline()
				return

/atom/movable/screen/storage/MouseExited()
	. = ..()
	last_outlined?.remove_outline()
	last_outlined = null

/atom/movable/screen/storage/MouseDrop()
	. = ..()
	last_outlined?.remove_outline()
	last_outlined = null

/atom/movable/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	COOLDOWN_DECLARE(gun_click_time)

	hud_slot = "other"
	copy_flags = NONE

/atom/movable/screen/gun/action()
	if(!COOLDOWN_FINISHED(src, gun_click_time))
		return FALSE
	if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
		to_chat(usr, "You need your gun in your active hand to do that!")
		return FALSE
	COOLDOWN_START(src, gun_click_time, 3 SECONDS) //give them 3 seconds between mode changes.
	return TRUE

/atom/movable/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

/atom/movable/screen/gun/move/update_icon(client/client)
	name = "[client.target_can_move ? "Disallow" : "Allow"] Walking"
	icon_state = "no_walk[client.target_can_move]"

/atom/movable/screen/gun/move/action()
	if(..())
		usr.client.AllowTargetMove()

/atom/movable/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

/atom/movable/screen/gun/run/update_icon(client/client)
	name = "[client.target_can_run ? "Disallow" : "Allow"] Running"
	icon_state = "no_run[client.target_can_run]"

/atom/movable/screen/gun/run/action()
	if(..())
		usr.client.AllowTargetRun()

/atom/movable/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

/atom/movable/screen/gun/item/update_icon(client/client)
	name = "[client.target_can_click ? "Disallow" : "Allow"] Item Use"
	icon_state = "no_item[client.target_can_click]"

/atom/movable/screen/gun/item/action()
	if(..())
		usr.client.AllowTargetClick()

/atom/movable/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select

	hud_slot = "adding"

/atom/movable/screen/gun/mode/action()
	usr.client.ToggleGunMode()

/atom/movable/screen/gun/mode/update_icon(client/client)
	icon_state = client.gun_mode ? "gun1" : "gun0"

/atom/movable/screen/gun/mode/add_to_hud(datum/hud/hud)
	. = ..()
	var/client/client = hud.mymob.client

	update_icon(client)

	if(client.gun_mode)
		client.add_gun_icons()

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/action(location, control, params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return

	set_selected_zone(choice, usr)

/atom/movable/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/atom/movable/screen/zone_sel/MouseMove(location, control, params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'icons/mob/screen_gen.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/atom/movable/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					return BP_R_LEG
				if(17 to 22)
					return BP_L_LEG
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					return BP_R_LEG
				if(17 to 22)
					return BP_L_LEG
		if(10 to 13) //Arms and groin
			switch(icon_x)
				if(8 to 11)
					return BP_R_ARM
				if(12 to 20)
					return BP_GROIN
				if(21 to 24)
					return BP_L_ARM
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					return BP_R_ARM
				if(12 to 20)
					return BP_CHEST
				if(21 to 24)
					return BP_L_ARM
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							return O_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							return O_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							return O_EYES
				return BP_HEAD

/atom/movable/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(choice != selecting)
		selecting = choice
		var/mob/living/L = usr
		if(istype(L))
			L.update_combos()
		update_icon()

/atom/movable/screen/zone_sel/update_icon()
	cut_overlays()
	add_overlay(image('icons/mob/zone_sel.dmi', "[selecting]"))

/atom/movable/screen/zone_sel/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon()

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "pull1"
	screen_loc = ui_pull_resist

	hud_slot = "hotkeys"
	copy_flags = 1

/atom/movable/screen/pull/action()
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon(mob/mymob)
	icon_state = mymob.pulling ? "pull1" : "pull0"

/atom/movable/screen/pull/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/pull/robot
	screen_loc = ui_borg_pull

/atom/movable/screen/equip
	name = "equip"
	icon_state = "act_equip"
	screen_loc = ui_equip
	plane = ABOVE_HUD_PLANE

	hud_slot = "hotkeys"

/atom/movable/screen/equip/action()
	if(istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.quick_equip()

/atom/movable/screen/resist
	name = "resist"
	icon_state = "act_resist"
	screen_loc = ui_pull_resist
	plane = HUD_PLANE

	hud_slot = "hotkeys"

/atom/movable/screen/resist/action()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/atom/movable/screen/resist/ian
	screen_loc = ui_drop_throw

/atom/movable/screen/move_intent
	name = "mov_intent"
	screen_loc = ui_movi
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/move_intent/action()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.set_m_intent(C.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)

/atom/movable/screen/move_intent/update_icon(mob/mymob)
	icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")

/atom/movable/screen/move_intent/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/internal
	name = "internal"
	icon_state = "internal0"
	screen_loc = ui_internal

	copy_flags = 1

/atom/movable/screen/internal/update_icon(mob/living/carbon/mymob)
	if(!istype(mymob))
		return
	icon_state = mymob.internal ? "internal1" : "internal0"

/atom/movable/screen/internal/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/internal/action()
	if(!iscarbon(usr))
		return

	var/mob/living/carbon/C = usr
	if((C.incapacitated() && !C.weakened) || (internal_switch > world.time))
		return

	internal_switch = world.time + 16

	var/internalsound
	if(C.internal)
		C.internal = null
		to_chat(C, "<span class='notice'>No longer running on internals.</span>")
		internalsound = 'sound/misc/internaloff.ogg'
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
				internalsound = 'sound/misc/riginternaloff.ogg'
		playsound(C, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)
		update_icon(C)
		return

	if(!istype(C.wear_mask, /obj/item/clothing/mask))
		to_chat(C, "<span class='notice'>You are not wearing a mask.</span>")
		internal_switch = world.time + 8
		return

	if(!(C.wear_mask.flags & MASKINTERNALS))
		to_chat(C, "<span class='notice'>This mask doesn't support breathing through the tanks.</span>")
		return

	var/list/nicename
	var/list/tankcheck
	var/inhale_type = C.inhale_gas
	var/poison_type = C.poison_gas

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
		tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
	else
		nicename = list("Right Hand", "Left Hand", "Back")
		tankcheck = list(C.r_hand, C.l_hand, C.back)

	var/best = null
	var/bestcontents = 0

	for(var/i in 1 to tankcheck.len)
		var/obj/item/weapon/tank/t = tankcheck[i]
		if(!istype(t))
			continue

		var/datum/gas_mixture/t_gasses = t.air_contents.gas
		var/inhale = t_gasses[inhale_type]

		if(!t_gasses[poison_type] && inhale)
			if(bestcontents < inhale)
				best = i
				bestcontents = inhale

	//We've determined the best container now we set it as our internals

	if(best)
		to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] on your [nicename[best]].</span>")
		C.internal = tankcheck[best]
		internalsound = 'sound/misc/internalon.ogg'
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.head, /obj/item/clothing/head/helmet/space) && istype(H.wear_suit, /obj/item/clothing/suit/space))
				internalsound = 'sound/misc/riginternalon.ogg'
		playsound(C, internalsound, VOL_EFFECTS_MASTER, null, FALSE, null, -5)
		update_icon(C)
	else
		to_chat(C, "<span class='notice'>You don't have [inhale_type=="oxygen" ? "an" : "a"] [inhale_type] tank.</span>")

/atom/movable/screen/intent
	screen_loc = ui_acti
	plane = ABOVE_HUD_PLANE
	var/index

	copy_flags = NONE
	

/atom/movable/screen/intent/action()
	usr.set_a_intent(name)

/atom/movable/screen/intent/update_icon(atom/movable/screen/act_intent)
	var/icon/ico = new(act_intent.icon, act_intent.icon_state)
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	var/x1
	var/y1

	switch(index)
		if(1, 4)
			x1 = 1
		if(2, 3)
			x1 = ico.Width() / 2 + 1

	switch(index)
		if(1, 2)
			y1 = ico.Height() / 2 + 1
		if(3, 4)
			y1 = 1

	var/x2 = x1 + (ico.Width() / 2 - 1)
	var/y2 = y1 + (ico.Height() / 2 - 1)
	ico.DrawBox(rgb(255,255,255,1), x1, y1, x2, y2)
	icon = ico

/atom/movable/screen/intent/help
	name = INTENT_HELP
	index = 1

/atom/movable/screen/intent/push
	name = INTENT_PUSH
	index = 2

/atom/movable/screen/intent/grab
	name = INTENT_GRAB
	index = 3

/atom/movable/screen/intent/harm
	name = INTENT_HARM
	index = 4

/atom/movable/screen/throw
	name = "throw"
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

	hud_slot = "hotkeys"

/atom/movable/screen/throw/action()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/atom/movable/screen/drop
	name = "drop"
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	plane = HUD_PLANE

	hud_slot = "hotkeys"

/atom/movable/screen/drop/action()
	usr.drop_item()

/atom/movable/screen/nuke
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	screen_loc = "1,0"
	plane = SPLASHSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/temp
	plane = SPLASHSCREEN_PLANE
	var/mob/user
	var/delay = 0

/atom/movable/screen/temp/atom_init(mapload, mob/M)
	. = ..()
	user = M
	if(user.client)
		user.client.screen += src
	QDEL_IN(src, delay)

/atom/movable/screen/temp/Destroy()
	if(user.client)
		user.client.screen -= src
	user = null
	return ..()

/atom/movable/screen/temp/cult_teleportation
	name = "cult teleportation"
	icon = 'icons/effects/bloodTP.dmi'
	icon_state = "cult_tp"
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	delay = 8.5

/atom/movable/screen/cooldown_overlay
	name = ""
	icon_state = "cooldown"
	pixel_y = 4
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM | KEEP_TOGETHER | RESET_ALPHA
	vis_flags = VIS_INHERIT_ID
	var/cooldown_time = 0
	var/atom/movable/screen/parent_button
	var/datum/callback/callback
	var/timer

/atom/movable/screen/cooldown_overlay/atom_init(mapload, button)
	. = ..()
	parent_button = button

/atom/movable/screen/cooldown_overlay/Destroy()
	stop_cooldown()
	deltimer(timer)
	return ..()

/atom/movable/screen/cooldown_overlay/proc/start_cooldown(delay, need_timer = TRUE)
	parent_button.color = "#8000007c"
	parent_button.vis_contents += src
	cooldown_time = delay
	set_maptext(cooldown_time)
	if(need_timer)
		timer = addtimer(CALLBACK(src, .proc/tick), 1 SECOND, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/tick()
	if(cooldown_time == 1)
		stop_cooldown()
		return
	cooldown_time--
	set_maptext(cooldown_time)
	if(timer)
		timer = addtimer(CALLBACK(src, .proc/tick), 1 SECOND, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/stop_cooldown()
	cooldown_time = 0
	parent_button.color = "#ffffffff"
	parent_button.vis_contents -= src
	if(callback)
		callback.Invoke()

/atom/movable/screen/cooldown_overlay/proc/set_maptext(time)
	maptext = "<div style=\"font-size:6pt;font:'Arial Black';text-align:center;\">[time]</div>"

/proc/start_cooldown(atom/movable/screen/button, time, datum/callback/callback)
	if(!time)
		return
	var/atom/movable/screen/cooldown_overlay/cooldown = new(button, button)
	if(callback)
		cooldown.callback = callback
		cooldown.start_cooldown(time)
	else
		cooldown.start_cooldown(time, FALSE)
	return cooldown

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = ui_mood

	copy_flags = NONE

/atom/movable/screen/health
	name = "health"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "health0"
	screen_loc = ui_health

	copy_flags = 1

/atom/movable/screen/health/robot
	icon = 'icons/mob/screen1_robot.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/health_doll
	icon = 'icons/mob/screen_gen.dmi'
	name = "health doll"
	screen_loc = ui_healthdoll

	copy_flags = NONE

/atom/movable/screen/nutrition
	name = "nutrition"
	icon_state = "starving"
	screen_loc = ui_nutrition

	copy_flags = NONE

/atom/movable/screen/nutrition/update_icon(mob/living/carbon/human/mymob)
	icon = mymob.species.flags[IS_SYNTHETIC] ? 'icons/mob/screen_alert.dmi' : 'icons/mob/screen_gen.dmi'

/atom/movable/screen/nutrition/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)
