/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock
	name = "Awakening Shock"
	desc = "Send a powerful electric signal through host's brain that will wake them up."
	cost = 3
	chemicals = 40

/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock/activate()
	. = ..()
	holder.host.setHalLoss(0)
	holder.host.SetParalysis(0)
	holder.host.SetStunned(0)
	holder.host.SetWeakened(0)
	holder.host.SetSleeping(0)
	holder.host.lying = 0
	holder.host.update_canmove()
	holder.host.adjustBrainLoss(rand(10, 15))

	to_chat(holder, "<span class='notice'>You send awakening electric impulse through host's brain.</span>")
	to_chat(holder.host, "<span class='notice'>You feel awakening electric impulse going through your body.</span>")
