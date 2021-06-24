/obj/effect/proc_holder/borer/active/noncontrol/electric_shock
	name = "Electric Shock"
	desc = "Send electric impulse down your host's spinal cord to punish him for disobedience."
	cooldown = 30 SECONDS
	chemicals = 25
	cost = 2

/obj/effect/proc_holder/borer/active/noncontrol/electric_shock/activate()
	if(holder.host.stat != CONSCIOUS)
		to_chat(holder, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	if(!cd_and_chemicals(holder))
		return
	if(ishuman(holder.host))
		var/mob/living/carbon/human/H = holder.host
		H.custom_pain("You feel electric shock going through your spinal cord!", 1)
	holder.host.apply_effects(weaken = 3, agony = 80, eyeblur = 10)
	holder.host.adjustBrainLoss(rand(5, 10))
