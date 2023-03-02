/datum/replicator_array_upgrade/support
	category = REPLICATOR_UPGRADE_CATEGORY_SUPPORT


/datum/replicator_array_upgrade/support/efficency
	name = "Efficency"
	desc = "Manipulator upgrade speeds up disintegration speed."

	icon_state = "upgrade_efficency"

/datum/replicator_array_upgrade/support/efficency/add_to_unit(mob/living/simple_animal/hostile/replicator/R)
	R.efficency += 0.5

/datum/replicator_array_upgrade/support/efficency/remove_from_unit(mob/living/simple_animal/hostile/replicator/R)
	R.efficency -= 0.5
