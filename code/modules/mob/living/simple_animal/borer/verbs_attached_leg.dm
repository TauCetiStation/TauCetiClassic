/obj/item/verbs/borer/attached_leg/verb/borer_speak(message as text)
	set category = "Alien"
	set name = "Borer Speak"
	set desc = "Communicate with your brethren."

	if(!message)
		return

	var/msg = message
	msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	msg = capitalize(msg)

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.borer_speak(msg)

/obj/item/verbs/borer/attached_leg/verb/evolve()
	set category = "Alien"
	set name = "Evolve"
	set desc = "Upgrade yourself or your host."

	var/mob/living/simple_animal/borer/B=loc
	if(!istype(B))
		return
	B.evolve()

/obj/item/verbs/borer/attached_leg/verb/secrete_chemicals()
	set category = "Alien"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.secrete_chemicals()

/obj/item/verbs/borer/attached_leg/verb/abandon_host()
	set category = "Alien"
	set name = "Abandon Host"
	set desc = "Slither out of your host."

	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		return
	B.abandon_host()
