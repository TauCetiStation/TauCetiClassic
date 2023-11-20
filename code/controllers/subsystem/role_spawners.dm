SUBSYSTEM_DEF(role_spawners)
	name = "Role Spawners"
	flags = SS_NO_FIRE

	var/global/list/datum/spawner/spawners = list()
	var/global/list/datum/spawners_cooldown = list()

	var/global/list/datum/spawner/round_start_autoroll = list()

/datum/controller/subsystem/role_spawners/Initialize(timeofday)
	..()
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(roll_round_start))

/datum/controller/subsystem/role_spawners/proc/add_to_list(datum/spawner/S)
	spawners += S
	sortTim(spawners, GLOBAL_PROC_REF(cmp_spawners_asc))
	//trigger_ui_update()

/datum/controller/subsystem/role_spawners/proc/remove_from_list(datum/spawner/S)
	spawners -= S
	//trigger_ui_update()

/datum/controller/subsystem/role_spawners/proc/roll_round_start()
	for(var/datum/spawner/S in spawners)
		if(S.lobby_spawner)
			S.roll_registrations()

/*/datum/controller/subsystem/role_spawners/proc/trigger_ui_update()
	for(var/mob/dead/M in (new_player_list + observer_list))
		if(!M.client)
			continue

		if(M.spawners_menu)
			SStgui.update_uis(M.spawners_menu)
*/
