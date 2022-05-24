/mob/living/silicon/ai/add_to_hud(datum/hud/hud)
	hud.ui_style = null

	hud.init_screens(list(
		/atom/movable/screen/ai_core,
		/atom/movable/screen/camera_list,
		/atom/movable/screen/camera_track,
		/atom/movable/screen/camera_light,
		/atom/movable/screen/radio_settings,
		/atom/movable/screen/crew_manifest,
		/atom/movable/screen/alerts,
		/atom/movable/screen/announcement,
		/atom/movable/screen/call_shuttle,
		/atom/movable/screen/state_laws,
		/atom/movable/screen/robot_pda/send/ai,
		/atom/movable/screen/robot_pda/log/ai,
		/atom/movable/screen/robot_image/take/ai,
		/atom/movable/screen/robot_image/view/ai,
		/atom/movable/screen/sensor_augmentation,
	))
