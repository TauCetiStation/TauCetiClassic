//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/make_datum_references_lists()
	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/hair))
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H
		for(var/S in H.species_allowed)
			hairs_cache["[S][H.gender][H.ipc_head_compatible]"] += list(H.name = list(null, null))
			if(H.gender == NEUTER)
				hairs_cache["[S][MALE][H.ipc_head_compatible]"] += list(H.name = list(null, null))
				hairs_cache["[S][FEMALE][H.ipc_head_compatible]"] += list(H.name = list(null, null))
			hairs_cache["[S][PLURAL][H.ipc_head_compatible]"] += list(H.name = list(null, null)) // contents all hairs for species

	// Circular double list initialization
	for(var/hash in hairs_cache)
		var/hairs_cache_len = length(hairs_cache[hash])
		hairs_cache[hash][hairs_cache[hash][1]][LEFT] = hairs_cache[hash][hairs_cache_len]
		hairs_cache[hash][hairs_cache[hash][hairs_cache_len]][RIGHT] = hairs_cache[hash][1]
		for(var/i in 1 to hairs_cache_len)
			hairs_cache[hash][hairs_cache[hash][i]][LEFT] = hairs_cache[hash][hairs_cache[hash][i]][LEFT] || hairs_cache[hash][i - 1]
			hairs_cache[hash][hairs_cache[hash][i]][RIGHT] = hairs_cache[hash][hairs_cache[hash][i]][RIGHT] || hairs_cache[hash][i + 1]

	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	for(var/path in subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H
		for(var/S in H.species_allowed)
			facial_hairs_cache["[S][H.gender][H.ipc_head_compatible]"] += list(H.name = list(null, null))
			if(H.gender == NEUTER)
				facial_hairs_cache["[S][MALE][H.ipc_head_compatible]"] += list(H.name = list(null, null))
				facial_hairs_cache["[S][FEMALE][H.ipc_head_compatible]"] += list(H.name = list(null, null))
			facial_hairs_cache["[S][PLURAL][H.ipc_head_compatible]"] += list(H.name = list(null, null)) // contents all hairs for species

	// Circular double list initialization
	for(var/hash in facial_hairs_cache)
		var/hairs_cache_len = length(facial_hairs_cache[hash])
		facial_hairs_cache[hash][facial_hairs_cache[hash][1]][LEFT] = facial_hairs_cache[hash][hairs_cache_len]
		facial_hairs_cache[hash][facial_hairs_cache[hash][hairs_cache_len]][RIGHT] = facial_hairs_cache[hash][1]
		for(var/i in 1 to hairs_cache_len)
			facial_hairs_cache[hash][facial_hairs_cache[hash][i]][LEFT] = facial_hairs_cache[hash][facial_hairs_cache[hash][i]][LEFT] || facial_hairs_cache[hash][i - 1]
			facial_hairs_cache[hash][facial_hairs_cache[hash][i]][RIGHT] = facial_hairs_cache[hash][facial_hairs_cache[hash][i]][RIGHT] || facial_hairs_cache[hash][i + 1]


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
			language_keys[":[lowertext(key)]"] = L

	var/rkey = 0
	for(var/T in subtypesof(/datum/species))
		rkey++
		var/datum/species/S = new T
		S.race_key = rkey //Used in mob icon caching.
		all_species[S.name] = S

		if(S.flags[IS_WHITELISTED])
			whitelisted_species += S.name
		if(S.flags[SPRITE_SHEET_RESTRICTION])
			global.sprite_sheet_restricted += S.name

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

	// Create list for rituals to determine the value of things
	var/list/money_type_by_cash_am = list()
	var/list/type_cash = subtypesof(/obj/item/weapon/spacecash) - /obj/item/weapon/spacecash/ewallet
	for(var/money_type in type_cash)
		var/obj/item/weapon/spacecash/cash = money_type
		var/cash_am = "[initial(cash.worth)]"
		money_type_by_cash_am[cash_am] = cash

	var/i = 0
	for(var/cash_am in money_type_by_cash_am)
		if(i == money_type_by_cash_am.len - 1)
			break
		i++
		var/money_type = money_type_by_cash_am[cash_am]
		var/next_money_type = money_type_by_cash_am[money_type_by_cash_am[i + 1]]
		cash_increase_list[money_type] = next_money_type

	cash_increase_list[/obj/item/weapon/spacecash/c1000] = /obj/item/stack/sheet/mineral/gold
	cash_increase_list[/obj/item/weapon/spacecash] = /obj/item/weapon/spacecash/c1

	global.combat_combos = list()
	for(var/path in subtypesof(/datum/combat_combo))
		var/datum/combat_combo/CC = new path()
		var/list/hashes = CC.get_hash()
		for(var/hash in hashes)
			if(global.combat_combos[hash])
				var/datum/combat_combo/conflict = global.combat_combos[hash]
				warning("[CC.name] IS CONFLICTING WITH [conflict.name]!")
			global.combat_combos[hash] = CC
		global.combat_combos_by_name[CC.name] = CC

	/*
		Chaplain related: Spells and Rites
	*/
	global.spells_by_aspects = list()
	for(var/path in subtypesof(/obj/effect/proc_holder/spell))
		var/obj/effect/proc_holder/spell/S = new path()
		if(!S.needed_aspect)
			continue

		// Don't bother adding ourselves to other aspects, it is redundant.
		var/aspect_type = S.needed_aspect[1]

		if(!global.spells_by_aspects[aspect_type])
			global.spells_by_aspects[aspect_type] = list()
		global.spells_by_aspects[aspect_type] += path

	global.rites_by_aspects = list()
	for(var/path in subtypesof(/datum/religion_rites))
		var/datum/religion_rites/RR = new path()
		if(!RR.needed_aspects)
			continue

		// Don't bother adding ourselves to other aspects, it is redundant.
		var/aspect_type = RR.needed_aspects[1]

		if(!global.rites_by_aspects[aspect_type])
			global.rites_by_aspects[aspect_type] = list()
		global.rites_by_aspects[aspect_type] += path

	global.holy_reagents_by_aspects = list()
	for(var/id in global.chemical_reagents_list)
		var/datum/reagent/R = global.chemical_reagents_list[id]
		if(!R.needed_aspects)
			continue

		// Don't bother adding ourselves to other aspects, it is redundant.
		var/aspect_type = R.needed_aspects[1]

		if(!global.holy_reagents_by_aspects[aspect_type])
			global.holy_reagents_by_aspects[aspect_type] = list()
		global.holy_reagents_by_aspects[aspect_type] += id

	global.faith_reactions = list()
	for(var/path in subtypesof(/datum/faith_reaction))
		var/datum/faith_reaction/FR = new path
		if(!FR.id)
			continue

		global.faith_reactions[FR.id] = FR

	global.faith_reactions_by_aspects = list()
	for(var/id in global.faith_reactions)
		var/datum/faith_reaction/FR = global.faith_reactions[id]
		if(!FR.needed_aspects)
			continue

		// Don't bother adding ourselves to other aspects, it is redundant.
		var/aspect_type = FR.needed_aspects[1]

		if(!global.faith_reactions_by_aspects[aspect_type])
			global.faith_reactions_by_aspects[aspect_type] = list()
		global.faith_reactions_by_aspects[aspect_type] += id

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
