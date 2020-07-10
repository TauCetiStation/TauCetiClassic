/datum/codex_category/species/
	name = "Species"
	desc = "Sapient species encountered in known space."

/datum/codex_category/species/proc/build_description(thing)
	var/description = ""
	var/datum/species/species = thing

	if(IS_SYNTHETIC in species.flags)
		description += "[species.name] are a synthetic species.<br> "

	if(NO_BREATHE in species.flags)
		description += "[species.name] don't breathe.<br> "
	else
		description += "[species.name] need [species.breath_type] to breathe.<br> "
	switch(species.dietflags) // What this species eat.
		if(DIET_OMNI)
			description += "[species.name] are <font color = '[COLOR_YELLOW]'>omnivore</font>.<br> "
		if(DIET_PLANT)
			description += "[species.name] are <font color = '[COLOR_GREEN]'>herbivore</font>.<br> "
		if(DIET_MEAT + DIET_DAIRY)
			description += "[species.name] are <font color = '[COLOR_RED]'>carnivore</font>.<br> "
		else
			description += "[species.name] gain nutrition from untraditional sources. <br>"

	switch(species.brute_mod) // How resistive this species is to brute damage.
		if(-INFINITY to 0.99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>resistant</font> to <font color = '[COLOR_RED]'>brute</font> damage.<br> "
		if(1 to 1.09)
			description += "[species.name] <font color = '[COLOR_GRAY80]'>averagely resistant</font> to <font color = '[COLOR_RED]'>brute</font> damage.<br> "
		if(1.1 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>vulnerable</font> to <font color = '[COLOR_RED]'>brute</font> damage.<br> "

	switch(species.burn_mod) // // How resistive this species is to burn damage.
		if(-INFINITY to 0.99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>resistant</font> to <font color = '[COLOR_YELLOW]'>burn</font> damage.<br> "
		if(1 to 1.09)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>averagely resistant</font> to <font color = '[COLOR_YELLOW]'>burn</font> damage.<br> "
		if(1.1 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>vulnerable</font> to <font color = '[COLOR_YELLOW]'>burn</font> damage.<br> "

	switch(species.cold_level_2)
		if(-1)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>invulnerable</font> to <font color = '[COLOR_BLUE]'>cold</font>.<br> "
		if(0 to 199,99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>resistant</font> to <font color = '[COLOR_BLUE]'>cold</font>.<br> "
		if(200 to 200.99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>averagely resistant</font> to <font color = '[COLOR_BLUE]'>cold</font>.<br> "
		if(201 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>vulnerable</font> to <font color = '[COLOR_BLUE]'>cold</font>.<br> "

	switch(species.heat_level_2)
		if(0 to 399.99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>vulnerable</font> to <font color = '[COLOR_ORANGE]'>heat</font>.<br> "
		if(400 to 400.99)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>averagely resistant</font> to <font color = '[COLOR_ORANGE]'>heat</font>.<br> "
		if(401 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>resistant</font> to <font color = '[COLOR_ORANGE]'>heat</font>.<br> "

	switch(species.speed_mod)
		if(-INFINITY to -0.2)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>quite fast</font>.<br> "
		if(-0.19 to 0.19)
			description += "[species.name] move with <font color = '[COLOR_GRAY80]'>average speed</font>.<br> "
		if(0.2 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>quite slow</font>.<br> "

	switch(species.hazard_low_pressure)
		if(0)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>invulnerable</font> to vacuum.<br> "
		if(0.01 to 14.9)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>resistant</font> to low pressures.<br> "
		if(15 to 24.9)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>averagely resistant</font> to low pressures.<br> "
		if(25 to INFINITY)
			description += "[species.name] are <font color = '[COLOR_GRAY80]'>vulnerable</font> to low pressures.<br> "

	if(NO_BLOOD in species.flags)
		description += "[species.name] don't have blood or any similar liquid circulating in them.<br>  "

	if(NO_PAIN in species.flags)
		description += "[species.name] don't feel pain.<br>  "

	if(NO_FAT in species.flags)
		description += "[species.name] can't be obese.<br>  "

	if(RAD_ABSORB in species.flags)
		description += "[species.name] are <font color = '[COLOR_GRAY80]'>invulnerable</font> to radiation.<br>"

	if(species.nighteyes == 1)
		description += "[species.name] can see in darkness.<br> "

	if(species.language)
		description += "[species.name]'s main language is [species.language].<br> "

	if(species.unarmed_type == /datum/unarmed_attack/punch) //How this species fight.
		description += "[species.name] use fists in combat.<br> "
	else if(species.unarmed_type == /datum/unarmed_attack/claws)
		description += "[species.name] use claws in combat.<br> "
	else
		description += "[species.name] use untraditional means of unarmed combat. <br>"

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
