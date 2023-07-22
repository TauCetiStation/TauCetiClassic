#define AUTO_TRAITORS_SPAWN_CD 15 MINUTES

/datum/faction/traitor/auto
	name = "AutoTraitors"
	var/next_try = 0

/datum/faction/traitor/auto/can_setup(num_players)
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	if(config.traitor_scaling)
		max_roles = max_traitors - 1 + prob(traitor_prob)
		log_mode("Number of traitors: [max_roles]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [max_roles]")
	else
		max_roles = max(1, min(num_players, traitors_possible))

	return TRUE

/datum/faction/traitor/auto/traitorcheckloop()
	log_mode("Try add new autotraitor.")
	. = ..()
	if(!.)
		return
	addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)

/datum/faction/traitor/auto/OnPostSetup()
	addtimer(CALLBACK(src, PROC_REF(traitorcheckloop)), global.autotraitors_spawn_cd)
	return ..()
