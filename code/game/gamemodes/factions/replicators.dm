var/global/datum/faction/replicators/replicators_faction

/datum/faction/replicators
	name = F_REPLICATORS
	ID = F_REPLICATORS
	required_pref = ROLE_REPLICATOR

	min_roles = 1
	max_roles = 3

	initroletype = /datum/role/replicator

	logo_state = "replicators"

	var/materials = 0
	var/next_materials_update = 0
	var/this_second_materials_change = 0
	var/last_second_materials_change  = 0
	// The Swarm consumes materials if there's enough for at least one drone. Consumed materials increase bandwidth.
	var/materials_consumed = 0
	var/consumed_materials_until_upgrade = REPLICATOR_COST_REPLICATE

	// Energy in posession of the swarm. Used as backup power if can't steal from station.
	var/energy = 0

	var/compute = 0

	// Max amount of available drones.
	var/bandwidth = 6
	// Can't go any further.
	var/max_bandwidth = 50

	var/max_goodwill_ckey = null

	var/list/swarms_goodwill = list(
	)

	var/list/ckey2presence_name = list()

	var/swarms_gift_duration = 5 MINUTES
	var/spawned_at_time = 0

	var/list/vents4spawn

	var/nodes_to_spawn = 0
	var/node_spawn_cooldown = 3 MINUTES
	var/next_node_spawn = 0

	// Win condition is launching 10 replicators.
	var/replicators_launched = 0

/datum/faction/replicators/New()
	..()
	spawned_at_time = world.time
	vents4spawn = get_vents()

/datum/faction/replicators/can_setup(num_players)
	max_roles = max(1, round(num_players / 20))

	if(length(vents4spawn) > 0)
		return TRUE

	return TRUE

/datum/faction/replicators/OnPostSetup()
	var/list/pos_vents = vents4spawn.Copy()
	for(var/datum/role/role in members)
		var/mob/living/simple_animal/replicator/R
		var/V = pick_n_take(vents4spawn)

		if(length(vents4spawn) > 0)
			V = pick_n_take(vents4spawn)
		else
			V = pick(pos_vents)

		R = new(V)
		R.add_ventcrawl(V)

		role.antag.transfer_to(R)
		// I can not imagine why this is required but everyone else does this :shrug:
		QDEL_NULL(role.antag.original)

	vents4spawn = null

	return ..()

/datum/faction/replicators/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/replicator_replicate)
	return TRUE

/datum/faction/replicators/process()
	. = ..()

	if(next_materials_update < world.time)
		last_second_materials_change = this_second_materials_change
		this_second_materials_change = 0
		next_materials_update = world.time + 1 SECOND

	if(next_node_spawn < world.time)
		nodes_to_spawn += 1
		next_node_spawn = world.time + node_spawn_cooldown

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

/datum/faction/replicators/proc/adjust_materials(material_amount, adjusted_by=null)
	materials += material_amount
	this_second_materials_change += material_amount
	if(adjusted_by == null)
		return

	// give Swarm's Goodwill to the one donated. Goodwill increases font size to enforce leadership.
	if(!swarms_goodwill[adjusted_by])
		swarms_goodwill[adjusted_by] = 0
	swarms_goodwill[adjusted_by] += material_amount

	if(swarms_goodwill[adjusted_by] > swarms_goodwill[max_goodwill_ckey])
		max_goodwill_ckey = adjusted_by

/datum/faction/replicators/proc/adjust_compute(compute_amount, adjusted_by=null)
	compute += compute_amount

/datum/faction/replicators/proc/get_presence_name(ckey)
	if(ckey2presence_name[ckey])
		return ckey2presence_name[ckey]

	var/new_name = greek_pronunciation[length(ckey2presence_name) + 1] + "-[rand(0, 9)] Presence"

	ckey2presence_name[ckey] = new_name
	return ckey2presence_name[ckey]

/datum/faction/replicators/proc/give_gift(mob/living/simple_animal/replicator/R)
	if(spawned_at_time + swarms_gift_duration < world.time)
		return

	R.apply_status_effect(STATUS_EFFECT_SWARMS_GIFT, spawned_at_time + swarms_gift_duration - world.time)
	// Scale volume with amount of drones?
	R.playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)

/datum/faction/replicators/proc/victory_animation(turf/T)
	SSticker.explosion_in_progress = TRUE
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/AI/DeltaBOOM.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)

	to_chat(world, "Reality warp imminent in 10")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "[i]")

	sleep(10)
	enter_allowed = FALSE
	SSticker.station_explosion_cinematic(0, null)
	addtimer(CALLBACK(src, .proc/blue_screen), 17.6 SECONDS)

	var/obj/effect/cross_action/spacetime_dist/center = new(T)
	center.linked_dist = center

	for(var/turf/other as anything in RANGE_TURFS(80, center))
		if(isspaceturf(other))
			continue

		var/obj/effect/cross_action/spacetime_dist/SD = new(other)
		SD.linked_dist = center

	SSticker.station_was_nuked = TRUE
	SSticker.explosion_in_progress = FALSE

/datum/faction/replicators/proc/blue_screen()
	for(var/mob/M in player_list)
		flash_color(M, flash_color="#A8DFF0", flash_time=1 MINUTE)

/datum/faction/replicators/check_win()
	return SSticker.station_was_nuked
