/*
 * Cargo Guard edict ("ЧОП Карго") lifecycle.
 *
 * setup_cargo_guard_edict()   - called at round start: resets the request flag and, if the edict
 *                               is active this shift, spawns the reminder sheets (QM office + bridge).
 * resolve_cargo_guard_edict() - called at round end (ticker/declare_completion): activates or
 *                               revokes the edict in the DB based on what happened this shift.
 *
 * "End of shift / shuttle arrival at CentComm" is the round-end moment: players who escaped on the
 * emergency shuttle are on a CentComm z-level (is_centcom_level), which is how we read "alive on the
 * shuttle at CC".
 */

// Round start: refresh per-round state and lay out the reminder paperwork when the law is in force.
/proc/setup_cargo_guard_edict()
	global.cargo_guard_edict_requested = FALSE

	if(!is_edict_active(EDICT_CARGO_GUARD))
		return

	var/obj/machinery/computer/cargo/qm/console = locate() in global.cargo_consoles
	if(console)
		new /obj/item/weapon/paper/cargo_guard_edict(get_turf(console))

	var/obj/item/weapon/paper/cargo_guard_edict/bridge_copy = new
	if(!print_to_command_fax(bridge_copy))
		qdel(bridge_copy)

// Round end: recompute the edict's value - the number of Cargo Guard slots - per the scaling rules.
// Below the population floor the law cannot change at all. Any failure is a FULL reset to 0; growth
// is at most +1 per shift and is gated on the QM requesting it and cargo affording the next slot.
/proc/resolve_cargo_guard_edict()
	if(!global.available_edicts[EDICT_CARGO_GUARD])
		return
	if(edict_living_player_count() < CARGO_GUARD_MIN_POP)
		return

	var/n = get_edict_value(EDICT_CARGO_GUARD)
	var/money = global.cargo_account ? global.cargo_account.money : 0

	if(n > 0)
		// 1. Cargo can no longer fund the guards it has -> full reset.
		if(money < n * CARGO_GUARD_PRICE)
			set_edict_value(EDICT_CARGO_GUARD, 0)
			return
		// 2. More security escaped than cargo -> full reset.
		var/cargo = edict_count_escapees_with_role(list(JOB_QM, JOB_CARGO_TECH, JOB_MINER, JOB_RECYCLER, JOB_CARGO_PSC))
		var/security = edict_count_escapees_with_role(list(JOB_OFFICER, JOB_HOS, JOB_WARDEN))
		if(cargo < security)
			set_edict_value(EDICT_CARGO_GUARD, 0)
			return
		// 3. Command delivered the stamped repeal and arrested the guard -> full reset.
		if(cargo_guard_command_revoke_satisfied())
			set_edict_value(EDICT_CARGO_GUARD, 0)
			return

	// 4. Growth: the QM requested another slot, cargo can fund N+1, and we're below the cap (+1 only).
	if(n < CARGO_GUARD_MAX && money >= (n + 1) * CARGO_GUARD_PRICE)
		var/mob/qm = find_qm_with_form_at_centcom()
		if(qm)
			set_edict_value(EDICT_CARGO_GUARD, n + 1, qm)
	// else: value unchanged - the law is simply maintained for another shift.

// The QM personally delivered the request form to CentComm, alive and not under arrest. Returns the
// QM mob (used as the actor for the DB record), or null.
/proc/find_qm_with_form_at_centcom()
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.stat == DEAD || !H.mind)
			continue
		if(H.mind.assigned_role != JOB_QM)
			continue
		if(H.handcuffed) // under arrest
			continue
		var/turf/T = get_turf(H)
		if(!T || !is_centcom_level(T.z))
			continue
		if(locate(/obj/item/weapon/paper/cargo_guard_request) in H.GetAllContents())
			return H
	return null

// Command revocation: an edict sheet stamped by Captain + HoS sits at CentComm, both of them are
// alive at CC, and every living cargo guard is handcuffed aboard the emergency shuttle.
/proc/cargo_guard_command_revoke_satisfied()
	var/sheet_delivered = FALSE
	for(var/obj/item/weapon/paper/cargo_guard_edict/P in global.cargo_guard_edict_papers)
		var/turf/T = get_turf(P)
		if(!T || !is_centcom_level(T.z))
			continue
		if((/obj/item/weapon/stamp/cap in P.stamped) && (/obj/item/weapon/stamp/sec/hos in P.stamped))
			sheet_delivered = TRUE
			break
	if(!sheet_delivered)
		return FALSE

	if(!edict_head_alive_at_centcom(JOB_CAPTAIN))
		return FALSE
	if(!edict_head_alive_at_centcom(JOB_HOS))
		return FALSE

	return all_cargo_guards_arrested_on_shuttle()

// --- helpers ---

// Living players present at round end (excludes lobby/observers). Used for the population floor.
/proc/edict_living_player_count()
	. = 0
	for(var/mob/M in global.mob_list)
		if(M.client && M.mind && M.stat != DEAD && !isnewplayer(M))
			.++

// Counts connected players with one of the given roles who escaped: alive and on a CentComm
// z-level at round end. SSD/abandoned bodies (no client) are not counted.
/proc/edict_count_escapees_with_role(list/roles)
	. = 0
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.stat == DEAD || !H.mind || !H.client)
			continue
		if(!(H.mind.assigned_role in roles))
			continue
		var/turf/T = get_turf(H)
		if(T && is_centcom_level(T.z))
			.++

/proc/edict_head_alive_at_centcom(role)
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.stat == DEAD || !H.mind)
			continue
		if(H.mind.assigned_role != role)
			continue
		var/turf/T = get_turf(H)
		if(T && is_centcom_level(T.z))
			return TRUE
	return FALSE

// TRUE only if there is at least one living cargo guard and EVERY living guard is handcuffed aboard
// the escape shuttle. Dead guards are ignored (already neutralized); one free living guard blocks it.
/proc/all_cargo_guards_arrested_on_shuttle()
	var/found = FALSE
	for(var/mob/living/carbon/human/H in global.human_list)
		if(!H.mind || H.mind.assigned_role != JOB_CARGO_PSC)
			continue
		if(H.stat == DEAD)
			continue
		found = TRUE
		if(!H.handcuffed)
			return FALSE
		if(!istype(get_area(H), /area/shuttle/escape))
			return FALSE
	return found
