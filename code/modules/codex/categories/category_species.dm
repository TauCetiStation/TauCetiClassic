/datum/codex_category/species/
	name = "Species"
	desc = "Sapient species encountered in known space."

/datum/codex_category/species/proc/build_description(thing)
	var/description = ""
	var/datum/species/species = thing

	if(IS_SYNTHETIC in species.flags)
		description += "[species.name] are a synthetic species.  "

	if(NO_BREATHE in species.flags)
		description += "[species.name] don't breathe.  "
	else
		description += "[species.name] need [species.breath_type] to breathe.  "

	switch(species.dietflags) // What this species eat.
		if(DIET_OMNI)
			description += "[species.name] are omnivore. "
		if(DIET_PLANT)
			description += "[species.name] are herbivore. "
		if(DIET_MEAT + DIET_DAIRY)
			description += "[species.name] are carnivore. "
		else
			description += "[species.name] gain nutrition from untraditional sources. "

	switch(species.brute_mod) // How resistive this species is to brute damage.
		if(-INFINITY to 0.99)
			description += "[species.name] are resistant to brute damage. "
		if(1 to 1.09)
			description += "[species.name] don't react to brute damage in any special way. "
		if(1.1 to INFINITY)
			description += "[species.name] are vulnerable to brute damage. "

	switch(species.burn_mod) // // How resistive this species is to burn damage.
		if(-INFINITY to 0.99)
			description += "[species.name] are resistant to burn damage. "
		if(1 to 1.09)
			description += "[species.name] don't react to burn damage in any special way. "
		if(1.1 to INFINITY)
			description += "[species.name] are vulnerable to burn damage. "

	switch(species.cold_level_2)
		if(-1)
			description += "[species.name] are invulnerable to cold. "
		if(0 to 199,99)
			description += "[species.name] are resistant to cold. "
		if(200 to 200.99)
			description += "[species.name] don't react to cold in any special way. "
		if(201 to INFINITY)
			description += "[species.name] are vulnerable to cold. "

	switch(species.heat_level_2)
		if(0 to 399.99)
			description += "[species.name] are vulnerable to heat. "
		if(400 to 400.99)
			description += "[species.name] don't react to heat in any special way. "
		if(401 to INFINITY)
			description += "[species.name] are resistant to heat. "

	switch(species.speed_mod)
		if(-INFINITY to -0.2)
			description += "[species.name] are quite fast. "
		if(-0.19 to 0.19)
			description += "[species.name] move with average speed. "
		if(0.2 to INFINITY)
			description += "[species.name] are quite slow. "

	switch(species.hazard_low_pressure)
		if(0)
			description += "[species.name] are invulnerable to vacuum. "
		if(0.01 to 14.9)
			description += "[species.name] are resistant to low pressures. "
		if(15 to 24.9)
			description += "[species.name] are averagely resistant to low pressures. "
		if(25 to INFINITY)
			description += "[species.name] are vulnerable to low pressures. "

	if(NO_BLOOD in species.flags)
		description += "[species.name] don't have blood or any similar liquid circulating in them.  "

	if(NO_PAIN in species.flags)
		description += "[species.name] don't feel pain.  "

	if(NO_FAT in species.flags)
		description += "[species.name] can't be obese.  "

	if(RAD_ABSORB in species.flags)
		description += "[species.name] are invulnerable to radiation.  "

	if(species.nighteyes == 1)
		description += "[species.name] can see in darkness. "

	if(species.language)
		description += "[species.name]'s main language is [species.language]. "

	if(species.unarmed_type == /datum/unarmed_attack/punch) //How this species fight.
		description += "[species.name] use fists in combat. "
	else if(species.unarmed_type == /datum/unarmed_attack/claws)
		description += "[species.name] use claws in combat. "
	else
		description += "[species.name] use untraditional means of unarmed combat. "



	return description


/datum/codex_category/species/Initialize()
	for(var/thing in all_species)
		var/datum/species/species = all_species[thing]
		if(!species.hidden_from_codex)
			var/datum/codex_entry/entry = new(_display_name = "[species.name] (species)")
			entry.lore_text = species.codex_description
			entry.mechanics_text = build_description(species)
			entry.update_links()
			SScodex.add_entry_by_string(entry.display_name, entry)
			SScodex.add_entry_by_string(species.name, entry)
			items += entry.display_name
	..()
