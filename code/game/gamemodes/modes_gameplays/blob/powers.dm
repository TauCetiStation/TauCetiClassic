// Point controlling procs

/mob/camera/blob/proc/can_buy(cost = 15)
	if(blob_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this.</span>")
		return FALSE
	add_points(-cost)
	return TRUE

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Transport back to your core."

	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/obj/effect/blob/node/N in blob_nodes)
			nodes[N.given_name] = N
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/effect/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob (10)"
	set desc = "Create a shield blob."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(turf/T)

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	if(!can_buy(10))
		return


	B.change_to(/obj/effect/blob/shield)

/mob/camera/blob/verb/create_resource_power()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)
	create_resource(T)

/mob/camera/blob/proc/create_resource(turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/resource/blob in orange(4, T))
		to_chat(src, "There is a resource blob nearby, move more than 4 tiles away from it!")
		return

	if(!can_buy(40))
		return


	B.change_to(/obj/effect/blob/resource)
	var/obj/effect/blob/resource/R = locate() in T
	if(R)
		R.overmind = src


/mob/camera/blob/verb/create_node_power()
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)
	create_node(T)

/mob/camera/blob/proc/create_node(turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/node/blob in orange(5, T))
		to_chat(src, "There is another node nearby, move more than 5 tiles away from it!")
		return

	if(!can_buy(60))
		return


	B.change_to(/obj/effect/blob/node)

/mob/camera/blob/verb/create_factory_power()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)
	create_factory(T)

/mob/camera/blob/proc/create_factory(turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(!istype(B, /obj/effect/blob/normal))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/effect/blob/factory/blob in orange(7, T))
		to_chat(src, "There is a factory blob nearby, move more than 7 tiles away from it!")
		return

	if(!can_buy(60))
		return

	B.change_to(/obj/effect/blob/factory)

/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/verb/remove_blob(turf/T)
	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(istype(B, /obj/effect/blob/core))
		to_chat(src, "Unable to remove this blob.")
		return

	qdel(B)


/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob (5)"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."

	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(turf/T)
	if(!T)
		return

	var/obj/effect/blob/B = locate() in T
	if(B)
		to_chat(src, "There is a blob here!")
		return

	var/obj/effect/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		to_chat(src, "There is no blob adjacent to you.")
		return

	if(!can_buy(5))
		return
	OB.expand(T, 0)
	return


/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores (5)"
	set desc = "Rally the spores to move to your location."

	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(turf/T)

	if(!can_buy(5))
		return

	to_chat(src, "You rally your spores.")

	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return

	for(var/mob/living/simple_animal/hostile/blobspore/BS in alive_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/rename_node(obj/effect/blob/node/target in view())
	set category = "Blob"
	set name = "Rename Node"
	set desc = "Rename blob node"

	if(!target)
		return

	var/new_name = sanitize(input(src, "Enter new name for this node:", "Rename Node", target.given_name) as text|null)
	if(new_name)
		target.given_name = new_name

/mob/camera/blob/proc/prompt_upgrade(obj/effect/blob/B)
	var/list/datum/callback/blob_upgrade = list(
		"Resource" = CALLBACK(src, .proc/create_resource),
		"Node"     = CALLBACK(src, .proc/create_node),
		"Factory"  = CALLBACK(src, .proc/create_factory),
	)
	var/static/list/icon/upgrade_icon = list(
		"Resource" = icon('icons/mob/blob.dmi', "radial_resource"),
		"Node"     = icon('icons/mob/blob.dmi', "radial_node"),
		"Factory"  = icon('icons/mob/blob.dmi', "radial_factory"),
	)
	var/choice = show_radial_menu(src, B, upgrade_icon)
	var/datum/callback/CB = blob_upgrade[choice]
	CB?.Invoke(get_turf(B))
