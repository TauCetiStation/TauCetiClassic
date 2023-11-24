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
	)

	var/list/datum/faction/factions = list()
	var/list/datum/spawner/fort_team/spawners = list()
	var/list/obj/machinery/computer/fort_console/consoles = list()

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
			if(4000 to 10000)
				teammate.antag_hud_name = "hud_team_1"
			if(10000 to 25000)
				teammate.antag_hud_name = "hud_team_2"
			if(25000 to INFINITY)
				teammate.antag_hud_name = "hud_team_3"

	teammate.logo_file = 'icons/hud/hud.dmi'
	teammate.logo_state = teammate.antag_hud_name

	teammate.skillset_type = /datum/skillset/jack_of_all_trades

	teammate.AssignToFaction(faction)
	teammate.AssignToRole(M.mind, msg_admins = FALSE)

	// gamemode will do this for first roll players, and we need to do this for latespawn roles
	// todo: wrap it somehow too
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		setup_role(teammate)

/* spawner */
/datum/spawner/fort_team
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников!"
	//wiki_ref = "Forst event" // todo

	lobby_spawner = TRUE
	// сделать зависимым от фракции...
	positions = INFINITY

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
	// uncomment me
	//INVOKE_ASYNC(C, TYPE_PROC_REF(/client, create_human_apperance), H, new_name, TRUE)

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
	set name = "Fort: assign commander"


/client/proc/fort_open_spawns()
	set category = "Event"
	set name = "Fort: toggle spawn"

	if(!fort_spawn_poddors)
		return

	for(var/obj/machinery/door/poddoor/door as anything in fort_spawn_poddors)
		if(door.density)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, do_open))
		else
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door/poddoor, do_close))

var/global/list/obj/machinery/door/poddoor/fort_spawn_poddors

/obj/machinery/door/poddoor/fort_spawn/atom_init()
	. = ..()

	LAZYADD(fort_spawn_poddors, src)

/obj/machinery/door/poddoor/fort_spawn/Destroy()
	. = ..()

	LAZYREMOVE(fort_spawn_poddors, src)
