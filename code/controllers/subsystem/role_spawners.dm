SUBSYSTEM_DEF(role_spawners)
	name = "Role Spawners"
	flags = SS_NO_FIRE

	var/list/datum/spawner/spawners = list()
	var/list/spawners_cooldown = list()

/datum/controller/subsystem/role_spawners/Initialize(timeofday)
	..()
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(roll_round_start))

/datum/controller/subsystem/role_spawners/proc/add_to_list(datum/spawner/S)
	spawners += S
	sortTim(spawners, GLOBAL_PROC_REF(cmp_spawners_asc))

/datum/controller/subsystem/role_spawners/proc/remove_from_list(datum/spawner/S)
	spawners -= S

/datum/controller/subsystem/role_spawners/proc/roll_round_start()
	for(var/datum/spawner/S in spawners)
		if(S.lobby_spawner)
			S.roll_registrations()
