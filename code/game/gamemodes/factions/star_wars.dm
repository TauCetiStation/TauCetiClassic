
/datum/faction/star_wars
	var/obj/structure/ivent/star_wars/artifact/force_source
	var/competition = FALSE
	var/escalation = FALSE
	required_pref = ROLE_TRAITOR

/datum/faction/star_wars/proc/isforceuser(mob/living/carbon/C)
	return C in force_source.force_users

/datum/faction/star_wars/proc/isjedi(mob/living/carbon/C)
	if(isrolebytype(/datum/role/star_wars/jedi_leader, C))
		return TRUE
	if(isrolebytype(/datum/role/star_wars/jedi, C))
		return TRUE
	return FALSE

/datum/faction/star_wars/proc/issith(mob/living/carbon/C)
	if(isrolebytype(/datum/role/star_wars/sith_leader, C))
		return TRUE
	if(isrolebytype(/datum/role/star_wars/sith, C))
		return TRUE
	return FALSE

/datum/faction/star_wars/proc/isforcetrained(mob/living/carbon/C)
	return issith(C) || isjedi(C)

// JEDI

/datum/faction/star_wars/jedi
	name = "Jedi Order"
	ID = F_JEDI_ORDER

	initroletype = /datum/role/star_wars/jedi_leader
	roletype = /datum/role/star_wars/jedi

	min_roles = 2
	max_roles = 2

	logo_state = "jedi_logo"

	var/list/admin_verbs = list(
		/client/proc/star_wars_jedi_competition,
		/client/proc/star_wars_escalation,
		/client/proc/star_wars_create_spawners)
	var/spawners_created = FALSE

/datum/faction/star_wars/jedi/OnPostSetup()
	. = ..()
	for(var/datum/role/R in members)
		R.antag.current.forceMove(pick_landmarked_location("Jedi Spawn"))

	addtimer(CALLBACK(src, PROC_REF(give_announce)), 5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(open_gate)), 10 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(give_competition_objective)), 30 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(give_escalation_objective)), 60 MINUTES)

	setup_temp_admin_verbs(admin_verbs, "Star Wars Ivent")

/datum/faction/star_wars/jedi/proc/give_announce()
	var/datum/announcement/centcomm/star_wars/jedi_arrival/A = new
	A.play()

/datum/faction/star_wars/jedi/proc/open_gate()
	var/obj/machinery/gateway/center/jedi_gate
	var/obj/machinery/gateway/center/station_gate

	for(var/obj/machinery/gateway/center/G in global.gateways_list)
		if(G.name == "Jedi Gateway")
			jedi_gate = G
		if(G.name == "[station_name()] Gateway")
			station_gate = G

	jedi_gate.destination = station_gate
	jedi_gate.toggleon()

	AppendObjective(/datum/objective/star_wars/jedi/research)
	AppendObjective(/datum/objective/star_wars/jedi/convert)
	AnnounceObjectives()

/datum/faction/star_wars/jedi/proc/give_competition_objective()
	if(!competition)
		AppendObjective(/datum/objective/star_wars/jedi/competition)
		AnnounceObjectives()
		competition = TRUE

/datum/faction/star_wars/jedi/proc/give_escalation_objective()
	if(!escalation)
		AppendObjective(/datum/objective/star_wars/jedi/escalation)
		AnnounceObjectives()
		escalation = TRUE

/datum/faction/star_wars/jedi/proc/create_dm_spawners()
	if(!spawners_created)
		create_spawner(/datum/spawner/star_wars/blue)
		create_spawner(/datum/spawner/star_wars/red)
		var/turf/T = pick_landmarked_location("SW Red Portal")
		new /obj/structure/ivent/star_wars/red_portal(T)

		var/datum/announcement/centcomm/star_wars/star_war_begin/A = new
		A.play()

		SSshuttle.incall()
		SSshuttle.announce_emer_called.play()
		make_maint_all_access()

		spawners_created = TRUE

// SITH

/datum/faction/star_wars/sith
	name = "Sith Order"
	ID = F_SITH_ORDER

	initroletype = /datum/role/star_wars/sith_leader
	roletype = /datum/role/star_wars/sith

	min_roles = 2
	max_roles = 2

	logo_state = "sith_logo"

/datum/faction/star_wars/sith/forgeObjectives()
	if(!..())
		return FALSE

	AppendObjective(/datum/objective/star_wars/sith/convert)
	return TRUE

/datum/faction/star_wars/sith/OnPostSetup()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(give_competition_objective)), 5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(give_escalation_objective)), 60 MINUTES)

/datum/faction/star_wars/sith/proc/give_competition_objective()
	if(!competition)
		AppendObjective(/datum/objective/star_wars/sith/competition)
		AnnounceObjectives()
		competition = TRUE

/datum/faction/star_wars/sith/proc/give_escalation_objective()
	if(!escalation)
		AppendObjective(/datum/objective/star_wars/sith/escalation)
		AnnounceObjectives()
		escalation = TRUE

// admin verbs

/client/proc/star_wars_jedi_competition()
	set category = "Event"
	set name = "STAR WARS Jedi Competition"

	var/datum/faction/star_wars/jedi/J = find_faction_by_type(/datum/faction/star_wars/jedi)

	if(J.competition)
		tgui_alert(mob, "Джедаям уже выдана эта цель", "", list("Ок"))
		return

	if(tgui_alert(mob, "Это даст джедаям информацию о том, что ситхи на станции!", "Вы уверены?", list("Да", "Нет")) == "Да")
		J.give_competition_objective()

/client/proc/star_wars_escalation()
	set category = "Event"
	set name = "STAR WARS Escalation"

	var/datum/faction/star_wars/jedi/J = find_faction_by_type(/datum/faction/star_wars/jedi)
	var/datum/faction/star_wars/sith/S = find_faction_by_type(/datum/faction/star_wars/sith)

	if(J.escalation)
		tgui_alert(mob, "Цели на эскалацию уже выданы", "", list("Ок"))
		return

	if(tgui_alert(mob, "Это приведёт к эскалации конфликта между ситхами и джедаями!", "Вы уверены?", list("Да", "Нет")) == "Да")
		J.give_escalation_objective()
		S.give_escalation_objective()

/client/proc/star_wars_create_spawners()
	set category = "Event"
	set name = "STAR WARS Final Spawners"

	var/datum/faction/star_wars/jedi/J = find_faction_by_type(/datum/faction/star_wars/jedi)

	if(J.spawners_created)
		tgui_alert(mob, "Спавнеры уже созданы", "", list("Ок"))
		return

	if(tgui_alert(mob, "Это откроет для гостов спавнеры солдат империи и клонов! Открывать стоит только когда джедаи и ситхи начали сражаться!", "Вы уверены?", list("Да", "Нет")) == "Да")
		J.create_dm_spawners()
