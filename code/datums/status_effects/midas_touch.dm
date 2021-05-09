// Midas Touch -- humans that died under this status effect will turn into golden statues

/datum/status_effect/midas
	id = "midas"
	tick_interval = 20
	status_type = STATUS_EFFECT_REFRESH
	duration = 100

/datum/status_effect/midas/on_apply()
	if(owner.stat == DEAD || (GOLDEN in owner.mutations))
		return FALSE
	return ..()

/datum/status_effect/midas/tick()
	if(owner.stat == DEAD)
		if(GOLDEN in owner.mutations)
			owner.remove_status_effect(src)
			return
		owner.mutations.Add(GOLDEN)
	..()