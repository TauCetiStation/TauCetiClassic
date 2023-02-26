/datum/spawner/living/replicator
	name = "Репликатор"
	id = "replicator"
	desc = "Стань частью пожирающего Роя!"
	wiki_ref = "Replicator"

/datum/spawner/living/replicator/can_spawn(mob/dead/observer/ghost)
	// TO-DO: check if guy is banned from Replicators.
	return ..()
