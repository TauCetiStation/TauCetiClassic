/obj/effect/proc_holder/borer/active/control/cheer_host
	name = "Cheer host"
	desc = "Cheer up host by making them feel good."
	cooldown = 150
	check_capability = FALSE

/obj/effect/proc_holder/borer/active/control/cheer_host/activate()
	if(holder.host_brain.ckey)
		to_chat(holder.getControlling(), "<span class='notice'>You drop relaxing and satisfying thoughts into host's brain.</span>")
		to_chat(holder.host_brain, "<span class='notice'><FONT size=3>You feel relaxed and happy.</FONT></span>")
	
		return TRUE
	return FALSE
