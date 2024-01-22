/*
	This datum is used to neatly package all of religion's choices and etc
	and save them somewhere for future reference.
*/

// Create a religion. You must declare proc/setup_religions() of religion
/proc/create_religion(type)
	return new type

/datum/religion
	// The name of this religion.
	var/name = ""
	// Lore of this religion. Is displayed to "God(s)". If none is set, chaplain will be prompted to set up their own lore.
	var/lore = ""
	var/list/lore_by_name = list()

	// List of names of deities of this religion.
	// There is no "default" deity, please specify one for your religion here.
	var/list/deity_names = list()
	var/list/deity_names_by_name

	/*
		Church customization
	*/
	// Default is /datum/bible_info/custom, if one is not specified here.
	var/datum/bible_info/bible_info
	// Type of bible of religion
	var/bible_type

	var/list/bible_info_by_name

	var/religious_tool_type

	var/emblem_icon_state
	// Is required to have a "Default" as a fallback.
	var/list/emblem_info_by_name
	// Radial menu
	var/list/emblem_skins

	var/altar_icon_state
	// Is required to have a "Default" as a fallback.
	var/list/altar_info_by_name
	// Radial menu
	var/list/altar_skins

	var/carpet_type
	var/list/carpet_type_by_name

	// Now only for cults
	var/list/wall_types
	var/list/floor_types
	var/list/door_types

	var/decal
	// List of possible decals
	var/list/decal_by_name
	var/list/decal_radial_menu
	// Main area with structures
	var/area_type
	// Subtypes of area_type
	var/list/area_types
	// Refs
	var/list/area/captured_areas = list()

	/*
		Aspects and Rites related
	*/
	// The religion's 'Mana'
	// Maybe I'll make this field protected and make getters and setters.
	var/favor = 0
	// The max amount of favor the religion can have
	var/max_favor = 3000
	// The amount of favor generated passively
	var/passive_favor_gain = 0.0
	// More important than favor, used in very expensive rites
	// Maybe I'll make this field protected and make getters and setters.
	var/piety = 0

	// Chosen aspects, name = aspect
	var/list/aspects = list()
	// Spells that are determined by aspect combinations, are given to God.
	var/list/god_spells = list()
	var/list/active_deities = list()

	// Lists of rites with information. Converts itself into a list of rites with "name - desc (favor_cost)"
	// rite.name = info
	var/list/rites_info = list()
	// Lists of rite name by type. "name = rite"
	var/list/rites_by_name = list()
	// "name" = int, shows how many times the ritual was cast
	var/list/ritename_by_count = list()
	// List with the types of all mandatory rites which are always given
	var/list/binding_rites = list()

	// All runes on map
	var/list/obj/effect/rune/runes = list()
	// ckey = list(rune, rune, rune)
	var/list/runes_by_ckey
	// Max runes on mob
	var/max_runes_on_mob

	/*
		Others
	*/
	// Contains an altar, wherever it is
	var/list/obj/structure/altar_of_gods/altars = list()
	// The whole composition of beings in religion. Contains any mobs, even dead and without mind.
	var/list/mob/members = list()
	// Tech_id by ref
	var/list/all_techs = list()
	// Used for cloning and round result
	var/list/datum/mind/members_minds = list()
	// Easy access
	var/datum/religion_sect/sect
	// css
	var/style_text
	// It`s hud
	var/symbol_icon_state
	// String information about rituals, sects, aspects, etc.
	var/datum/religion_interface/encyclopedia = new

	/*
		Building
	*/
	// All constructions that religion can build
	var/list/datum/building_agent/available_buildings = list()
	// Type of initial construction agent for which available_buildings will be generated
	var/build_agent_type
	// All runes that religion can scribe
	var/list/datum/building_agent/available_runes = list()
	// Type of initial runes agent for which available_runes will be generated
	var/rune_agent_type
	// All tech that religion can research
	var/list/datum/building_agent/available_techs = list()
	// Type of initial tech agent for which available_runes will be generated
	var/tech_agent_type

	/*
		Holy reagents
	*/
	// A list of ids of holy reagents from aspects.
	var/list/holy_reagents = list()
	// A list of possible faith reactions.
	var/list/faith_reactions = list()

	// A dict of holy turfs of format holy_turf = timer_id.
	var/list/holy_turfs = list()

/datum/religion/New()
	all_religions += src
	reset_religion()
	setup_religions()

	area_types = typesof(area_type)
	religify_area(null, null, null, TRUE)

	encyclopedia.init_encyclopedia(src)

/datum/religion/process()
	if(passive_favor_gain == 0.0)
		STOP_PROCESSING(SSreligion, src)
		return

	adjust_favor(passive_favor_gain)

// This proc is called from tickers setup, right after economy is done, but before any characters are spawned.
/datum/religion/proc/setup_religions()
	return

/datum/religion/proc/reset_religion()
	lore = initial(lore)
	lore_by_name = list()
	deity_names = list()
	bible_info = initial(bible_info)
	for(var/god in active_deities)
		remove_deity(god)
	favor = initial(favor)
	max_favor = initial(max_favor)
	aspects = list()
	god_spells = list()
	rites_info = list()
	rites_by_name = list()
	members = list()

	for(var/obj/structure/altar_of_gods/altar in altars)
		altar.chosen_aspect = initial(altar.chosen_aspect)
		altar.religion = initial(altar.religion)
		altar.performing_rite = initial(altar.performing_rite)

	create_default()

/datum/religion/Destroy()
	QDEL_LIST_ASSOC_VAL(holy_turfs)
	holy_turfs = null

	altars = null
	return ..()

/datum/religion/proc/gen_bible_info()
	if(bible_info_by_name[name])
		var/info_type = bible_info_by_name[name]
		bible_info = new info_type(src)
	else
		bible_info = new /datum/bible_info/chaplain/custom(src)

/datum/religion/proc/gen_altar_variants()
	altar_skins = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/info in altar_info_by_name)
		var/image/I = image(icon = 'icons/obj/structures/chapel.dmi', icon_state = altar_info_by_name[info])
		I.transform = M
		altar_skins[info] = I

/datum/religion/proc/gen_emblem_variants()
	emblem_skins = list()
	for(var/info in emblem_info_by_name)
		emblem_skins[info] = image(icon = 'icons/obj/lectern.dmi', icon_state = "[emblem_info_by_name[info]]")

/datum/religion/proc/gen_decal_variants()
	decal_radial_menu = list()
	var/matrix/M = matrix()
	M.Scale(0.7)
	for(var/name in decal_by_name)
		var/image/I = image(icon = 'icons/turf/turf_decals.dmi', icon_state = "religion_[lowertext(name)]")
		I.transform = M
		//I.color = "#000000"
		decal_radial_menu[name] = I

// This proc creates a "preset" of religion, before allowing to fill out the details.
/datum/religion/proc/create_default()
	lore = lore_by_name[name]
	if(!lore)
		lore = ""

	deity_names = deity_names_by_name[name]
	if(!deity_names)
		warning("ERROR IN SETTING UP RELIGION: [name] HAS NO DEITIES WHATSOVER. HAVE YOU SET UP RELIGIONS CORRECTLY?")
		deity_names = list("Error")

	gen_bible_info()
	gen_altar_variants()
	gen_emblem_variants()
	gen_decal_variants()

	gen_agent_lists()

	update_structure_info()

// Update all info regarding structure based on current religion info.
/datum/religion/proc/update_structure_info()
	var/emblem_info = emblem_info_by_name[name]
	if(emblem_info)
		emblem_icon_state = emblem_info
	else
		emblem_icon_state = emblem_info_by_name["Default"]

	var/altar_info = altar_info_by_name[name]
	if(altar_info)
		altar_icon_state = altar_info
	else
		altar_icon_state = altar_info_by_name["Default"]

	var/carpet_info = carpet_type_by_name[name]
	if(carpet_info)
		carpet_type = carpet_info
	else
		carpet_type = carpet_type_by_name["Default"]

// This proc converts all related objects in area_type to this reigion's liking.
/datum/religion/proc/religify(_area_type = area_type, datum/callback/after_action, mob/user, force = FALSE)
	var/area/area = get_area_by_type(_area_type)
	if(area && !istype(area.religion, type) && !force)
		if(user)
			to_chat(user, "<span class='warning'>[area] больше не под контролем вашей религии!</span>")
		return FALSE

	var/list/to_religify = get_area_all_atoms(_area_type)
	var/i = 0
	for(var/atom/A in to_religify)
		var/atom_changed = FALSE
		if(A.atom_religify(src))
			atom_changed = TRUE

		i++
		if(after_action && atom_changed)
			if(!after_action.Invoke(i, to_religify))
				return FALSE
	return TRUE

// This proc denotes the area of a particular religion
/datum/religion/proc/religify_area(_area_type = area_type, datum/callback/after_action, mob/user, force = FALSE)
	if(!religify(_area_type, after_action, user, force))
		return FALSE

	var/list/areas = get_areas(_area_type)
	for(var/area/A in areas)
		if(A.religion)
			A.religion.captured_areas -= A
		captured_areas += A
		A.religion = src
		passive_favor_gain = max(0, captured_areas.len - area_types.len)
	return TRUE

// This proc returns a bible object of this religion, spawning it at a given location.
/datum/religion/proc/spawn_bible(atom/location)
	var/obj/item/weapon/storage/bible/B = new bible_type(location)
	bible_info.apply_to(B)
	B.religion = src
	return B

// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion/proc/adjust_favor(amount = 0)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if(favor + amount > max_favor)
		. = (max_favor - favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add
	favor = clamp(favor + amount, 0, max_favor)
	if(amount > 0)
		adjust_piety(amount)

// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion/proc/set_favor(amount = 0)
	favor = clamp(amount, 0, max_favor)
	return favor

/datum/religion/proc/adjust_piety(amount = 0)
	if(amount > 0) // when decrease you dont need it
		amount = amount / 10
	. = amount
	if(piety + amount < 0)
		. = piety
	piety = clamp(piety + amount, 0, INFINITY)

/datum/religion/proc/check_costs(favor_cost, piety_cost, mob/user)
	var/corrects = 0

	if(!isnull(favor_cost))
		if(favor_cost > 0 && favor_cost > favor)
			if(user)
				to_chat(user, "<span class ='warning'>You need [favor_cost - favor] more favors.</span>")
			return FALSE
		corrects += 1

	if(!isnull(piety_cost))
		if(piety_cost > 0 && piety_cost > piety)
			if(user)
				to_chat(user, "<span class ='warning'>You need [piety_cost - piety] more piety.</span>")
			return FALSE
		corrects += 1

	switch(corrects)
		if(1)
			if(!isnull(piety_cost) && !isnull(favor_cost))
				return FALSE
			return TRUE
		if(2)
			if(!isnull(piety_cost) && !isnull(favor_cost))
				return TRUE

// This predicate is used to determine whether this religion meets spells/rites aspect requirements.
// Is used in is_sublist_assoc
/datum/religion/proc/satisfy_requirements(element, datum/aspect/A)
	return element <= A.power

// This proc is used to change divine power of a spell or rite according to this religion's aspects.
// Uses a form of this formula:
// power = power * (summ of aspect diferences / amount of spell aspects + 1)
/datum/religion/proc/calc_divine_power(list/needed_aspects, initial_divine_power)
	if(!needed_aspects || !needed_aspects.len)
		return initial_divine_power

	var/divine_power = initial_divine_power

	var/diff = 0

	for(var/aspect_name in aspects)
		var/datum/aspect/asp = aspects[aspect_name]
		if(needed_aspects[asp.name])
			diff += asp.power - needed_aspects[asp.name]

	divine_power = round(divine_power * (diff / needed_aspects.len + 1), 1)

	return divine_power

/datum/religion/proc/affect_divine_power_spell(obj/effect/proc_holder/spell/S)
	S.divine_power = calc_divine_power(S.needed_aspects, initial(S.divine_power))

/datum/religion/proc/affect_divine_power_rite(datum/religion_rites/R)
	R.divine_power = calc_divine_power(R.needed_aspects, initial(R.divine_power))

/**
 * Returns a list with the difference between the needed aspects for rite and those in religion.
 * Return format: "Aspect name" = difference
 */
/datum/religion/proc/get_aspect_diffs(list/rite_aspects)
	var/list/diffs = list()
	for(var/need_aspect in rite_aspects)
		var/datum/aspect/aspect = aspects[need_aspect]
		diffs[aspect.name] = aspect.power - rite_aspects[need_aspect]
	return diffs

// Give our gods all needed spells which in /list/spells
/datum/religion/proc/give_god_spells(mob/G)
	for(var/spell in god_spells)
		var/obj/effect/proc_holder/spell/S = G.GetSpell(spell)
		if(S)
			affect_divine_power_spell(S)
			continue
		else
			S = new spell
			affect_divine_power_spell(S)
			G.AddSpell(S)

/datum/religion/proc/remove_god_spells(mob/G)
	G.ClearSpells()

/datum/religion/proc/update_deities()
	for(var/mob/deity in active_deities)
		give_god_spells(deity)

/datum/religion/proc/get_rite_info(datum/religion_rites/RI)
	var/name_entry = ""

	var/tip_text
	for(var/tip in RI.tips)
		if(tip_text)
			tip_text += " "
		tip_text += tip
	if(tip_text)
		name_entry += "[EMBED_TIP(RI.name, tip_text)]"
	else
		name_entry += "[RI.name]"

	if(RI.desc)
		name_entry += " - [RI.desc]"
	if(RI.favor_cost)
		name_entry += " ([RI.favor_cost] favor)"
	if(RI.piety_cost)
		for(var/obj/structure/altar_of_gods/altar in altars)
			altar.look_piety = TRUE
		name_entry += "<span class='[style_text]'> ([RI.piety_cost] piety)</span>"

	return name_entry

// Generate new rite_list and updating existing rites' divine power
/datum/religion/proc/update_rites()
	if(rites_by_name.len > 0)
		rites_info = list()
		// Generates a list of information of rite, used for examine() in altar_of_gods
		for(var/i in rites_by_name)
			var/datum/religion_rites/RI = rites_by_name[i]
			rites_info[RI.name] = get_rite_info(RI)
			affect_divine_power_rite(RI)

// Adds all binding rites once
/datum/religion/proc/give_binding_rites()
	for(var/rite_type in binding_rites)
		setup_rite(rite_type)

// Gives the rite religion and divine_power and puts it in religion list rite_by_name
/datum/religion/proc/setup_rite(rite_type)
	var/datum/religion_rites/R = new rite_type
	R.religion = src
	rites_by_name[R.name] = R
	ritename_by_count[R.name] = 0
	affect_divine_power_rite(R)

// Adds all spells related to asp.
/datum/religion/proc/add_aspect_spells(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/spell_type in global.spells_by_aspects[asp.name])
		var/obj/effect/proc_holder/spell/S = new spell_type

		if(is_sublist_assoc(S.needed_aspects, aspects, aspect_pred))
			god_spells |= spell_type

		QDEL_NULL(S)

// Adds all rites related to asp.
/datum/religion/proc/add_aspect_rites(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/rite_type in global.rites_by_aspects[asp.name])
		var/datum/religion_rites/RR = new rite_type

		if(rites_by_name[RR.name] || (RR.religion_type && !istype(src, RR.religion_type)))
			QDEL_NULL(RR)
			continue

		if(is_sublist_assoc(RR.needed_aspects, aspects, aspect_pred))
			setup_rite(rite_type)

		QDEL_NULL(RR)

/datum/religion/proc/add_aspect_reagents(datum/aspect/asp, datum/callback/aspect_pred)
	for(var/reagent_id in global.holy_reagents_by_aspects[asp.name])
		var/datum/reagent/R = global.chemical_reagents_list[reagent_id]

		if(is_sublist_assoc(R.needed_aspects, aspects, aspect_pred))
			holy_reagents[R.name] = reagent_id

	for(var/reaction_id in global.faith_reactions_by_aspects[asp.name])
		var/datum/faith_reaction/FR = global.faith_reactions[reaction_id]

		if(is_sublist_assoc(FR.needed_aspects, aspects, aspect_pred))
			faith_reactions[FR.id] = FR

// Is called after any addition of new aspects.
// Manages new spells and rites, gained by adding the new aspects.
/datum/religion/proc/update_aspects()
	var/datum/callback/aspect_pred = CALLBACK(src, PROC_REF(satisfy_requirements))

	for(var/aspect_name in aspects)
		var/datum/aspect/asp = aspects[aspect_name]
		add_aspect_spells(asp, aspect_pred)
		add_aspect_rites(asp, aspect_pred)
		add_aspect_reagents(asp, aspect_pred)

	update_deities()
	update_rites()

// This proc is used to handle addition of aspects properly.
// It expects aspect_list to be of form list(aspect_type = aspect power)
/datum/religion/proc/add_aspects(list/aspect_list)
	for(var/aspect_type in aspect_list)
		var/datum/aspect/asp = aspect_type
		if(aspects[initial(asp.name)])
			var/datum/aspect/aspect = aspects[initial(asp.name)]
			aspect.power += aspect_list[aspect_type]
		else
			var/datum/aspect/aspect = new aspect_type
			aspect.power = aspect_list[aspect_type]
			aspects[aspect.name] = aspect

	update_aspects()

/datum/religion/proc/add_deity(mob/M)
	active_deities += M
	M.my_religion = src
	M.mind?.holy_role = HOLY_ROLE_HIGHPRIEST
	give_god_spells(M)
	var/datum/atom_hud/holy/hud = global.huds[DATA_HUD_HOLY]
	hud.add_hud_to(M)

/datum/religion/proc/remove_deity(mob/M)
	active_deities -= M
	M.my_religion = null
	M.mind?.holy_role = initial(M.mind.holy_role)
	remove_god_spells(M)
	var/datum/atom_hud/holy/hud = global.huds[DATA_HUD_HOLY]
	hud.remove_hud_from(src)

/datum/religion/proc/give_hud(mob/M)
	var/datum/atom_hud/holy/hud = global.huds[DATA_HUD_HOLY]
	hud.add_to_hud(M)
	M.set_holy_hud()
	if(!ishuman(M))
		hud.add_hud_to(M)

/datum/religion/proc/take_hud(mob/M)
	var/datum/atom_hud/holy/hud = global.huds[DATA_HUD_HOLY]
	hud.remove_from_hud(M)
	M.set_holy_hud()
	if(!ishuman(M))
		hud.remove_hud_from(M)

/datum/religion/proc/can_convert(mob/M)
	return TRUE

/datum/religion/proc/add_member(mob/M, holy_role)
	if(is_member(M) || !can_convert(M))
		return FALSE

	SEND_SIGNAL(src, COMSIG_REL_ADD_MEMBER, M, holy_role)

	members |= M
	if(M.mind)
		members_minds |= M.mind
		M.mind.holy_role = holy_role
	M.my_religion = src
	sect?.on_conversion(M)
	if(symbol_icon_state)
		give_hud(M)
	on_entry(M)
	return TRUE

/datum/religion/proc/on_entry(mob/M)
	return

/datum/religion/proc/remove_member(mob/M)
	if(!is_member(M))
		return FALSE

	SEND_SIGNAL(src, COMSIG_REL_REMOVE_MEMBER, M)

	members -= M
	M.my_religion = initial(M.my_religion)
	if(M.mind)
		M.mind.holy_role = initial(M.mind.holy_role)
		members_minds -= M.mind
	if(symbol_icon_state)
		take_hud(M)
	on_exit(M)
	return TRUE

/datum/religion/proc/on_exit(mob/M)
	return

/datum/religion/proc/is_member(mob/M)
	return M in members

/datum/religion/proc/gen_agent_lists()
	init_subtypes(build_agent_type, available_buildings)
	init_subtypes(rune_agent_type, available_runes)
	init_subtypes(tech_agent_type, available_techs)

/datum/religion/proc/on_holy_reagent_created(datum/reagent/R)
	RegisterSignal(R, list(COMSIG_REAGENT_REACTION_TURF), PROC_REF(holy_reagent_react_turf))

/datum/religion/proc/holy_reagent_react_turf(datum/source, turf/T, volume)
	if(!isfloorturf(T))
		return

	add_holy_turf(T, volume)

/datum/religion/proc/add_holy_turf(turf/simulated/floor/F, volume)
	if(holy_turfs[F])
		var/datum/holy_turf/HT = holy_turfs[F]
		HT.update(volume)
		return
	holy_turfs[F] = new /datum/holy_turf(F, src, volume)

/datum/religion/proc/remove_holy_turf(turf/simulated/floor/F)
	qdel(holy_turfs[F])

/datum/religion/proc/nearest_heretics(atom/target, range, ignore_holy = TRUE)
	var/list/heretics = list()
	var/turf/center = get_turf(target)
	for(var/mob/living/heretic in view(range, center))
		if(is_member(heretic))
			continue
		if(ignore_holy)
			if(heretic.my_religion || heretic.mind?.holy_role)
				continue
		heretics += heretic
	return heretics

/datum/religion/proc/nearest_acolytes(atom/target, range = 1, message)
	var/list/acolytes = list()
	var/turf/center = get_turf(target)
	for(var/mob/living/carbon/C in range(range, center))
		if(is_member(C) && C.stat == CONSCIOUS)
			acolytes += C
			if(message)
				C.say(message)
	return acolytes

/datum/religion/proc/send_message_to_members(message, name, font_size = 6, mob/source)
	var/format_name = name ? "[name]: " : ""
	for(var/mob/M in global.player_list)
		if(is_member(M) || isobserver(M))
			var/link = ""
			if(source && (iseminence(M) || isobserver(M)))
				link = FOLLOW_LINK(M, source)
			to_chat(M, "<font size='[font_size]'><span class='[style_text]'>[link][format_name][message]</span></font>")

/datum/religion/proc/add_tech(tech_type)
	var/datum/religion_tech/T = new tech_type
	T.on_add(src)
	all_techs[T.id] = T

/datum/religion/proc/get_tech(tech_id)
	return all_techs[tech_id]

/datum/religion/proc/get_runes_by_type(rune_type)
	var/list/valid_runes = list()
	for(var/obj/effect/rune/R as anything in runes)
		if(!istype(R.power, rune_type))
			continue
		if(!is_centcom_level(R.loc.z) || istype(get_area(R), area_type))
			valid_runes += R
	return valid_runes
