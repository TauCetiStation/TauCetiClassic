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

/proc/get_end_section_of_type(type)
	var/strtype = "[type]"
	var/delim_pos = findlasttext(strtype, "/")
	if(delim_pos == 0)
		return strtype
	return copytext(strtype, delim_pos)

/client/proc/debug_controller()
	set category = "Debug"
	set name = "Debug Controller"
	set desc = "Debug the various periodic loop controllers for the game (be careful!)"

	if(!holder || !check_rights(R_DEBUG))
		return
	var/list/options = list()
	options["Master"] = Master
	options["Failsafe"] = Failsafe
	options["Configuration"] = config
	for(var/i in Master.subsystems)
		var/datum/subsystem/S = i
		if(!istype(S))		//Eh, we're a debug verb, let's have typechecking.
			continue
		var/strtype = "SS[get_end_section_of_type(S.type)]"
		if(options[strtype])
			var/offset = 2
			while(istype(options["[strtype]_[offset] - DUPE ERROR"], /datum/subsystem))
				offset++
			options["[strtype]_[offset] - DUPE ERROR"] = S		//Something is very, very wrong.
		else
			options[strtype] = S

	var/pick = input(mob, "Choose a controller to debug/view variables of.", "VV controller:") as null|anything in options
	if(!pick)
		return
	var/datum/D = options[pick]
	if(!istype(D))
		return
	feedback_add_details("admin_verb", "DebugController")
	message_admins("Admin [key_name_admin(mob)] is debugging the [pick] controller.")
	debug_variables(D)
