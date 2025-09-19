// Nebula-dev\code\modules\admin\verbs\fluids.dm

/datum/admins/proc/spawn_fluid_verb()
	set name = "Fluid: Spawn fluid"
	set desc = "Flood the turf you are standing on."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return

	var/mob/user = usr
	if(!istype(user) || !user.client)
		return
	var/spawn_range = input("How wide a radius?", "Spawn Fluid", 0) as num|null
	var/reagent_amount = input("How deep?", "Spawn Fluid", 1000) as num|null
	if(!reagent_amount)
		return
	var/reagent_id = "water"// = input("What kind of reagent?", "Spawn Fluid", /decl/material/liquid/water) as null|anything in decls_repository.get_decl_paths_of_subtype(/decl/material)
	if(!reagent_id || !user || !check_rights(R_SPAWN))
		return
	var/turf/flooding = get_turf(user)
	for(var/turf/T as anything in RANGE_TURFS(spawn_range, flooding))
		T.add_to_reagents(reagent_id, reagent_amount)

/datum/admins/proc/spawn_fluid_source_verb()
	set name = "Fluid: Create/Delete Water Source"
	set desc = "Sets/unsets turf under you to be water source."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return

	var/mob/user = usr
	if(!istype(user) || !user.client)
		return

	var/turf/T = get_turf(user)
	new /obj/effect/spawner/mapped_flood(T, T.flooded)

/datum/admins/proc/jump_to_fluid_source()
	set name = "Fluid: Jump To Fluid Source"
	set desc = "Jump to an active fluid source."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return
	var/mob/user = usr
	if(istype(user) && user.client)
		if(SSfluids.water_sources.len)
			user.forceMove(get_turf(pick(SSfluids.water_sources)))
		else
			to_chat(user, "No active fluid sources.")

/datum/admins/proc/jump_to_fluid_active()
	set name = "Fluid: Jump To Fluid Activity"
	set desc = "Jump to an active fluid overlay."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return
	var/mob/user = usr
	if(istype(user) && user.client)
		if(SSfluids.active_fluids.len)
			user.forceMove(get_turf(pick(SSfluids.active_fluids)))
		else
			to_chat(user, "No active fluids.")
