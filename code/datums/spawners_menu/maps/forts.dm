/datum/spawner/fort_team
	name = "Fort Team"
	desc = "Отстраивайте и защищайте форт своей команды, уничтожьте форт команды противников!"
	wiki_ref = "Forst"

	lobby_spawner = TRUE
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
