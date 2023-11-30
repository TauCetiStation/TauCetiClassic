// Original idea author: BartNixon, 2019

/datum/map_module/forts
	name = MAP_MODULE_FORTS

	gamemode = "Extended"
	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE
	disable_default_spawners = TRUE

	admin_verbs = list(
		/client/proc/toggle_passmode_shields,
		/client/proc/fort_assign_commander,
		/client/proc/fort_open_spawns,
		/client/proc/fort_points,
		/client/proc/fort_points_multiplier,
	)

	// assoc lists (TEAMNAME = reference)
	var/list/factions = list()
	var/list/spawners = list()
	var/list/consoles = list() 

/datum/map_module/forts/New()
	..()

	var/objective = "Защитите свой командный пункт и уничтожьте командный пункт противника!"
	factions[TEAM_NAME_RED] = create_custom_faction(TEAM_NAME_RED, TEAM_NAME_RED, "red", objective)
	factions[TEAM_NAME_BLUE] = create_custom_faction(TEAM_NAME_BLUE, TEAM_NAME_BLUE, "blue", objective)

	spawners[TEAM_NAME_RED] = create_spawner(/datum/spawner/fort_team/red, src)
	spawners[TEAM_NAME_BLUE] = create_spawner(/datum/spawner/fort_team/blue, src)

/datum/map_module/forts/proc/assign_to_team(mob/M, datum/faction/faction, rank = "Team Member")
	var/datum/role/custom/teammate = new
	teammate.name = rank

	switch(faction.ID) // faction can be renamed, so we check ID
		if(TEAM_NAME_RED)
			teammate.antag_hud_type = ANTAG_HUD_TEAMS_RED
		if(TEAM_NAME_BLUE)
			teammate.antag_hud_type = ANTAG_HUD_TEAMS_BLUE

	if(rank == "Commander")
		teammate.antag_hud_name = "hud_team_captain"
	else
		switch(M.client.player_ingame_age)
			if(0 to 4000)
				teammate.antag_hud_name = "hudblank" // only background
			if(4000 to 15000)
				teammate.antag_hud_name = "hud_team_1"
			if(15000 to 30000)
				teammate.antag_hud_name = "hud_team_2"
			if(30000 to INFINITY)
				teammate.antag_hud_name = "hud_team_3"

	teammate.logo_file = 'icons/hud/hud.dmi'
	teammate.logo_state = teammate.antag_hud_name

	teammate.skillset_type = /datum/skillset/jack_of_all_trades

	teammate.AssignToFaction(faction)
	teammate.AssignToRole(M.mind, msg_admins = FALSE)

	if(rank == "Commander")
		var/obj/item/weapon/card/id/captains_spare/card = new 
		card.assignment = "Commander"
		card.assign(M.real_name)
		M.equip_to_appropriate_slot(card)

	// gamemode will do this for first roll players, and we need to do this for latespawn roles
	// todo: wrap it somehow too
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		setup_role(teammate)

/datum/map_module/forts/proc/announce(message, mob/user, from_team, team_only = FALSE)
	var/datum/announcement/A = new

	A.title = "Forts Arena Announcement"
	if(from_team)
		if(team_only)
			A.faction_filter = factions[from_team]
			A.subtitle = "[from_team] private announcement"
		else
			A.subtitle = "[from_team] public announcement"

	A.message = message
	A.flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND
	A.sound = "bell"
	A.announcer = user?.GetVoice()
	A.play()

/datum/map_module/forts/stat_entry(mob/M)
	if(M.client.holder)
		stat(null, "Red Points: [consoles[TEAM_NAME_RED]?.points || "--"]")
		stat(null, "Blue Points: [consoles[TEAM_NAME_BLUE]?.points || "--"]")

/* spawner */
/datum/spawner/fort_team
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников!"
	//wiki_ref = "Forst event" // todo

	lobby_spawner = TRUE
	// сделать зависимым от фракции...
	positions = INFINITY

	cooldown_type = /datum/spawner/fort_team // will be shared between both teams
	cooldown = 5 MINUTES

	var/datum/map_module/forts/map_module

	var/team_name
	var/team_outfit

/datum/spawner/fort_team/New(datum/map_module/forts/MM)
	. = ..()
	map_module = MM
	faction = MM.factions[team_name]

/datum/spawner/fort_team/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(spawnloc)
	H.key = C.key

	map_module.assign_to_team(H, faction)
	H.equipOutfit(team_outfit)

	var/new_name = spectator.name
	// comment me for tests
	INVOKE_ASYNC(C, TYPE_PROC_REF(/client, create_human_apperance), H, new_name, TRUE)

/datum/spawner/fort_team/red
	name = TEAM_NAME_RED
	team_name = TEAM_NAME_RED
	spawn_landmark_name = TEAM_NAME_RED // /obj/effect/landmark/red_team

	team_outfit = /datum/outfit/forts_team/red

/datum/spawner/fort_team/blue
	name = TEAM_NAME_BLUE
	team_name = TEAM_NAME_BLUE
	spawn_landmark_name = TEAM_NAME_BLUE // /obj/effect/landmark/blue_team

	team_outfit = /datum/outfit/forts_team/blue

/* admin verbs */
/client/proc/fort_assign_commander()
	set category = "Event"
	set name = "Fort: Assign Commander"

	var/datum/map_module/forts/forts_map_module = SSmapping.get_map_module(MAP_MODULE_FORTS)

	var/faction_name = tgui_input_list(src,"Choise faction:", "Assign Commander", forts_map_module.factions)
	if(!faction_name)
		return
	var/datum/faction/F = forts_map_module.factions[faction_name]

	if(!length(F.members))
		to_chat(usr, "<span class='warning'>Faction is empty!</span>")
		return

	var/list/candidates = list()

	for(var/datum/role/R in F.members) // how we can get active clients in faction
		var/mob/M = R.antag?.current
		if(!M || !M.client)
			continue
		candidates["[M.real_name] ([M.client])"] = M

	var/new_commander = tgui_input_list(src,"Choise member to become a commander:", "Assign Commander", candidates)

	message_admins("[key_name(src)] assigned [candidates[new_commander]] as Commander of [faction_name].")

	forts_map_module.assign_to_team(candidates[new_commander], faction = F, rank = "Commander")

/client/proc/fort_open_spawns()
	set category = "Event"
	set name = "Fort: Poddors"

	if(!fort_spawn_poddors)
		return

	for(var/obj/machinery/door/poddoor/door as anything in fort_spawn_poddors)
		if(door.density)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, do_open))
		else
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, do_close))

	message_admins("[key_name(src)] toggled spawn blocking poddors.")

var/global/list/obj/machinery/door/poddoor/fort_spawn_poddors

/obj/machinery/door/poddoor/fort_spawn/atom_init()
	. = ..()

	LAZYADD(fort_spawn_poddors, src)

/obj/machinery/door/poddoor/fort_spawn/Destroy()
	. = ..()

	LAZYREMOVE(fort_spawn_poddors, src)

/client/proc/fort_points()
	set category = "Event"
	set name = "Fort: Give Points"

	var/add_points = input("Enter points you want to give for teams.", "Points") as num|null

	if(!add_points)
		return

	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	for(var/team_name in MM.consoles)
		var/obj/machinery/computer/fort_console/console = MM.consoles[team_name]
		console.points += add_points

	MM.announce("Команды получили в своё распоряжение [add_points] бонусных очков!")

	message_admins("[key_name(src)] added [add_points] points for teams.")

var/global/forts_points_multiplier = 1
/client/proc/fort_points_multiplier()
	set category = "Event"
	set name = "Fort: Points Multiplier"

	var/multiplier = input("Enter points multiplier factor.", "Points", forts_points_multiplier) as num|null
	if(!multiplier)
		return

	forts_points_multiplier = multiplier

	var/datum/map_module/forts/MM = SSmapping.get_map_module(MAP_MODULE_FORTS)
	if(forts_points_multiplier == 1)
		MM.announce("Скорость получения очков вернулась в норму!")
	else
		MM.announce("Скорость получения очков увеличина в [forts_points_multiplier] [pluralize_russian(forts_points_multiplier, "раз", "раза", "раз")]!")
 
	message_admins("[key_name(src)] changed points multiplier to [forts_points_multiplier].")
