/mob/living/simple_animal/hostile/replicator/proc/acquire_array_upgrade()
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
	if(!RAI)
		return

	if(length(RAI.acquired_upgrades) >= FR.upgrades_amount)
		return

	var/list/choices = RAI.get_upgrade_choices()

	var/list/radial_choices = list()
	for(var/upgrade_name in choices)
		var/datum/replicator_array_upgrade/RAU = choices[upgrade_name]
		radial_choices[upgrade_name] = image(icon=initial(RAU.icon), icon_state=initial(RAU.icon_state))

	var/upgrade_name = show_radial_menu(src, src, radial_choices, radius = 30, tooltips = TRUE)
	if(!upgrade_name)
		return

	var/datum/replicator_array_upgrade/upgrade_type = choices[upgrade_name]

	playsound(src, 'sound/magic/heal.ogg', VOL_EFFECTS_MASTER)
	to_chat(src, "<span class='notice'>[initial(upgrade_type.name)] upgrade acquired. Adapting array drones...</span>")
	RAI.acquire_upgrade(upgrade_type)

/datum/replicator_array_info
	var/list/datum/replicator_array_upgrade/acquired_upgrades = list()

	var/list/upgrade_type_pool = REPLICATOR_STARTING_UPGRADE_POOL

	var/list/cached_choice_upgrades

/datum/replicator_array_info/proc/add_unit(mob/living/simple_animal/hostile/replicator/R, just_spawned=FALSE)
	for(var/datum/replicator_array_upgrade/RAU as anything in acquired_upgrades)
		RAU.add_to_unit(R, just_spawned)

/datum/replicator_array_info/proc/remove_unit(mob/living/simple_animal/hostile/replicator/R)
	for(var/datum/replicator_array_upgrade/RAU as anything in acquired_upgrades)
		RAU.remove_from_unit(R)

/datum/replicator_array_info/proc/acquire_upgrade(upgrade_type)
	var/datum/replicator_array_upgrade/RAU = new upgrade_type
	RAU.on_acquire(src)

	acquired_upgrades += RAU

	for(var/mob/living/simple_animal/hostile/replicator/R as anything in get_array_units(get_or_create_replicators_faction()))
		RAU.add_to_unit(R)

/datum/replicator_array_info/proc/get_upgrades_string()
	var/list/upgrade_strings = list()
	for(var/datum/replicator_array_upgrade/RAU as anything in acquired_upgrades)
		var/keystring = "[RAU.name]. [RAU.desc]"
		if(!upgrade_strings[keystring])
			upgrade_strings[keystring] = 0
		upgrade_strings[keystring] += 1

	. = ""
	for(var/keystring in upgrade_strings)
		. += "[keystring] ([upgrade_strings[keystring]])\n"

/datum/replicator_array_info/proc/get_upgrade_choices()
	if(cached_choice_upgrades)
		return cached_choice_upgrades

	var/list/category2choices = list()
	for(var/category in REPLICATOR_UPGRADE_CATEGORIES)
		for(var/datum/replicator_array_upgrade/RAU_type as anything in upgrade_type_pool)
			if(category == initial(RAU_type.category))
				LAZYADDASSOCLIST(category2choices, category, RAU_type)

	var/list/name2upgrade_type = list()
	for(var/category in REPLICATOR_UPGRADE_CATEGORIES)
		if(!length(category2choices[category]))
			continue
		var/datum/replicator_array_upgrade/chosen_type = pick(category2choices[category])
		var/input_string = "[initial(chosen_type.name)]: [initial(chosen_type.desc)] ([category])"
		name2upgrade_type[input_string] = chosen_type

	cached_choice_upgrades = name2upgrade_type
	return name2upgrade_type

/datum/replicator_array_info/proc/clear_upgrade_choices()
	cached_choice_upgrades = null


/datum/replicator_array_upgrade
	var/name
	var/desc

	// For radial choices.
	var/icon = 'icons/mob/replicator.dmi'
	var/icon_state

	// one of REPLICATOR_UPGRADE_CATEGORIES
	var/category

	var/list/allow_upgrade_types
	var/list/prohibit_upgrade_types

/datum/replicator_array_upgrade/proc/on_acquire(datum/replicator_array_info/RAI)
	RAI.upgrade_type_pool |= allow_upgrade_types
	RAI.upgrade_type_pool -= prohibit_upgrade_types

/datum/replicator_array_upgrade/proc/add_to_unit(mob/living/simple_animal/hostile/replicator/R, just_spawned)
	return

// Must be a complete reversal of add_to_unit.
/datum/replicator_array_upgrade/proc/remove_from_unit(mob/living/simple_animal/hostile/replicator/R)
	return
