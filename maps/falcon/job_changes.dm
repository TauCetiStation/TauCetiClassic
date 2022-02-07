#define JOB_MODIFICATION_MAP_NAME "Falcon Station"

/datum/job/assistant/New()
	..()
	MAP_JOB_CHECK
	total_positions = 2
	spawn_positions = 2

/datum/job/cyborg/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 2400

/datum/job/rd/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 6000

/datum/job/scientist/New()
	..()
	MAP_JOB_CHECK
	access += list(access_robotics)
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 1200

/datum/job/research_assistant/New()
	..()
	MAP_JOB_CHECK
	access += list(access_tox, access_xenoarch)
	total_positions = 1
	spawn_positions = 1

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 12000

/datum/job/hop/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 6000

/datum/job/hos/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 10800

/datum/job/officer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 1800

/datum/job/cadet/New()
	..()
	MAP_JOB_CHECK
	access += list(access_security)
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 600

/datum/job/cmo/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 6000

/datum/job/doctor/New()
	..()
	MAP_JOB_CHECK
	access += list(access_external_airlocks, access_sec_doors, access_research, access_mailsorting, access_engineering_lobby)
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 900

/datum/job/intern/New()
	..()
	MAP_JOB_CHECK
	access += list(access_morgue, access_surgery, access_maint_tunnels, access_medbay_storage)
	total_positions = 1
	spawn_positions = 1

/datum/job/chief_engineer/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 6000

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 600

/datum/job/technical_assistant/New()
	..()
	MAP_JOB_CHECK
	access += list(access_engine, access_engine_equip, access_external_airlocks)
	total_positions = 1
	spawn_positions = 1

/datum/job/chef/New()
	..()
	MAP_JOB_CHECK
	access += list(access_engine, access_engine_equip, access_external_airlocks)
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 120

/datum/job/qm/New()
	..()
	MAP_JOB_CHECK
	minimal_player_ingame_minutes = 900

/datum/job/mining/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1
	minimal_player_ingame_minutes = 600

MAP_REMOVE_JOB(barber)

MAP_REMOVE_JOB(chaplain)

MAP_REMOVE_JOB(cargo_tech)

MAP_REMOVE_JOB(recycler)

MAP_REMOVE_JOB(hydro)

MAP_REMOVE_JOB(janitor)

MAP_REMOVE_JOB(librarian)

MAP_REMOVE_JOB(lawyer)

MAP_REMOVE_JOB(mime)

MAP_REMOVE_JOB(atmos)

MAP_REMOVE_JOB(paramedic)

MAP_REMOVE_JOB(chemist)

MAP_REMOVE_JOB(geneticist)

MAP_REMOVE_JOB(virologist)

MAP_REMOVE_JOB(psychiatrist)

MAP_REMOVE_JOB(xenoarchaeologist)

MAP_REMOVE_JOB(xenobiologist)

MAP_REMOVE_JOB(roboticist)

MAP_REMOVE_JOB(warden)

MAP_REMOVE_JOB(detective)

MAP_REMOVE_JOB(forensic)

MAP_REMOVE_JOB(ai)

#undef JOB_MODIFICATION_MAP_NAME
