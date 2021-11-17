// Ranged polls that allow voters to give choices a certain score
/datum/poll/range
	multiple_votes = TRUE
	choice_types = list(/datum/vote_choice/range)

/datum/poll/range/vote(datum/vote_choice/range/choice, value, client/C)
	var/ckey = C.ckey
	if(!(value in choice.options))
		return
	var/score = choice.options[value]
	var/total = score * get_vote_power(C)
	if(ckey in choice.voters)
		if(can_revote && can_unvote)
			choice.voters.Remove(ckey)
	else
		if(multiple_votes)
			choice.voters[ckey] = total
		else
			var/already_voted = FALSE
			for(var/datum/vote_choice/VC in choices)
				if(ckey in VC.voters)
					already_voted = TRUE
					if(can_revote)
						VC.voters.Remove(ckey)
			if(can_revote || !already_voted)
				choice.voters[ckey] = total

/datum/vote_choice/range
	// List of vote options. The associations are button names and values are scores that are summed up
	var/list/options = list("minus 1" = -1, "0" = 0, "plus 1" = 1)

/datum/vote_choice/range/render_html(client/voter)
	. = ""
	for(var/O in options)
		var/t = "<a href='?src=\ref[SSvote];vote=\ref[src];voteval=[url_encode(O)]'>[O]</a>"
		var/total = options[O] * SSvote.active_vote.get_vote_power(voter)
		if((voter.ckey in voters) && voters[voter.ckey] == total)
			t = "<b>[t]</b>"
		. += t
	. += " - [text]"
