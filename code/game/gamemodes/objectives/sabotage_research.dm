/datum/objective/research_sabotage
	explanation_text = "Sabotage the R&D servers and systems. Alt Click on R&D Server Controller to complete a objective."
	var/already_completed = FALSE //used in /obj/machinery/computer/rdservercontrol/AltClick(mob/user)

/datum/objective/research_sabotage/check_completion()
	..()
	for(var/var/obj/machinery/r_n_d/server/s in rnd_server_list)
		if((!s.sabotaged))
			return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
