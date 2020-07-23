/proc/GameOver()
	if(!hadevent)
		hadevent = 1
		message_admins("The apocalypse has begun! (this holiday event can be disabled by toggling events off within 60 seconds)")
		spawn(600)
			if(!config.allow_random_events)	return
			Show2Group4Delay(ScreenText(null,"<center><font color='red' size='8'>GAME OVER</font></center>"),null,150)
			var/datum/event_container/apocalypse_events = new/datum/event_container/major
			for(var/datum/event_meta/E in apocalypse_events.available_events)
				new E.event_type(E)
				sleep(50)
