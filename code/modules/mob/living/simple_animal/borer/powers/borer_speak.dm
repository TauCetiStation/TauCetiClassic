/obj/effect/proc_holder/borer/active/borer_speak
	name = "Cortical Link"
	desc = "Communicate with fellow borers."
	check_docility = FALSE

/obj/effect/proc_holder/borer/active/borer_speak/activate()
	var/msg = sanitize(input(holder.getControlling(), null, "Borer chat") as text|null)
	holder.borer_speak(msg)
