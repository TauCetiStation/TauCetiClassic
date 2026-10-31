/obj/item/weapon/card/id/cargo/cargo_guard
	sec_hud_icon = JOB_CARGO_TECH

/datum/job/cargo_psc
	title = JOB_CARGO_PSC
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(3)
	total_positions = 0
	spawn_positions = 0
	supervisors = "the quartermaster"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo/cargo_guard
	access = list(access_maint_tunnels, access_cargo, access_cargoshop, access_mailsorting)
	salary = 130
	minimal_player_ingame_minutes = 480
	outfit = /datum/outfit/job/cargo_psc
	skillsets = list(JOB_CARGO_PSC = /datum/skillset/officer)
	var/edict_slots

// The number of Cargo Guard slots equals the edict's value this shift (0..CARGO_GUARD_MAX). Keep
// map_* overrides because SSjob.ResetOccupations() rebuilds positions from them after a failed setup.
/datum/job/cargo_psc/New()
	. = ..()
	var/slots = get_edict_value(EDICT_CARGO_GUARD)
	if(!isnull(slots))
		edict_slots = clamp(slots, 0, CARGO_GUARD_MAX)
	var/positions = isnull(edict_slots) ? 0 : edict_slots
	total_positions = positions
	spawn_positions = positions
	map_total_positions = positions
	map_spawn_positions = positions

// Gates the role into SSjob.active_occupations: the role is absent from manifests, preferences and
// late-join unless the edict is on (value > 0) AND this map has not opted out of it (blocked_edicts).
/datum/job/cargo_psc/map_check()
	return !isnull(edict_slots) && edict_slots > 0 && !is_edict_blocked_on_map(EDICT_CARGO_GUARD)

/datum/job/cargo_psc/get_roundstart_spawn_turf(mob/living/carbon/human/H)
	var/list/free_turfs = list()
	var/list/valid_turfs = list()
	for(var/obj/effect/landmark/start/landmark as anything in landmarks_list[JOB_CARGO_TECH])
		var/area/landmark_area = get_area(landmark)
		for(var/turf/T as anything in RANGE_TURFS(1, landmark))
			if(get_area(T) != landmark_area || is_blocked_turf(T))
				continue
			valid_turfs |= T
			if(!(locate(/mob/living) in T))
				free_turfs |= T

	if(!length(valid_turfs))
		for(var/turf/T as anything in get_area_turfs(/area/station/cargo, ignore_blocked = TRUE))
			if(!is_station_level(T.z))
				continue
			valid_turfs |= T
			if(!(locate(/mob/living) in T))
				free_turfs |= T

	if(length(free_turfs))
		return pick(free_turfs)
	if(length(valid_turfs))
		return pick(valid_turfs)
	return null
