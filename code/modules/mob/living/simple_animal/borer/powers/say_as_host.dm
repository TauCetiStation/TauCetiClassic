/obj/effect/proc_holder/borer/active/noncontrol/say_as_host
	name = "Host Commune"
	desc = "Allows borer to speak as host."
	cost = 1
	chemicals = 5

/obj/effect/proc_holder/borer/active/noncontrol/say_as_host/activate(mob/living/simple_animal/borer/B)
	if(B.docile)
		to_chat(B, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return
	if(B.host.stat != CONSCIOUS)
		to_chat(B, "<span class='notice'>The host are unconscious, they won't speak for you.</span>")
		return
	if(B.host.getBrainLoss() >= 100)
		to_chat(B, "<span class='warning'>Host brain won't obey you!</span>")
		return
	// say proc sanitizes any way
	var/text_to_say = input(B, "Say as host") as text|null
	if(text_to_say && use_chemicals(B))
		B.host.say(text_to_say)
		B.host.adjustBrainLoss(1)
