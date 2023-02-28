/datum/replicator_array_upgrade/defensive
	category = REPLICATOR_UPGRADE_CATEGORY_DEFENSIVE


/datum/replicator_array_upgrade/defensive/max_health_points
	name = "Integriy"
	desc = "Growing out plates increases structural integrity."

	icon_state = "upgrade_max_health"

/datum/replicator_array_upgrade/defensive/max_health_points/add_to_unit(mob/living/simple_animal/replicator/R)
	R.maxHealth += 30

/datum/replicator_array_upgrade/defensive/max_health_points/remove_from_unit(mob/living/simple_animal/replicator/R)
	R.maxHealth -= 30
	R.health = min(R.health, R.maxHealth)
