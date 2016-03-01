/mob/var/typing = 0

/mob/var/image/typing_indicator
/mob/var/typing_shown = 0

/mob/proc/set_typing_indicator(var/state)

	if(!typing_indicator)
		typing_indicator = image('icons/mob/talk.dmi',src,"typing")

	if(!typing_shown && state)
		typing_indicator.alpha = 0
		typing_indicator.transform = matrix()*0.5
		animate(typing_indicator, transform = matrix(), alpha = 255, time = 2, easing = CUBIC_EASING)

	if(client && !stat)
		if(state)
			if(!typing)
				typing = 1
				for(var/mob/M in viewers(src, null))
					M << typing_indicator
		else
			animate(typing_indicator, alpha = 0, time = 2, easing = CUBIC_EASING)
			spawn(2)
				qdel(typing_indicator)
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