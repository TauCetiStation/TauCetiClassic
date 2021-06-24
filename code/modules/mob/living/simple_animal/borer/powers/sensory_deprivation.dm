/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation
	name = "Sensory Deprivation"
	desc = "Temporarily disable host's ability to see and hear the world around him."
	cost = 2
	cooldown = 80 SECONDS

/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation/activate(mob/living/simple_animal/borer/B)
	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(B.host.stat != CONSCIOUS)
		to_chat(B, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	put_on_cd()
	B.host.adjustBrainLoss(rand(5, 10))
	B.host.eye_blind = max(B.host.eye_blind, 15)
	B.host.ear_deaf = max(B.host.ear_deaf, 15)
	to_chat(B, "<span class='notice'>You temporarily disable your host's ears and eyes.</span>")
	to_chat(B.host, "<span class='warning'><font size='3'>Suddenly, everything becomes dark and quiet...</font></span>")
