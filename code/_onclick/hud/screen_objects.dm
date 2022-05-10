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
	var/gun_click_time = -100 //I'm lazy.
	var/internal_switch = 0 // Cooldown for internal switching
	var/assigned_map
	var/del_on_map_removal = TRUE

/atom/movable/screen/Destroy()
	master = null
	return ..()

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/atom/movable/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/atom/movable/screen/close
	name = "close"

/atom/movable/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
	return TRUE


/atom/movable/screen/grab
	name = "grab"

/atom/movable/screen/grab/Click()
	if(master)
		var/obj/item/weapon/grab/G = master
		G.s_click(src)
	return TRUE

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

/atom/movable/screen/storage/Click(location, control, params)
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated())
		return TRUE
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return TRUE
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			master.attackby(I, usr, params)
			usr.next_move = world.time+2
			return TRUE

		var/obj/item/weapon/storage/S = master
		if(!S || !S.storage_ui)
			return TRUE
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
					return TRUE
	return TRUE

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
	master = null

/atom/movable/screen/gun/move
	name = "Allow Walking"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

/atom/movable/screen/gun/run
	name = "Allow Running"
	icon_state = "no_run0"
	screen_loc = ui_gun3

/atom/movable/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

/atom/movable/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select
	//dir = 1

/atom/movable/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST
	var/static/list/hover_overlays_cache = list()
	var/hovering

/atom/movable/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL[ICON_X])
	var/icon_y = text2num(PL[ICON_Y])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return TRUE

	return set_selected_zone(choice, usr)

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
	return TRUE

/atom/movable/screen/zone_sel/update_icon()
	cut_overlays()
	add_overlay(image('icons/mob/zone_sel.dmi', "[selecting]"))

/atom/movable/screen/pull
	name = "stop pulling"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "pull1"

/atom/movable/screen/pull/Click()
	usr.stop_pulling()

/atom/movable/screen/pull/update_icon(mob/mymob)
	if(!mymob) return
	if(mymob.pulling)
		icon_state = "pull1"
	else
		icon_state = "pull0"

/atom/movable/screen/toggle
	name = "toggle"
	icon = ui_style
	icon_state = "other"
	screen_loc = ui_inventory
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/equip
	name = "equip"
	icon_state = "act_equip"
	screen_loc = ui_equip
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/current_sting
	icon = 'icons/mob/screen_gen.dmi'
	name = "current sting"
	screen_loc = ui_lingstingdisplay
	plane = ABOVE_HUD_PLANE
	invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/resist
	name = "resist"
	icon_state = "act_resist"
	screen_loc = ui_pull_resist
	plane = HUD_PLANE

/atom/movable/screen/resist/ian
	screen_loc = ui_drop_throw

/atom/movable/screen/resist/alien
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/move_intent
	name = "mov_intent"
	screen_loc = ui_movi
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/move_intent/alien
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/internal
	name = "internal"
	icon_state = "internal0"
	screen_loc = ui_internal

/atom/movable/screen/act_intent
	name = "act_intent"
	screen_loc = ui_acti
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/act_intent/alien
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/act_intent/robot
	icon = 'icons/mob/screen1_robot.dmi'

/atom/movable/screen/intent
	screen_loc = ui_acti
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/intent/help
	name = INTENT_HELP

/atom/movable/screen/intent/push
	name = INTENT_PUSH

/atom/movable/screen/intent/grab
	name = INTENT_GRAB

/atom/movable/screen/intent/harm
	name = INTENT_HARM

/atom/movable/screen/throw
	name = "throw"
	icon_state = "act_throw_off"
	screen_loc = ui_drop_throw

/atom/movable/screen/throw/alien
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/drop
	name = "drop"
	icon_state = "act_drop"
	screen_loc = ui_drop_throw
	plane = HUD_PLANE

/atom/movable/screen/drop/alien
	icon = 'icons/mob/screen1_xeno.dmi'

// Robots
/atom/movable/screen/module
	name = "module"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "nomod"
	screen_loc = ui_borg_module

/atom/movable/screen/inventory
	name = "inventory"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "inventory"
	screen_loc = ui_borg_inventory

/atom/movable/screen/radio
	name = "radio"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "radio"
	screen_loc = ui_movi
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/panel
	name = "panel"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "panel"
	screen_loc = ui_borg_panel
	plane = HUD_PLANE

/atom/movable/screen/store
	name = "store"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "store"
	screen_loc = ui_borg_store

/atom/movable/screen/robo_hands
	icon = 'icons/mob/screen1_robot.dmi'
	using.plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_hands/first
	name = "module1"
	icon_state = "inv1"
	screen_loc = ui_inv1

/atom/movable/screen/robot_hands/second
	name = "module2"
	icon_state = "inv2"
	screen_loc = ui_inv2

/atom/movable/screen/robot_hands/third
	name = "module3"
	icon_state = "inv3"
	screen_loc = ui_inv3

// AI (&robot)
/atom/movable/screen/ai_core
	name = "AI Core"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "ai_core"
	screen_loc = ui_ai_core
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_list
	name = "Show Camera List"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "camera"
	screen_loc = ui_ai_camera_list
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_track
	name = "Track With Camera"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "track"
	screen_loc = ui_ai_track_with_camera
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_light
	name = "Toggle Camera Light"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "camera_light"
	screen_loc = ui_ai_camera_light
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/radio_settings
	name = "Radio Settings"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "radio_control"
	screen_loc = ui_ai_control_integrated_radio
	plane = ABOVE_HUD_PLANE


/atom/movable/screen/crew_manifest
	name = "Show Crew Manifest"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "manifest"
	screen_loc = ui_ai_crew_manifest
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/crew_manifest/robot
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "crewmanifest"
	screen_loc = ui_borg_show_manifest

/atom/movable/screen/alerts
	name = "Show Alerts"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "alerts"
	screen_loc = ui_ai_alerts
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/alerts/robot
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "showalerts"
	screen_loc = ui_borg_show_alerts

/atom/movable/screen/announcement
	name = "Announcement"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "announcement"
	screen_loc = ui_ai_announcement
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/call_shuttle
	name = "Call Emergency Shuttle"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "call_shuttle"
	screen_loc = ui_ai_shuttle
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/state_laws
	name = "State Laws"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "state_laws"
	screen_loc = ui_ai_state_laws
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/state_laws/robot
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "statelaws"
	screen_loc = ui_borg_state_laws

// Robot
/atom/movable/screen/show_laws
	name = "Show Laws"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "showlaws"
	screen_loc = ui_borg_show_laws
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/toggle_lights
	name = "Toggle Lights"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "togglelights"
	screen_loc = ui_borg_light
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/self_diagnosis
	name = "Self Diagnosis"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "selfdiagnosis"
	screen_loc = ui_borg_diagnostic
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/namepick
	name = "Namepick"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "changename"
	screen_loc = ui_borg_namepick
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/show_pda_screens
		name = "Show Pda Screens"
		icon = 'icons/mob/screen1_robot.dmi'
		icon_state = "pda"
		screen_loc = ui_borg_show_pda
		plane = ABOVE_HUD_PLANE

/atom/movable/screen/show_photo_screens
	name = "Show Foto Screens"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "photo"
	screen_loc = ui_borg_show_foto
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/toggle_components
	name = "Toggle Components"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "togglecompanent"
	screen_loc = ui_borg_component
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_pda
	icon = 'icons/mob/screen1_robot.dmi'
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_pda/send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/atom/movable/screen/robot_pda/send/ai
	icon = 'icons/mob/screen_ai.dmi'
	screen_loc = ui_ai_pda_send

/atom/movable/screen/robot_pda/log
	name = "PDA - Show Message Log"
	icon_state = "pda_log"

/atom/movable/screen/robot_pda/log/ai
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "pda_receive"
	screen_loc = ui_ai_pda_log

/atom/movable/screen/robot_pda/ringtone
	name = "Pda - Ringtone"
	icon_state = "ringtone"

/atom/movable/screen/robot_pda/toggle
	name = "Pda - Toggle"
	icon_state = "toggleringer"

/atom/movable/screen/robot_image
	icon = 'icons/mob/screen1_robot.dmi'
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_image/take
	name = "Take Image"
	icon_state = "takephoto"

/atom/movable/screen/robot_image/take/ai
	icon =  'icons/mob/screen_ai.dmi'
	icon_state = "take_picture"
	screen_loc = ui_ai_take_picture

/atom/movable/screen/robot_image/view
	name = "View Images"
	icon_state = "photos"

/atom/movable/screen/robot_image/view/ai
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "view_images"
	screen_loc = ui_ai_view_images

/atom/movable/screen/robot_image/delete
	name = "Delete Image"
	icon_state = "deletthis"

/atom/movable/screen/sensor_augmentation
	name = "Sensor Augmentation"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "ai_sensor"
	screen_loc = ui_ai_sensor
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/sensor_augmentation/robot
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "setsensor"
	screen_loc = ui_borg_sensor

/atom/movable/screen/Click(location, control, params)
	if(!usr)
		return TRUE

	SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)

	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return TRUE
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("current sting")
			var/mob/living/carbon/U = usr
			U.unset_sting()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()

		if("mov_intent")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr

				C.set_m_intent(C.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)

		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
					if(internal_switch > world.time)
						return
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
						if(C.internals)
							C.internals.icon_state = "internal0"
					else
						if(!istype(C.wear_mask, /obj/item/clothing/mask))
							to_chat(C, "<span class='notice'>You are not wearing a mask.</span>")
							internal_switch = world.time + 8
							return TRUE
						else
							if(C.wear_mask.flags & MASKINTERNALS)
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

								if(C.internal)
									if(C.internals)
										C.internals.icon_state = "internal1"
								else
									to_chat(C, "<span class='notice'>You don't have a[inhale_type=="oxygen" ? "n oxygen" : addtext(" ",inhale_type)] tank.</span>")
							else
								to_chat(C, "<span class='notice'>This mask doesn't support breathing through the tanks.</span>")
					internal_switch = world.time + 16
		if("act_intent")
			usr.a_intent_change(INTENT_HOTKEY_RIGHT)
		if(INTENT_HELP)
			usr.set_a_intent(INTENT_HELP)
			usr.hud_used.action_intent.icon_state = "intent_help"
		if(INTENT_HARM)
			usr.set_a_intent(INTENT_HARM)
			usr.hud_used.action_intent.icon_state = "intent_harm"
		if(INTENT_GRAB)
			usr.set_a_intent(INTENT_GRAB)
			usr.hud_used.action_intent.icon_state = "intent_grab"
		if(INTENT_PUSH)
			usr.set_a_intent(INTENT_PUSH)
			usr.hud_used.action_intent.icon_state = "intent_push"
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr:toggle_throw_mode()
		if("drop")
			if(usr.client)
				usr.client.drop_item()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.pick_module()

		if("inventory")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return TRUE
				else
					to_chat(R, "You haven't selected a module yet.")

		if("radio")
			if(issilicon(usr))
				usr:radio_menu()
		if("panel")
			if(issilicon(usr))
				usr:installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.uneq_active()
				else
					to_chat(R, "You haven't selected a module yet.")

		if("module1")
			if(isrobot(usr))
				usr:toggle_module(1)

		if("module2")
			if(isrobot(usr))
				usr:toggle_module(2)

		if("module3")
			if(isrobot(usr))
				usr:toggle_module(3)

		if("AI Core")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.view_core()

		if("Show Camera List")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/camera = input(AI) in AI.get_camera_list()
				AI.ai_camera_list(camera)

		if("Track With Camera")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				var/target_name = input(AI) in AI.trackable_mobs()
				AI.ai_camera_track(target_name)

		if("Toggle Camera Light")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.toggle_camera_light()

		if("Radio Settings")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.control_integrated_radio()

		if("Show Crew Manifest")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				S.show_station_manifest()

		if("Show Alerts")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				S.show_alerts()

		if("Announcement")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_announcement()

		if("Call Emergency Shuttle")
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				AI.ai_call_shuttle()

		if("State Laws")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				S.checklaws()

		if("Show Laws")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.show_laws()

		if("Toggle Lights")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.toggle_lights()

		if("Self Diagnosis")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.self_diagnosis()

		if("Namepick")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.Namepick()

		if("Show Pda Screens")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.shown_robot_pda = !R.shown_robot_pda
				R.hud_used.toggle_robot_additional_screens(0, R.shown_robot_pda)

		if("Show Foto Screens")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.shown_robot_foto = !R.shown_robot_foto
				R.hud_used.toggle_robot_additional_screens(1, R.shown_robot_foto)

		if("Toggle Components")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				R.toggle_component()

		if("PDA - Send Message")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/obj/item/device/pda/silicon/PDA = S.pda
				PDA.cmd_send_pdamesg(S)

		if("PDA - Show Message Log")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/obj/item/device/pda/silicon/PDA = S.pda
				PDA.cmd_show_message_log(usr)

		if("Pda - Ringtone")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				var/obj/item/device/pda/silicon/PDA = R.pda
				PDA.cmd_toggle_pda_silent()

		if("Pda - Toggle")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				var/obj/item/device/pda/silicon/PDA = R.pda
				PDA.cmd_toggle_pda_receiver()

		if("Take Image")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/obj/item/device/camera/siliconcam/camera = S.aiCamera
				camera.take_image()

		if("View Images")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				var/obj/item/device/camera/siliconcam/camera = S.aiCamera
				camera.view_images()

		if("Delete Image")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				var/obj/item/device/camera/siliconcam/ai_camera/camera = R.aiCamera
				camera.deletepicture(camera)

		if("Sensor Augmentation")
			if(issilicon(usr))
				var/mob/living/silicon/S = usr
				S.toggle_sensor_mode()

		if("Allow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Disallow Walking")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetMove()
			gun_click_time = world.time

		if("Allow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Disallow Running")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetRun()
			gun_click_time = world.time

		if("Allow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time


		if("Disallow Item Use")
			if(gun_click_time > world.time - 30)	//give them 3 seconds between mode changes.
				return
			if(!istype(usr.get_active_hand(),/obj/item/weapon/gun))
				to_chat(usr, "You need your gun in your active hand to do that!")
				return
			usr.client.AllowTargetClick()
			gun_click_time = world.time

		if("Toggle Gun Mode")
			usr.client.ToggleGunMode()

		else
			return FALSE
	return TRUE

/atom/movable/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE
	if(usr.incapacitated())
		return TRUE
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return TRUE
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
				usr.next_move = world.time+2
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
				usr.next_move = world.time+2
		if("swap")
			usr:swap_hand()
		if("hand")
			usr:swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand()
				usr.update_inv_r_hand()
				usr.next_move = world.time+6
	return TRUE

/atom/movable/screen/inventory/MouseEntered()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	add_stored_outline()

/atom/movable/screen/inventory/MouseExited()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	remove_stored_outline()

/atom/movable/screen/inventory/proc/add_stored_outline()
	if(!slot_id || !usr.client.prefs.outline_enabled)
		return
	var/obj/item/inv_item = usr.get_item_by_slot(slot_id)
	if(!inv_item)
		return
	if(usr.incapacitated())
		inv_item.apply_outline(COLOR_RED_LIGHT)
	else
		inv_item.apply_outline()

/atom/movable/screen/inventory/proc/remove_stored_outline()
	if(!slot_id)
		return
	var/obj/item/inv_item = usr.get_item_by_slot(slot_id)
	if(!inv_item)
		return
	inv_item.remove_outline()

/atom/movable/screen/inventory/craft
	name = "crafting menu"
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/atom/movable/screen/inventory/craft/Click()
	var/mob/living/M = usr
	M.OpenCraftingMenu()

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
