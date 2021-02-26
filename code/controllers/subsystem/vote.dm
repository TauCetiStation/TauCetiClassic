SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = SS_WAIT_VOTE
	flags = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING | SS_NO_INIT

	var/list/votes = list()  // List of all possible votes (datum/poll)
	var/list/voters = list() //List of clients with opened vote window
	var/datum/poll/active_vote = null
	var/vote_start_time = 0

/datum/controller/subsystem/vote/PreInit()
	for(var/T in subtypesof(/datum/poll))
		var/datum/poll/P = new T
		votes[T] = P

/datum/controller/subsystem/vote/fire()	//called by master_controller
	if(active_vote)
		active_vote.process()
		if(active_vote)//Need to check again because the active vote can be nulled during its process. For example if an admin forces start
			if(get_vote_time() < 0)
				active_vote.check_winners()
				for(var/client/C in voters)
					C << browse(null, "window=vote")
				stop_vote()
			else
				for(var/client/C in voters)
					interface_client(C)


/datum/controller/subsystem/vote/proc/interface_client(client/C)
	var/datum/browser/panel = new(C, "vote", "Voting Panel", 500, 650, nref = src)
	panel.set_content(interface(C))
	panel.open()

/datum/controller/subsystem/vote/proc/start_vote(newvote)
	if(active_vote)
		return FALSE

	var/datum/poll/poll = null

	if(ispath(newvote) && (newvote in votes))
		poll = votes[newvote]

	//can_start check is done before calling this so that admins can skip it
	if(!poll)
		return FALSE

	if(!poll.start())
		return

	vote_start_time = world.time

	for(var/client/C in clients)
		interface_client(C)

	var/text = "[poll.name] vote started by [poll.initiator]."
	log_vote(text)
	to_chat(world, "<span class='vote'><b>[text]</b><br>Type <b>vote</b> or click <a href='?src=\ref[src]'>here</a> to place your votes. <br>You have [get_vote_time()] seconds to vote.</span>")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/misc/notice1.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)

	return TRUE

/datum/controller/subsystem/vote/proc/stop_vote()
	if(!active_vote)
		return FALSE
	active_vote.reset()
	vote_start_time = 0
	voters.Cut()
	active_vote = null
	return TRUE

/datum/controller/subsystem/vote/proc/get_vote_time()	//How many seconds vote lasts
	return round((vote_start_time + config.vote_period - world.time)/10)

/datum/controller/subsystem/vote/proc/interface(client/C)
	if(!C)
		return
	var/admin = FALSE
	if(C.holder && (C.holder.rights & R_ADMIN))
		admin = TRUE
	voters |= C

	if(active_vote)
		. += "<h2>Vote: <span style='color:[active_vote.color]'>[active_vote.name]</span></h2>"
		. += "<i><b><span style='color:[active_vote.color]'>[active_vote.question]</span></b></i><br><br>"
		. += "Time Left: [get_vote_time()] s<br>"
		. += "Started by: <b>[active_vote.initiator]</b><hr>"

		if(active_vote.multiple_votes)
			. += "You can vote <b>multiple</b> choices.<br>"
		else
			. += "You can vote <b>only one</b> choice.<br>"

		if(active_vote.can_revote)
			. += "You <b>can change</b> your vote.<br>"
		else
			. += "You <b>can't change</b> your vote.<br>"

		if(active_vote.can_unvote)
			. += "You <b>can remove</b> vote.<br>"
		else
			. += "You <b>can't remove</b> vote.<br>"
		if(active_vote.minimum_win_percentage)
			. += "A minimum <b>[active_vote.minimum_win_percentage * 100]%</b> is required to win the option."

		. += "<hr>"
		. += "<table width = '100%'><tr><td width = '80%' align = 'center'><b>Choices</b></td><td align = 'center'><b>Votes</b></td>"

		for(var/datum/vote_choice/choice in active_vote.choices)
			var/c_votes = (active_vote.see_votes || admin) ? choice.total_votes() : "*"
			. += "<tr><td>"
			if(C.ckey in choice.voters)
				. += "<b><a href='?src=\ref[src];vote=\ref[choice]'>[choice.text]</a></b>"
				. += " [html_decode("&#10003")]" // Checkmark
			else
				. += "<a href='?src=\ref[src];vote=\ref[choice]'>[choice.text]</a>"
			. += "</td><td align = 'center'>[c_votes]</td></tr>"

		. += "</table><hr>"
		if(active_vote.description)
			. += "[active_vote.description]<hr>"
		if(admin)
			. += "<a href='?src=\ref[src];cancel=1'>Cancel Vote</a>"
	else
		var/any_votes = FALSE
		. += "<h2>Start a vote:</h2><hr>"
		. += "<table width='auto'>"
		for(var/P in votes)
			var/datum/poll/poll = votes[P]
			if(poll.only_admin && !admin)
				continue
			. += "<tr>"
			any_votes = TRUE

			if(poll.can_start() && (!poll.only_admin || admin))
				. += "<td class='collapsing'><a href='?src=\ref[src];start_vote=\ref[poll]'>[poll.name]</a></td>"
				. += "<td class='collapsing'></td>"
			else
				. += "<td class='collapsing'><s>[poll.name]</s></td>"
				if(admin)
					if(!poll.get_force_blocking_reason())
						. += "<td class='collapsing'><a href='?src=\ref[src];start_vote=\ref[poll]'>force</a></td>"
					else
						. += "<td class='collapsing'><s>\[force]</s></td>"
				else
					. += "<td class='collapsing'></td>"
			if(admin)
				. += "<td class='collapsing'><a href='?src=\ref[src];toggle_admin=\ref[poll]'>[poll.only_admin ? "Only admin" : "Allowed"]</a></td>"
			. += "<td><i>[poll.get_blocking_reason()]</i></td>"
			. += "</tr>"

		if(!any_votes)
			. += "<li><i>There is no available votes here now.</i></li>"

		. += "</table><hr>"
	return .


/datum/controller/subsystem/vote/Topic(href, href_list[], hsrc)
	if(href_list["vote"])
		if(active_vote)
			var/datum/vote_choice/choice = locate(href_list["vote"]) in active_vote.choices
			if(istype(choice) && usr && usr.client)
				active_vote.vote(choice, usr.client)

	if(href_list["toggle_admin"])
		var/datum/poll/poll = locate(href_list["toggle_admin"])
		if(istype(poll) && check_rights(R_ADMIN))
			poll.only_admin = !poll.only_admin

	if(href_list["start_vote"])
		var/datum/poll/poll = locate(href_list["start_vote"])
		if(istype(poll) && (check_rights(R_ADMIN) || (!poll.only_admin && poll.can_start())))
			start_vote(poll.type)

	if(href_list["cancel"])
		if(active_vote && check_rights())
			to_chat(world, "<span class='vote'><b>[active_vote.name] vote canceled by [usr.key].</b></span>")
			stop_vote()

	if(href_list["close"])
		if(usr && usr.client)
			voters.Remove(usr.client)
			usr.client << browse(null, "window=vote")
			return

	usr.vote()

/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	SSvote.interface_client(client)
