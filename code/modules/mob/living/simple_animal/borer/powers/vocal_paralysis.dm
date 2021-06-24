/obj/effect/proc_holder/borer/active/noncontrol/vocal_paralysis
	name = "Vocal Cord Paralysis"
	desc = "Temporarily disable host's ability to speak."
	cost = 3
	requires_t = list(/obj/effect/proc_holder/borer/active/noncontrol/sensory_deprivation)
	cooldown = 120 SECONDS

/obj/effect/proc_holder/borer/active/noncontrol/vocal_paralysis/activate()
	if(holder.docile)
		to_chat(holder, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(holder.host.stat != CONSCIOUS)
		to_chat(holder, "<span class='notice'>The host won't feel that, they're unconscious.</span>")
		return
	put_on_cd()
	holder.host.adjustBrainLoss(rand(5, 10))
	to_chat(holder, "<span class='notice'>You temporarily disable your host's vocal chords.</span>")
	to_chat(holder, "<span class='warning'>Your throat feels numb.</span>")
	holder.host.silent = max(holder.host.silent, 15)
