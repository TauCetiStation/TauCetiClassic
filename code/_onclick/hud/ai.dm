/datum/hud/proc/ai_hud()
	var/atom/movable/screen/using

//AI core
	adding += new /atom/movable/screen/ai_core()

//Camera list
	adding += new /atom/movable/screen/camera_list()

//Track
	adding += new /atom/movable/screen/camera_track()

//Camera light
	adding += new /atom/movable/screen/camera_light()

//Crew Monitorting
	adding += new /atom/movable/screen/radio_settings()

//Crew Manifest
	adding += new /atom/movable/screen/crew_manifest()

//Alerts
	adding += new /atom/movable/screen/alerts()

//Announcement
	adding += new /atom/movable/screen/announcement()

//Shuttle
	adding += new /atom/movable/screen/call_shuttle()

//Laws
	adding += new /atom/movable/screen/state_laws()

//PDA message
	adding += new /atom/movable/screen/robot_pda/send/ai()

//PDA log
	adding += new /atom/movable/screen/robot_pda/log/ai()

//Take image
	adding += new /atom/movable/screen/robot_image/take/ai()

//View images
	adding += new /atom/movable/screen/robot_image/view/ai()

//Medical/Security sensors
	adding += new /atom/movable/screen/sensor_augmentation()
