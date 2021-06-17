/mob/proc/infestable()
	return FALSE

var/global/list/borer_banned_species = list(IPC, GOLEM, SLIME, DIONA)

/mob/living/carbon/infestable()
	return !(get_species() in borer_banned_species) && !has_brain_worms()

/obj/effect/proc_holder/borer/active/hostless/infest
	name = "Infest"
	desc = "Infest a suitable humanoid host."

/obj/effect/proc_holder/borer/active/hostless/infest/activate(mob/living/simple_animal/borer/B)
	if(B.incapacitated())
		to_chat(B, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1, B))
		if(B.Adjacent(C) && C.infestable())
			choices[C] = C

	if(!choices.len)
		return

	var/mob/living/carbon/C = show_radial_menu(B, B, choices)
	if(!C || B.incapacitated() || B.host)
		return

	if(!B.Adjacent(C))
		return

	if(C.has_brain_worms())
		to_chat(B, "You cannot infest someone who is already infested!")
		return
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.check_head_coverage())
			to_chat(B, "You cannot get through that host's protective gear.")
			return

	if(B.is_busy())
		return

	to_chat(C, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(B, "You slither up [C] and begin probing at their ear canal...")

	if(!do_after(B, 50, target = C))
		to_chat(B, "As [C] moves away, you are dislodged and fall to the ground.")
		return

	if(!C.infestable())
		return
	if(!C || !B)
		return

	if(B.incapacitated())
		to_chat(B, "You cannot infest a target in your current state.")
		return

	if(!(C in view(1, B)))
		to_chat(B, "They are no longer in range!")
		return

	to_chat(B, "You wiggle into [C]'s ear.")
	if(C.stat == CONSCIOUS)
		to_chat(C, "Something disgusting and slimy wiggles into your ear!")

	B.host = C
	B.forceMove(C)

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.implants += B
		H.sec_hud_set_implants()

	B.host_brain.name = C.name
	B.host_brain.real_name = C.real_name
	B.host.parasites += B 
