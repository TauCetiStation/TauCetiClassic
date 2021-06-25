/obj/effect/proc_holder/borer/active/hostless/invis
	name = "Invisibility"
	desc = "Allows borer to become invisible to human eye. Costs 0.5 chemicals per second."
	cost = 2
	cooldown = 150

/obj/effect/proc_holder/borer/active/hostless/invis/activate()
	if(holder.invisibility)
		holder.deactivate_invisibility()
	else
		holder.activate_invisibility()
	put_on_cd()

/mob/living/simple_animal/borer/proc/activate_invisibility()
	if(!invisibility)
		alpha = 100 // so it's still visible to observers
		invisibility = 26
		to_chat(src, "<span class='notice'>You are invisible now.</span>")
		passive_chemical_regeneration -= 1 // it's 1u per life tick, which is sometimes equals to 0.5u per second

/mob/living/simple_animal/borer/proc/deactivate_invisibility()
	if(invisibility)
		alpha = 255
		invisibility = 0
		to_chat(src, "<span class='notice'>You are visible now.</span>")
		passive_chemical_regeneration += 1
