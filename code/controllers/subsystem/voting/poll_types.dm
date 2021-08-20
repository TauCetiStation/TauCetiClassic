/*********************
	Restart
**********************/
/datum/poll/restart
	name = "Рестарт"
	question = "Рестарт раунда"
	color = "red"
	choice_types = list(
		/datum/vote_choice/restart,
		/datum/vote_choice/continue_round
		)
	only_admin = FALSE
	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = FALSE
	detailed_result = FALSE

	cooldown = 60 MINUTES
	minimum_win_percentage = 0.75

	description = "У вас будет больше вес голоса, если вы глава или антагонист, и меньше, если вы мертвы или призрак."
	warning_message = "Рестарт не подводит итоги раунда и не сохраняет статистику, поэтому используйте его как экстренное средство в случае технических проблем. Для корректного завершения раунда используйте голосование за Crew Transfer!"

/datum/poll/restart/get_force_blocking_reason()
	. = ..()
	if(!world.has_round_started())
		return "Раунд ещё не началася"
	if(world.has_round_finished())
		return "Раунд закончен"

/datum/poll/restart/get_blocking_reason()
	. = ..()
	if(.)
		return
	for(var/client/C in admins)
		if((C.holder.rights & R_ADMIN) && !C.holder.fakekey && !C.is_afk())
			return "Администрация сейчас в сети"

/datum/poll/restart/get_vote_power(client/C)
	return get_vote_power_by_role(C)

/datum/vote_choice/restart
	text = "Рестарт"

/datum/vote_choice/continue_round
	text = "Продолжить раунд"

/datum/vote_choice/restart/on_win()
	var/active_admins = FALSE
	for(var/client/C in admins)
		if(!C.is_afk() && (R_SERVER & C.holder.rights))
			active_admins = TRUE
			break
	if(!active_admins)
		to_chat(world, "<span class='boldannounce'>По результатам голосования мир будет перезагружен ...</span>")
		sleep(50)
		world.Reboot(end_state = "restart vote")
	else
		to_chat(world, "<span class='boldannounce'>Notice: Restart vote will not restart the server automatically because there are active admins on.</span>")
		message_admins("A restart vote has passed, but there are active admins on with +server, so it has been canceled. If you wish, you may restart the server.")


/*********************
	Crew Transfer
**********************/
/datum/poll/crew_transfer
	name = "Конец смены"
	question = "Вы хотите инициировать конец смены и вызвать шаттл для транспортировки экипажа?"
	choice_types = list(
		/datum/vote_choice/crew_transfer,
		/datum/vote_choice/no_crew_transfer
		)
	only_admin = FALSE
	can_revote = TRUE
	can_unvote = TRUE
	see_votes = FALSE
	detailed_result = FALSE

	minimum_win_percentage = 0.501

	cooldown = 30 MINUTES
	next_vote = 90 MINUTES //Minimum round length before it can be called for the first time

	description = "У вас будет больше вес голоса, если вы глава или антагонист, и меньше, если вы мертвы или если вы призрак."

/datum/poll/crew_transfer/get_force_blocking_reason()
	. = ..()
	if(.)
		return
	if(!world.has_round_started())
		return "Раунд ещё не начался"
	if(world.has_round_finished())
		return "Раунд закончен"

/datum/poll/crew_transfer/get_blocking_reason()
	. = ..()
	if(.)
		return
	if(SSshuttle.online || SSshuttle.location != 0)
		return "Шаттл используется"
	if(security_level >= SEC_LEVEL_RED)
		return "Код безопасности КРАСНЫЙ или выше"

/datum/poll/crew_transfer/get_vote_power(client/C)
	return get_vote_power_by_role(C)

/datum/vote_choice/crew_transfer
	text = "Конец смены"

/datum/vote_choice/no_crew_transfer
	text = "Продолжить играть"

/datum/vote_choice/crew_transfer/on_win()
	if(!SSshuttle.online && SSshuttle.location == 0)
		message_admins("A crew transfer vote has passed, calling the shuttle.")
		log_admin("A crew transfer vote has passed, calling the shuttle.")

		if(SSshuttle.fake_recall || SSshuttle.time_for_fake_recall)
			message_admins("The shuttle fake recall was supressed because of crew transfer vote.")
			log_admin("The shuttle fake recall was supressed because of crew transfer vote.")
			SSshuttle.fake_recall = FALSE
			SSshuttle.time_for_fake_recall = 0

		SSshuttle.shuttlealert(1)
		SSshuttle.incall()
		SSshuttle.announce_crew_called.play()


/*********************
	GameMode
**********************/
/datum/poll/gamemode
	name = "Режим Игры"
	question = "Выбрать режим игры"
	choice_types = list()
	minimum_voters = 0
	only_admin = FALSE

	multiple_votes = TRUE
	can_revote = TRUE
	can_unvote = TRUE
	see_votes = FALSE

	var/pregame = FALSE

/datum/poll/gamemode/get_force_blocking_reason()
	. = ..()
	if(.)
		return
	if(!world.is_round_preparing())
		return "Доступно только перед началом игры"

/datum/poll/gamemode/get_blocking_reason()
	. = ..()
	if(.)
		return

/datum/poll/gamemode/init_choices()
	for(var/type in subtypesof(/datum/modesbundle))
		var/datum/modesbundle/M = type
		if(!initial(M.votable))
			continue
		var/datum/modesbundle/bundle = new type()
		var/datum/vote_choice/gamemode/vc = new
		vc.text = bundle.name
		vc.new_gamemode = bundle.name
		choices.Add(vc)
		var/list/submodes = bundle.get_gamemodes_name()
		if(length(submodes) > 0)
			description += "<b>[bundle]</b>: "
			description += submodes.Join(", ")
			description += "<br>"
		qdel(bundle)

/datum/poll/gamemode/process()
	if(pregame && SSticker.current_state > GAME_STATE_PREGAME)
		pregame = FALSE
		SSvote.stop_vote()
		to_chat(world, "<b>Голосование прервано из-за начала игры.</b>")

/datum/poll/gamemode/on_start()
	if(SSticker.current_state == GAME_STATE_PREGAME)
		pregame = TRUE
		if(SSticker.timeLeft < config.vote_period + 15 SECONDS)
			SSticker.timeLeft = config.vote_period + 15 SECONDS
			to_chat(world, "<b>Начало игры отложено из-за голосования.</b>")

/datum/poll/gamemode/on_end()
	..()
	pregame = FALSE

/datum/vote_choice/gamemode
	text = "Название режима игры"
	var/new_gamemode = "casual_shift"

/datum/vote_choice/gamemode/on_win()
	if(master_mode != new_gamemode)
		master_mode = new_gamemode
		world.save_mode(new_gamemode)


/*********************
	Custom
**********************/
/datum/poll/custom
	name = "Пользовательское"
	question = "Почему здесь нет текста?"
	choice_types = list()

	only_admin = TRUE
	multiple_votes = TRUE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = TRUE

/datum/poll/custom/init_choices()
	multiple_votes = FALSE
	can_revote = TRUE
	can_unvote = FALSE
	see_votes = TRUE

	question = sanitize(input("Какой вопрос голосования?", "Пользовательское голосование", "Вопрос пользовательского голосования"))

	var/choice_text = ""
	var/ch_num = 1
	do
		choice_text = sanitize(input("Вариант ответа [ch_num]. Оставьте пустым, чтобы закончить ввод вариантов ответа и перейти дальше.", "Пользовательское голосование", ""))
		ch_num += 1
		if(choice_text != "")
			var/datum/vote_choice/custom/C = new
			C.text = choice_text
			choices.Add(C)
	while(choice_text != "" && ch_num < 10)

	if(tgui_alert(usr, "Можно ли проголосовать за несколько вариантов ответа?", "Пользовательское голосование", list("Да", "Нет")) == "Да")
		multiple_votes = TRUE

	if(tgui_alert(usr, "Можно ли изменять вариант ответа?", "Пользовательское голосование", list("Да", "Нет")) == "Нет")
		can_revote = FALSE

	if(tgui_alert(usr, "Можно ли отменить выбранный вариант ответа?", "Пользовательское голосование", list("Да", "Нет")) == "Да")
		can_unvote = TRUE

	if(tgui_alert(usr, "Можно ли видеть, сколько проголосовало за варианты ответа?", "Пользовательское голосование", list("Да", "Нет")) == "Нет")
		see_votes = FALSE

	if(tgui_alert(usr, "Завершить создание голосования?", "Пользовательское голосование", list("Да", "Нет")) == "Нет")
		choices.Cut()

/datum/vote_choice/custom
	text = "Вариант ответа"
