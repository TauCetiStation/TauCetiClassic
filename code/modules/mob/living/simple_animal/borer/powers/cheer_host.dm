/obj/effect/proc_holder/borer/active/control/cheer_host
	name = "Cheer host"
	desc = "Cheer up host by making them feel good."
	cooldown = 150

/obj/effect/proc_holder/borer/active/control/cheer_host/activate(mob/user)
	var/mob/living/simple_animal/borer/B = user.has_brain_worms()
	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(user, "<span class='notice'>You drop relaxing and satisfying thoughts into host's brain.</span>")
		to_chat(B.host_brain, "<span class='notice'><FONT size=3>You feel relaxed and happy.</FONT></span>")
	
		..()
