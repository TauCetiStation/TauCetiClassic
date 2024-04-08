/obj/effect/proc_holder/changeling/hivemind_upload
	name = "Hive Channel"
	desc = "Allows us to channel DNA in the airwaves to allow other changelings to absorb it."
	button_icon_state = "hivemind_channel"
	chemical_cost = 10
	genomecost = 0

/obj/effect/proc_holder/changeling/hivemind_upload/sting_action(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	if(!changeling.faction)
		return FALSE

	var/datum/faction/changeling/hivemind = changeling.faction
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(!(DNA in hivemind.hivemind_bank))
			names += DNA.real_name

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return FALSE

	var/chosen_name = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!chosen_name)
		return FALSE

	var/datum/dna/chosen_dna = changeling.GetDNA(chosen_name)
	if(!chosen_dna)
		return FALSE

	hivemind.hivemind_bank += chosen_dna
	to_chat(user, "<span class='notice'>We channel the DNA of [chosen_name] to the air.</span>")
	feedback_add_details("changeling_powers","HU")
	return TRUE

/obj/effect/proc_holder/changeling/hivemind_download
	name = "Hive Absorb"
	desc = "Allows us to absorb DNA that has been channeled to the airwaves. Does not count towards absorb objectives."
	button_icon_state = "hive_absorb"
	chemical_cost = 20
	genomecost = 0

/obj/effect/proc_holder/changeling/hivemind_download/sting_action(mob/user)
	var/datum/role/changeling/changeling = user.mind.GetRoleByType(/datum/role/changeling)
	if(!changeling.faction)
		return FALSE

	var/datum/faction/changeling/hivemind = changeling.faction
	var/list/names = list()
	for(var/datum/dna/DNA in hivemind.hivemind_bank)
		if(!(DNA in changeling.absorbed_dna))
			names[DNA.real_name] = DNA

	if(names.len <= 0)
		to_chat(user, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return FALSE

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)
		return FALSE
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return FALSE

//	if(changeling.absorbed_dna.len)
//		changeling.absorbed_dna.Cut(1,2)
	changeling.absorbed_dna += chosen_dna
	to_chat(user, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	feedback_add_details("changeling_powers","HD")
	return TRUE
