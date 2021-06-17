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
	
	to_chat(C, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(B, "You slither up [C] and begin probing at their ear canal...")

	if(!do_after(B, B.infest_delay, target = C))
		to_chat(B, "As [C] moves away, you are dislodged and fall to the ground.")
		return

	if(!(C in view(1, B)))
		to_chat(B, "They are no longer in range!")
		return

	if(B.is_busy())
		return
	if(B.infest_check(C))
		B.infest(C)
		return

/mob/living/simple_animal/borer/proc/infest_check(mob/living/carbon/target, mob/user, show_warnings = TRUE)
	. = FALSE
	if(!user)
		user = src

	if(incapacitated())
		if(show_warnings)
			to_chat(user, "You cannot infest a target in your current state.")
		return

	if(!user.Adjacent(target)) // we check adjacency for user because the borer might be inside user while infesting (direct transfer power)
		return

	if(!target.infestable())
		return
	if(target.has_brain_worms())
		if(show_warnings)
			to_chat(user, "You cannot infest someone who is already infested!")
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_head_coverage())
			if(show_warnings)
				to_chat(user, "You cannot get through that host's protective gear.")
			return
	return TRUE

/mob/living/simple_animal/borer/proc/infest(mob/living/carbon/target)
	if(!target || !src)
		return

	to_chat(src, "You wiggle into [target]'s ear.")
	if(target.stat == CONSCIOUS)
		to_chat(target, "Something disgusting and slimy wiggles into your ear!")
	deactivate_invisibility()
	deactivate_biograde_vision()
	host = target
	forceMove(target)

	if(ishuman(host))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.implants += src
		H.sec_hud_set_implants()

	host_brain.name = target.name
	host_brain.real_name = target.real_name
	host.parasites += src