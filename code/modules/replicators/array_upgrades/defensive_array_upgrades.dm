/datum/replicator_array_upgrade/defensive
	category = REPLICATOR_UPGRADE_CATEGORY_DEFENSIVE


/datum/replicator_array_upgrade/defensive/max_health_points
	name = "Integrity"
	desc = "Growing out plates increases structural integrity."

	icon_state = "upgrade_max_health"

/datum/replicator_array_upgrade/defensive/max_health_points/add_to_unit(mob/living/simple_animal/hostile/replicator/R, just_spawned)
	R.maxHealth += 20
	if(just_spawned)
		R.health = R.maxHealth

/datum/replicator_array_upgrade/defensive/max_health_points/remove_from_unit(mob/living/simple_animal/hostile/replicator/R)
	R.maxHealth -= 20
	R.health = min(R.health, R.maxHealth)
