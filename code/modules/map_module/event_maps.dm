// Original idea author: BartNixon, 2019

/datum/map_module/forts
	name = MAP_MODULE_FORTS

	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE

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

/* spawner */
/datum/spawner/fort_team
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников!"
	//wiki_ref = "Forst event" // todo

	lobby_spawner = TRUE
	// сделать зависимым от фракции...
	positions = INFINITY

	var/team_name
	var/team_outfit

/datum/spawner/fort_team/New(datum/map_module/forts/MM)
	. = ..()
	faction = MM.factions[team_name]

/datum/spawner/fort_team/proc/assign_to_team(mob/M)
	var/datum/role/custom/teammate = new
	teammate.name = "Team Member"
	// updates here
	// todo: can we use hud rank as teammate.logo_state?
	teammate.antag_hud_type = ANTAG_HUD_TEAMS
	teammate.antag_hud_name = "hud_team_captain"
	// add skillset_type
	teammate.AssignToFaction(faction)
	teammate.AssignToRole(M.mind, msg_admins = FALSE)

	// gamemode will do this for first roll players, and we need to do this for latespawn roles
	// todo: wrap it somehow too
	if(SSticker.current_state >= GAME_STATE_PLAYING)
		setup_role(teammate)

/datum/spawner/fort_team/spawn_body(mob/dead/spectator)
	var/spawnloc = pick_spawn_location()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(spawnloc)
	H.key = C.key
	assign_to_team(H)
	//var/new_name = "[pick(last_names)]"
	//asynk //C.create_human_apperance(H, new_name)
	H.equipOutfit(team_outfit)

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
