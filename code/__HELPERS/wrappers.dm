// This is used purely for callbacks to call byond procs thru them.

/proc/_step(ref, dir)
	step(ref, dir)

// used in hotkeys so that we can call proc instead of winset(src, null, "command=say")
/mob/proc/say_wrapper()
	set_typing_indicator(TRUE)
	var/message = input("","say (text)") as text|null
	if(message)
		say_verb(message)
	set_typing_indicator(FALSE)

/mob/proc/me_wrapper()
	set_typing_indicator(TRUE)
	var/message = input("","me (text)") as text|null
	if(message)
		me_verb(message)
	set_typing_indicator(FALSE)

/client/proc/ooc_wrapper()
	var/message = input("","ooc (text)") as text|null
	if(message)
		ooc(message)

/client/proc/looc_wrapper()
	var/message = input("","looc (text)") as text|null
	if(message)
		looc(message)
