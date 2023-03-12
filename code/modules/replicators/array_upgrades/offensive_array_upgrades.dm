/datum/replicator_array_upgrade/offensive
	category = REPLICATOR_UPGRADE_CATEGORY_OFFENSIVE


/datum/replicator_array_upgrade/offensive/ranged_attack_damage
	name = "Destruction"
	desc = "Further concentration of energy allows for greater combat capabilities."

	icon_state = "upgrade_ranged_attack_damage"

/datum/replicator_array_upgrade/offensive/ranged_attack_damage/add_to_unit(mob/living/simple_animal/hostile/replicator/R, just_spawned)
	R.disabler_damage_increase += 1.0

/datum/replicator_array_upgrade/offensive/ranged_attack_damage/remove_from_unit(mob/living/simple_animal/hostile/replicator/R)
	R.disabler_damage_increase -= 1.0
