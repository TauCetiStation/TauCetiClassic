#define LOWPOP_FAMILIES_COUNT 50

#define TWO_STARS_HIGHPOP 11
#define THREE_STARS_HIGHPOP 16
#define FOUR_STARS_HIGHPOP 21
#define FIVE_STARS_HIGHPOP 31

#define TWO_STARS_LOW 6
#define THREE_STARS_LOW 9
#define FOUR_STARS_LOW 12
#define FIVE_STARS_LOW 15

// This is not at all like on /tg/.
// "Family" and "gang" used interchangeably in code.
/datum/faction/cops
	/// Whether the "5 minute warning" announcement has been sent. Used and set internally.
	var/sent_second_announcement = FALSE
	var/datum/announcement/centcomm/gang/cops_closely/second_announce = new
	/// Whether the space cops have arrived. Set internally; used internally, and for updating the wanted HUD.
	var/cops_arrived = FALSE
	/// The current wanted level. Set internally; used internally, and for updating the wanted HUD.
	var/wanted_level

/datum/faction/cops/process()
	if(world.time > (end_time - 5 MINUTES) && !sent_second_announcement)
		five_minute_warning()
		addtimer(CALLBACK(src, .proc/send_in_the_fuzz), 5 MINUTES)
	..()

/datum/faction/cops/proc/five_minute_warning()
	second_announce.play()
	sent_second_announcement = TRUE

/datum/faction/cops/proc/change_apperance(mob/living/carbon/human/cop, client/C)
	var/new_name = sanitize_safe(input(C, "Pick a name","Name") as null|text, MAX_LNAME_LEN)
	C.create_human_apperance(cop, new_name)

/datum/faction/cops/proc/end_hostile_sit()
	SSshuttle.fake_recall = FALSE
	SSshuttle.incall(0.8)

/// Internal. Polls ghosts and sends in a team of space cops according to the wanted level, accompanied by an announcement. Will let the shuttle leave 10 minutes after sending. Freezes the wanted level.
/datum/faction/cops/proc/send_in_the_fuzz()
	var/team_size
	var/cops_to_send
	switch(wanted_level)
		if(1)
			team_size = 5
			cops_to_send = /datum/role/cop/beatcop
			var/datum/announcement/centcomm/gang/cops_1/announce = new
			announce.play()
		if(2)
			team_size = 6
			cops_to_send = /datum/role/cop/beatcop/armored
			var/datum/announcement/centcomm/gang/cops_2/announce = new
			announce.play()
		if(3)
			team_size = 7
			cops_to_send = /datum/role/cop/beatcop/swat
			var/datum/announcement/centcomm/gang/cops_3/announce = new
			announce.play()
		if(4)
			team_size = 8
			cops_to_send = /datum/role/cop/beatcop/fbi
			var/datum/announcement/centcomm/gang/cops_4/announce = new
			announce.play()
		if(5)
			team_size = 9
			cops_to_send = /datum/role/cop/beatcop/military
			var/datum/announcement/centcomm/gang/cops_5/announce = new
			announce.play()

	if(global.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		team_size += 3

	var/list/candidates = pollGhostCandidates("Хотите помочь разобраться с преступностью на станции?", ROLE_FAMILIES)
	if(candidates.len)
		//Pick the (un)lucky players
		var/numagents = min(team_size, candidates.len)

		var/list/spawnpoints = global.copsstart
		var/index = 0
		while(numagents && candidates.len)
			var/spawnloc = spawnpoints[index+1]
			//loop through spawnpoints one at a time
			index = (index + 1) % spawnpoints.len
			var/mob/dead/observer/chosen_candidate = pick(candidates)
			candidates -= chosen_candidate
			if(!chosen_candidate.key)
				continue

			//Spawn the body
			var/mob/living/carbon/human/cop = new(spawnloc)
			INVOKE_ASYNC(src, .proc/change_apperance, cop, chosen_candidate.client)
			cop.key = chosen_candidate.key

			//Give antag datum
			var/datum/faction/cops/faction = find_faction_by_type(/datum/faction/cops)
			if(faction)
				faction.roletype = cops_to_send
				add_faction_member(faction, cop, TRUE, TRUE)

			numagents--

	cops_arrived = TRUE
	update_wanted_level(wanted_level) // gotta make sure everyone's wanted level display looks nice
	addtimer(CALLBACK(src, .proc/end_hostile_sit), 10 MINUTES)
	return TRUE

/// Internal. Checks if our wanted level has changed; calls update_wanted_level. Only updates wanted level post the initial announcement and until the cops show up. After that, it's locked.
/datum/faction/cops/proc/check_wanted_level()
	if(cops_arrived)
		update_wanted_level(wanted_level) // at this point, we still want to update people's star huds, even though they're mostly locked, because not everyone is around for the last update before the rest of this proc gets shut off forever, and that's when the wanted bar switches from gold stars to red / blue to signify the arrival of the space cops
		return
	if(!sent_announcement)
		return
	var/new_wanted_level
	if(global.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		switch(global.deaths_during_shift)
			if(0 to TWO_STARS_HIGHPOP-1)
				new_wanted_level = 1
			if(TWO_STARS_HIGHPOP to THREE_STARS_HIGHPOP-1)
				new_wanted_level = 2
			if(THREE_STARS_HIGHPOP to FOUR_STARS_HIGHPOP-1)
				new_wanted_level = 3
			if(FOUR_STARS_HIGHPOP to FIVE_STARS_HIGHPOP-1)
				new_wanted_level = 4
			if(FIVE_STARS_HIGHPOP to INFINITY)
				new_wanted_level = 5
	else
		switch(global.deaths_during_shift)
			if(0 to TWO_STARS_LOW-1)
				new_wanted_level = 1
			if(TWO_STARS_LOW to THREE_STARS_LOW-1)
				new_wanted_level = 2
			if(THREE_STARS_LOW to FOUR_STARS_LOW-1)
				new_wanted_level = 3
			if(FOUR_STARS_LOW to FIVE_STARS_LOW-1)
				new_wanted_level = 4
			if(FIVE_STARS_LOW to INFINITY)
				new_wanted_level = 5
	update_wanted_level(new_wanted_level)

/// Internal. Updates the icon states for everyone, and calls procs that send out announcements / change the end_time if the wanted level has changed.
/datum/faction/cops/proc/update_wanted_level(newlevel)
	if(newlevel > wanted_level)
		on_gain_wanted_level(newlevel)
	else if (newlevel < wanted_level)
		on_lower_wanted_level(newlevel)
	wanted_level = newlevel
	for(var/i in global.player_list)
		var/mob/M = i
		if(!M.hud_used?.wanted_lvl)
			continue
		var/datum/hud/H = M.hud_used
		H.wanted_lvl.wanted_level = newlevel
		H.wanted_lvl.cops_arrived = cops_arrived
		H.wanted_lvl.update_icon_state()

/// Internal. Updates the end_time and sends out an announcement if the wanted level has increased. Called by update_wanted_level().
/datum/faction/cops/proc/on_gain_wanted_level(newlevel)
	var/announcement_message
	var/datum/announcement/centcomm/gang/change_wanted_level/announce = new
	switch(newlevel)
		if(2)
			if(!sent_second_announcement) // when you hear that they're "arriving in 5 minutes," that's a goddamn guarantee
				end_time = start_time + 50 MINUTES
			announcement_message = "Небольшое количество полицейского транспорта было замечено на пути к [station_name()]."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + 40 MINUTES
			announcement_message = "Большой отряд полицейского транспорта был замечен на пути к [station_name()]."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + 35 MINUTES
			announcement_message = "Флот высокотехнологичного транспорта был замечен на пути к [station_name()]."
		if(5)
			if(!sent_second_announcement)
				end_time = start_time + 30 MINUTES
			announcement_message = "Флот, направляющийся к [station_name()], теперь имеет транспорт национальной гвардии."

	announcement_message += " Они прибудут через [(end_time - start_time) / (1 MINUTES)] минут."
	if(newlevel == 1) // specific exception to stop the announcement from triggering right after the families themselves are announced because aesthetics
		return

	announce.play(announcement_message)

/// Internal. Updates the end_time and sends out an announcement if the wanted level has decreased. Called by update_wanted_level().
/datum/faction/cops/proc/on_lower_wanted_level(newlevel)
	var/announcement_message
	var/datum/announcement/centcomm/gang/change_wanted_level/announce = new
	switch(newlevel)
		if(1)
			if(!sent_second_announcement)
				end_time = start_time + 60 MINUTES
			announcement_message = "Сейчас только несколько едениц полицейского транспорта направляется к [station_name()]."
		if(2)
			if(!sent_second_announcement)
				end_time = start_time + 50 MINUTES
			announcement_message = "В сторону [station_name()] теперь направляется меньше полицейского транспорта."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + 40 MINUTES
			announcement_message = "Флот, направляющийся к [station_name()], больше не имеет высокотехнологичного трапспорта."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + 35 MINUTES
			announcement_message = "Конвой, направляющийся к [station_name()], больше не имеет транспорт национальной гвардии."

	announcement_message += " Они прибудут через [(end_time - start_time) / (1 MINUTES)] минут."
	announce.play(announcement_message)

#undef LOWPOP_FAMILIES_COUNT
#undef TWO_STARS_HIGHPOP
#undef THREE_STARS_HIGHPOP
#undef FOUR_STARS_HIGHPOP
#undef FIVE_STARS_HIGHPOP
#undef TWO_STARS_LOW
#undef THREE_STARS_LOW
#undef FOUR_STARS_LOW
#undef FIVE_STARS_LOW