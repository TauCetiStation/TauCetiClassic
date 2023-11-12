// Original idea author: BartNixon, 2019

#define TEAM_NAME_RED "Red Team"
#define TEAM_NAME_BLUE "Blue Team"

/datum/map_module/forts
	name = "Forts Arena"

	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE

	var/datum/faction/custom/team_red
	var/datum/faction/custom/team_blue

/datum/map_module/forts/New()
	..()

	create_spawner(/datum/spawner/fort_team/red, INFINITY, src)
	create_spawner(/datum/spawner/fort_team/blue, INFINITY, src)

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

// some low level factions code here, need to wrap it better somehow...
/datum/spawner/fort_team/New(datum/map_module/MM)
	. = ..()
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(init_faction))

/datum/spawner/fort_team/proc/init_faction()
	faction = new 
	faction.name = team_name
	faction.ID = team_name
	faction.forgeObjectives("Защитите свой командный пункт и уничтожьте командный пункт противника!")

/datum/spawner/fort_team/roll_registrations()
	SSticker.mode.factions += faction // todo
	. = ..()

/datum/spawner/fort_team/proc/assign_to_team(mob/M)
	var/datum/role/custom/teammate = new
	teammate.name = "Team Member"
	// updates here
	if(team_name == TEAM_NAME_RED)
		teammate.logo_state = "red"
	else
		teammate.logo_state = "blue"

	teammate.antag_hud_type = ANTAG_HUD_TEAMS
	teammate.antag_hud_name = "hud_team_captain"
	//skillset_type

	teammate.AssignToFaction(faction)
	teammate.AssignToRole(M.mind, msg_admins = FALSE) // todo: why it announce faction twice

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

#undef TEAM_NAME_RED
#undef TEAM_NAME_BLUE
