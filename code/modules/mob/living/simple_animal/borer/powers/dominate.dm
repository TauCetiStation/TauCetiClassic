/obj/effect/proc_holder/borer/active/hostless/dominate
	name = "Dominate Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	cooldown = 30 SECONDS

/obj/effect/proc_holder/borer/active/hostless/dominate/activate()
	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3, holder))
		if(C.stat != DEAD && C.infestable())
			choices[C] = C

	if(!choices.len)
		return

	var/mob/living/carbon/M = show_radial_menu(holder, holder, choices)
	if(!M || holder.incapacitated() || holder.host)
		return

	if(M.has_brain_worms())
		to_chat(src, "You cannot dominate someone who is already infested!")
		return

	to_chat(holder, "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='warning'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Weaken(3)

	put_on_cd()
