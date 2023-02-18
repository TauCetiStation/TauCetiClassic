var/global/datum/faction/replicators/replicators_faction

/datum/faction/replicators
	name = F_REPLICATORS
	ID = F_REPLICATORS
	required_pref = ROLE_REPLICATOR

	min_roles = 3

	initroletype = /datum/role/replicator

	logo_state = "replicators"

	var/materials = 0
	var/next_materials_update = 0
	var/this_second_materials_change = 0
	var/last_second_materials_change  = 0
	// The Swarm consumes materials if there's enough for at least one drone. Consumed materials increase bandwidth.
	var/materials_consumed = 0
	var/consumed_materials_until_upgrade = REPLICATOR_COST_REPLICATE

	var/compute = 0

	// Max amount of available drones.
	var/bandwidth = 6
	// Can't go any further.
	var/max_bandwidth = 50

	var/list/swarms_goodwill = list(
	)

	var/list/presence_names = list()

	var/swarm_gift_duration = 5 MINUTES
	var/spawned_at_time = 0

/datum/faction/replicators/New()
	..()
	spawned_at_time = world.time

/datum/faction/replicators/process()
	. = ..()

	if(next_materials_update < world.time)
		last_second_materials_change = this_second_materials_change
		this_second_materials_change = 0
		next_materials_update = world.time + 1 SECOND

	if(bandwidth >= max_bandwidth)
		return

	if(materials > REPLICATOR_COST_REPLICATE + length(global.active_transponders))
		materials -= length(global.active_transponders)
		materials_consumed += length(global.active_transponders)

	if(materials_consumed > consumed_materials_until_upgrade)
		materials_consumed = 0
		consumed_materials_until_upgrade += REPLICATOR_COST_REPLICATE
		announce_swarm("The Swarm", "The Swarm", "Ample materials consumed. Bandwidth increased.")
		bandwidth++

/datum/faction/replicators/proc/announce_swarm(presence_name, presence_ckey, message)
	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		to_chat(R.antag, "[presence_name] says, \"[message]\"")

/datum/faction/replicators/proc/adjust_materials(material_amount, adjusted_by=null)
	materials += material_amount
	this_second_materials_change += material_amount
	// give Swarm's Goodwill to the one donated. Goodwill increases font size to enforce leadership.
	if(adjusted_by != null)
		if(!swarms_goodwill[adjusted_by])
			swarms_goodwill[adjusted_by] = 0
		swarms_goodwill[adjusted_by] += material_amount

/datum/faction/replicators/proc/adjust_compute(compute_amount, adjusted_by=null)
	compute += compute_amount

/datum/faction/replicators/proc/get_presence_name(ckey)
	if(presence_names[ckey])
		return presence_names[ckey]

	presence_names[ckey] = pick(list("Alpha", "Beta", "Gamma", "Delta")) + "-[rand(0, 9)]"
	return presence_names[ckey]

/datum/faction/replicators/proc/give_gift(mob/living/simple_animal/replicator/R)
	if(spawned_at_time + swarm_gift_duration < world.time)
		return

	R.apply_status_effect(STATUS_EFFECT_SWARM_GIFT, spawned_at_time + swarm_gift_duration - world.time)
