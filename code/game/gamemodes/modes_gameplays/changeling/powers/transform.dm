/obj/effect/proc_holder/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed."
	button_icon_state = "transform"
	chemical_cost = 5
	genomecost = 0
	req_dna = 1
	req_human = 1
	genetic_damage = 30
	max_genetic_damage = 30
	can_be_used_in_abom_form = FALSE

//Change our DNA to that of somebody we've absorbed.
/obj/effect/proc_holder/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	var/datum/dna/chosen_dna = changeling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_dna)
		return FALSE

	user.visible_message("<span class='warning'>[user] transforms!</span>")
	var/changeling_original_name = user.dna.original_character_name
	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	user.dna.original_character_name = changeling_original_name
	user.flavor_text = ""
	user.UpdateAppearance()
	domutcheck(user, null)
	SEND_SIGNAL(user, COMSIG_CHANGELING_TRANSFORM)

	user.fixblood(FALSE) // to change blood DNA too

	feedback_add_details("changeling_powers","TR")
	return TRUE

/datum/role/changeling/proc/select_dna(prompt, title)
	var/list/names = list()
	for(var/datum/dna/DNA in absorbed_dna)
		names += "[DNA.original_character_name]"

	var/chosen_name = input(prompt, title, null) as null|anything in names
	if(!chosen_name)
		return
	var/datum/dna/chosen_dna = GetDNA(chosen_name)
	return chosen_dna
