/obj/effect/proc_holder/changeling/change_species
	name = "Change Species"
	desc = "We take on the apperance of a species that we have absorbed."
	chemical_cost = 5
	genomecost = 0
	req_dna = 1
	req_human = 1
	genetic_damage = 30
	max_genetic_damage = 30

//Change our DNA to that of somebody we've absorbed.
/obj/effect/proc_holder/changeling/change_species/sting_action(mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	if(changeling.absorbed_species.len < 2)
		to_chat(src, "<span class='warning'>We do not know of any other species genomes to use.</span>")
		return

	var/S = input("Select the target species: ", "Target Species", null) as null|anything in changeling.absorbed_species
	if(!S)	return

	domutcheck(user, null)
	user.visible_message("<span class='warning'>[user] transforms!</span>")
	user.set_species(S,null,1) //Until someone moves body colour into DNA, they're going to have to use the default.

	user.changeling_update_languages(changeling.absorbed_languages)
	user.regenerate_icons()

	feedback_add_details("changeling_powers","TS")
	return 1
