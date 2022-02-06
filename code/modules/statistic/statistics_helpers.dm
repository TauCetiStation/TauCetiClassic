// the main file for statistics is statcollection.dm, look there first

// generate simple body for the stat datum
// does not support naming arguments
#define STAT_ADD_PROC(STAT_DATUM, TO_LIST, arguments...) \
/datum/stat_collector/proc/add_to_##TO_LIST(##arguments){\
	var##STAT_DATUM/stat = new;\
	var/list/stat_vars = stat.vars.Copy() - ROOT_DATUM_VARS;\
	if(stat_vars.len != args.len) {\
		CRASH("The number of arguments passed ([args.len]) is not equal to the number of variables ([stat_vars.len]) declared in the ([##STAT_DATUM])");\
	}\
	for(var/i in 1 to args.len) {\
		stat.vars[stat_vars[i]] = args[i];\
	}\
	TO_LIST += stat;\
}

// remove this shit and add normal copypaste
STAT_ADD_PROC(/datum/stat/antagonists_completion, completion_antagonists,
	faction,\
	role,\
	html)

STAT_ADD_PROC(/datum/stat/centcomm_communication, centcomm_communications)
/proc/add_communication_log(type, title, author, content, time = roundduration2text())
	SSStatistics.add_to_centcomm_communications(type, title, author, time, content)

STAT_ADD_PROC(/datum/stat/achievement, achievements)



/*
/datum/stat_collector/proc/get_research_score()
	var/obj/machinery/r_n_d/server/server = null
	var/tech_level_total
	for(var/obj/machinery/r_n_d/server/serber in machines)
		if(serber.name == "Core R&D Server")
			server=serber
			break
	if(!server)
		return
	for(var/ID in tech_list)
		var/datum/tech/T = tech_list[ID]
		if(T.goal_level==0) // Ignore illegal tech, etc
			continue
		var/datum/tech/KT = server.files.GetKTechByID(ID)
		tech_level_total += KT.level
	return tech_level_total

/datum/stat_collector/proc/add_explosion_stat(turf/epicenter, const/dev_range, const/hi_range, const/li_range)
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return

	var/datum/stat/explosion_stat/e = new
	e.epicenter_x = epicenter.x
	e.epicenter_y = epicenter.y
	e.epicenter_z = epicenter.z
	e.devastation_range = dev_range
	e.heavy_impact_range = hi_range
	e.light_impact_range = li_range
	explosions.Add(e)

/datum/stat_collector/proc/add_death_stat(mob/living/M)
	//if(M.iscorpse) return 0 // only ever 1 if they are a corpse landmark spawned mob
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING) return 0 // We don't care about pre-round or post-round deaths.
	if(!istype(M, /mob/living))
		return 0

	var/datum/stat/death_stat/d = new
	d.time_of_death = M.timeofdeath

	var/turf/spot = get_turf(M)
	d.death_x = spot.x
	d.death_y = spot.y
	d.death_z = spot.z

	d.mob_typepath = M.type
	d.mind_name = M.name

	d.damage["BRUTE"] = M.bruteloss
	d.damage["FIRE"]  = M.fireloss
	d.damage["TOXIN"] = M.toxloss
	d.damage["OXY"]   = M.oxyloss
	d.damage["CLONE"] = M.cloneloss
	d.damage["BRAIN"] = M.brainloss

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			d.assigned_role = M.mind.assigned_role
		// if(M.mind.special_role && M.mind.special_role != "")
		// 	d.special_role = M.mind.special_role
		if(M.mind.key)
			d.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			d.mind_name = M.mind.name
		d.from_suicide = M.suiciding
	deaths.Add(d)

/datum/stat_collector/proc/add_survivor_stat(mob/living/M)
	if(!istype(M, /mob/living)) return 0

	var/datum/stat/survivor/s = new
	s.mob_typepath = M.type
	s.mind_name = M.name

	var/turf/spot = get_turf(M)
	s.loc_x = spot.x
	s.loc_y = spot.y
	s.loc_z = spot.z

	s.damage["BRUTE"] = M.bruteloss
	s.damage["FIRE"]  = M.fireloss
	s.damage["TOXIN"] = M.toxloss
	s.damage["OXY"]   = M.oxyloss
	s.damage["CLONE"] = M.cloneloss
	s.damage["BRAIN"] = M.brainloss

	if(istype(M, /mob/living/silicon/robot))
		borgs_at_round_end++
	// how the scoreboard checked for escape-ness:
	// if(istype(T.loc, /area/shuttle/escape/centcom) || istype(T.loc, /area/shuttle/escape_pod1/centcom) || istype(T.loc, /area/shuttle/escape_pod2/centcom) || istype(T.loc, /area/shuttle/escape_pod3/centcom) || istype(T.loc, /area/shuttle/escape_pod5/centcom))
	// luckily this works for us:
	if(is_centcom_level(M.z))
		s.escaped = TRUE // not all survivors escape, and not all rounds end with the shuttle

	if(M.mind)
		if(M.mind.assigned_role && M.mind.assigned_role != "")
			s.assigned_role = M.mind.assigned_role
			if(M.mind.assigned_role in command_positions)
				heads_at_round_end++
		if(M.mind.special_role && M.mind.special_role != "")
			s.special_role = M.mind.special_role
		if(M.mind.key)
			s.key = ckey(M.mind.key) // To prevent newlines in keys
		if(M.mind.name)
			s.mind_name = STRIP_NEWLINE(M.mind.name)
	survivors.Add(s)

/datum/stat_collector/proc/uplink_purchase(datum/uplink_item/bundle, obj/resulting_item, mob/user )
	var/was_traitor = TRUE
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return

	// if(user.mind && user.mind.special_role != "traitor")
	// 	was_traitor = FALSE

	if(istype(bundle, /datum/uplink_item/badass/bundle))
		var/datum/stat/uplink_badass_bundle_stat/BAD = new
		var/obj/item/weapon/storage/box/B = resulting_item
		for(var/obj/O in B.contents)
			BAD.contains.Add(O.type)
		BAD.purchaser_key = ckey(user.mind.key)
		BAD.purchaser_name = STRIP_NEWLINE(user.mind.name)
		BAD.purchaser_is_traitor = was_traitor
		badass_bundles.Add(BAD)
	else
		var/datum/stat/uplink_purchase_stat/PUR = new
		if(istype(bundle, /datum/uplink_item/badass/random))
			PUR.itemtype = resulting_item.type
		else
			PUR.itemtype = bundle.item
		PUR.bundle = bundle.type
		PUR.purchaser_key = ckey(user.mind.key)
		PUR.purchaser_name = STRIP_NEWLINE(user.mind.name)
		PUR.purchaser_is_traitor = was_traitor
		uplink_purchases.Add(PUR)

/*
/datum/stat_collector/proc/add_role(datum/role/R)
	R.stat_datum.generate_statistics(R)
	roles.Add(R.stat_datum)

/datum/stat_collector/proc/add_faction(datum/faction/F)
	F.stat_datum.generate_statistics(F)
	factions.Add(F.stat_datum)
*/
*/