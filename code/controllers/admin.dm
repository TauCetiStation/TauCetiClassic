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
		if(istype(target, /datum/controller/subsystem))
			class = "subsystem"
		else if(istype(target, /datum/controller))
			class = "controller"
		else if(istype(target, /datum))
			class = "datum"
		else
			class = "unknown"

	usr.client.debug_variables(target)
	message_admins("Admin [key_name_admin(usr)] is debugging the [target] [class].")

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

	// Protection from the moron admin
	if(R_BAN & holder.rights)
		if(tgui_alert(mob, "Если Вы используется это просто так, то не надо!", "Вы уверены?", list("Да", "Нет")) != "Да")
			return

		if(tgui_alert(mob, "Нажав \"Да\" Вы начинаете нести ответственность за поломанную статистику, информацию о конце раунда и введёте игроков в заблуждение.", "Вы уверены?", list("Нет", "Да")) != "Да")
			return

		if(tgui_alert(mob, "Подумайте трижды, прежде чем нажимать на \"Да\"", "Вы уверены?", list("Нет", "Да")) != "Да")
			return

		if(tgui_alert(mob, "Вы уверены? Раз.", "Вы уверены?", list("Да", "Нет")) != "Да")
			return

		if(tgui_alert(mob, "Вы уверены? Два.", "Вы уверены?", list("Нет", "Да")) != "Да")
			return

		// First "Да" have english "a" and russian "Д"
		if(tgui_alert(mob, "Вы уверены? Три.", "Вы уверены?", list("Дa", "Да", "Нет")) != "Да")
			return

	SSticker.generate_scoreboard(mob)
	message_admins("Admin [key_name_admin(usr)] has forced made a scoreboard.")

/client/proc/save_statistics()
	set category = "Debug"
	set name = "Force save statistics"
	set desc = "Force save statistics"

	if(!holder)
		return
	if(!check_rights(R_DEBUG))
		return

	SSStatistics.drop_round_stats(stealth = TRUE)
	message_admins("Admin [key_name_admin(usr)] has forced save the statistics.")

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
