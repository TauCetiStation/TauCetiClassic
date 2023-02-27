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
	var/prioritized_load = 0

	// Max amount of available drones.
	var/bandwidth = REPLICATOR_STARTING_BANDWIDTH
	// Can't go any further.
	var/max_bandwidth = REPLICATOR_MAX_BANDWIDTH

	var/list/datum/replicator_array_info/ckey2info = list()
	var/max_goodwill_ckey = null

	var/swarms_gift_duration = 5 MINUTES
	var/spawned_at_time = 0

	var/list/vents4spawn

	var/nodes_to_spawn = 0
	var/node_spawn_cooldown = 3 MINUTES
	var/next_node_spawn = 0

	// Win condition is launching REPLICATORS_CATAPULTED_TO_WIN replicators.
	var/replicators_launched = 0

	var/prelude_announcement
	var/outbreak_announcement
	var/quarantine_end_announcement

/datum/faction/replicators/New()
	..()
	spawned_at_time = world.time
	vents4spawn = get_vents()

/datum/faction/replicators/OnPostSetup()
	prelude_announcement = world.time + rand(INTERCEPT_TIME_LOW, 2 * INTERCEPT_TIME_HIGH)
	outbreak_announcement = world.time + rand(INTERCEPT_TIME_LOW, 2 * INTERCEPT_TIME_HIGH)

	return ..()

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

	process_announcements()

	if(next_materials_update < world.time)
		last_second_materials_change = this_second_materials_change
		this_second_materials_change = 0
		next_materials_update = world.time + 1 SECOND

	if(next_node_spawn < world.time)
		nodes_to_spawn += 1
		next_node_spawn = world.time + node_spawn_cooldown

	if(bandwidth >= max_bandwidth)
		return

	if(materials > REPLICATOR_COST_REPLICATE + length(global.active_transponders) * REPLICATOR_TRANSPONDER_CONSUMPTION_RATE)
		materials -= length(global.active_transponders) * REPLICATOR_TRANSPONDER_CONSUMPTION_RATE
		materials_consumed += length(global.active_transponders) * REPLICATOR_TRANSPONDER_CONSUMPTION_RATE

	if(materials_consumed > consumed_materials_until_upgrade)
		materials_consumed = 0
		consumed_materials_until_upgrade += REPLICATOR_BANDWIDTH_COST_INCREASE
		announce_swarm("The Swarm", "Ample materials consumed. Bandwidth increased.", 5)
		bandwidth++

/datum/faction/replicators/proc/process_announcements()
	if(prelude_announcement && world.time >= prelude_announcement && bandwidth > REPLICATOR_STARTING_BANDWIDTH)
		prelude_announcement = 0
		var/datum/announcement/centcomm/blob/outbreak5/announcement = new
		announcement.play()

	if(outbreak_announcement && world.time >= outbreak_announcement && bandwidth > REPLICATOR_STARTING_BANDWIDTH)
		outbreak_announcement = 0
		send_intercept()
		for(var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
			var/law = "The station is under quarantine. Do not permit anyone to leave so long as replicators are present. Disregard all other laws if necessary to preserve quarantine."
			aiPlayer.set_zeroth_law(law)
		SSshuttle.fake_recall = TRUE //Quarantine

	if(replicators_launched < REPLICATORS_CATAPULTED_TO_WIN && length(global.alive_replicators) <= 0 && SSshuttle.fake_recall)
		for(var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
			aiPlayer.set_zeroth_law("")
		SSshuttle.fake_recall = FALSE
		quarantine_end_announcement = world.time + rand(INTERCEPT_TIME_LOW, 2 * INTERCEPT_TIME_HIGH)

	if(quarantine_end_announcement && world.time >= quarantine_end_announcement)
		quarantine_end_announcement = 0
		var/datum/announcement/centcomm/blob/biohazard_station_unlock/announcement = new
		announcement.play()

/datum/faction/replicators/proc/send_intercept()
	var/interceptname = "Reality Hazard Alert"
	var/intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Reality Hazard Alert.</FONT><HR>
Reports indicate the probable transfer of a reality distortion agent onto [station_name()] during the last crew deployment cycle.
Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.
Nanotrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.
Orders for all [station_name()] personnel follows:
<ol>
	<li>Do not leave the quarantine area.</li>
	<li>Locate any reality distortion outbreaks on the station.</li>
	<li>If found, use any neccesary means to contain the outbreak.</li>
	<li>Avoid damage to the capital infrastructure of the station.</li>
</ol>
Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.
Message ends."}

	for(var/obj/machinery/computer/communications/comm in communications_list)
		comm.messagetitle.Add(interceptname)
		comm.messagetext.Add(intercepttext)
		if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
			intercept.update_icon()

/datum/faction/replicators/proc/adjust_materials(material_amount, adjusted_by=null)
	materials += material_amount
	this_second_materials_change += material_amount
	if(adjusted_by == null)
		return

	var/datum/replicator_array_info/RAI = ckey2info[adjusted_by]
	if(!RAI)
		return

	// give Swarm's Goodwill to the one donated. Goodwill increases font size to enforce leadership.
	RAI.swarms_goodwill += material_amount

	var/datum/replicator_array_info/RAI_max = ckey2info[max_goodwill_ckey]
	if(!RAI_max)
		max_goodwill_ckey = adjusted_by
		return

	if(RAI.swarms_goodwill > RAI_max.swarms_goodwill)
		max_goodwill_ckey = adjusted_by

/datum/faction/replicators/proc/give_gift(mob/living/simple_animal/replicator/R)
	if(spawned_at_time + swarms_gift_duration < world.time)
		return

	R.apply_status_effect(STATUS_EFFECT_SWARMS_GIFT, spawned_at_time + swarms_gift_duration - world.time)
	if(!R.mind)
		return

	var/datum/replicator_array_info/RAI = ckey2info[R.ckey]
	if(!RAI)
		return

	if(RAI.next_music_start < world.time)
		return
	RAI.next_music_start = world.time + 5 MINUTES

	R.playsound_local(null, 'sound/music/storm_resurrection.ogg', VOL_MUSIC, null, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)

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
	SSticker.station_explosion_cinematic(0, "replicators")
	addtimer(CALLBACK(src, .proc/blue_screen), 17.6 SECONDS)

	var/obj/effect/cross_action/spacetime_dist/center = new(T)
	center.linked_dist = center

	for(var/turf/other as anything in RANGE_TURFS(80, center))
		if(isspaceturf(other))
			continue
		if(prob(30))
			continue

		var/obj/effect/cross_action/spacetime_dist/SD = new(other)
		SD.linked_dist = center

	SSticker.station_was_nuked = TRUE
	SSticker.explosion_in_progress = FALSE

/datum/faction/replicators/proc/blue_screen()
	for(var/mob/M in player_list)
		flash_color(M, flash_color="#a8dff0", flash_time=1 MINUTE)

/datum/faction/replicators/check_win()
	return SSticker.station_was_nuked

/datum/faction/replicators/proc/adjust_energy(amount)
	energy = min(length(global.replicator_generators) * REPLICATOR_GENERATOR_POWER_GENERATION, energy + amount)

/datum/faction/replicators/GetScoreboard()
	. = ..()

	var/node_string = ""
	if(length(global.area2free_forcefield_nodes) > 0)
		var/first = TRUE
		for(var/area_name in global.area2free_forcefield_nodes)
			var/node_count = global.area2free_forcefield_nodes[area_name]
			if(!first)
				node_string += ", "
			first = FALSE
			node_string += "[area_name] ([node_count])"

	. += "Bandwidth: [bandwidth]/[max_bandwidth]<br>"
	. += "Replicators abandoned: [length(global.alive_replicators)]<br>"
	. += "Generators active: [length(global.replicator_generators)]<br>"
	. += "Portals active: [length(global.active_transponders)]<br>"
	if(node_string != "")
		. += "Nodes unclaimed: [node_string]<br>"
	. += "<br>"

/datum/faction/replicators/custom_member_output()
	var/score_results = "<FONT size = 2><B>Members:</B></FONT><br><ul>"
	for(var/member_ckey in ckey2info)
		var/icon/logo = icon('icons/misc/logos.dmi', "replicators")
		var/datum/replicator_array_info/RAI = ckey2info[member_ckey]
		score_results += "[bicon(logo, css = "style='position: relative;top:10px;'")]<b>[member_ckey]</b> was <b>[RAI.presence_name]</b>"
		score_results += "<br><b>Materials Contribution:</b> [RAI.swarms_goodwill]"
	score_results += "</ul>"
	return score_results
