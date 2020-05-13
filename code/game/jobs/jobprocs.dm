

//TODO: put these somewhere else
/client/proc/mimewall()
	set category = "Mime"
	set name = "Invisible wall"
	set desc = "Create an invisible wall on your location."
	if(usr.incapacitated())
		to_chat(usr, "Not when you're incapicated.")
		return
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(!H.miming)
		to_chat(usr, "You still haven't atoned for your speaking transgression. Wait.")
		return
	addtimer(CALLBACK(GLOBAL_PROC, /client/proc/return_mimewall, H), 300)
	H.visible_message("<span class='notice'>[H] looks as if a wall is in front of them.</span>", "You form a wall in front of yourself.")
	H.verbs -= /client/proc/mimewall
	H.mind.special_verbs  -= /client/proc/mimewall
	new /obj/effect/forcefield/magic/mime(get_turf(H), H, 300)

/client/proc/return_mimewall(mob/living/carbon/human/H)
	H.verbs += /client/proc/mimewall
	if(H.mind)
		H.mind.special_verbs  += /client/proc/mimewall

///////////Mimewalls///////////

/obj/effect/forcefield/magic/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

///////////////////////////////

/client/proc/mimespeak()
	set category = "Mime"
	set name = "Speech"
	set desc = "Toggle your speech."
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(H.miming)
		H.miming = 0
	else
		to_chat(H, "You'll have to wait if you want to atone for your sins.")
		addtimer(CALLBACK(GLOBAL_PROC, /client/proc/return_speech, H), 3000)

/client/proc/return_speech(mob/living/carbon/human/H)
	H.miming = 1
