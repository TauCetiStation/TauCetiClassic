/obj/effect/proc_holder/changeling/epinephrine
	name = "Adrenaline Overdose"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Removes all stuns instantly and adds a short-term reduction in further stuns. Can be used while unconscious. Every use poisons the body."
	button_icon_state = "adrenaline"
	chemical_cost = 35
	genomecost = 2
	req_human = 1
	req_stat = UNCONSCIOUS

//Recover from stuns.
/obj/effect/proc_holder/changeling/epinephrine/sting_action(mob/user)

	if(user.lying)
		to_chat(user, "<span class='notice'>We arise.</span>")
	else
		to_chat(user, "<span class='notice'>Adrenaline rushes through us.</span>")
	user.stat = CONSCIOUS
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.reagents.add_reagent("stimulants", 5)
	user.reagents.add_reagent("toxin", 2)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.setHalLoss(0)
		H.shock_stage = 0

	feedback_add_details("changeling_powers","UNS")
	return TRUE
