
/obj/item/verbs/borer/severed/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.abandon_host()

/obj/item/verbs/borer/severed/verb/borer_speak(message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your brethren."

	if(!message)
		return

	var/msg = message
	msg = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	msg = capitalize(message)

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.borer_speak(msg)