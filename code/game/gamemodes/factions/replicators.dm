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

	var/swarm_gift_duration = 5 MINUTES
	var/spawned_at_time = 0

	var/list/vents4spawn

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
	AppendObjective(/datum/objective/reproduct)
	return TRUE

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

/datum/faction/replicators/proc/announce_swarm(presence_name, presence_ckey, message, atom/announcer=null)
	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		var/open_tags = ""
		var/close_tags = ""

		if(swarms_goodwill[presence_ckey] && swarms_goodwill[max_goodwill_ckey])
			var/goodwill_coeff = swarms_goodwill[presence_ckey] / swarms_goodwill[max_goodwill_ckey]
			var/goodwill_font_size = max(round(goodwill_coeff * 4), 1)
			if(presence_ckey == max_goodwill_ckey)
				open_tags += "<font size='[goodwill_font_size]'>"
				close_tags += "</font>"

		var/message_open_tags = "<span class='message'><span class='replicator'>"
		var/message_close_tags = "</span></span>"

		if(announcer && get_dist(announcer, R.antag.current) < 7)
			message_open_tags += "<b>"
			message_close_tags = "</b>[message_close_tags]"

		var/channel = "<span class='replicator'>\[???\]</span>"
		var/speaker_name = "<b>[presence_name]</b>"

		to_chat(R.antag, "[open_tags][channel][speaker_name] announces, [message_open_tags]\"[message]\"[message_close_tags][close_tags]")

/datum/faction/replicators/proc/drone_message(mob/living/simple_animal/replicator/drone, message, transfer=FALSE, dismantle=FALSE)
	for(var/r in members)
		var/datum/role/replicator/R = r
		if(!R.antag)
			continue
		var/jump_button = transfer ? "<a href='?src=\ref[R.antag.current];replicator_jump=\ref[drone]'>(JMP)</a>" : ""
		var/dismantle_button = dismantle ? "<a href='?src=\ref[R.antag.current];replicator_kill=\ref[drone]'>(KILL)</a>" : ""
		to_chat(R.antag, "<span class='replicator'>\[???\]</span> <b>[drone.name]</b> requests, <span class='message'><span class='replicator'>\"[message]\"</span></span>[jump_button][dismantle_button]")

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

	var/new_name = greek_pronunciation[length(ckey2presence_name)] + "-[rand(0, 9)] Presence"

	ckey2presence_name[ckey] = new_name
	return ckey2presence_name[ckey]

/datum/faction/replicators/proc/give_gift(mob/living/simple_animal/replicator/R)
	if(spawned_at_time + swarm_gift_duration < world.time)
		return

	R.apply_status_effect(STATUS_EFFECT_SWARM_GIFT, spawned_at_time + swarm_gift_duration - world.time)
