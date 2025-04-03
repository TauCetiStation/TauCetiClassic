/datum/spawner/multiple_landmark/fort_teams
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников!"
	wiki_ref = "Forst"

	lobby_spawner = TRUE
	positions = INFINITY

	cooldown = 5 MINUTES
	spawn_landmarks_names = list(TEAM_NAME_BLUE, TEAM_NAME_RED)

	var/datum/map_module/forts/map_module

	var/list/team_outfits = list(TEAM_NAME_BLUE = /datum/outfit/forts_team/blue, TEAM_NAME_RED = /datum/outfit/forts_team/red)
	var/list/factions = list()

/datum/spawner/multiple_landmark/fort_teams/New(datum/map_module/forts/MM)
	. = ..()
	map_module = MM
	factions[TEAM_NAME_BLUE] = map_module.factions[TEAM_NAME_BLUE]
	factions[TEAM_NAME_RED]  = map_module.factions[TEAM_NAME_RED]

/datum/spawner/multiple_landmark/fort_teams/spawn_body(mob/dead/spectator)
	var/team_name = pick_landmark_name()

	var/client/C = spectator.client

	var/mob/living/carbon/human/H = new(pick_landmarked_location(team_name))
	H.key = C.key

	H.equipOutfit(team_outfits[team_name])
	map_module.assign_to_team(H, factions[team_name])

	var/new_name = spectator.name
	INVOKE_ASYNC(C, TYPE_PROC_REF(/client, create_human_apperance), H, new_name, TRUE)
