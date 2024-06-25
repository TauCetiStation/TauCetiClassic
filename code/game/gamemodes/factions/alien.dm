#define CHECK_PERIOD 	200

/datum/faction/alien
	name = F_XENOMORPH
	ID = F_XENOMORPH
	logo_state = "xeno-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 1
	max_roles = 1

	var/last_check = 0

/datum/faction/infestation/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len > 0)
		return TRUE
	return FALSE

/datum/faction/alien/OnPostSetup()
	for(var/datum/role/role in members)
		var/mob/living/carbon/xenomorph/larva/alien/L
		var/start_point = pick(xeno_spawn)

		L = new (get_turf(start_point))
		role.antag.transfer_to(L)
		QDEL_NULL(role.antag.original)

	return ..()

/datum/faction/alien/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/bloodbath)
	return TRUE

/datum/faction/proc/check_crew()
	var/total_human = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.mind || !H.client)
			continue
		if(!istype(H, /mob/living/carbon/human/machine))
		total_human++
	return total_human
