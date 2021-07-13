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

/client/proc/generate_round_scoreboard()
	set category = "Debug"
	set name = "Throw Scoreboad"
	set desc = "Generates and sends statistics to all players"

	if(!holder)
		return
	if(!check_rights(R_DEBUG))
		return
	if(!SSticker)
		return

	SSticker.generate_scoreboard(mob)
	message_admins("Admin [key_name_admin(usr)] has forced made a scoreboard.")

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
