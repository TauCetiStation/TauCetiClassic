/obj/effect/proc_holder/borer/active/borer_speak
	name = "Cortical Link"
	desc = "Communicate with fellow borers."

/obj/effect/proc_holder/borer/active/borer_speak/activate(mob/user)
	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	var/msg = sanitize(input(user, null, "Borer chat") as text|null)
	B.borer_speak(msg)
