/obj/effect/proc_holder/borer/active/noncontrol/electric_shock
	name = "Electric Shock"
	desc = "Send electric impulse down your host's spinal cord to punish him for disobedience."
	cooldown = 30 SECONDS
	chemicals = 25
	cost = 2

/obj/effect/proc_holder/borer/active/noncontrol/electric_shock/activate(mob/living/simple_animal/borer/B)
	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(B.host.stat != CONSCIOUS)
		to_chat(B, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	if(!cd_and_chemicals(B))
		return
	if(ishuman(B.host))
		var/mob/living/carbon/human/H = B.host
		H.custom_pain("You feel electric shock going through your spinal cord!", 1)
	B.host.apply_effects(weaken = 3, agony = 80, eyeblur = 10)
	B.host.adjustBrainLoss(rand(5, 10))
