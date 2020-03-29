/obj/effect/proc_holder/changeling/humanform
	name = "Human form"
	desc = "We change into a human."
	chemical_cost = 5
	genetic_damage = 20
//	req_dna = 1
	max_genetic_damage = 20

/obj/effect/proc_holder/changeling/humanform/sting_action(mob/living/carbon/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	user.visible_message("<span class='warning'>[user] transforms!</span>")

	user.dna = chosen_dna.Clone()
	user.mind.changeling.purchasedpowers -= src
	user.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)
	feedback_add_details("changeling_powers","LFT")

	return 1
