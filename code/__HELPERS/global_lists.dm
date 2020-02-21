//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair))
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H

	//Surgery Steps - Initialize all /datum/surgery_step into a list
	for(var/T in subtypesof(/datum/surgery_step))
		var/datum/surgery_step/S = new T
		surgery_steps += S
	sort_surgeries()

	init_subtypes(/datum/crafting_recipe, crafting_recipes)
	init_subtypes(/datum/dirt_cover, global.all_dirt_covers)

	//Medical side effects. List all effects by their names
	for(var/T in subtypesof(/datum/medical_effect))
		var/datum/medical_effect/M = new T
		side_effects[M.name] = T

	//Languages and species.
	for(var/T in subtypesof(/datum/language))
		var/datum/language/L = new T
		all_languages[L.name] = L

	for(var/language_name in all_languages)
		var/datum/language/L = all_languages[language_name]
		for(var/key in L.key)
			language_keys[":[lowertext_(key)]"] = L

	var/rkey = 0
	for(var/T in subtypesof(/datum/species))
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S

		if(S.flags[IS_WHITELISTED])
			whitelisted_species += S.name

	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
	global.chemical_reagents_list = list()
	for(var/path in subtypesof(/datum/reagent))
		var/datum/reagent/D = new path()
		global.chemical_reagents_list[D.id] = D

	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reaction_list["phoron"] is a list of all reactions relating to phoron
	global.chemical_reactions_list = list()
	for(var/path in subtypesof(/datum/chemical_reaction))

		var/datum/chemical_reaction/D = new path()
		var/list/reaction_ids = list()

		if(D.required_reagents && D.required_reagents.len)
			for(var/reaction in D.required_reagents)
				reaction_ids += reaction

		// Create filters based on each reagent id in the required reagents list
		for(var/id in reaction_ids)
			if(!global.chemical_reactions_list[id])
				global.chemical_reactions_list[id] = list()
			global.chemical_reactions_list[id] += D
			break // Don't bother adding ourselves to other reagent ids, it is redundant.

	populate_gear_list()

/proc/init_joblist() // Moved here because we need to load map config to edit jobs, called from SSjobs
	//List of job. I can't believe this was calculated multiple times per tick!
	for(var/T in (subtypesof(/datum/job) - list(/datum/job/ai,/datum/job/cyborg)))
		var/datum/job/J = new T
		joblist[J.title] = J

/* // Uncomment to debug chemical reaction list.
/client/verb/debug_chemical_list()

	for (var/reaction in chemical_reactions_list)
		. += "chemical_reactions_list\[\"[reaction]\"\] = \"[chemical_reactions_list[reaction]]\"\n"
		if(islist(chemical_reactions_list[reaction]))
			var/list/L = chemical_reactions_list[reaction]
			for(var/t in L)
				. += "    has: [t]\n"
	to_chat(world, .)
*/

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in typesof(prototype))
			if(path == prototype)
				continue
			L+= path
		return L
