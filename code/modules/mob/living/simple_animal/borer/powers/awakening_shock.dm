/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock
	name = "Awakening Shock"
	desc = "Send a powerful electric signal through host's brain that will wake them up."
	cost = 3
	chemicals = 40

/obj/effect/proc_holder/borer/active/noncontrol/awakening_shock/activate(mob/living/simple_animal/borer/B)
	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(!..())
		return
	B.host.setHalLoss(0)
	B.host.SetParalysis(0)
	B.host.SetStunned(0)
	B.host.SetWeakened(0)
	B.host.lying = 0
	B.host.update_canmove()
	B.host.adjustBrainLoss(rand(10, 15))

	to_chat(B, "<span class='notice'>You send awakening electric impulse through host's brain.</span>")
	to_chat(B.host, "<span class='notice'>You feel awakening electric impulse going through your body.</span>")
