// Clickable stat() button.
/obj/effect/statclick
	name = "Initializing..."
	var/target

INITIALIZE_IMMEDIATE(/obj/effect/statclick)

/obj/effect/statclick/atom_init(mapload, text, target)
	. = ..()
	name = text
	src.target = target

/obj/effect/statclick/proc/update(text)
	name = text
	return src

/obj/effect/statclick/debug
	var/class

/obj/effect/statclick/debug/Click()
	if(!usr.client.holder || !target)
		return
	if(!(usr.client.holder.rights & R_DEBUG))
		return
	if(!class)
		if(istype(target, /datum/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(istype(target, /datum))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")


// Debug verbs.
/client/proc/restart_controller(controller in list("Master", "Failsafe"))
	set category = "Debug"
	set name = "Restart Controller"
	set desc = "Restart one of the various periodic loop controllers for the game (be careful!)"

	if(!holder)
		return
	if(!check_rights(R_DEBUG))
		return
	switch(controller)
		if("Master")
			new/datum/controller/master()
			Master.process()
			feedback_add_details("admin_verb","RMC")
		if("Failsafe")
			new /datum/controller/failsafe()
			feedback_add_details("admin_verb","RFailsafe")

	message_admins("Admin [key_name_admin(usr)] has restarted the [controller] controller.")

/client/proc/debug_controller(controller in list("failsafe", "Master", "Air", "Sun", "Configuration", "pAI",
	"Cameras", "Garbage", "Event", "Vote", "Shuttle", "Timer", "Weather"))
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder || !check_rights(R_DEBUG))
		return
	switch(controller)
		if("failsafe")
			debug_variables(Failsafe)
			feedback_add_details("admin_verb", "dfailsafe")
		if("Master")
			debug_variables(Master)
			feedback_add_details("admin_verb","Dsmc")
		if("Air")
			debug_variables(SSair)
			feedback_add_details("admin_verb","DAir")
		if("Sun")
			debug_variables(SSsun)
			feedback_add_details("admin_verb","DSun")
		if("Configuration")
			debug_variables(config)
			feedback_add_details("admin_verb","DConf")
		if("pAI")
			debug_variables(paiController)
			feedback_add_details("admin_verb","DpAI")
		if("Cameras")
			debug_variables(cameranet)
			feedback_add_details("admin_verb","DCameras")
		if("Garbage")
			debug_variables(SSgarbage)
			feedback_add_details("admin_verb","DGarbage")
		if("Event")
			debug_variables(SSevents)
			feedback_add_details("admin_verb","DEvent")
		if("Vote")
			debug_variables(SSvote)
			feedback_add_details("admin_verb","DVote")
		if("Shuttle")
			debug_variables(SSshuttle)
			feedback_add_details("admin_verb","DShuttle")
		if("Timer")
			debug_variables(SStimer)
			feedback_add_details("admin_verb","DTimer")
		if("Weather")
			debug_variables(SSweather)
			feedback_add_details("admin_verb","DWeather")

	message_admins("Admin [key_name_admin(usr)] is debugging the [controller] controller.")
