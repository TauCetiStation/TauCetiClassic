/datum/replicator_array_upgrade/support
	category = REPLICATOR_UPGRADE_CATEGORY_SUPPORT


/datum/replicator_array_upgrade/support/efficency
	name = "Efficency"
	desc = "Manipulator upgrade speeds up disintegration speed."

/datum/replicator_array_upgrade/support/efficency/add_to_unit(mob/living/simple_animal/replicator/R)
	R.efficency += 0.2

/datum/replicator_array_upgrade/support/efficency/remove_from_unit(mob/living/simple_animal/replicator/R)
	R.efficency -= 0.2
