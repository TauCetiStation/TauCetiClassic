#define JOB_MODIFICATION_MAP_NAME "Deathmatch Paradise Island"

////////////////////////////////////////////////////
//BLUE TEAM
////////////////////////////////////////////////////

/datum/job/cmo/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Leader"
	selection_color = "#5eabeb"
	total_positions = 0
	spawn_positions = 1
	supervisors = "the God"
	idtype = /obj/item/weapon/card/id/civGold
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/leader
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 1000
	give_loadout_items = FALSE

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Medic"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/medic
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/paramedic/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Scout"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/scout
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/chemist/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Sniper"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/sniper
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/geneticist/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Experimental"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/experimental
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/virologist/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Mage"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/mage
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/psychiatrist/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Crusader"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/crusader
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/intern/New()
	..()
	MAP_JOB_CHECK
	title = "Blue Team Soldier"
	alt_titles = null
	selection_color = "#b0eaf6"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Blue Leader"
	idtype = /obj/item/weapon/card/id/civ
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/blue_team/soldier
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

////////////////////////////////////////////////////
//RED TEAM
////////////////////////////////////////////////////
/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Leader"
	selection_color = "#d74722"
	total_positions = 0
	spawn_positions = 1
	supervisors = "the God"
	idtype = /obj/item/weapon/card/id/secGold
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/leader
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 1000
	give_loadout_items = FALSE

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Medic"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/medic
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/xenoarchaeologist/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Scout"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/scout
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/xenobiologist/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Sniper"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/sniper
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/roboticist/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Experimental"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/experimental
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/research_assistant/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Mage"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/mage
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Crusader"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/crusader
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE

/datum/job/warden/New()
	..()
	MAP_JOB_CHECK
	title = "Red Team Soldier"
	alt_titles = null
	selection_color = "#e67c34"
	total_positions = 0
	spawn_positions = 2
	supervisors = "the Red Leader"
	idtype = /obj/item/weapon/card/id/sec
	access = list()
	salary = 0
	restricted_species = list()
	outfit = /datum/outfit/deathmatch/red_team/soldier
	skillsets = list("Maximum skillset" = /datum/skillset/max)
	minimal_player_ingame_minutes = 0
	give_loadout_items = FALSE


/datum/job/assistant/New()
	..()
	MAP_JOB_CHECK
	title = "Tea Drinker"
	alt_titles = null
	selection_color = "#79b330"
	outfit = /datum/outfit/deathmatch/tea_drinker
	skillsets = list("Maximum skillset" = /datum/skillset/max)


MAP_REMOVE_JOB(bartender)

MAP_REMOVE_JOB(clown)

MAP_REMOVE_JOB(barber)

MAP_REMOVE_JOB(cyborg)

MAP_REMOVE_JOB(ai)

MAP_REMOVE_JOB(captain)

MAP_REMOVE_JOB(hop)

MAP_REMOVE_JOB(detective)

MAP_REMOVE_JOB(officer)

MAP_REMOVE_JOB(cadet)

MAP_REMOVE_JOB(chief_engineer)

MAP_REMOVE_JOB(engineer)

MAP_REMOVE_JOB(technical_assistant)

MAP_REMOVE_JOB(chef)

MAP_REMOVE_JOB(chaplain)

MAP_REMOVE_JOB(qm)

MAP_REMOVE_JOB(mining)

MAP_REMOVE_JOB(recycler)

MAP_REMOVE_JOB(cargo_tech)

MAP_REMOVE_JOB(hydro)

MAP_REMOVE_JOB(janitor)

MAP_REMOVE_JOB(librarian)

MAP_REMOVE_JOB(lawyer)

MAP_REMOVE_JOB(mime)

MAP_REMOVE_JOB(atmos)

MAP_REMOVE_JOB(forensic)

MAP_REMOVE_JOB(blueshield)

#undef JOB_MODIFICATION_MAP_NAME
