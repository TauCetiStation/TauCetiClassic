/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation
	name = "Sensory Deprivation"
	desc = "Temporarily disable host's ability to see and hear the world around him."
	cost = 2
	cooldown = 80 SECONDS
	check_docility = TRUE

/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation/activate()
	if(holder.host.stat != CONSCIOUS)
		to_chat(holder, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	put_on_cd()
	holder.host.adjustBrainLoss(rand(5, 10))
	holder.host.eye_blind = max(holder.host.eye_blind, 15)
	holder.host.ear_deaf = max(holder.host.ear_deaf, 15)
	to_chat(holder, "<span class='notice'>You temporarily disable your host's ears and eyes.</span>")
	to_chat(holder.host, "<span class='warning'><font size='3'>Suddenly, everything becomes dark and quiet...</font></span>")
