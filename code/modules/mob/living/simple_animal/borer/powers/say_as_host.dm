/obj/effect/proc_holder/borer/active/noncontrol/say_as_host
	name = "Host Commune"
	desc = "Allows borer to speak as host."
	cost = 1
	chemicals = 5

/obj/effect/proc_holder/borer/active/noncontrol/say_as_host/activate()
	. = FALSE
	if(holder.host.stat != CONSCIOUS)
		to_chat(holder, "<span class='notice'>The host are unconscious, they won't speak for you.</span>")
		return
	if(holder.host.getBrainLoss() >= 100)
		to_chat(holder, "<span class='warning'>Host brain won't obey you!</span>")
		return
	// say proc sanitizes any way
	var/text_to_say = input(holder, "Say as host") as text|null
	if(!can_activate()) //Sanity check.
		return
	if(text_to_say)
		holder.host.say(text_to_say)
		holder.host.adjustBrainLoss(1)
		return TRUE
