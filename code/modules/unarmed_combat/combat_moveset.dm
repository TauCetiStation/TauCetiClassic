/datum/combat_moveset
	var/name = "Default Moveset"
	/// List of combo names that this moveset teaches.
	var/list/teach_combos = list()
	// Assoc list of combo_name = upgraded_combo_name.
	// Will replace the combo_name of mob with the upgraded_combo_name,
	// but not grant upgraded_combo_name if he doesn't have combo_name.
	var/list/upgrade_combos = list()

/datum/combat_moveset/proc/apply(mob/living/L, source)
	for(var/combo_name in teach_combos)
		var/datum/combat_combo/CC = global.combat_combos_by_name[combo_name]
		L.learn_combo(CC, src)

	for(var/combo_name in upgrade_combos)
		var/datum/combat_combo/CC = global.combat_combos_by_name[combo_name]
		if(!(CC in L.known_combos))
			continue
		L.allowed_combos -= CC

		var/upgrade_name = upgrade_combos[combo_name]
		var/datum/combat_combo/UCC = global.combat_combos_by_name[upgrade_name]
		L.learn_combo(UCC, src)

	RegisterSignal(L, list(COMSIG_LIVING_LEARN_COMBO), PROC_REF(on_combo_learn))
	RegisterSignal(L, list(COMSIG_LIVING_FORGET_COMBO), PROC_REF(on_combo_forget))

	if(!L.movesets_by_source[source])
		L.movesets_by_source[source] = list()
	L.movesets_by_source[source] += src

/datum/combat_moveset/proc/remove(mob/living/L, source)
	UnregisterSignal(L, list(COMSIG_LIVING_LEARN_COMBO, COMSIG_LIVING_FORGET_COMBO))

	L.movesets_by_source[source] -= src
	if(length(L.movesets_by_source[source]) == 0)
		L.movesets_by_source -= source

	for(var/combo_name in teach_combos)
		var/datum/combat_combo/CC = global.combat_combos_by_name[combo_name]
		L.forget_combo(CC, src)

	for(var/combo_name in upgrade_combos)
		var/datum/combat_combo/CC = global.combat_combos_by_name[combo_name]
		var/upgrade_name = upgrade_combos[combo_name]
		var/datum/combat_combo/UCC = global.combat_combos_by_name[upgrade_name]

		if(CC in L.known_combos)
			L.allowed_combos[CC] = list() + L.known_combos[CC]
		L.forget_combo(UCC, src)

/datum/combat_moveset/proc/on_combo_learn(datum/source, datum/combat_combo/combo, datum/combat_moveset/moveset)
	var/mob/living/L = source
	if(upgrade_combos[combo.name])
		L.allowed_combos -= combo

		var/upgrade_name = upgrade_combos[combo.name]
		var/datum/combat_combo/UCC = global.combat_combos_by_name[upgrade_name]
		L.learn_combo(UCC, src)

/datum/combat_moveset/proc/on_combo_forget(datum/source, datum/combat_combo/combo, datum/combat_moveset/moveset)
	var/mob/living/L = source
	if(upgrade_combos[combo.name])
		var/upgrade_name = upgrade_combos[combo.name]
		var/datum/combat_combo/UCC = global.combat_combos_by_name[upgrade_name]
		L.forget_combo(UCC, src)
