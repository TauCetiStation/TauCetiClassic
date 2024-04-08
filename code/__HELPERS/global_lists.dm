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

	// Keybindings
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.name))
			continue
		var/datum/keybinding/instance = new keybinding
		global.keybindings_by_name[instance.name] = instance
		if(length(instance.hotkey_keys))
			for(var/bound_key in instance.hotkey_keys)
				global.hotkey_keybinding_list_by_key[bound_key] += list(instance.name)

	init_subtypes(/datum/crafting_recipe, crafting_recipes)
	init_subtypes(/datum/dirt_cover, global.all_dirt_covers)

	//Languages and species.
	for(var/T in subtypesof(/datum/language))
		var/datum/language/L = new T
		all_languages[L.name] = L

	for(var/language_name in all_languages)
		var/datum/language/L = all_languages[language_name]
		for(var/key in L.key)
			language_keys[":[lowertext(key)]"] = L

	for(var/T in subtypesof(/datum/species))
		var/datum/species/S = new T
		all_species[S.name] = S

		if(S.flags[IS_WHITELISTED])
			whitelisted_species += S.name

	//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
	global.chemical_reagents_list = list()
	global.allergen_reagents_list = list()
	for(var/path in subtypesof(/datum/reagent))
		var/datum/reagent/D = new path()
		global.chemical_reagents_list[D.id] = D

		if(!D.allergen)
			continue
		global.allergen_reagents_list[D.id] = TRUE

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
	var/list/type_cash = subtypesof(/obj/item/weapon/spacecash)
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
		if(!S.needed_aspects)
			continue

		// Don't bother adding ourselves to other aspects, it is redundant.
		var/aspect_type = S.needed_aspects[1]

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

	global.contraband_listings = list()
	for(var/listing in subtypesof(/datum/contraband_listing))
		global.contraband_listings[listing] = new listing

	populate_gear_list()

	global.bridge_commands = list()
	for(var/command in subtypesof(/datum/bridge_command))
		var/datum/bridge_command/C = new command
		global.bridge_commands[C.name] = C

	sortTim(bridge_commands, GLOBAL_PROC_REF(cmp_bridge_commands))

	global.metahelps = list()
	for(var/help in subtypesof(/datum/metahelp))
		var/datum/metahelp/H = new help
		global.metahelps[H.id] = H

	global.special_roles = get_list_of_primary_keys(special_roles_ignore_question)

	global.antag_roles = global.special_roles - ROLE_GHOSTLY

	global.full_ignore_question = get_list_of_keys_from_values_as_list_from_associative_list(special_roles_ignore_question)


	global.all_skills = list()
	for(var/skill_type in subtypesof(/datum/skill))
		global.all_skills[skill_type] = new skill_type

	global.all_skillsets = list()
	for(var/skillset_type in subtypesof(/datum/skillset))
		global.all_skillsets[skillset_type] = new skillset_type

	global.skillset_names_aliases = list()
	for(var/s in all_skillsets)
		var/datum/skillset/skillset = all_skillsets[s]
		global.skillset_names_aliases[skillset.name] = s

	global.all_emotes = list()
	for(var/emote_type in subtypesof(/datum/emote))
		global.all_emotes[emote_type] = new emote_type

	global.emotes_for_emote_panel = list()
	var/emote_icons = 'icons/misc/emotes.dmi'
	var/mob/living/carbon/human/H = new /mob/living/carbon/human // meh initial doesn't work with lists
	for(var/datum/emote/E as anything in H.default_emotes) // non-humans emotes but humans have them
		if(initial(E.key) in icon_states(emote_icons))
			global.emotes_for_emote_panel |= initial(E.key)
	qdel(H)
	for(var/datum/emote/E as anything in subtypesof(/datum/emote/human)) // humans emotes
		if(initial(E.key) in icon_states(emote_icons))
			global.emotes_for_emote_panel |= initial(E.key)
	for(var/datum/species/S as anything in subtypesof(/datum/species)) // IPC emotes and etc.
		S = new S
		for(var/datum/emote/E as anything in S.emotes)
			if(initial(E.key) in icon_states(emote_icons))
				global.emotes_for_emote_panel |= initial(E.key)
		qdel(S)

	global.light_modes_by_type = list()
	global.light_modes_by_name = list()
	for(var/type as anything in subtypesof(/datum/light_mode))
		var/datum/light_mode/LM = new type
		light_modes_by_name[LM.name] = LM
		light_modes_by_type[type] = LM

	global.smartlight_presets = list()
	for(var/datum/smartlight_preset/type as anything in subtypesof(/datum/smartlight_preset))
		smartlight_presets[initial(type.name)] = type

	global.lighting_effects = list()
	for(var/datum/level_lighting_effect/type as anything in subtypesof(/datum/level_lighting_effect))
		lighting_effects[initial(type.name)] = type

	global.virus_types_by_pool = list()
	for(var/e in subtypesof(/datum/disease2/effect))
		var/datum/disease2/effect/f = new e
		var/list/L = f.pools
		qdel(f)
		if(!L.len)
			continue
		for(var/pool in L)
			LAZYADD(virus_types_by_pool[pool], e)

	global.ringtones_by_names = list()
	for(var/datum/ringtone/Ring as anything in subtypesof(/datum/ringtone))
		global.ringtones_by_names["[initial(Ring.name)]"] = new Ring

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

/proc/gen_hex_by_color()
	if(!hex_by_color)
		hex_by_color = list()

	for(var/color in color_by_hex)
		hex_by_color[color_by_hex[color]] = color
