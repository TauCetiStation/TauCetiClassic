/datum/vote_choice
	var/text = "Nothing"
	var/list/voters = list() //assoc list of ckeys of voters and the voting power they contributed

/datum/vote_choice/proc/on_win()
	return

/datum/vote_choice/proc/total_votes()
	. = 0
	for(var/voter in voters)
		. += voters[voter]

// The html of choice entry in SSvote interface
/datum/vote_choice/proc/render_html(client/voter)
	. = ""
	if(voter.ckey in voters)
		. += "<b><a href='?src=\ref[SSvote];vote=\ref[src];voteval=1'>[text]</a></b>"
		. += " [html_decode("&#10003")]" // Checkmark
	else
		. += "<a href='?src=\ref[SSvote];vote=\ref[src];voteval=1'>[text]</a>"
