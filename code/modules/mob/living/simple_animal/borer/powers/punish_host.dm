/obj/effect/proc_holder/borer/active/control/punish_host
	name = "Torment host"
	desc = "Punish your host with agony."
	cooldown = 150
	check_capability = FALSE

/obj/effect/proc_holder/borer/active/control/punish_host/activate()
	if(holder.host_brain.ckey)
		to_chat(holder.getControlling(), "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(holder.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")
	
		return TRUE
