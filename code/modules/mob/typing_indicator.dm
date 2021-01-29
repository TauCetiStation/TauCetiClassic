/mob/proc/set_typing_indicator(state)
	if(!typing_indicator)
		typing_indicator = new(null, "[typing_indicator_type]0")

	if(typing_indicator.icon_state != "[typing_indicator_type]0")
		typing_indicator.icon_state = "[typing_indicator_type]0"

	if(state)
		if(client && !stat)
			vis_contents += typing_indicator
			typing = TRUE
	else
		vis_contents -= typing_indicator
		typing = FALSE

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	set_typing_indicator(TRUE)
	var/message = input("","say (text)") as text|null
	if(message)
		say_verb(message)
	set_typing_indicator(FALSE)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

	var/message = input("","me (text)") as text|null
	if(message)
		me_verb(message)
