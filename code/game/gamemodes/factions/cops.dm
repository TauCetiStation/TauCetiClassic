/datum/faction/cops
	name = F_COPS
	ID = F_COPS
	required_pref = ROLE_FAMILIES

	initroletype = /datum/role/cop/undercover
	roletype = /datum/role/cop

	logo_state = "space_cop"

	min_roles = 1
	max_roles = 3

	/// The time, in deciseconds, that the datum's OnPostSetup() occured at. Used in end_time. Used and set internally.
	var/start_time = null
	/// The time, in deciseconds, that the space cops will arrive at. Calculated based on wanted level and start_time. Used and set internally.
	var/end_time = null
	/// Whether the gamemode-announcing announcement has been sent. Used and set internally.
	var/sent_announcement = FALSE
	/// time in ticks when the dealer will arrive
	var/dealer_timer

	var/datum/announcement/centcomm/gang/announce_gamemode/first_announce = new

/datum/faction/cops/OnPostSetup()
	. = ..()
	start_time = world.time
	end_time = start_time + 80 MINUTES

	dealer_timer = addtimer(CALLBACK(src, PROC_REF(send_syndicate)), rand(25 MINUTES, 35 MINUTES), TIMER_STOPPABLE) // called here because cops are only faction
	addtimer(CALLBACK(src, PROC_REF(announce_gang_locations)), 5 MINUTES)
	SSshuttle.fake_recall = TRUE

/datum/faction/cops/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/gang/destroy_gangs)

/datum/faction/cops/proc/send_syndicate()
	create_spawners(/datum/spawner/dealer, 2)

/datum/faction/cops/proc/announce_gang_locations()
	var/list/readable_gang_names = list()
	var/list/gangs = find_factions_by_type(/datum/faction/gang)
	for(var/GG in gangs)
		var/datum/faction/gang/G = GG
		readable_gang_names += "[G.name]"
	var/finalized_gang_names = get_english_list(readable_gang_names)
	first_announce.play(finalized_gang_names)
	sent_announcement = TRUE
	check_wanted_level() // i like it when the wanted level updates at the same time as the announcement

/datum/faction/cops/AdminPanelEntry()
	. = ..()
	. += "<br>Уровень розыска: [wanted_level]"
	var/time_to_cops = max(((end_time - world.time) / 600), 0)
	var/minutes = pluralize_russian(time_to_cops, "[time_to_cops] минута", "[time_to_cops] минуты", "[time_to_cops] минут")
	. += "<br>До прилёта полиции: [minutes]"
	var/dealer_time = timeleft(dealer_timer)
	var/time_to_dealer = dealer_time ? max((dealer_time / 600), 0) : 0
	. += "<br>До прилёта дилера: [time_to_dealer]"
	. += "<br>Смертей: [global.deaths_during_shift]"

/datum/faction/cops/custom_result()
	var/list/all_gangs = find_factions_by_type(/datum/faction/gang)
	if(!all_gangs.len)
		return
	var/list/all_gangsters = list()
	for(var/G in all_gangs)
		var/datum/faction/gang/GG = G
		all_gangsters |= GG.members

	var/report
	var/highest_point_value = 0
	var/highest_gang = "Leet Like Jeff K"
	var/objective_failures = TRUE

	for(var/G in all_gangs)
		var/datum/faction/gang/GG = G
		if(GG.IsSuccessful())
			objective_failures = FALSE
			break
	for(var/G in all_gangs)
		var/datum/faction/gang/GG = G
		if(!objective_failures)
			if(GG.points >= highest_point_value && GG.members.len && GG.IsSuccessful())
				highest_point_value = GG.points
				highest_gang = GG.name
		else
			if(GG.points >= highest_point_value && GG.members.len)
				highest_point_value = GG.points
				highest_gang = GG.name

	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/M in all_gangsters)
		var/datum/role/gangster/gangbanger = M
		if(gangbanger.antag.current)
			if(!ishuman(gangbanger.antag.current))
				continue
			var/mob/living/carbon/human/H = gangbanger.antag.current
			if(H.stat != CONSCIOUS || H.handcuffed)
				continue
			alive_gangsters++
	for(var/M in members)
		var/datum/role/cop/bacon = M
		if(bacon.antag.current)
			if(!ishuman(bacon.antag.current)) // always returns false
				continue
			var/mob/living/carbon/human/H = bacon.antag.current
			if(H.stat != CONSCIOUS)
				continue
			alive_cops++

	if(alive_gangsters > alive_cops)
		if(!objective_failures)
			report = "<span class='red'>[highest_gang] побеждает, выполнив свою свою задачу и набрав наибольшее количество очков!</span>"
		else
			report = "<span class='red'>[highest_gang] побеждает, набрав наибольшее количество очков!</span>"
	else if(alive_gangsters == alive_cops)
		report = "<span class='orange'>Легенды гласят, что у НаноТрейзен и семей до сих пор идет конфликт!</span>"
	else
		report = "<span class='green'>НаноТрейзен смогла остановить деятельность банд!</span>"

	return "[report]"
