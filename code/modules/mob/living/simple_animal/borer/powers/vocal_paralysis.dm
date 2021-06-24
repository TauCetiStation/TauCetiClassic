/obj/effect/proc_holder/borer/active/noncontrol/vocal_paralysis
	name = "Vocal Cord Paralysis"
	desc = "Temporarily disable host's ability to speak."
	cost = 3
	requires_t = list(/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation)
	cooldown = 120 SECONDS

/obj/effect/proc_holder/borer/active/noncontrol/vocal_paralysis/activate(mob/living/simple_animal/borer/B)
	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(B.host.stat != CONSCIOUS)
		to_chat(B, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	put_on_cd()
	B.host.adjustBrainLoss(rand(5, 10))
	to_chat(B, "<span class='notice'>You temporarily disable your host's vocal chords.</span>")
	to_chat(B, "<span class='warning'>Your throat feels numb.</span>")
	B.host.silent = max(B.host.silent, 15)
