#define JOB_MODIFICATION_MAP_NAME "Nostromo (Alien)"

/datum/job/assistant/New()
	..()
	MAP_JOB_CHECK
	title = "Crewmate"
	alt_titles = list()
	total_positions = 6
	spawn_positions = 6
	access = list(access_maint_tunnels)
	skillsets = list("Crewmate" = /datum/skillset/jack_of_all_trades)
	outfit = /datum/outfit/nostromo

/datum/job/captain/New()
	..()
	MAP_JOB_CHECK
	access = list(access_maint_tunnels, access_captain)
	minimal_player_ingame_minutes = 1200
	skillsets = list("Captain" = /datum/skillset/jack_of_all_trades)
	outfit = /datum/outfit/nostromo/Arthur_Dallas

// ONLY HUMAN CAN PLAY THIS IVENT XENOSI SOSAAAAT
/datum/job/special_species_check(datum/species/S)
	return S.name == HUMAN

MAP_REMOVE_JOB(cargo_tech)

MAP_REMOVE_JOB(doctor)

MAP_REMOVE_JOB(blueshield)

MAP_REMOVE_JOB(engineer)

MAP_REMOVE_JOB(chief_engineer)

MAP_REMOVE_JOB(chief_engineer)

MAP_REMOVE_JOB(atmos)

MAP_REMOVE_JOB(technical_assistant)

MAP_REMOVE_JOB(cyborg)

MAP_REMOVE_JOB(clown)

MAP_REMOVE_JOB(bartender)

MAP_REMOVE_JOB(ai)

MAP_REMOVE_JOB(rd)

MAP_REMOVE_JOB(scientist)

MAP_REMOVE_JOB(research_assistant)

MAP_REMOVE_JOB(mining)

MAP_REMOVE_JOB(qm)

MAP_REMOVE_JOB(chaplain)

MAP_REMOVE_JOB(chef)

MAP_REMOVE_JOB(intern)

MAP_REMOVE_JOB(cmo)

MAP_REMOVE_JOB(cadet)

MAP_REMOVE_JOB(officer)

MAP_REMOVE_JOB(detective)

MAP_REMOVE_JOB(hos)

MAP_REMOVE_JOB(hop)

MAP_REMOVE_JOB(recycler)

MAP_REMOVE_JOB(barber)

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

#undef JOB_MODIFICATION_MAP_NAME
