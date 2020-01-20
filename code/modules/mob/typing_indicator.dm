/mob/var/typing = FALSE

/mob/var/image/typing_indicator

/mob/proc/set_typing_indicator(state, indi_icon = "typing")
	if(!typing_indicator)
		typing_indicator = image('icons/mob/talk.dmi', indi_icon)
		typing_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		typing_indicator.layer = MOB_LAYER + 1

	if(typing_indicator.icon_state != indi_icon)
		if(typing && state)
			cut_overlay(typing_indicator)
		typing_indicator.icon_state = indi_icon

	if(state)
		if(client && !stat)
			add_overlay(typing_indicator)
			typing = TRUE
	else
		cut_overlay(typing_indicator)
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
