/datum/job/cargo_psc
	title = JOB_CARGO_PSC
	departments = list(DEP_CIVILIAN)
	order = CREW_INTEND_EMPLOYEE(5)
	total_positions = 0
	spawn_positions = 0
	supervisors = "the quartermaster"
	selection_color = "#d7b088"
	idtype = /obj/item/weapon/card/id/cargo
	access = list(access_maint_tunnels, access_cargo, access_cargoshop, access_mailsorting)
	salary = 130
	outfit = /datum/outfit/job/cargo_psc
	skillsets = list(JOB_CARGO_PSC = /datum/skillset/officer)

// The number of Cargo Guard slots equals the edict's value this shift (0..CARGO_GUARD_MAX). We set
// it through the map_* overrides because SSjob.ResetOccupations() rebuilds positions from those (or
// initial()) every round; reading the DB value here at SSjob init pins the count for the round.
/datum/job/cargo_psc/New()
	. = ..()
	var/slots = get_edict_value(EDICT_CARGO_GUARD)
	map_total_positions = slots
	map_spawn_positions = slots

// Gates the role into SSjob.active_occupations: the role is absent from manifests, preferences and
// late-join unless the edict is on (value > 0) AND this map has not opted out of it (blocked_edicts).
/datum/job/cargo_psc/map_check()
	return is_edict_active(EDICT_CARGO_GUARD) && !is_edict_blocked_on_map(EDICT_CARGO_GUARD)
