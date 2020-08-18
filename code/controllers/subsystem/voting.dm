SUBSYSTEM_DEF(vote)
	name = "Vote"

	wait = SS_WAIT_VOTE

	flags = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING | SS_NO_INIT

	var/initiator = null
	var/voting_started_time = null	//...thats why we use separate var to count remaining vote time.
	var/time_remaining = 0
	var/mode = null
	var/question = null
	var/description = null
	var/list/last_vote_time = list() //Not counting for custom votes, because it will apply voting cooldown and this is bad...
	var/list/delay_after_start = list("default", "restart")
	var/list/choices = list()
	var/list/voted = list()
	var/list/voting = list()
	var/static/list/votemode2text = list(
		"restart" = "Restart",
		"crew_transfer" = "Crew Transfer",
		"gamemode" = "GameMode",
		"custom" = "Custom"
		)

/datum/controller/subsystem/vote/fire()	//called by master_controller
	if(mode)
		time_remaining = round((voting_started_time + config.vote_period - world.time)/10)

		if(time_remaining < 0)
			result()
			for(var/client/C in voting)
				C << browse(null, "window=vote;can_close=0")
			reset()
		else
			var/datum/browser/client_popup
			for(var/client/C in voting)
				client_popup = new(C, "vote", "Voting Panel")
				client_popup.set_window_options("can_close=0")
				client_popup.set_content(interface(C))
				client_popup.open(0)


/datum/controller/subsystem/vote/proc/reset()
	initiator = null
	time_remaining = 0
	mode = null
	question = null
	description = null
	choices.Cut()
	voted.Cut()
	voting.Cut()

/datum/controller/subsystem/vote/proc/get_result()
	//get the highest number of votes
	var/greatest_votes = 0
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
		if(votes > greatest_votes)
			greatest_votes = votes
	//default-vote for everyone who didn't vote
	if(!config.vote_no_default && choices.len)
		var/non_voters = (clients.len - total_votes)
		if(non_voters > 0)
			if(mode == "restart")
				choices["Continue Playing"] += non_voters
				if(choices["Continue Playing"] >= greatest_votes)
					greatest_votes = choices["Continue Playing"]
			else if(mode == "crew_transfer")
				choices["Continue Playing"] += non_voters
				if(choices["Continue Playing"] >= greatest_votes)
					greatest_votes = choices["Continue Playing"]
			else if(mode == "gamemode")
				if(master_mode in choices)
					choices[master_mode] += non_voters
					if(choices[master_mode] >= greatest_votes)
						greatest_votes = choices[master_mode]
	//get all options with that many votes and return them in a list
	. = list()
	if(greatest_votes)
		for(var/option in choices)
			if(choices[option] == greatest_votes)
				. += option
	return .

/datum/controller/subsystem/vote/proc/announce_result()
	var/list/winners = get_result()
	var/text
	if(winners.len > 0)
		if(question)
			text += "<b>[question]</b>"
		else
			text += "<b>[capitalize(mode)] Vote</b>"
		for(var/i=1,i<=choices.len,i++)
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			text += "\n<b>[choices[i]]:</b> [votes]"
		if(mode != "custom")
			if(winners.len > 1)
				text = "\n<b>Vote Tied Between:</b>"
				for(var/option in winners)
					text += "\n\t[option]"
			. = pick(winners)
			text += "\n<b>Vote Result: [.]</b>"
		else
			text += "\n<b>Did not vote:</b> [clients.len-voted.len]"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	to_chat(world, "\n<font color='purple'>[text]</font>")
	return .

/datum/controller/subsystem/vote/proc/result()
	. = announce_result()
	var/restart = 0
	var/crewtransfer = 0
	if(.)
		switch(mode)
			if("restart")
				if(. == "Restart Round")
					restart = 1
			if("crew_transfer")
				if(. == "End Shift")
					crewtransfer = 1
			if("gamemode")
				if(master_mode != .)
					world.save_mode(.)
					if(SSticker && SSticker.mode)
						restart = 1
					else
						master_mode = .
	if(restart)
		var/active_admins = 0
		for(var/client/C in admins)
			if(!C.is_afk() && (R_SERVER & C.holder.rights))
				active_admins = 1
				break
		if(!active_admins)
			world.Reboot(end_state = "restart vote")
		else
			to_chat(world, "<span style='boldannounce'>Notice:Restart vote will not restart the server automatically because there are active admins on.</span>")
			message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")
	if(crewtransfer)
		if(!SSshuttle.online && SSshuttle.location == 0)
			SSshuttle.shuttlealert(1)
			SSshuttle.incall()
			captain_announce("A crew transfer has been initiated. The shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "crew_shut_called")
			message_admins("A crew transfer vote has passed, calling the shuttle.")
			log_admin("A crew transfer vote has passed, calling the shuttle.")

	return .

/datum/controller/subsystem/vote/proc/submit_vote(vote)
	if(mode)
		if(config.vote_no_dead && usr.stat == DEAD && !usr.client.holder)
			return 0
		if(!(usr.ckey in voted))
			if(vote && 1<=vote && vote<=choices.len)
				voted[usr.ckey] = choices[vote]
				choices[choices[vote]]++	//check this
				return vote

	return 0

/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, initiator_key)
	var/is_admin = FALSE
	if(check_rights(R_ADMIN))
		is_admin = TRUE
	var/timer_mode = "default"
	if(vote_type == "restart")
		timer_mode = "restart"
	if(!mode)
		if(last_vote_time[timer_mode] != null && !is_admin)
			var/next_allowed_time = (last_vote_time[timer_mode] + config.vote_delay)
			if(next_allowed_time > world.time)
				to_chat(usr, "<span class='vote'>Next [votemode2text[vote_type]] vote is available after [round((next_allowed_time-world.time)/600)] minutes</span>")
				return 0

		reset()
		switch(vote_type)
			if("restart")
				if(!is_admin)
					var/num_admins_online = 0
					for(var/client/C in admins)
						if(C.holder.rights & R_ADMIN)
							if(!C.holder.fakekey && !C.is_afk())
								num_admins_online++
					if(num_admins_online)
						to_chat(usr, "<span class='vote'>Admins online. Restart vote canceled</span>")
						return 0
				choices.Add("Restart Round","Continue Playing")
			if("gamemode")
				choices.Add(config.votable_modes)
				for(var/M in config.votable_modes)
					if(config.is_modeset(M))
						var/list/submodes = list()
						for(var/datum/game_mode/D in config.get_runnable_modes(M, FALSE))
							submodes.Add(D.name)
						if(length(submodes) > 0)
							description += "<b>[M]</b>: "
							description += submodes.Join(", ")
							description += "<br>"
			if("crew_transfer")
				if(!is_admin)
					if(get_security_level() == "red" || get_security_level() == "delta")
						to_chat(usr, "<span class='vote'>Security level is red or delta. Crew transfer vote canceled</span>")
						return 0
				choices.Add("End Shift","Continue Playing")
			if("custom")
				question = capitalize(sanitize(input(usr,"What is the vote for?")))
				if(!question)
					return 0
				for(var/i=1,i<=10,i++)
					var/option = capitalize(sanitize(input(usr,"Please enter an option or hit cancel to finish")))
					if(!option || mode || !usr.client)
						break
					choices.Add(option)
			else
				return 0
		mode = vote_type
		initiator = initiator_key
		voting_started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator]."
		if(mode == "custom")
			text += "\n[question]"
		else
			last_vote_time[timer_mode] = world.time
		log_vote(text)
		var/vote_sound = 'sound/misc/notice1.ogg'
		if(mode == "restart")
			vote_sound = 'sound/misc/interference.ogg'
		for(var/mob/M in player_list)
			M.playsound_local(null, vote_sound, VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
		to_chat(world, "\n<font color='purple'><b>[text]</b>\nType <b>vote</b> or click <a href='?src=\ref[src]'>here</a> to place your votes.\nYou have [config.vote_period/10] seconds to vote.</font>")
		time_remaining = round(config.vote_period/10)

		if(vote_type != "custom")
			for(var/client/C in clients)
				var/datum/browser/popup = new(C, "vote", "Voting Panel")
				popup.set_window_options("can_close=0")
				popup.set_content(SSvote.interface(C))
				popup.open(0)
		return 1
	return 0

/datum/controller/subsystem/vote/proc/interface(client/C)
	if(!C)
		return
	var/admin = FALSE
	if(C.holder && (C.holder.rights & R_ADMIN))
		admin = TRUE
	voting |= C

	if(mode)
		switch(mode)
			if("custom")
				. += "<h2>Vote: '[sanitize(question)]'</h2>"
			if("restart")
				. += "<h2 style='color:red'>Vote: /!!!\\ Restart /!!!\\</h2>"
			else
				. += "<h2>Vote: [capitalize(mode)]</h2>"
		. += "Time Left: [time_remaining] s<hr><ul>"
		for(var/i=1,i<=choices.len,i++)
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			. += "<li><a href='?src=\ref[src];vote=[i]'>[sanitize(choices[i])]</a>"
			if(mode == "custom" || admin)
				. += "([votes] votes)"
			if(choices[i] == voted[C.ckey])
				. += " [html_decode("&#10003")]" // Checkmark
			. += "</li>"
		. += "</ul><hr>"
		if(description)
			. += "[description]<hr>"
		if(admin)
			. += "(<a href='?src=\ref[src];vote=cancel'>Cancel Vote</a>) "
	else
		. += "<h2>Start a vote:</h2><hr><ul><li>"
		//restart
		if(admin || config.allow_vote_restart && world.has_round_started())
			. += "<a href='?src=\ref[src];vote=restart'>Restart</a>"
		else
			. += "<font color='grey'>Restart (Disallowed)</font>"
		if(admin)
			. += "&emsp;(<a href='?src=\ref[src];vote=toggle_restart'>[config.allow_vote_restart?"Allowed":"Disallowed"]</a>)"
		. += "</li><li>"
		//crew transfer
		if(admin || config.allow_vote_mode && crew_transfer_available())
			. += "<a href='?src=\ref[src];vote=crew_transfer'>Crew Transfer</a>"
		else
			. += "<font color='grey'>Crew Transfer (Disallowed)</font>"
		if(admin)
			. += "\t(<a href='?src=\ref[src];vote=toggle_crew'>[config.allow_vote_mode?"Allowed":"Disallowed"]</a>)"
		. += "</li><li>"
		//gamemode
		if(admin || config.allow_vote_mode && world.is_round_preparing())
			. += "<a href='?src=\ref[src];vote=gamemode'>GameMode</a>"
		else
			. += "<font color='grey'>GameMode (Disallowed)</font>"
		if(admin)
			. += "\t(<a href='?src=\ref[src];vote=toggle_gamemode'>[config.allow_vote_mode?"Allowed":"Disallowed"]</a>)"

		. += "</li>"
		//custom
		if(admin)
			. += "<li><a href='?src=\ref[src];vote=custom'>Custom</a></li>"
		. += "</ul><hr>"
	. += "<a href='?src=\ref[src];vote=close' style='position:absolute;right:50px'>Close</a>"
	return .

/datum/controller/subsystem/vote/Topic(href,href_list[],hsrc)
	if(!usr || !usr.client)
		return	//not necessary but meh...just in-case somebody does something stupid
	switch(href_list["vote"])
		if("close")
			voting -= usr.client
			usr << browse(null, "window=vote")
			return
		if("cancel")
			if(usr.client.holder)
				reset()
		if("toggle_restart")
			if(usr.client.holder)
				config.allow_vote_restart = !config.allow_vote_restart
		if("toggle_crew")
			if(usr.client.holder)
				config.allow_vote_mode = !config.allow_vote_mode
		if("toggle_gamemode")
			if(usr.client.holder)
				config.allow_vote_mode = !config.allow_vote_mode
		if("restart")
			if((config.allow_vote_restart || usr.client.holder) && !SSshuttle.online && SSshuttle.location == 0)
				initiate_vote("restart",usr.key)
		if("crew_transfer")
			if((config.allow_vote_mode || usr.client.holder) && crew_transfer_available())
				initiate_vote("crew_transfer",usr.key)
		if("gamemode")
			if((config.allow_vote_mode || usr.client.holder) && world.is_round_preparing())
				initiate_vote("gamemode",usr.key)
		if("custom")
			if(usr.client.holder)
				initiate_vote("custom",usr.key)
		else
			submit_vote(round(text2num(href_list["vote"])))
	usr.vote()


/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	var/datum/browser/popup = new(src, "vote", "Voting Panel")
	popup.set_window_options("can_close=0")
	popup.set_content(SSvote.interface(client))
	popup.open(0)

/datum/controller/subsystem/vote/proc/crew_transfer_available()
	return (world.has_round_started() && !world.has_round_finished() && !SSshuttle.online && SSshuttle.location == 0)
