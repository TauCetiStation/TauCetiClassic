/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	button_icon_state = "lesser_form"
	chemical_cost = 5
	genomecost = 1
	genetic_damage = 30
	max_genetic_damage = 30
	can_be_used_in_abom_form = FALSE
	var/last_resort = FALSE

/obj/effect/proc_holder/changeling/lesserform/on_purchase(mob/user)
	. = ..()
	RegisterSignal(user, list(COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE), PROC_REF(changed_form))

/obj/effect/proc_holder/changeling/lesserform/sting_action(mob/living/carbon/user)
	//Transform into a human.
	if(ismonkey(user))
		var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
		var/list/names = list()
		for(var/datum/dna/DNA in changeling.absorbed_dna)
			names += "[DNA.real_name]"

		var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
		if(!S)
			return FALSE

		var/datum/dna/chosen_dna = changeling.GetDNA(S)
		if(!chosen_dna)
			return FALSE

		user.visible_message("<span class='warning'>[user] transforms!</span>")

		user.dna = chosen_dna.Clone()
		user.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)
		feedback_add_details("changeling_powers","LFT")

	//Transform into a monkey.
	else if(ishuman(user))
		if(user.has_brain_worms())
			to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
			return FALSE
		if(user.restrained())
			to_chat(user,"<span class='warning'>We cannot perform this ability as you restrained!</span>")
			return FALSE

		user.visible_message("<span class='warning'>[user] transforms!</span>")
		to_chat(user, "<span class='warning'>Our genes cry out!</span>")

		user.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

		feedback_add_details("changeling_powers","LF")


	return TRUE

/obj/effect/proc_holder/changeling/lesserform/proc/changed_form(mob/living/carbon/old_vessel, mob/living/carbon/new_vessel)
	SIGNAL_HANDLER
	var/datum/role/changeling/C = new_vessel.mind.GetRoleByType(/datum/role/changeling)
	if(C)
		var/obj/effect/proc_holder/changeling/lesserform/A = locate(/obj/effect/proc_holder/changeling/lesserform) in C.purchasedpowers
		if(!A.action.button || A.last_resort)
			qdel(src)
			return

		RegisterSignal(new_vessel, list(COMSIG_HUMAN_MONKEYIZE, COMSIG_MONKEY_HUMANIZE), PROC_REF(changed_form))
		new_vessel.changeling_update_languages(C.absorbed_languages)
		for(var/mob/living/parasite/essence/M in old_vessel)
			M.transfer(new_vessel)

		if(ishuman(new_vessel))
			A.action.button_icon_state = "lesser_form"
			A.action.button.name = "Lesser form"
			A.action.button.UpdateIcon()
		else
			A.action.button_icon_state = "human_form"
			A.action.button.name = "Human form"
			A.action.button.UpdateIcon()
