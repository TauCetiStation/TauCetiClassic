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
	using = new /atom/movable/screen/announcement()
	adding += using

//Shuttle
	using = new /atom/movable/screen/call_shuttle()
	adding += using

//Laws
	using = new /atom/movable/screen/state_laws()
	adding += using

//PDA message
	using = new /atom/movable/screen/robot_pda/send/ai()
	adding += using

//PDA log
	using = new /atom/movable/screen/robot_pda/log/ai()
	adding += using

//Take image
	using = new /atom/movable/screen/robot_image/take/ai()
	adding += using

//View images
	using = new /atom/movable/screen/robot_image/view/ai()
	adding += using

//Medical/Security sensors
	using = new /atom/movable/screen/sensor_augmentation()
	adding += using

	mymob.client.screen += adding + other
	return
