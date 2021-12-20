SUBSYSTEM_DEF(vote)
	name = "Vote"

	wait = SS_WAIT_VOTE

	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

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
	var/datum/browser/panel = new(C, "vote", "Панель голосования", 550, 650, nref = src)
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

	var/text = "[poll.initiator] начал голосование \"[poll.name]\"."
	log_vote(text)
	to_chat(world, "<span class='vote'><b>[text]</b><br>Введите <b>vote</b> или нажмите <a href='?src=\ref[src]'>здесь</a>, чтобы проголосовать. <br>У вас есть [get_vote_time()] [pluralize_russian(get_vote_time(), "секунда", "секунды", "секунд")], чтобы проголосовать.</span>")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/misc/notice1.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)

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
		. += "<h2>Голосование: <span style='color:[active_vote.color]'>[active_vote.name]</span></h2>"
		. += "<i><b><span style='color:[active_vote.color]'>[active_vote.question]</span></b></i><br><br>"
		. += "Оставшееся время: [get_vote_time()] s<br>"
		. += "Инициатор голосования: <b>[active_vote.initiator]</b><hr>"

		if(active_vote.multiple_votes)
			. += "Вы можете проголосовать за <b>несколько</b> вариантов.<br>"
		else
			. += "Вы можете проголосовать <b>только за один</b> вариант.<br>"

		if(active_vote.can_revote)
			. += "Вы <b>можете изменить</b> свой голос.<br>"
		else
			. += "Вы <b>не можете изменить</b> свой голос.<br>"

		if(active_vote.can_unvote)
			. += "Вы <b>можете отменить</b> свой голос.<br>"
		else
			. += "Вы <b>не можете отменить</b> свой голос.<br>"
		if(active_vote.minimum_win_percentage)
			. += "Необходимо набрать минимум <b>[active_vote.minimum_win_percentage * 100]%</b>, чтобы вариант победил."

		. += "<hr>"
		. += "<table width = '100%'><tr><td width = '80%' align = 'center'><b>Варианты</b></td><td align = 'center'><b>Голоса</b></td>"

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
			. += "<a href='?src=\ref[src];cancel=1'>Отменить голосование</a>"
	else
		var/any_votes = FALSE
		. += "<h2>Начать голосование:</h2><hr>"
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
						. += "<td class='collapsing'><a href='?src=\ref[src];start_vote=\ref[poll]'>начать</a></td>"
					else
						. += "<td class='collapsing'><s>\[начать]</s></td>"
				else
					. += "<td class='collapsing'></td>"
			if(admin)
				. += "<td class='collapsing'><a href='?src=\ref[src];toggle_admin=\ref[poll]'>[poll.only_admin ? "Только админы" : "Разрешено всем"]</a></td>"
			. += "<td><i>[poll.get_blocking_or_warning_message()]</i></td>"
			. += "</tr>"

		if(!any_votes)
			. += "<li><i>Сейчас здесь нет доступных голосований.</i></li>"

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
			to_chat(world, "<span class='vote'><b>[usr.key] отменил голосование \"[active_vote.name]\".</b></span>")
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
