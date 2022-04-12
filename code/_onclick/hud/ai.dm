/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/atom/movable/screen/using

//AI core
	using = new /atom/movable/screen/ai_core()
	adding += using

//Camera list
	using = new /atom/movable/screen/camera_list()
	adding += using

//Track
	using = new /atom/movable/screen/camera_track()
	adding += using

//Camera light
	using = new /atom/movable/screen/camera_light()
	adding += using

//Crew Monitorting
	using = new /atom/movable/screen/radio_settings()
	adding += using

//Crew Manifest
	using = new /atom/movable/screen/crew_manifest()
	adding += using

//Alerts
	using = new /atom/movable/screen/alerts()
	adding += using

//Announcement
	using = new /atom/movable/screen()
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Shuttle
	using = new /atom/movable/screen()
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Laws
	using = new /atom/movable/screen()
	using.name = "State Laws"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.plane = ABOVE_HUD_PLANE
	adding += using

//PDA message
	using = new /atom/movable/screen()
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.plane = ABOVE_HUD_PLANE
	adding += using

//PDA log
	using = new /atom/movable/screen()
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Take image
	using = new /atom/movable/screen()
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.plane = ABOVE_HUD_PLANE
	adding += using

//View images
	using = new /atom/movable/screen()
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.plane = ABOVE_HUD_PLANE
	adding += using

//Medical/Security sensors
	using = new /atom/movable/screen()
	using.name = "Sensor Augmentation"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	using.plane = ABOVE_HUD_PLANE
	adding += using

	mymob.client.screen += adding + other
	return
