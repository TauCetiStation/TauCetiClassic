// Consume Fractol to regenerate.
/datum/component/replicator_regeneration

/datum/component/replicator_regeneration/Initialize(datum/callback/get_damage, datum/callback/regenerate)
	START_PROCESSING(SSobj, src)

/datum/component/replicator_regeneration/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/replicator_regeneration/proc/get_damage()
	if(isreplicator(parent))
		var/mob/living/simple_animal/hostile/replicator/R = parent
		if(R.stat == DEAD)
			return 0

		return R.maxHealth - R.health

	var/obj/O = parent
	return O.max_integrity - O.get_integrity()

/datum/component/replicator_regeneration/proc/regenerate(amount)
	if(isreplicator(parent))
		var/mob/living/simple_animal/hostile/replicator/R = parent
		R.last_disintegration = world.time
		R.heal_bodypart_damage(amount, 0.0)
		return

	var/obj/O = parent
	O.repair_damage(amount)

/datum/component/replicator_regeneration/proc/regen_from_swarm(repair_amount)
	var/atom/source = parent
	var/atom/source_loc = source.loc
	if(!(locate(/obj/structure/bluespace_corridor) in source_loc))
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	repair_amount = min(repair_amount, FR.gas)
	if(repair_amount <= 0)
		return
	FR.adjust_fractol(-repair_amount)
	regenerate(repair_amount)

/datum/component/replicator_regeneration/process()
	var/repair_amount = min(REPLICATOR_REGEN_PER_TICK, get_damage())
	if(repair_amount <= 0)
		return

	var/atom/source = parent
	var/atom/source_loc = source.loc
	if(!source_loc)
		return

	var/datum/gas_mixture/environment = source_loc.return_air()
	if(!environment)
		regen_from_swarm(repair_amount)
		return

	if(environment.get_gas("fractol") < REPLICATOR_GAS_HEAL_MINIMUM)
		regen_from_swarm(repair_amount)
		return

	repair_amount = min(repair_amount, environment.get_gas("fractol"))
	if(repair_amount < REPLICATOR_GAS_HEAL_MINIMUM)
		return

	environment.adjust_gas("fractol", -repair_amount / REPLICATOR_GAS_HEAL_PER_MOLE)

	regenerate(repair_amount)
