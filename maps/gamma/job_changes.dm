#define JOB_MODIFICATION_MAP_NAME "Gamma Station"

/datum/job/clown/New()
	..()
	MAP_JOB_CHECK
	map_total_positions = 6
	map_spawn_positions = 6

#undef JOB_MODIFICATION_MAP_NAME
