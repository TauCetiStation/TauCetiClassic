/datum/replicator_array_upgrade/support
	category = REPLICATOR_UPGRADE_CATEGORY_SUPPORT


/datum/replicator_array_upgrade/support/efficiency
	name = "Efficiency"
	desc = "Manipulator upgrade speeds up disintegration speed."

	icon_state = "upgrade_efficiency"

/datum/replicator_array_upgrade/support/efficiency/add_to_unit(mob/living/simple_animal/hostile/replicator/R, just_spawned)
	R.efficency += 0.4

/datum/replicator_array_upgrade/support/efficiency/remove_from_unit(mob/living/simple_animal/hostile/replicator/R)
	R.efficency -= 0.4
