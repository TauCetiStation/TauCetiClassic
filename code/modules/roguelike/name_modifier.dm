/*
 * A container to manage all the modifiers.
 */
/datum/component/name_modifiers
	dupe_type = COMPONENT_DUPE_UNIQUE

	/// An amount of allowed modifiers to be displayed by group.
	var/list/amount_by_group

	/// The name of parent before any modifiers.
	var/saved_name
	/// The full mob's name ignoring amount_by_group
	var/full_name

	/// dict of sort: type = modifier
	var/list/modifiers_by_type
	/// dict of sort: group = list(priority = list(modifiers))
	var/list/name_modifiers
	/// dict of sort: group = highest_priority
	var/list/priority_by_group
	/// dict of sort: group = list(highest_priority_modifiers)
	var/list/highest_priority_modifiers

	var/highest_affect_priority
	// dict of sort: affect_priority = list(modifiers)
	var/list/affect_priorities
	/// a list of highest affect priority modifiers
	var/list/highest_affect_priority_modifiers

/datum/component/name_modifiers/Initialize(list/amount_by_group)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/A = parent
	saved_name = A.name
	src.amount_by_group = amount_by_group

	RegisterSignal(parent, list(COMSIG_NAME_MOD_ADD), .proc/AddModifier)
	RegisterSignal(parent, list(COMSIG_NAME_MOD_REMOVE), .proc/RemoveModifier)
	RegisterSignal(parent, list(COMSIG_ATOM_GET_EXAMINE_NAME), .proc/AddFullName)

/datum/component/name_modifiers/Destroy()
	var/atom/A = parent
	A.name = saved_name

	name_modifiers = null
	highest_priority_modifiers = null

	affect_priorities = null
	highest_affect_priority_modifiers = null

	for(var/mod_type in modifiers_by_type)
		qdel(modifiers_by_type[mod_type])
	modifiers_by_type = null
	return ..()

/// Get the max priority for a certain group.
/datum/component/name_modifiers/proc/get_max_priority(group)
	return priority_by_group[group]

/// Adds a modifier as highest priority one.
/datum/component/name_modifiers/proc/add_max_priority(datum/name_modifier/NM)
	priority_by_group[NM.group] = NM.priority
	highest_priority_modifiers[NM.group] += NM

/// Removes a modifier from highest priority logic.
/datum/component/name_modifiers/proc/remove_max_priority(datum/name_modifier/NM)
	highest_priority_modifiers[NM.group] -= NM

	if(length(highest_priority_modifiers[NM.group]) == 0)
		// 0 is not an available priority
		var/new_highest = 0
		for(var/i in 1 to NM.priority - 1)
			if(name_modifiers[NM.group]["[i]"] && i > new_highest)
				new_highest = i

		if(new_highest > 0)
			highest_priority_modifiers[NM.group] += name_modifiers[NM.group]["[new_highest]"]
			priority_by_group[NM.group] = new_highest

		if(length(highest_priority_modifiers[NM.group]) == 0)
			highest_priority_modifiers -= NM.group
			priority_by_group -= NM.group
			UNSETEMPTY(highest_priority_modifiers)
			UNSETEMPTY(priority_by_group)

/// Adds a modifier as highest affect priority.
/datum/component/name_modifiers/proc/add_max_affect_priority(datum/name_modifier/NM)
	highest_affect_priority = NM.affect_priority
	highest_affect_priority_modifiers += NM

/// Removes a modifier from highest priority list.
/datum/component/name_modifiers/proc/remove_max_affect_priority(datum/name_modifier/NM)
	highest_affect_priority_modifiers -= NM

	if(highest_affect_priority_modifiers.len == 0)
		var/new_highest = 0
		for(var/i in 1 to NM.affect_priority - 1)
			if(affect_priorities["[i]"] && i > new_highest)
				new_highest = i

		if(new_highest > 0)
			highest_priority_modifiers += affect_priorities["[new_highest]"]
			highest_affect_priority = new_highest

		if(highest_affect_priority_modifiers.len == 0)
			highest_affect_priority_modifiers = null
			affect_priorities = null
			highest_affect_priority = null

/// Gets an amount amount modifiers of group with highest priorities. ~Luduk
/datum/component/name_modifiers/proc/get_modifiers(group, amount)
	var/max_prio = get_max_priority(group)
	// If there's no priority for this group, there's no group.
	if(!max_prio)
		return null

	var/list/pos_modifiers = name_modifiers[group]
	var/list/approved = list()

	// This should be done with a linked list of priorities.
	for(var/i in 1 to max_prio)
		for(var/mod in pos_modifiers["[i]"])
			approved += mod
			amount -= 1
			if(amount <= 0)
				return approved
	return approved

/// Updates the name of an atom.
/datum/component/name_modifiers/proc/update_name()
	var/atom/A = parent

	// This should be done with a linked list. ~Luduk
	var/list/affect_with = list()
	var/highest_affect_priority_temp = 0

	for(var/group in amount_by_group)
		var/list/to_affect = get_modifiers(group, amount_by_group[group])
		for(var/datum/name_modifier/NM in to_affect)
			if(NM.affect_priority > highest_affect_priority_temp)
				highest_affect_priority_temp = NM.affect_priority

			LAZYINITLIST(affect_with["[NM.affect_priority]"])
			affect_with["[NM.affect_priority]"] += NM

	A.name = saved_name

	// Nothing is affecting mob's name, just reset it and leave.
	if(!highest_affect_priority)
		return

	for(var/i in 1 to highest_affect_priority_temp)
		for(var/datum/name_modifier/NM in affect_with["[i]"])
			NM.affect(A)

	full_name = saved_name

	for(var/i in 1 to highest_affect_priority)
		for(var/datum/name_modifier/NM in affect_priorities["[i]"])
			full_name = NM.affect_text(full_name)

/// Add the modifier mod_type.
/datum/component/name_modifiers/proc/AddModifier(datum/source, mod_type, severity = 1)
	LAZYINITLIST(modifiers_by_type)
	if(modifiers_by_type[mod_type])
		var/datum/name_modifier/NM = modifiers_by_type[mod_type]
		NM.severity += severity
		update_name()
		return

	var/datum/name_modifier/NM = new mod_type
	NM.severity = severity

	LAZYINITLIST(name_modifiers)
	LAZYINITLIST(name_modifiers[NM.group])
	LAZYINITLIST(name_modifiers[NM.group]["[NM.priority]"])

	name_modifiers[NM.group]["[NM.priority]"] += NM
	modifiers_by_type[mod_type] = NM

	LAZYINITLIST(priority_by_group)
	LAZYINITLIST(highest_priority_modifiers)
	LAZYINITLIST(highest_priority_modifiers[NM.group])

	var/highest_priority = get_max_priority(NM.group)
	if(!highest_priority)
		add_max_priority(NM)
	else if(NM.priority == highest_priority)
		add_max_priority(NM)
	else if(NM.priority > highest_priority)
		highest_priority_modifiers[NM.group] = list()
		add_max_priority(NM)

	LAZYINITLIST(affect_priorities)
	LAZYINITLIST(affect_priorities["[NM.affect_priority]"])
	LAZYINITLIST(highest_affect_priority_modifiers)

	affect_priorities["[NM.affect_priority]"] += NM

	if(!highest_affect_priority)
		add_max_affect_priority(NM)
	else if(NM.affect_priority == highest_affect_priority)
		add_max_affect_priority(NM)
	else if(NM.affect_priority > highest_priority)
		highest_affect_priority_modifiers = list()
		add_max_affect_priority(NM)

	update_name()

/// Remove the modifier mod_type.
/datum/component/name_modifiers/proc/RemoveModifier(datum/source, mod_type, severity = 1)
	if(!modifiers_by_type)
		return

	var/datum/name_modifier/NM = modifiers_by_type[mod_type]
	if(!NM)
		return

	NM.severity -= severity
	if(NM.severity > 0)
		update_name()
		return

	var/highest_priority = get_max_priority()
	if(NM.priority == highest_priority)
		remove_max_priority(NM)

	if(NM.affect_priority == highest_affect_priority)
		remove_max_affect_priority(NM)

	name_modifiers[NM.group]["[NM.priority]"] -= NM
	if(name_modifiers[NM.group]["[NM.priority]"] == 0)
		name_modifiers[NM.group] -= "[NM.priority]"
		if(length(name_modifiers[NM.group]) == 0)
			name_modifiers -= NM.group
			UNSETEMPTY(name_modifiers)

	modifiers_by_type -= mod_type
	UNSETEMPTY(modifiers_by_type)

	update_name()

/datum/component/name_modifiers/proc/AddFullName(datum/source, mob/user, list/override)
	var/atom/A = parent
	override[EXAMINE_POSITION_NAME] = "[EMBED_TIP(A.name, full_name)]"
	return COMPONENT_EXNAME_CHANGED

/*
 * This is a data class used to contain all info about a certain prefix.
 */
/datum/name_modifier
	/// The text of the modifier itself.
	var/text = ""
	/// The "severity" of this name modifier. "very health", "super healthy", "uber healthy", and alike.
	var/severity = 1
	/// Priority of this modifier appearing, the higher it is - the less likely it is to appear. Should be higher than zero.
	var/priority = 1
	/// Group in which this modifiers priority is accounted.
	var/group = ""
	/// In which priority group does this modifier affect. Lower numbers - earlier affects. Should be higher than zero.
	var/affect_priority = 1

/datum/name_modifier/proc/affect(atom/A)
	return

/datum/name_modifier/proc/affect_text(txt)
	return get_txt()

/datum/name_modifier/proc/get_txt()
	return get_severity_txt() + text

/datum/name_modifier/proc/get_severity_txt()
	switch(severity)
		if(1)
			return ""
		if(2, 3)
			return "very "
		if(4, 5)
			return "very very "
		if(5, 6)
			return "super "
		else
			return "uber "
