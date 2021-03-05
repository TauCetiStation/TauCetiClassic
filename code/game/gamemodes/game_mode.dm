/*
	Gamemode datums
		Used for co-ordinating factions in a round, what factions should be in operation, etc.
	@name: String: The name of the gamemode, e.g. Changelings
	@factions: List(reference): What factions are currently in operation in the gamemode
	@factions_allowed: List(object): what factions will the gamemode start with, or attempt to start with
	@minimum_player_count: Integer: Minimum required players to start the gamemode
	@roles_allowed: List(object): What roles will the gamemode start with, or attempt to start with
	@probability: Integer: How likely it is to roll this gamemode
	@votable: Boolean: If this mode can be voted for
	@orphaned_roles: List(reference): List of faction-less roles currently in the gamemode
*/

/datum/game_mode
	var/name = "invalid"
	var/list/factions_allowed = list()
	var/list/roles_allowed = list()
	var/minimum_player_count
	var/minimum_players_bundles
	var/votable = TRUE
	var/probability = 0

	var/list/factions = list()
	var/list/orphaned_roles = list()
	var/dat = ""


	var/config_tag = null
	var/playable_mode = 1
	var/modeset = null        // if game_mode in modeset
	var/station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = 0 //sit back and relax
	var/nar_sie_has_risen = 0 //check, if there is already one god in the world who was summoned (only for tomes)
	var/completion_text = ""
	var/mode_result = "undefined"
	var/list/datum/mind/modePlayer = new // list of current antags.
	var/list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
	var/list/protected_jobs = list("Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")	// Jobs that can't be traitors because

	// Specie flags that for any amount of reasons can cause this role to not be available.
	// TO-DO: use traits? ~Luduk
	var/list/restricted_species_flags = list()

	var/required_players = 0 // Minimum number of players, if game mode is forced
	var/required_players_bundles = 0 //Minimum number of players for that game mode to be chose in Secret|BS12|TauClassic
	var/required_enemies = 0
	var/recommended_enemies = 0
	var/list/datum/mind/antag_candidates = list()	// List of possible starting antags goes here
	var/list/restricted_jobs_autotraitor = list("Cyborg", "Security Officer", "Warden", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")
	var/autotraitor_delay = 15 MINUTES // how often to try to add new traitors.
	var/role_type = null
	var/newscaster_announcements = null
	var/ert_disabled = 0

	var/check_ready = TRUE

	var/antag_hud_type
	var/antag_hud_name

	var/uplink_welcome = "Syndicate Uplink Console:"
	var/uplink_uses = 20
	var/uplink_items = {"Highly Visible and Dangerous Weapons;
/obj/item/weapon/gun/projectile/revolver/syndie:6:Revolver;
/obj/item/ammo_box/a357:2:Ammo-357;
/obj/item/weapon/gun/energy/crossbow:5:Energy Crossbow;
/obj/item/weapon/melee/energy/sword:4:Energy Sword;
/obj/item/weapon/storage/box/syndicate:10:Syndicate Bundle;
/obj/item/weapon/storage/box/emps:3:5 EMP Grenades;
Whitespace:Seperator;
Stealthy and Inconspicuous Weapons;
/obj/item/weapon/pen/paralysis:3:Paralysis Pen;
/obj/item/weapon/soap/syndie:1:Syndicate Soap;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA Cartridge;
Whitespace:Seperator;
Stealth and Camouflage Items;
/obj/item/weapon/storage/box/syndie_kit/chameleon:3:Chameleon Kit;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/weapon/card/id/syndicate:2:Agent ID card;
/obj/item/clothing/mask/gas/voice:4:Voice Changer;
/obj/item/device/chameleon:4:Chameleon-Projector;
Whitespace:Seperator;
Devices and Tools;
/obj/item/weapon/card/emag:3:Cryptographic Sequencer;
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/weapon/storage/box/syndie_kit/space:3:Space Suit;
/obj/item/clothing/glasses/thermal/syndi:3:Thermal Imaging Glasses;
/obj/item/device/encryptionkey/binary:3:Binary Translator Key;
/obj/item/weapon/aiModule/freeform/syndicate:7:Hacked AI Upload Module;
/obj/item/weapon/plastique:2:C-4 (Destroys walls);
/obj/item/device/powersink:5:Powersink (DANGER!);
/obj/item/device/radio/beacon/syndicate:7:Singularity Beacon (DANGER!);
/obj/item/weapon/circuitboard/teleporter:20:Teleporter Circuit Board;
Whitespace:Seperator;
Implants;
/obj/item/weapon/storage/box/syndie_kit/imp_freedom:3:Freedom Implant;
/obj/item/weapon/storage/box/syndie_kit/imp_uplink:10:Uplink Implant (Contains 5 Telecrystals);
/obj/item/weapon/storage/box/syndie_kit/imp_explosive:6:Explosive Implant (DANGER!);
/obj/item/weapon/storage/box/syndie_kit/imp_compress:4:Compressed Matter Implant;Whitespace:Seperator;
(Pointless) Badassery;
/obj/item/toy/syndicateballoon:10:For showing that You Are The BOSS (Useless Balloon);"}

/datum/game_mode/proc/announce()
	to_chat(world, "<B>Notice</B>: [src] did not define announce()")

/datum/game_mode/proc/get_player_count()
	var/players = 0
	for(var/mob/dead/new_player/P in new_player_list)
		if(P.client && (!check_ready || P.ready))
			players++

	return players

/datum/game_mode/proc/can_start()
	if(minimum_player_count && minimum_player_count < get_player_count())
		return FALSE
	return TRUE

//For when you need to set factions and factions_allowed not on compile
/datum/game_mode/proc/SetupFactions()
	return

// Infos on the mode.
/datum/game_mode/proc/AdminPanelEntry()
	return

/datum/game_mode/proc/Setup()
	if(minimum_player_count && minimum_player_count < get_player_count())
		TearDown()
		return FALSE
	SetupFactions()
	var/FactionSuccess = CreateFactions()
	var/RolesSuccess = CreateRoles()
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
	var/pc = get_player_count() //right proc?
	for(var/Fac in factions_to_process)
		if(islist(Fac))
			var/list/L = Fac
			CreateFactions(L, FALSE)
		else
			CreateFaction(Fac, pc)
	if(populate_factions)
		return PopulateFactions()

/datum/game_mode/proc/CreateFaction(Fac, population, override = 0)
	var/datum/faction/F = new Fac
	if(F.can_setup(population) || override)
		F.setup()
		factions += F
		factions_allowed -= F
		return F
	else
		warning("Faction ([F]) could not set up properly with given population.")
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

/datum/game_mode/proc/PopulateFactions()
	var/list/available_players = get_ready_players()
	for(var/datum/faction/F in factions)
		for(var/mob/dead/new_player/P in available_players)
			if(F.max_roles && F.members.len >= F.max_roles)
				break
			if(!P.client || !P.mind)
				continue
			if(!P.client.prefs.be_role.Find(F.required_pref) || jobban_isbanned(P, F.required_pref) || role_available_in_minutes(P, F.required_pref))
				continue
			if(!F.HandleNewMind(P.mind))
				stack_trace("[P.mind] failed [F] HandleNewMind!")
				continue
	return TRUE


/*=====ROLE RELATED STUFF=====*/

/datum/game_mode/proc/setup_num_of_roles()
	return

/datum/game_mode/proc/CreateRoles() //Must return TRUE in some way, else the gamemode is scrapped.
	if(!roles_allowed.len) //No roles to handle
		return TRUE
	setup_num_of_roles()
	for(var/role in roles_allowed)
		if(isnum(roles_allowed[role]))
			return CreateStrictNumOfRoles(role, roles_allowed[role])
		else
			CreateNumOfRoles(role, FilterAvailablePlayers(role))
			return TRUE

/datum/game_mode/proc/CreateNumOfRoles(datum/role/R, list/candidates)
	if(!candidates || !candidates.len)
		WARNING("ran out of available players to fill role [R]!")
		return
	for(var/mob/M in candidates)
		CreateRole(R, M)

/datum/game_mode/proc/CreateStrictNumOfRoles(datum/role/R, num)
	var/number_of_roles = 0
	var/list/available_players = FilterAvailablePlayers(R)
	for(var/i = 0 to num)
		if(!available_players.len)
			WARNING("ran out of available players to fill role [R]!")
			break
		shuffle(available_players)
		var/mob/dead/new_player/P = pick(available_players)
		available_players.Remove(P)
		if(!CreateRole(R, P))
			i--
			continue
		number_of_roles++ // Get the roles we created
	return number_of_roles


/datum/game_mode/proc/CreateBasicRole(type_role)
	return new type_role

/datum/game_mode/proc/FilterAvailablePlayers(datum/role/R, list/players_to_choose = get_ready_players())
	for(var/mob/dead/new_player/P in players_to_choose)
		if(!P.client || !P.mind)
			players_to_choose.Remove(P)
			continue
		if(!P.client.prefs.be_role.Find(initial(R.required_pref)) || jobban_isbanned(P, initial(R.required_pref)) || role_available_in_minutes(P, initial(R.required_pref)))
			players_to_choose.Remove(P)
			continue
	if(!players_to_choose.len)
		warning("No available players for [R]")
	return players_to_choose

/datum/game_mode/proc/CreateRole(datum/role/R, mob/P)
	var/datum/role/newRole = CreateBasicRole(R)

	if(!newRole)
		warning("Role killed itself or was otherwise missing!")
		return FALSE

	if(!newRole.AssignToRole(P.mind))
		warning("Role refused mind and dropped!")
		newRole.Drop()
		return FALSE

	return TRUE

/datum/game_mode/proc/latespawn(mob/mob) //Check factions, see if anyone wants a latejoiner
	var/list/possible_factions = list()
	for(var/datum/faction/F in factions)
		if(F.max_roles && F.members.len >= F.max_roles)
			continue
		if(!mob.client || !mob.mind)
			continue
		if(!mob.client.prefs.be_role.Find(F.required_pref) || jobban_isbanned(mob, F.required_pref) || role_available_in_minutes(mob, F.required_pref))
			continue
		if(F.accept_latejoiners)
			possible_factions.Add(F)
	if(possible_factions.len)
		var/datum/faction/F = pick(possible_factions)
		F.HandleRecruitedMind(mob.mind)

/datum/game_mode/proc/PostSetup()
	addtimer(CALLBACK(GLOBAL_PROC, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)

	addtimer(CALLBACK(src, .proc/send_intercept), rand(INTERCEPT_TIME_LOW , INTERCEPT_TIME_HIGH))

	var/list/exclude_autotraitor_for = list("extended", "sandbox") // config_tag var
	if(!(initial(name) in exclude_autotraitor_for))
		addtimer(CALLBACK(src, .proc/traitorcheckloop), autotraitor_delay)

	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(SSticker && SSticker.mode)
		feedback_set_details("game_mode","[SSticker.mode]")
	feedback_set_details("server_ip","[world.internet_address]:[world.port]")

	start_state = new /datum/station_state()
	start_state.count(1)

	for(var/datum/faction/F in factions)
		F.forgeObjectives()
		F.OnPostSetup()
	for(var/datum/role/R in orphaned_roles)
		R.ForgeObjectives()
		R.AnnounceObjectives()
		R.OnPostSetup()

	if(dbcon.IsConnected())
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET game_mode = '[sanitize_sql(SSticker.mode)]' WHERE id = [round_id]")
		query_round_game_mode.Execute()

	return TRUE

// This is where the game mode is shut down and cleaned up.
/datum/game_mode/proc/TearDown()
	return

/datum/game_mode/proc/GetScoreboard()
	dat += "<h2>Factions & Roles</h2>"
	var/exist = FALSE
	for(var/datum/faction/F in factions)
		if (F.members.len > 0)
			exist = TRUE
			dat += F.GetObjectivesMenuHeader()
			dat += F.GetScoreboard()
			dat += "<HR>"
	if (orphaned_roles.len > 0)
		dat += "<FONT size = 2><B>Independents:</B></FONT><br>"
	for(var/datum/role/R in orphaned_roles)
		exist = TRUE
		dat += R.GetScoreboard()
	if (!exist)
		dat += "(none)"

	count_survivors()

	return dat

/datum/game_mode/proc/get_ready_players()
	var/list/players = list()
	for(var/mob/dead/new_player/P in player_list)
		if(P.client && P.ready)
			players.Add(P)

	return players


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
	if(SSshuttle.location == SHUTTLE_AT_CENTCOM || SSticker.station_was_nuked)
		return TRUE
	return FALSE

/datum/game_mode/proc/declare_completion()
	return GetScoreboard()

/datum/game_mode/proc/mob_destroyed(mob/M)
	return

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report</b>\n\n</span>"
	for(var/mob/living/L in living_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in observer_list)
			if(D.mind && (D.mind.original == L || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive

	for(var/client/M in admins)
		if(M.holder)
			to_chat(M, msg)

// Adds the specified antag hud to the player. Usually called in an antag datum file
/datum/proc/add_antag_hud(antag_hud_type, antag_hud_name, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = global.huds[antag_hud_type]
	hud.join_hud(mob_override)
	set_antag_hud(mob_override, antag_hud_name)

// Removes the specified antag hud from the player. Usually called in an antag datum file
/datum/proc/remove_antag_hud(antag_hud_type, mob/living/mob_override)
	var/datum/atom_hud/antag/hud = global.huds[antag_hud_type]
	hud.leave_hud(mob_override)
	set_antag_hud(mob_override, null)
