SUBSYSTEM_DEF(vote)
	name = "Vote"

	wait = SS_WAIT_VOTE

	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT | SS_SHOW_IN_MC_TAB

	var/list/datum/poll/possible_polls = list()
	var/datum/poll/active_poll
	var/vote_start_time = 0

/datum/controller/subsystem/vote/PreInit()
	for(var/T in subtypesof(/datum/poll))
		var/datum/poll/P = new T
		possible_polls[T] = P

/datum/controller/subsystem/vote/fire()	//called by master_controller
	if(!active_poll)
		return

	active_poll.process(wait * 0.1)
	if(!active_poll)//Need to check again because the active vote can be nulled during its process. For example if an admin forces start
		return

	if(get_vote_time() < 0)
		active_poll.check_winners()
		SSStatistics.add_vote(active_poll)
		stop_vote()

/datum/controller/subsystem/vote/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vote", "Панель голосования")
		ui.open()

/datum/controller/subsystem/vote/tgui_state(mob/user)
	return global.always_state

/datum/controller/subsystem/vote/tgui_data(mob/user)
	var/list/data = ..()

	var/is_admin = user.client.holder?.rights & R_ADMIN
	data["isAdmin"] = is_admin

	data["polls"] = list()
	data["currentPoll"] = null

	for(var/poll_path in possible_polls)
		var/datum/poll/poll_inst = possible_polls[poll_path]

		var/list/poll = list(
			"name" = poll_inst.name,
			"type" = "[poll_path]", // i hate every line of that
			"adminOnly" = poll_inst.only_admin,
			"canStart" = poll_inst.can_start(),
			"forceBlocked" = !!poll_inst.get_force_blocking_reason(),
			"message" = poll_inst.get_blocking_or_warning_message(),
		)

		data["polls"] += list(poll)

		if(poll_inst == active_poll)
			var/list/choices = list()
			for(var/datum/vote_choice/choice in active_poll.choices)
				choices += list(list(
					"name" = choice.text,
					"ref" = "\ref[choice]",
					"votes" = choice.total_votes(),
					"selected" = (user.client.ckey in choice.voters),
				))

			data["currentPoll"] = list(
				"poll" = poll,
				"question" = active_poll.question,
				"description" = active_poll.description,
				"showWarning" = !!active_poll.warning_message,
				"timeRemaining" = get_vote_time(),
				"choices" = choices,
				"canVoteMultiple" = active_poll.multiple_votes,
				"canRevote" = active_poll.can_revote,
				"canUnvote" = active_poll.can_unvote,
				"minimumWinPercentage" = active_poll.minimum_win_percentage,
			)

	return data

/datum/controller/subsystem/vote/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return

	switch(action)
		if("putVote")
			if(!active_poll)
				return TRUE
			var/datum/vote_choice/choice = locate(params["choiceRef"]) in active_poll.choices
			if(istype(choice) && usr && usr.client)
				active_poll.vote(choice, usr.client)

		if("callVote")
			var/poll_path = text2path(params["pollRef"])
			if(!(poll_path in possible_polls))
				return TRUE

			var/datum/poll/poll = possible_polls[poll_path]
			if(check_rights(R_ADMIN) || (!poll.only_admin && poll.can_start()))
				start_vote(poll)

		if("toggleAdminOnly")
			var/poll_path = text2path(params["pollRef"])
			if(!(poll_path in possible_polls))
				return TRUE

			var/datum/poll/poll = possible_polls[poll_path]
			if(check_rights(R_ADMIN))
				poll.only_admin = !poll.only_admin

		if("cancelVote")
			if(active_poll && check_rights())
				to_chat(world, "<span class='vote'><b>[usr.key] отменил голосование \"[active_poll.name]\".</b></span>")
				stop_vote()
	return TRUE

/datum/controller/subsystem/vote/proc/start_vote(datum/poll/poll)
	if(active_poll)
		return FALSE

	//can_start check is done before calling this so that admins can skip it
	if(!istype(poll))
		return FALSE

	if(!poll.start())
		return

	active_poll = poll
	vote_start_time = world.time

	for(var/client/C in clients)
		tgui_interact(C.mob)

	var/text = "[poll.initiator] начал голосование \"[poll.name]\"."
	log_vote(text)
	to_chat(world, "<span class='vote'><b>[text]</b><br>Введите <b>vote</b> или нажмите <a href='byond://winset?command=vote'>здесь</a>, чтобы проголосовать. <br>У вас есть [get_vote_time()] [pluralize_russian(get_vote_time(), "секунда", "секунды", "секунд")], чтобы проголосовать.</span>")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/misc/notice1.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)

	return TRUE

/datum/controller/subsystem/vote/proc/stop_vote()
	if(!active_poll)
		return FALSE
	active_poll.reset()
	vote_start_time = 0
	active_poll = null

	return TRUE

/datum/controller/subsystem/vote/proc/get_vote_time()	//How many seconds vote lasts
	var/vote_period

	if(active_poll && active_poll.vote_period)
		vote_period = active_poll.vote_period
	else
		vote_period = config.vote_period

	return round((vote_start_time + vote_period - world.time)/10)

/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	SSvote.tgui_interact(src)
