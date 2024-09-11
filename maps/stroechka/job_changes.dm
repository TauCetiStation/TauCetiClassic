#define JOB_MODIFICATION_MAP_NAME "Stroecka Station"

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = 0
	spawn_positions = 1
	minimal_player_ingame_minutes = 2000

/datum/job/chief_engineer/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 3600
	skillsets = list("Chief Engineer" = /datum/skillset/stroechka/engineer)

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 6
	spawn_positions = 6
	minimal_player_ingame_minutes = 600
	skillsets = list("Station Engineer" = /datum/skillset/stroechka/engineer)

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	total_positions = 3
	spawn_positions = 3
	minimal_player_ingame_minutes = 600
	access += list(access_engine_equip)
	skillsets = list("Station Engineer" = /datum/skillset/stroechka/engineer)

/datum/job/technical_assistant/New()
	..()
	MAP_JOB_CHECK
	total_positions = -1
	spawn_positions = -1
	access += list(access_engine_equip, access_external_airlocks)
	skillsets = list("Technical Assistant" = /datum/skillset/stroechka/engineer)

MAP_REMOVE_JOB(clown)

MAP_REMOVE_JOB(bartender)

MAP_REMOVE_JOB(assistant)

MAP_REMOVE_JOB(ai)

MAP_REMOVE_JOB(rd)

MAP_REMOVE_JOB(scientist)

MAP_REMOVE_JOB(research_assistant)

MAP_REMOVE_JOB(captain)

MAP_REMOVE_JOB(mining)

MAP_REMOVE_JOB(qm)

MAP_REMOVE_JOB(chaplain)

MAP_REMOVE_JOB(chef)

MAP_REMOVE_JOB(intern)

MAP_REMOVE_JOB(doctor)

MAP_REMOVE_JOB(cmo)

MAP_REMOVE_JOB(cadet)

MAP_REMOVE_JOB(officer)

MAP_REMOVE_JOB(detective)

MAP_REMOVE_JOB(hos)

MAP_REMOVE_JOB(hop)

MAP_REMOVE_JOB(recycler)

MAP_REMOVE_JOB(barber)

MAP_REMOVE_JOB(cargo_tech)

MAP_REMOVE_JOB(hydro)

MAP_REMOVE_JOB(janitor)

MAP_REMOVE_JOB(librarian)

MAP_REMOVE_JOB(lawyer)

MAP_REMOVE_JOB(mime)

MAP_REMOVE_JOB(paramedic)

MAP_REMOVE_JOB(chemist)

MAP_REMOVE_JOB(geneticist)

MAP_REMOVE_JOB(virologist)

MAP_REMOVE_JOB(psychiatrist)

MAP_REMOVE_JOB(xenoarchaeologist)

MAP_REMOVE_JOB(xenobiologist)

MAP_REMOVE_JOB(roboticist)

MAP_REMOVE_JOB(warden)

MAP_REMOVE_JOB(forensic)

MAP_REMOVE_JOB(blueshield)

#undef JOB_MODIFICATION_MAP_NAME
