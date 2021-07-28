// Categories
#define RITES        "RITES"
#define SECTS        "SECTS"
#define ASPECTS      "ASPECTS"
#define GOD_SPELLS   "GOD SPELLS"
#define HOLY_REAGS   "HOLY REAGENTS"
#define FAITH_REACTS "FAITH REACTIONS"

// Rites info
#define RITE_NAME        "name"
#define RITE_DESC        "desc"
#define RITE_TIPS        "tips"
#define RITE_LENGTH      "ritual_length"
#define RITE_FAVOR       "favor_cost"
#define RITE_PIETY       "piety_cost"
#define RITE_ASPECTS     "needed_aspects"
#define RITE_TALISMANED  "can_talismaned"
#define RITE_PATH        "path"

// Sects info
#define SECT_NAME      "name"
#define SECT_DESC      "desc"
#define SECT_PRESET    "aspect_preset"
#define SECT_ASP_COUNT "aspects_count"
#define SECT_PATH      "path"

// Aspect info
#define ASP_NAME       "name"
#define ASP_DESC       "desc"
#define ASP_GOD_DESC   "god_desc"
#define ASP_COLOR      "color"

// Spell info
#define SPELL_NAME    "name"
#define SPELL_COST    "favor_cost"
#define SPELL_CD      "charge_max"
#define SPELL_ASPECTS "needed_aspects"

// Holy reagents info
#define REAGENT_NAME    "name"
#define REAGENT_ASPECTS "needed_aspects"

// Faith reactions info
#define REACTION_CONVERTABLE "convertable_id"
#define REACTION_RESULT      "result_id"
#define REACITON_COST        "favor_cost"
#define REACTION_ASPECTS     "needed_aspects"

/datum/religion
	// String information about rituals, sects, aspects, etc.
	var/list/encyclopedia = list()

/datum/religion/proc/init_encyclopedia()
	encyclopedia[RITES]        = list()
	encyclopedia[SECTS]        = list()
	encyclopedia[ASPECTS]      = list()
	encyclopedia[GOD_SPELLS]   = list()
	encyclopedia[HOLY_REAGS]   = list()
	encyclopedia[FAITH_REACTS] = list()

	parse_all()

/datum/religion/proc/parse_all()
	parse_rites()
	parse_sects()
	parse_aspects()
	parse_spells()
	parse_reags()
	parse_reacts()

/datum/religion/proc/parse_rites()
	var/list/all_rites = subtypesof(/datum/religion_rites)
	for(var/rite_type in all_rites)
		var/datum/religion_rites/RR = new rite_type

		if(!RR.desc || !RR.name || (RR.religion_type && !istype(src, RR.religion_type)))
			QDEL_NULL(RR)
			continue

		var/list/rite_info = list()

		rite_info[RITE_NAME]       = RR.name
		rite_info[RITE_DESC]       = RR.desc
		rite_info[RITE_TIPS]       = RR.tips
		rite_info[RITE_LENGTH]     = RR.ritual_length
		rite_info[RITE_FAVOR]      = RR.favor_cost
		rite_info[RITE_PIETY]      = RR.piety_cost
		rite_info[RITE_ASPECTS]    = RR.needed_aspects
		rite_info[RITE_TALISMANED] = RR.can_talismaned
		rite_info[RITE_PATH]       = RR.type

		encyclopedia[RITES] += list(rite_info)

		QDEL_NULL(RR)

/datum/religion/proc/get_sects_types()
	return subtypesof(/datum/religion_sect)

/datum/religion/chaplain/get_sects_types()
	return subtypesof(/datum/religion_sect/preset/chaplain) + /datum/religion_sect/custom/chaplain

/datum/religion/cult/get_sects_types()
	return subtypesof(/datum/religion_sect/preset/cult) + /datum/religion_sect/custom/cult

/datum/religion/proc/parse_sects()
	var/list/all_sects = get_sects_types()
	for(var/sect_type in all_sects)
		var/datum/religion_sect/RS = new sect_type

		var/list/sect_info = list()

		sect_info[SECT_NAME]      = RS.name
		if(RS.add_religion_name)
			sect_info[SECT_NAME] += " [name]"
		sect_info[SECT_DESC]      = RS.desc
		sect_info[SECT_PRESET]    = null
		sect_info[SECT_ASP_COUNT] = null
		sect_info[SECT_PATH]      = RS.type

		if(istype(RS, /datum/religion_sect/preset))
			var/datum/religion_sect/preset/PRS = RS
			var/list/aspect_name_by_count = list()
			for(var/asp_type in PRS.aspect_preset)
				var/datum/aspect/asp_byond_cheat = asp_type
				aspect_name_by_count[initial(asp_byond_cheat.name)] = PRS.aspect_preset[asp_type]
			sect_info[SECT_PRESET]    = aspect_name_by_count
		else if(istype(RS, /datum/religion_sect/custom))
			var/datum/religion_sect/custom/CRS = RS
			sect_info[SECT_ASP_COUNT] = CRS.aspects_count

		encyclopedia[SECTS] += list(sect_info)

		QDEL_NULL(RS)

/datum/religion/proc/parse_aspects()
	var/list/all_aspects = subtypesof(/datum/aspect)
	for(var/asp_type in all_aspects)
		var/datum/aspect/ASP = new asp_type

		if(!ASP.name)
			QDEL_NULL(ASP)
			continue

		var/list/aspect_info = list()

		aspect_info[ASP_NAME]     = ASP.name
		aspect_info[ASP_DESC]     = ASP.desc
		aspect_info[ASP_GOD_DESC] = ASP.god_desc
		aspect_info[ASP_COLOR]    = ASP.color

		encyclopedia[ASPECTS] += list(aspect_info)

		QDEL_NULL(ASP)

/datum/religion/proc/parse_spells()
	var/list/all_spells = subtypesof(/obj/effect/proc_holder/spell)
	for(var/spell_type in all_spells)
		var/obj/effect/proc_holder/spell/S = new spell_type
		if(!S.needed_aspects || !S.name)
			QDEL_NULL(S)
			continue

		var/list/spell_info = list()

		spell_info[SPELL_NAME]    = S.name
		spell_info[SPELL_COST]    = S.favor_cost
		spell_info[SPELL_CD]      = S.charge_max
		spell_info[SPELL_ASPECTS] = S.needed_aspects

		encyclopedia[GOD_SPELLS] += list(spell_info)

		QDEL_NULL(S)

/datum/religion/proc/parse_reags()
	for(var/id in global.chemical_reagents_list)
		var/datum/reagent/R = global.chemical_reagents_list[id]
		if(!R.needed_aspects)
			continue

		var/list/reagent_info = list()

		reagent_info[REAGENT_NAME]    = R.name
		reagent_info[REAGENT_ASPECTS] = R.needed_aspects

		encyclopedia[HOLY_REAGS] += list(reagent_info)

/datum/religion/proc/parse_reacts()
	for(var/id in global.faith_reactions)
		var/datum/faith_reaction/FR = global.faith_reactions[id]
		if(!FR.needed_aspects)
			continue

		var/list/reaction_info = list()

		reaction_info[REACTION_CONVERTABLE] = FR.convertable_id
		reaction_info[REACTION_RESULT]      = FR.result_id
		reaction_info[REACITON_COST]        = FR.favor_cost
		reaction_info[REACTION_ASPECTS]     = FR.needed_aspects

		encyclopedia[FAITH_REACTS] += list(reaction_info)
