/*********************
	GameMode Exclusive
**********************/

// something copypasted from old gamemode vote. maybe we should have pregame vote component?
/datum/poll/range/gamemode
	name = "Выбрать режимы игры"
	description = "Выберите режимы, которые вы хотите играть."
	announce_winner = FALSE
	choice_types = list()
	minimum_voters = 0
	only_admin = FALSE

	multiple_votes = TRUE
	can_revote = TRUE
	can_unvote = TRUE
	see_votes = FALSE

	var/pregame = FALSE

/datum/poll/range/gamemode/get_force_blocking_reason()
	. = ..()
	if(.)
		return
	if(!world.is_round_preparing())
		return "Доступно только перед началом игры"

/datum/poll/range/gamemode/get_blocking_reason()
	. = ..()
	if(.)
		return

/datum/poll/range/gamemode/process()
	if(pregame && SSticker.current_state > GAME_STATE_PREGAME)
		pregame = FALSE
		SSvote.stop_vote()
		to_chat(world, "<b>Голосование прервано из-за начала игры.</b>")

/datum/poll/range/gamemode/on_start()
	if(SSticker.current_state == GAME_STATE_PREGAME)
		pregame = TRUE
		if(SSticker.timeLeft < config.vote_period + 15 SECONDS)
			SSticker.timeLeft = config.vote_period + 15 SECONDS
			to_chat(world, "<b>Начало игры отложено из-за голосования.</b>")

/datum/poll/range/gamemode/init_choices()
	for(var/type in subtypesof(/datum/game_mode))
		var/datum/game_mode/T = type
		if(!initial(T.name)) // exclude abstract gamemode types
			continue
		var/datum/game_mode/mode = new type()
		var/datum/vote_choice/range/gamemode/C = new()
		C.text = mode.name
		choices.Add(C)
		qdel(mode)

/datum/poll/range/gamemode/get_winners(list/choice_votes)
	var/max_votes = -INFINITY
	. = list()
	for(var/datum/vote_choice/V in choice_votes)
		// get most wanted modes from those which are runnable
		// for example, if 29 player server votes 10 for blob and 9 for traitor, traitor will win
		// because blob cannot run on 29 people
		var/datum/game_mode/M = config.pick_mode(V.text)
		if(!M.potential_runnable())
			continue
		max_votes = max(max_votes, choice_votes[V])
	for(var/datum/vote_choice/V in choice_votes)
		if(choice_votes[V] == max_votes)
			. += V

/datum/poll/range/gamemode/on_end()
	. = ..()
	pregame = FALSE
	for(var/datum/poll/gamemode/P in SSvote.votes)
		P.next_vote = last_vote + P.cooldown

/datum/vote_choice/range/gamemode
	options = list("Не хочу" = -1, "Хочу" = 1)

/datum/vote_choice/range/gamemode/on_win()
	if(master_mode != "Secret")
		master_mode = "Secret"
		world.save_mode("Secret")
	secret_force_mode = text

