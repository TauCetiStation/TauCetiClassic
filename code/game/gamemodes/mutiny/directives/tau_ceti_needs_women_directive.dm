/datum/directive/tau_ceti_needs_women
	var/list/command_targets = list()
	var/list/alien_targets = list()

/datum/directive/tau_ceti_needs_women/proc/get_target_gender()
	if(!mode.head_loyalist) return FEMALE
	return mode.head_loyalist.current.get_gender() == FEMALE ? MALE : FEMALE

/datum/directive/tau_ceti_needs_women/proc/is_target_gender(mob/M)
	var/species = M.get_species()
	return species != DIONA && M.get_gender() == get_target_gender()

/datum/directive/tau_ceti_needs_women/proc/get_crew_of_target_gender()
	var/list/targets[0]
	for(var/mob/M in player_list)
		if(M.is_ready() && is_target_gender(M) && !M.is_mechanical())
			targets.Add(M)
	return targets

/datum/directive/tau_ceti_needs_women/proc/get_target_heads()
	var/list/heads[0]
	for(var/mob/M in get_crew_of_target_gender())
		if(command_positions.Find(M.mind.assigned_role))
			heads.Add(M)
	return heads

/datum/directive/tau_ceti_needs_women/proc/get_target_aliens()
	var/list/aliens[0]
	for(var/mob/M in get_crew_of_target_gender())
		var/species = M.get_species()
		if(species == TAJARAN || species == UNATHI || species == SKRELL)
			aliens.Add(M)
	return aliens

/datum/directive/tau_ceti_needs_women/proc/count_heads_reassigned()
	var/heads_reassigned = 0
	for(var/obj/item/weapon/card/id in command_targets)
		if (command_targets[id])
			heads_reassigned++

	return heads_reassigned

/datum/directive/tau_ceti_needs_women/get_description()
	return {"
		<p>
			Recent evidence suggests [get_target_gender()] aptitudes may be effected by radiation from [system_name()].
			Effects were measured under laboratory and station conditions. Humans remain more trusted than Xeno. Further information is classified.
		</p>
	"}

/datum/directive/tau_ceti_needs_women/initialize()
	for(var/mob/living/carbon/human/H in get_target_heads())
		command_targets[H.wear_id] = 0

	for(var/mob/living/carbon/human/H in get_target_aliens())
		alien_targets.Add(H.wear_id)

	special_orders = list(
		"Remove [get_target_gender()] personnel from Command positions.",
		"Terminate employment of all [get_target_gender()] Skrell, Tajara, and Unathi.")

/datum/directive/tau_ceti_needs_women/meets_prerequisites()
	var/females = 0
	var/males = 0
	for(var/mob/M in player_list)
		if(M.is_ready() && !M.is_mechanical() && M.get_species() != DIONA)
			var/gender = M.get_gender()
			if(gender == MALE)
				males++
			else if(gender == FEMALE)
				females++

	return males >= 2 && females >= 2

/datum/directive/tau_ceti_needs_women/directives_complete()
	return command_targets.len == count_heads_reassigned() && alien_targets.len == 0

/datum/directive/tau_ceti_needs_women/get_remaining_orders()
	var/text = ""
	for(var/head in command_targets)
		if(!command_targets[head])
			text += "<li>Remove [head] from a Head Role</li>"

	for(var/id in alien_targets)
		text += "<li>Terminate [id]</li>"

	return text
