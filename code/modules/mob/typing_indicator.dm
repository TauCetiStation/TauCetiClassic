/mob/var/typing = 0

/mob/var/obj/effect/decal/typing_indicator

/mob/proc/set_typing_indicator(state)

	if(!typing_indicator)
		typing_indicator = new
		typing_indicator.icon = 'icons/mob/talk.dmi'
		typing_indicator.icon_state = "typing"
		typing_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(client && !stat)
		typing_indicator.invisibility = invisibility
		if(state)
			if(!typing)
				overlays += typing_indicator
				typing = 1
		else
			if(typing)
				overlays -= typing_indicator
				typing = 0
		return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	set_typing_indicator(1)
	var/message = input("","say (text)") as text|null
	if(message)
		say_verb(message)
	set_typing_indicator(0)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

	var/message = input("","me (text)") as text|null
	if(message)
		me_verb(message)
