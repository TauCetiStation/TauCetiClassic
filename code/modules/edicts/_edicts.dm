/*
 * Edicts: persistent, cross-round station laws.
 *
 * State lives in the `edicts` DB table as an append-only history: every change is a NEW row.
 * The current state of an edict is therefore the row with the highest `id` for that name and server
 * port. The database is shared between servers, but each server keeps an independent edict history.
 * Never UPDATE existing rows - always INSERT a new one.
 *
 * The `active` column stores an integer VALUE, not just a flag: 0 means the edict is off, and a
 * positive number is a magnitude (for Cargo Guard - the number of guard slots, see cargo_guard/).
 *
 * Each edict is a `/datum/edict` subtype that owns its own round-start/round-end behaviour; the
 * lifecycle is driven by SSedicts (see code/controllers/subsystem/edicts.dm), which discovers the
 * subtypes and dispatches the ticker signals to them. `available_edicts` is a whitelist of valid
 * keys, checked by the DB helpers below - it is a plain compile-time list so it works at SSjob init
 * (jobs read edict values in New()), before any subsystem has initialised.
 */
var/global/list/available_edicts = list(
	EDICT_CARGO_GUARD = TRUE,
)

// Base class for an edict. One instance per subtype is created and registered by SSedicts; `name`
// is the DB key (an EDICT_* define) and must also be present in `available_edicts`.
/datum/edict
	var/name

// Round start hook (COMSIG_TICKER_ROUND_STARTING). Lay out paperwork / per-round state here.
/datum/edict/proc/on_round_start()
	return

// Round end hook (COMSIG_TICKER_DECLARE_COMPLETION). Recompute and persist the edict's value here.
/datum/edict/proc/on_round_end()
	return

// TRUE if the current map opted out of this edict (see /datum/map_config.blocked_edicts). SSedicts
// skips a blocked edict's round hooks, and the edict's job should also gate on this in map_check().
/datum/edict/proc/blocked_on_map()
	return is_edict_blocked_on_map(name)

// Map-side opt-out check, usable without an edict datum (e.g. from a job's map_check at SSjob init).
/proc/is_edict_blocked_on_map(edict_name)
	return SSmapping.config && (edict_name in SSmapping.config.blocked_edicts)

// Returns the live edict datum for a key, or null. Only valid after SSedicts has initialised.
/proc/get_edict(edict_name)
	return SSedicts ? SSedicts.edicts[edict_name] : null

// Prints `paper` at the highest-priority working command fax machine and returns it, or null if
// none exists on the map. Used for the "copy on the bridge" of edict paperwork; not every map has
// a "Bridge" fax, so we fall back to the captain's office.
/proc/print_to_command_fax(obj/item/weapon/paper/paper)
	for(var/dept in list("Bridge", "Captain's Office"))
		for(var/obj/machinery/faxmachine/F in allfaxes)
			if(F.department == dept && !(F.stat & (BROKEN|NOPOWER)))
				F.print_fax(paper)
				return F
	return null

// Returns the edict's current value (the `active` number of its most recent row). 0 on any
// failure (no DB, no history) - i.e. an edict that was never set reads as 0/off.
/proc/get_edict_value(edict_name)
	if(!available_edicts[edict_name])
		stack_trace("Attempted to retrieve invalid edict: `[edict_name]`")
		return 0

	if(!establish_db_connection("edicts"))
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT active FROM edicts WHERE server_port = [sanitize_sql(world.port)] AND name = '[sanitize_sql(edict_name)]' ORDER BY id DESC LIMIT 1")
	if(!query.Execute())
		return 0
	if(!query.NextRow())
		return 0

	return text2num(query.item[1])

// Convenience boolean: is the edict on at all (value > 0)?
/proc/is_edict_active(edict_name)
	return get_edict_value(edict_name) > 0

// Writes a new state row setting the edict's value. `actor` is whoever caused the change
// (may be null for automatic/system changes, e.g. survivor-count revocation).
/proc/set_edict_value(edict_name, value, mob/actor)
	if(!available_edicts[edict_name])
		stack_trace("Attempted to set invalid edict: `[edict_name]`")
		return FALSE

	if(!establish_db_connection("edicts"))
		return FALSE

	var/actor_ckey = actor ? actor.ckey : ""
	var/actor_name = actor ? actor.real_name : "system"

	var/DBQuery/query = dbcon.NewQuery("INSERT INTO edicts (datetime, round_id, server_port, actor_ckey, actor_character_name, name, active) \
		VALUES (Now(), [global.round_id], [sanitize_sql(world.port)], '[sanitize_sql(actor_ckey)]', '[sanitize_sql(actor_name)]', '[sanitize_sql(edict_name)]', [value])")
	return query.Execute()
