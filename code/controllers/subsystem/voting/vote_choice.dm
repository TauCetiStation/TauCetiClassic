/datum/vote_choice
	var/text = "Nothing"
	var/vote_weight = 1
	var/list/voters = list() //assoc list of ckeys of voters and the voting power they contributed

/datum/vote_choice/proc/on_win()
	return

/datum/vote_choice/proc/total_votes()
	. = 0
	for(var/voter in voters)
		. += voters[voter]

/datum/vote_choice/proc/render_html()
	return
