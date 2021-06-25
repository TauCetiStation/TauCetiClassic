/obj/effect/proc_holder/borer/active/hostless/biograde_vision
	name = "Biograde Vision"
	desc = "Make you see living beings through walls."
	cost = 2

/obj/effect/proc_holder/borer/active/hostless/biograde_vision/activate()
	. = ..()
	if(holder.sight & SEE_MOBS)
		holder.deactivate_biograde_vision()
	else
		holder.activate_biograde_vision()

/mob/living/simple_animal/borer/proc/activate_biograde_vision()
	if(!(sight & SEE_MOBS))
		sight |= SEE_MOBS
		to_chat(src, "<span class='notice'>You can now see living beings through walls.</span>")

/mob/living/simple_animal/borer/proc/deactivate_biograde_vision()
	if(sight & SEE_MOBS)
		sight &= ~SEE_MOBS
		to_chat(src, "<span class='notice'>You cannot see living beings through walls for now.</span>")
