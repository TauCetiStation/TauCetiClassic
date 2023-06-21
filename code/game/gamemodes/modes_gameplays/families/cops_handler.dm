#define LOWPOP_FAMILIES_COUNT 50

#define TWO_STARS_HIGHPOP 4
#define THREE_STARS_HIGHPOP 8
#define FOUR_STARS_HIGHPOP 12
#define FIVE_STARS_HIGHPOP 16

#define TWO_STARS_LOW 2
#define THREE_STARS_LOW 4
#define FOUR_STARS_LOW 6
#define FIVE_STARS_LOW 8


// This is not at all like on /tg/.
// "Family" and "gang" used interchangeably in code.
/datum/faction/cops
	/// Whether the "5 minute warning" announcement has been sent. Used and set internally.
	var/sent_second_announcement = FALSE
	var/datum/announcement/centcomm/gang/cops_closely/second_announce = new
	/// Whether the space cops have arrived. Set internally; used internally, and for updating the wanted HUD.
	var/cops_arrived = FALSE
	/// The current wanted level. Set internally; used internally, and for updating the wanted HUD.
	var/wanted_level = 0

/datum/faction/cops/process()
	if(isnull(start_time) || isnull(end_time))
		return
	check_wanted_level()
	if(world.time > (end_time - 5 MINUTES) && !sent_second_announcement)
		five_minute_warning()
		addtimer(CALLBACK(src, PROC_REF(send_in_the_fuzz)), 5 MINUTES)

	..()

/datum/faction/cops/proc/five_minute_warning()
	second_announce.play()
	sent_second_announcement = TRUE

/datum/faction/cops/proc/end_hostile_sit()
	SSshuttle.fake_recall = FALSE
	SSshuttle.shuttlealert(1)
	SSshuttle.incall(0.8)
	SSshuttle.announce_crew_called.play()

/// Internal. Polls ghosts and sends in a team of space cops according to the wanted level, accompanied by an announcement. Will let the shuttle leave 10 minutes after sending. Freezes the wanted level.
/datum/faction/cops/proc/send_in_the_fuzz()
	var/team_size
	var/cops_to_send
	switch(wanted_level)
		if(1)
			team_size = 5
			cops_to_send = /datum/spawner/cop/beatcop
			var/datum/announcement/centcomm/gang/cops_1/announce = new
			announce.play()
		if(2)
			team_size = 6
			cops_to_send = /datum/spawner/cop/armored
			var/datum/announcement/centcomm/gang/cops_2/announce = new
			announce.play()
		if(3)
			team_size = 7
			cops_to_send = /datum/spawner/cop/swat
			var/datum/announcement/centcomm/gang/cops_3/announce = new
			announce.play()
		if(4)
			team_size = 8
			cops_to_send = /datum/spawner/cop/fbi
			var/datum/announcement/centcomm/gang/cops_4/announce = new
			announce.play()
		if(5)
			team_size = 9
			cops_to_send = /datum/spawner/cop/military
			var/datum/announcement/centcomm/gang/cops_5/announce = new
			announce.play()

	if(global.joined_player_list.len > LOWPOP_FAMILIES_COUNT)
		team_size += 3

	spawn_space_police(team_size, cops_to_send)

	cops_arrived = TRUE
	update_wanted_level(wanted_level) // gotta make sure everyone's wanted level display looks nice
	addtimer(CALLBACK(src, PROC_REF(end_hostile_sit)), 10 MINUTES)

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
	var/atom/movable/screen/wanted/screen = wanted_lvl_screen
	screen.wanted_level = newlevel
	screen.cops_arrived = cops_arrived
	screen.update_icon_state()

/// Internal. Updates the end_time and sends out an announcement if the wanted level has increased. Called by update_wanted_level().
/datum/faction/cops/proc/on_gain_wanted_level(newlevel)
	var/announcement_message
	var/datum/announcement/centcomm/gang/change_wanted_level/announce = new
	switch(newlevel)
		if(2)
			if(!sent_second_announcement) // when you hear that they're "arriving in 5 minutes," that's a goddamn guarantee
				end_time= start_time + 70 MINUTES
			announcement_message = "Небольшое количество транспорта ОБОП было замечено на пути к [station_name()]."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + 60 MINUTES
			announcement_message = "Большой отряд транспорта ОБОП был замечен на пути к [station_name()]."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + 55 MINUTES
			announcement_message = "Флот высокотехнологичного транспорта ОБОП был замечен на пути к [station_name()]."
		if(5)
			if(!sent_second_announcement)
				end_time = start_time + 50 MINUTES
			announcement_message = "Флот, направляющийся к [station_name()], теперь имеет военизированный транспорт."

	var/time_to_cops = round((end_time - world.time) / 600)
	announcement_message += " ОБОП прибудет через [time_to_cops] минут."
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
				end_time = start_time + 80 MINUTES
			announcement_message = "Сейчас только несколько едениц транспорта ОБОП направляется к [station_name()]."
		if(2)
			if(!sent_second_announcement)
				end_time = start_time + 70 MINUTES
			announcement_message = "В сторону [station_name()] теперь направляется меньше транспорта ОБОП."
		if(3)
			if(!sent_second_announcement)
				end_time = start_time + 60 MINUTES
			announcement_message = "Флот, направляющийся к [station_name()], больше не имеет высокотехнологичного трапспорта."
		if(4)
			if(!sent_second_announcement)
				end_time = start_time + 55 MINUTES
			announcement_message = "Конвой, направляющийся к [station_name()], больше не имеет военизированный транспорт."

	var/time_to_cops = round((end_time - world.time) / 600)
	announcement_message += " ОБОП прибудут через [time_to_cops] минут."
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
