/*To prevent abuse and rule-by-salt, the evac vote weights each player's vote based on a few parameters
	If you are alive and have been for a while, then you have the normal 1 vote
	If you are dead, or just spawned, you get only 0.3 votes
	If you are an antag or a head of staff, you get 2 votes
*/
#define VOTE_WEIGHT_NONE   0
#define VOTE_WEIGHT_LOW    0.5
#define VOTE_WEIGHT_NORMAL 1
#define VOTE_WEIGHT_HIGH   1.5
#define MINIMUM_VOTE_LIFETIME 15 MINUTES


/datum/poll
	var/name = "Голосование"
	var/question = ""
	var/color = "white" // span color of question and name
	var/description = ""
	var/warning_message = ""
	var/list/choice_types = list(/datum/vote_choice) //Choices will be initialized from this list
	var/list/datum/vote_choice/choices = list() // contents initiated /datum/vote_choice
	var/initiator = null

	var/only_admin = TRUE //Is only admins can initiate this?
	var/multiple_votes = FALSE
	var/can_revote = TRUE //Can voters change their mind?
	var/can_unvote = FALSE
	var/see_votes  = TRUE //Can voters see choices votes count?
	var/detailed_result = TRUE

	var/minimum_voters = 1 //If less than this many people cast a vote, the result will be invalid
	var/minimum_win_percentage = 0 //If less than this portion of the total votes are for the winning option, result is invalid

	var/cooldown = 30 MINUTES //After this vote is called, how long must pass before it can be called again
	var/last_vote = 0 //When was the last time this vote was called
	var/next_vote = 0 //When will we next be allowed to call it again?
	//You can set this time to a nonzero value to force a minimum roundtime before the vote can be called

	var/vote_period = null //overrides default config.vote_period

	var/datum/vote_choice/winner

/datum/poll/proc/init_choices()
	for(var/ch in choice_types)
		choices.Add(new ch)

/datum/poll/proc/start()
	init_choices()
	if(!choices.len)
		return FALSE
	if(usr && usr.client)
		initiator = usr.client.key
	else
		initiator = "Сервер"
	on_start()
	return TRUE

/datum/poll/proc/get_force_blocking_reason()
	return

/datum/poll/proc/can_start()
	return !get_blocking_reason()

/datum/poll/proc/get_blocking_reason()
	. = get_force_blocking_reason()
	if(.)
		return
	if(world.time < next_vote)
		return "Голосование снова станет доступным через [round((next_vote - world.time) / 600)] [pluralize_russian(round((next_vote - world.time) / 600), "минуту", "минуты", "минут")]"

/datum/poll/proc/get_blocking_or_warning_message()
	return get_blocking_reason() || warning_message

/datum/poll/proc/on_start()
	return

/datum/poll/proc/on_end()
	last_vote = world.time
	//If this is false, the poll may have already set a custom next vote time
	if(next_vote <= last_vote)
		next_vote = last_vote + cooldown
	return

/datum/poll/proc/reset()
	on_end()
	choices.Cut()
	initiator = null
	description = initial(description)

/datum/poll/proc/reset_next_vote()
	next_vote = 0

/datum/poll/process()
	return

/datum/poll/proc/vote(datum/vote_choice/choice, client/C)
	var/ckey = C.ckey
	if(ckey in choice.voters)
		if(can_revote && can_unvote)
			choice.voters.Remove(ckey)
	else
		if(multiple_votes)
			choice.voters[ckey] = get_vote_power(C, choice)
		else
			var/already_voted = FALSE
			for(var/datum/vote_choice/VC in choices)
				if(ckey in VC.voters)
					already_voted = TRUE
					if(can_revote)
						VC.voters.Remove(ckey)
			if(can_revote || !already_voted)
				choice.voters[ckey] = get_vote_power(C, choice)


//How much does this person's vote count for?
/datum/poll/proc/get_vote_power(client/C, datum/vote_choice/choice)
	return VOTE_WEIGHT_NORMAL * choice.vote_weight

//How many unique people have cast votes?
/datum/poll/proc/total_voters()
	var/list/all_voters = list()
	for(var/datum/vote_choice/V in choices)
		all_voters |= V.voters
	return all_voters.len

//Whats the total vote power cast by all voters?
/datum/poll/proc/total_votes()
	var/total = 0
	for(var/datum/vote_choice/V in choices)
		total += V.total_votes()
	return total

/datum/poll/proc/check_winners()
	var/list/choice_votes = list()
	var/list/all_voters = list()
	for(var/datum/vote_choice/V in choices)
		all_voters |= V.voters
		choice_votes[V] = V.total_votes()
	var/max_votes = 0
	for(var/datum/vote_choice/V in choice_votes)
		max_votes = max(max_votes, choice_votes[V])

	var/text = "" //The result text will be built and displayed
	var/invalid = FALSE //Check for conditions that would nullify the vote

	//Need to pass the minimum threshold of voters
	if(total_voters() < minimum_voters)
		text += "<b>Голосование отменено: Недостаточно игроков проголосовало.</b><br>"
		text += "[total_voters()]/[minimum_voters] игроков проголосовало.<br><br>"
		invalid = TRUE

	//Lets see if the max votes meets the minimum threshold
	else if(total_votes() > 0) //Make sure we dont divide by zero
		var/max_votepercent = max_votes / total_votes()
		if(max_votepercent < minimum_win_percentage)
			text += "<b>Голосование отменено: Недостаточное большинство</b><br>"
			text += "Ни один из вариантов не набрал необходимые [minimum_win_percentage*100]% для победы.<br>"
			text += "Наибольший процент голосов: [PERCENT(max_votepercent)]%<br><br>"
			invalid = TRUE

	var/list/winners = list()
	if(!invalid)
		for(var/datum/vote_choice/V in choice_votes)
			if(choice_votes[V] == max_votes)
				winners.Add(V)
		if(winners.len)
			winner = pick(winners)

	var/non_voters = clients.len - all_voters.len

	text += "<b>Голоса:</b><br>"
	for(var/datum/vote_choice/ch in choice_votes)
		var/ch_percent = total_votes() ? PERCENT(choice_votes[ch] / total_votes()) : 0
		if(ch in winners)
			text += "\t<b>[ch.text] - [ch_percent]%[detailed_result ? " ([choice_votes[ch]])" : ""]</b><br>"
		else
			text += "\t[ch.text] - [ch_percent]%[detailed_result ? " ([choice_votes[ch]])" : ""]<br>"

	text += "Всего проголосовало - [all_voters.len]<br>"
	text += "Не проголосовало - [non_voters]<br>"

	if(winner)
		text += "<b>Результат голосования[winners.len > 1 ? " (Случайно)" : ""]: [winner.text]</b><br>"

	log_vote(text)
	to_chat(world, "<span class='vote'>[text]</span>")

	if(winner)
		winner.on_win()

/datum/poll/proc/get_vote_power_by_role(client/C)
	if(!istype(C))
		return VOTE_WEIGHT_NONE //Shouldnt be possible, but safety

	if(C.holder)
		return VOTE_WEIGHT_NORMAL

	var/mob/M = C.mob
	if(!M || M.stat == DEAD || isobserver(M) || isnewplayer(M) || ismouse(M) || isdrone(M))
		return VOTE_WEIGHT_LOW

	//Antags control the story of the round, they should be able to delay evac in order to enact their
	//fun and interesting plans
	if(is_special_character(M))
		return VOTE_WEIGHT_HIGH

	//How long has this player been alive
	//This comes after the antag check because that's more important
	var/lifetime = world.time - M.mind.creation_time
	if(lifetime <= MINIMUM_VOTE_LIFETIME)
		//If you just spawned for the vote, your weight is still low
		return VOTE_WEIGHT_LOW

	//Heads of staff are in a better position to understand the state of the ship and round,
	//their vote is more important.
	//This is after the lifetime check to prevent exploits of instaspawning as a head when a vote is called
	if(M.is_head_role())
		return VOTE_WEIGHT_HIGH

	//If we get here, its just a normal player who's been playing for at least 15 minutes. Normal weight
	return VOTE_WEIGHT_NORMAL

#undef VOTE_WEIGHT_NONE
#undef VOTE_WEIGHT_LOW
#undef VOTE_WEIGHT_NORMAL
#undef VOTE_WEIGHT_HIGH
#undef MINIMUM_VOTE_LIFETIME
