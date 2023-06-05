/atom/movable/screen/crew_manifest
	name = "Show Crew Manifest"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "manifest"
	screen_loc = ui_ai_crew_manifest
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/crew_manifest/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		S.show_station_manifest()

/atom/movable/screen/crew_manifest/robot
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "crewmanifest"
	screen_loc = ui_borg_show_manifest

/atom/movable/screen/alerts
	name = "Show Alerts"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "alerts"
	screen_loc = ui_ai_alerts
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/alerts/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		S.show_alerts()

/atom/movable/screen/alerts/robot
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "showalerts"
	screen_loc = ui_borg_show_alerts

/atom/movable/screen/sensor_augmentation
	name = "Sensor Augmentation"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "ai_sensor"
	screen_loc = ui_ai_sensor
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/sensor_augmentation/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		S.toggle_sensor_mode()

/atom/movable/screen/sensor_augmentation/robot
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "setsensor"
	screen_loc = ui_borg_sensor

/atom/movable/screen/state_laws
	name = "State Laws"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "state_laws"
	screen_loc = ui_ai_state_laws
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/state_laws/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		S.checklaws()

/atom/movable/screen/state_laws/robot
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "statelaws"
	screen_loc = ui_borg_state_laws

// Robots
/atom/movable/screen/health/robot
	icon = 'icons/hud/screen1_robot.dmi'
	screen_loc = ui_borg_health

/atom/movable/screen/pull/robot
	screen_loc = ui_borg_pull

/atom/movable/screen/module
	name = "module"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "nomod"
	screen_loc = ui_borg_module

/atom/movable/screen/module/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.pick_module()

/atom/movable/screen/module/update_icon(mob/living/silicon/robot/mymob)
	icon_state = mymob.module ? lowertext(mymob.modtype) : initial(icon_state)

/atom/movable/screen/module/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.module_icon = src

/atom/movable/screen/robot_inventory
	name = "inventory"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "inventory"
	screen_loc = ui_borg_inventory

/atom/movable/screen/robot_inventory/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(R.module)
			R.hud_used.toggle_show_robot_modules()
		else
			to_chat(R, "You haven't selected a module yet.")

/atom/movable/screen/radio
	name = "radio"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "radio"
	screen_loc = ui_movi
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/radio/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.radio_menu()

/atom/movable/screen/panel
	name = "panel"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "panel"
	screen_loc = ui_borg_panel

/atom/movable/screen/panel/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.installed_modules()

/atom/movable/screen/store
	name = "store"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "store"
	screen_loc = ui_borg_store

/atom/movable/screen/store/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(R.module)
			R.uneq_active()
		else
			to_chat(R, "You haven't selected a module yet.")

/atom/movable/screen/robot_hands
	icon = 'icons/hud/screen1_robot.dmi'
	plane = ABOVE_HUD_PLANE
	var/module_index

	hud_slot = HUD_SLOT_MAIN

/atom/movable/screen/robot_hands/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(module_index)

/atom/movable/screen/robot_hands/first
	name = "module1"
	icon_state = "inv1"
	screen_loc = ui_inv1
	module_index = 1

/atom/movable/screen/robot_hands/first/add_to_hud(datum/hud/hud)
	..()
	var/mob/living/silicon/robot/R = hud.mymob
	R.inv1 = src

/atom/movable/screen/robot_hands/second
	name = "module2"
	icon_state = "inv2"
	screen_loc = ui_inv2
	module_index = 2

/atom/movable/screen/robot_hands/second/add_to_hud(datum/hud/hud)
	..()
	var/mob/living/silicon/robot/R = hud.mymob
	R.inv2 = src

/atom/movable/screen/robot_hands/third
	name = "module3"
	icon_state = "inv3"
	screen_loc = ui_inv3
	module_index = 3

/atom/movable/screen/robot_hands/third/add_to_hud(datum/hud/hud)
	..()
	var/mob/living/silicon/robot/R = hud.mymob
	R.inv3 = src

// AI
/atom/movable/screen/ai_core
	name = "AI Core"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "ai_core"
	screen_loc = ui_ai_core
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/ai_core/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.view_core()

/atom/movable/screen/camera_list
	name = "Show Camera List"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "camera"
	screen_loc = ui_ai_camera_list
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_list/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		var/camera = input(AI) in AI.get_camera_list()
		AI.ai_camera_list(camera)

/atom/movable/screen/camera_track
	name = "Track With Camera"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "track"
	screen_loc = ui_ai_track_with_camera
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_track/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		var/target_name = input(AI) in AI.trackable_mobs()
		AI.ai_camera_track(target_name)

/atom/movable/screen/camera_light
	name = "Toggle Camera Light"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "camera_light"
	screen_loc = ui_ai_camera_light
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/camera_light/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.toggle_camera_light()

/atom/movable/screen/radio_settings
	name = "Radio Settings"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "radio_control"
	screen_loc = ui_ai_control_integrated_radio
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/radio_settings/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.control_integrated_radio()

/atom/movable/screen/announcement
	name = "Announcement"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "announcement"
	screen_loc = ui_ai_announcement
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/announcement/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_announcement()

/atom/movable/screen/call_shuttle
	name = "Call Emergency Shuttle"
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "call_shuttle"
	screen_loc = ui_ai_shuttle
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/call_shuttle/action()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_call_shuttle()

// Robot
/atom/movable/screen/show_laws
	name = "Show Laws"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "showlaws"
	screen_loc = ui_borg_show_laws
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/show_laws/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.show_laws()

/atom/movable/screen/toggle_lights
	name = "Toggle Lights"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "togglelights"
	screen_loc = ui_borg_light
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/toggle_lights/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_lights()

/atom/movable/screen/self_diagnosis
	name = "Self Diagnosis"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "selfdiagnosis"
	screen_loc = ui_borg_diagnostic
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/self_diagnosis/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.self_diagnosis()

/atom/movable/screen/namepick
	name = "Namepick"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "changename"
	screen_loc = ui_borg_namepick
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/namepick/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.Namepick()

/atom/movable/screen/toggle_components
	name = "Toggle Components"
	icon = 'icons/hud/screen1_robot.dmi'
	icon_state = "togglecompanent"
	screen_loc = ui_borg_component
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/toggle_components/action()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_component()

// pda and photo
/atom/movable/screen/robot_pda
	icon = 'icons/hud/screen1_robot.dmi'
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_pda/proc/pda_action(obj/item/device/pda/silicon/PDA)
	return

/atom/movable/screen/robot_pda/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		pda_action(S.pda)

/atom/movable/screen/robot_pda/send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/atom/movable/screen/robot_pda/send/pda_action(obj/item/device/pda/silicon/PDA)
	PDA.cmd_send_pdamesg(usr)

/atom/movable/screen/robot_pda/send/ai
	icon = 'icons/hud/screen_ai.dmi'
	screen_loc = ui_ai_pda_send

/atom/movable/screen/robot_pda/log
	name = "PDA - Show Message Log"
	icon_state = "pda_log"

/atom/movable/screen/robot_pda/log/pda_action(obj/item/device/pda/silicon/PDA)
	PDA.cmd_show_message_log(usr)

/atom/movable/screen/robot_pda/log/ai
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "pda_receive"
	screen_loc = ui_ai_pda_log

/atom/movable/screen/robot_pda/ringtone
	name = "Pda - Ringtone"
	icon_state = "ringtone"

/atom/movable/screen/robot_pda/ringtone/pda_action(obj/item/device/pda/silicon/PDA)
	PDA.cmd_toggle_pda_silent()

/atom/movable/screen/robot_pda/toggle
	name = "Pda - Toggle"
	icon_state = "toggleringer"

/atom/movable/screen/robot_pda/toggle/pda_action(obj/item/device/pda/silicon/PDA)
	PDA.cmd_toggle_pda_receiver()

/atom/movable/screen/robot_image
	icon = 'icons/hud/screen1_robot.dmi'
	plane = ABOVE_HUD_PLANE

/atom/movable/screen/robot_image/proc/camera_action(obj/item/device/camera/siliconcam/camera)
	return

/atom/movable/screen/robot_image/action()
	if(issilicon(usr))
		var/mob/living/silicon/S = usr
		camera_action(S.aiCamera)

/atom/movable/screen/robot_image/take
	name = "Take Image"
	icon_state = "takephoto"

/atom/movable/screen/robot_image/take/camera_action(obj/item/device/camera/siliconcam/camera)
	camera.take_image()

/atom/movable/screen/robot_image/take/ai
	icon =  'icons/hud/screen_ai.dmi'
	icon_state = "take_picture"
	screen_loc = ui_ai_take_picture

/atom/movable/screen/robot_image/view
	name = "View Images"
	icon_state = "photos"

/atom/movable/screen/robot_image/view/camera_action(obj/item/device/camera/siliconcam/camera)
	camera.view_images()

/atom/movable/screen/robot_image/view/ai
	icon = 'icons/hud/screen_ai.dmi'
	icon_state = "view_images"
	screen_loc = ui_ai_view_images

/atom/movable/screen/robot_image/delete
	name = "Delete Image"
	icon_state = "deletthis"

/atom/movable/screen/robot_image/delete/camera_action(obj/item/device/camera/siliconcam/camera)
	camera.deletepicture(camera)
