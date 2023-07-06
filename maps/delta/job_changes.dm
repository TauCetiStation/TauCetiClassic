#define JOB_MODIFICATION_MAP_NAME "Delta Station"

/datum/job/hydro/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/atmos/New()
	..()
	MAP_JOB_CHECK
	total_positions = 4
	spawn_positions = 4

/datum/job/technical_assistant/New()
	..()
	MAP_JOB_CHECK
	total_positions = 5
	spawn_positions = 5

/datum/job/engineer/New()
	..()
	MAP_JOB_CHECK
	total_positions = 8
	spawn_positions = 8

#undef JOB_MODIFICATION_MAP_NAME
