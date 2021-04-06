/*
	Gamemode datums
		Used for co-ordinating factions in a round, what factions should be in operation, etc.
	@name: String: The name of the gamemode, e.g. Changelings
	@factions: List(reference): What factions are currently in operation in the gamemode
	@factions_allowed: List(object): what factions will the gamemode start with, or attempt to start with
	@minimum_player_count: Integer: Minimum required players to start the gamemode
	@minimum_players_bundles: Integer: Minimum number of players for that game mode to be chose in Secret|BS12|TauClassic
	@roles_allowed: List(object): What roles will the gamemode start with, or attempt to start with
	@probability: Integer: How likely it is to roll this gamemode
	@orphaned_roles: List(reference): List of faction-less roles currently in the gamemode
*/

/datum/game_mode
	var/name
	var/list/factions_allowed = list()
	var/list/roles_allowed = list()
	var/minimum_player_count
	var/minimum_players_bundles
	var/probability = 1

	var/newscaster_announcements = null

	var/completition_text = ""

	var/list/factions = list()
	var/list/orphaned_roles = list()

// !!! DEBUG CODE !!!
/datum/game_mode/New()
	minimum_player_count = 0
	minimum_players_bundles = 0

/datum/game_mode/proc/announce()
	return

/datum/game_mode/proc/get_player_count(check_ready = TRUE)
	var/players = 0
	for(var/mob/dead/new_player/P in new_player_list)
		if(P.client && (!check_ready || P.ready))
			players++

	return players

/datum/game_mode/proc/get_ready_players(check_ready = TRUE)
	var/list/players = list()
	for(var/mob/dead/new_player/P in player_list)
		if(P.client && (!check_ready || P.ready))
			players.Add(P)

	return players

// !!! DEBUG CODE !!!
/datum/game_mode/proc/can_start(check_ready = TRUE)
	if(minimum_player_count == 0 && get_ready_players(check_ready))
		to_chat(world, "if(minimum_player_count == 0 && get_ready_players(check_ready))")
		return TRUE
	if(get_player_count(check_ready) < minimum_player_count)
		to_chat(world, "if(get_player_count(check_ready) < minimum_player_count)")
		return FALSE
	if(config.is_bundle_by_name(master_mode) && get_player_count(check_ready) <= minimum_players_bundles)
		to_chat(world, "if(config.is_bundle_by_name(master_mode) &")
		return FALSE
	if(!CanPopulateFaction(check_ready))
		to_chat(world, "f(!CanPopulateFaction(check_ready))")
		return FALSE
	return TRUE

/datum/game_mode/proc/potential_runnable()
	if(!can_start(FALSE))
		return FALSE
	return TRUE

//For when you need to set factions and factions_allowed not on compile
/datum/game_mode/proc/SetupFactions()
	return

// Infos on the mode.
/datum/game_mode/proc/AdminPanelEntry()
	return

/datum/game_mode/proc/Setup()
	if(!can_start(TRUE))
		return FALSE
	SetupFactions()
	var/FactionSuccess = CreateFactions()
	var/RolesSuccess = CreateRoles()
	to_chat(world, "[FactionSuccess] - [RolesSuccess]")
	return FactionSuccess && RolesSuccess

//1 = station, 2 = centcomm
/datum/game_mode/proc/ShuttleDocked(state)
	for(var/datum/faction/F in factions)
		F.ShuttleDocked(state)
	for(var/datum/role/R in orphaned_roles)
		R.ShuttleDocked(state)

/*===FACTION RELATED STUFF===*/

/datum/game_mode/proc/CreateFactions(list/factions_to_process, populate_factions = TRUE)
	if(factions_to_process == null)
		factions_to_process = factions_allowed
	var/pc = get_player_count()
	for(var/Fac in factions_to_process)
		if(islist(Fac))
			var/list/L = Fac
			CreateFactions(L, FALSE)
		else if(isnum(factions_allowed[Fac]))
			for(var/i in 1 to factions_allowed[Fac])
				CreateFaction(Fac, pc)
		else
			CreateFaction(Fac, pc)
	if(populate_factions)
		return PopulateFactions()

/datum/game_mode/proc/CreateFaction(Fac, population, override = 0)
	var/datum/faction/F = new Fac
	if(F.can_setup(population) || override)
		factions += F
		return F
	else
		log_mode("Faction ([F]) could not set up properly with given population.")
		qdel(F)
		return null
/*
	Get list of available players
	Get list of active factions
	Loop through the players to see if they're available for certain factions
		Not available if they
			don't have their preferences set accordingly
			already in another faction
*/

/datum/game_mode/proc/CanPopulateFaction(check_ready = TRUE)
	var/list/L = get_ready_players(check_ready)
	for(var/type in factions_allowed)
		var/datum/faction/F = new type()
		var/can_be = L.len
		for(var/mob/M in L)
			if(!F.can_join_faction(M))
				can_be--
		// !!! DEBUG CODE !!!
		to_chat(world, "[F.type] - [can_be] - [F.min_roles]")
		if(can_be < F.min_roles)
			return FALSE
		qdel(F)
	// !!! DEBUG CODE !!!
	to_chat(world, "ok")
	return TRUE

// !!! DEBUG CODE !!!
/datum/game_mode/proc/PopulateFactions()
	if(!factions.len)
		message_admins("No faction was created in [type].")
		log_mode("No faction was created in [type].")
		return FALSE
	var/list/available_players = get_ready_players()
	for(var/datum/faction/F in factions)
		for(var/mob/dead/new_player/P in available_players)
			to_chat(world, "P - [P]")
			if(F.max_roles && F.members.len >= F.max_roles)
				to_chat(world, "f(F.max_roles && F.members.len >= F.max_roles)")
				break
			if(!F.can_join_faction(P))
				to_chat(world, "f(!F.can_join_faction(P))ax_roles)")
				continue
			if(!F.HandleNewMind(P.mind))
				to_chat(world, "if(!F.HandleNewMind(P.mind)) - [P] - [F]")
				log_mode("[P] failed [F] HandleNewMind!")
				continue
		if(F.members.len < F.min_roles)
			to_chat(world, "if(F.members.len < F.min_roles)oles)")
			return FALSE
	return TRUE

/*=====ROLE RELATED STUFF=====*/

/datum/game_mode/proc/CreateRoles() //Must return TRUE in some way, else the gamemode is scrapped.
	if(!roles_allowed.len) //No roles to handle
		return TRUE
	for(var/role in roles_allowed)
		if(isnum(roles_allowed[role]))
			return CreateStrictNumOfRoles(role, roles_allowed[role])
		else
			CreateNumOfRoles(role, FilterAvailablePlayers(role))
			return TRUE

/datum/game_mode/proc/CreateNumOfRoles(role_type, list/candidates)
	if(!candidates || !candidates.len)
		log_mode("Ran out of available players to fill role [role_type]!")
		return
	for(var/mob/M in candidates)
		CreateRole(role_type, M)

/datum/game_mode/proc/CreateStrictNumOfRoles(role_type, num)
	var/number_of_roles = 0
	var/list/available_players = FilterAvailablePlayers(role_type)
	for(var/i = 0 to num)
		if(!available_players.len)
			log_mode("Ran out of available players to fill role [role_type]!")
			break
		shuffle(available_players)
		var/mob/dead/new_player/P = pick(available_players)
		available_players.Remove(P)
		if(!CreateRole(role_type, P))
			i--
			continue
		number_of_roles++ // Get the roles we created
	return number_of_roles


/datum/game_mode/proc/CreateBasicRole(type_role)
	return new type_role

/datum/game_mode/proc/FilterAvailablePlayers(datum/role/role_type, list/players_to_choose = get_ready_players())
	var/pref = initial(role_type.required_pref)
	if(!pref)
		log_mode("[role_type] has no required_pref")

	for(var/mob/dead/new_player/P in players_to_choose)
		if(!P.client || !P.mind)
			players_to_choose.Remove(P)
			continue
		if(!P.client.prefs.be_role.Find(pref) || jobban_isbanned(P, pref) || role_available_in_minutes(P, pref) || jobban_isbanned(P, "Syndicate"))
			players_to_choose.Remove(P)
			continue
	if(!players_to_choose.len)
		log_mode("No available players for [role_type]")
	return players_to_choose

/datum/game_mode/proc/CreateRole(role_type, mob/P)
	var/datum/role/newRole = CreateBasicRole(role_type)

	if(!newRole)
		log_mode("Role killed itself or was otherwise missing!")
		return FALSE

	newRole.is_roundstart_role = TRUE

	if(!newRole.AssignToRole(P.mind))
		log_mode("Role refused mind and dropped!")
		newRole.Drop()
		return FALSE

	return newRole

/datum/game_mode/proc/latespawn(mob/mob) //Check factions, see if anyone wants a latejoiner
	var/list/possible_factions = list()
	for(var/datum/faction/F in factions)
		F.latespawn(mob)
		if(!F.accept_latejoiners)
			continue
		if(F.max_roles && F.members.len >= F.max_roles)
			continue
		if(!F.can_join_faction(mob))
			continue
		possible_factions += F
	if(possible_factions.len)
		var/datum/faction/F = pick(possible_factions)
		F.HandleRecruitedMind(mob.mind)

/datum/game_mode/proc/PostSetup()
	addtimer(CALLBACK(GLOBAL_PROC, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)

	addtimer(CALLBACK(src, .proc/send_intercept), rand(INTERCEPT_TIME_LOW , INTERCEPT_TIME_HIGH))

	var/list/exclude_autotraitor_for = list(/datum/game_mode/extended)
	if(!(type in exclude_autotraitor_for))
		CreateFaction(/datum/faction/traitor/auto, num_players())

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(SSticker && SSticker.mode)
		feedback_set_details("game_mode","[SSticker.mode]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")

	start_state = new /datum/station_state()
	start_state.count(1)

	for(var/datum/faction/F in factions)
		for(var/datum/role/R in F.members)
			R.Greet()
		F.forgeObjectives()
		F.AnnounceObjectives()
		F.OnPostSetup()
	for(var/datum/role/R in orphaned_roles)
		R.Greet()
		R.forgeObjectives()
		R.AnnounceObjectives()
		R.OnPostSetup()

	if(dbcon.IsConnected())
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET game_mode = '[sanitize_sql(SSticker.mode)]' WHERE id = [round_id]")
		query_round_game_mode.Execute()

	return TRUE

/datum/game_mode/proc/GetScoreboard()
	completition_text = "<h2>Factions & Roles</h2>"
	var/exist = FALSE
	for(var/datum/faction/F in factions)
		if (F.members.len > 0)
			exist = TRUE
			completition_text += "<div class='Section'>"
			completition_text += F.GetFactionHeader()
			completition_text += F.GetScoreboard()
			completition_text += "</div>"
	if (orphaned_roles.len > 0)
		completition_text += "<FONT size = 2><B>Independents:</B></FONT><br>"
	for(var/datum/role/R in orphaned_roles)
		exist = TRUE
		completition_text += "<div class='Section'>"
		completition_text += R.GetScoreboard()
		completition_text += "</div>"
	if (!exist)
		completition_text += "(none)"
	completition_text += "<BR>"
	count_survivors()

	return completition_text


/datum/game_mode/process()
	for(var/datum/faction/F in factions)
		F.process()
	for(var/datum/role/R in orphaned_roles)
		R.process()

/datum/game_mode/proc/check_finished()
	for(var/datum/faction/F in factions)
		if (F.check_win())
			return TRUE
	for(var/datum/role/R in orphaned_roles)
		if (R.check_win())
			return TRUE
	if(SSticker.station_was_nuked)
		return TRUE
	return FALSE

/datum/game_mode/proc/declare_completion()
	return GetScoreboard()

/datum/game_mode/proc/mob_destroyed(mob/M)
	return

/datum/game_mode/proc/get_mode_result()
	if(factions_allowed.len)
		for(var/type in factions_allowed)
			var/list/datum/faction/game_mode_factions = find_active_all_faction_by_type(type)
			for(var/datum/faction/faction in game_mode_factions)
				if(!faction.IsSuccessful())
					return "loose"

	if(roles_allowed.len)
		for(var/type in roles_allowed)
			var/list/datum/role/game_mode_roles = list()
			for(var/datum/role/R in orphaned_roles)
				if(istype(R, type) && R.is_roundstart_role)
					game_mode_roles += R
			for(var/datum/role/R in game_mode_roles)
				if(!R.IsSuccessful())
					return "loose"

	return "win"
