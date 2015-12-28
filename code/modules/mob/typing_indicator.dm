#define TYPING_INDICATOR_LIFETIME 30 * 10	//grace period after which typing indicator disappears regardless of text in chatbar

/mob/var/hud_typing = 0 //set when typing in an input window instead of chatline
/mob/var/typing
/mob/var/last_typed
/mob/var/last_typed_time

/mob/var/image/typing_indicator
/mob/var/typing_shown = 0

/mob/proc/set_typing_indicator(var/state)

	if(!typing_indicator)
		typing_indicator = image('icons/mob/talk.dmi',src,"typing")
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
			if(typing)
				animate(typing_indicator, alpha = 0, time = 2, easing = CUBIC_EASING)
				spawn(2)
					qdel(typing_indicator)
					typing = 0
		return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	set_typing_indicator(1)
	hud_typing = 1
	typing_shown = 1
	var/message = input("","say (text)") as text
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		say_verb(message)
	typing_shown = 0

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1

	var/message = input("","me (text)") as text
	if(message)
		me_verb(message)

/mob/proc/handle_typing_indicator()
	if(client)
		if(!hud_typing)
			var/temp = winget(client, "input", "text")

			if (temp != last_typed)
				last_typed = temp
				last_typed_time = world.time

			if (world.time > last_typed_time + TYPING_INDICATOR_LIFETIME)
				set_typing_indicator(0)
				return
			if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
				set_typing_indicator(1)

			else
				set_typing_indicator(0)
