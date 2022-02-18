/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/atom/movable/screen/using

//AI core
	using = new /atom/movable/screen()
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Camera list
	using = new /atom/movable/screen()
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Track
	using = new /atom/movable/screen()
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Camera light
	using = new /atom/movable/screen()
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Crew Monitorting
	using = new /atom/movable/screen()
	using.name = "Radio Settings"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "radio_control"
	using.screen_loc = ui_ai_control_integrated_radio
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Crew Manifest
	using = new /atom/movable/screen()
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Alerts
	using = new /atom/movable/screen()
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Announcement
	using = new /atom/movable/screen()
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Shuttle
	using = new /atom/movable/screen()
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Laws
	using = new /atom/movable/screen()
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//PDA message
	using = new /atom/movable/screen()
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//PDA log
	using = new /atom/movable/screen()
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Take image
	using = new /atom/movable/screen()
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//View images
	using = new /atom/movable/screen()
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Medical/Security sensors
	using = new /atom/movable/screen()
	using.name = "Sensor Augmentation"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	adding += using

	mymob.client.screen += adding + other
	return
