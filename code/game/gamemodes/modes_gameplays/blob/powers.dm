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
		flash_color(src, "#187914", 20)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."

	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/obj/structure/blob/node/N in blob_nodes)
			nodes[N.given_name] = N
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/structure/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			flash_color(src, "#187914", 20)
			src.loc = chosen_node.loc

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create/Upgrade Shield Blob (10)"
	set desc = "Create a shield blob. Use it again on existing shield blob to upgrade it into a reflective blob."

	var/turf/T = get_turf(src)
	create_shield(T)

/mob/camera/blob/proc/create_shield(turf/T)

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!isblobnormal(B) && !isblobshield(B)) //Not special blob nor shield to upgrade
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	if(!can_buy(10))
		return

	if(isblobshield(B))
		if(B.get_integrity() < B.max_integrity / 2)
			to_chat(src, "<span class='warning'>This shield blob is too damaged to be modified!</span>")
			return
		B.change_to(/obj/structure/blob/shield/reflective, src)
	else
		B.change_to(/obj/structure/blob/shield)

/mob/camera/blob/verb/relocate_core_power()
	set category = "Blob"
	set name = "Relocate Core (70)"
	set desc = "Swaps a node and your core."

	relocate_core()

/mob/camera/blob/proc/relocate_core()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/node/B = locate() in T
	if(!B)
		to_chat(src, "<span class='warning'>You must be on a blob node!</span>")
		return
	if(isspaceturf(T))
		to_chat(src, "<span class='warning'>You cannot relocate your core here!</span>")
		return
	if(!can_buy(70))
		return
	var/turf/old_turf = get_turf(blob_core)
	blob_core.forceMove(T)
	B.forceMove(old_turf)

/mob/camera/blob/verb/blobbernaut_power()
	set category = "Blob"
	set name = "Create Blobbernaut (40)"
	set desc = "Create a shield blob. Use it again on existing shield blob to upgrade it into a reflective blob."

	create_blobbernaut()

/mob/camera/blob/proc/create_blobbernaut()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/factory/B = locate() in T
	if(!B)
		to_chat(src, "<span class='warning'>You must be on a factory blob!</span>")
		return
	if(B.naut) //if it already made a blobbernaut, it can't do it again
		to_chat(src, "<span class='warning'>This factory blob is already sustaining a blobbernaut.</span>")
		return
	if(B.get_integrity() < B.max_integrity * 0.5)
		to_chat(src, "<span class='warning'>This factory blob is too damaged to sustain a blobbernaut.</span>")
		return
	if(blob_points < 40)
		to_chat(src, "<span class='warning'>You cannot afford this.</span>")
		return FALSE

	B.naut = TRUE //temporary placeholder to prevent creation of more than one per factory.
	to_chat(src, "<span class='notice'>You attempt to produce a blobbernaut.</span>")
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a blobbernaut?", ROLE_BLOB, ROLE_BLOB, 50) //players must answer rapidly
	if(candidates.len) //if we got at least one candidate, they're a blobbernaut now.
		B.max_integrity = B.max_integrity * 0.25 //factories that produced a blobbernaut have much lower health
		B.visible_message("<span class='warning'><b>The blobbernaut [pick("rips", "tears", "shreds")] its way out of the factory blob!</b></span>")
		playsound(B.loc, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER, 50)
		var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(B))
		flick("blobbernaut_produce", blobber)
		B.naut = blobber
		blobber.factory = B
		blobber.overmind = src
		blobber.update_icons()
		blobber.health = blobber.maxHealth * 0.5
		blob_mobs += blobber
		var/mob/dead/observer/C = pick(candidates)
		blobber.key = C.key
		playsound(blobber, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
		to_chat(blobber, "<b>You are a blobbernaut!</b> \
		<br>You are powerful, hard to kill, and slowly regenerate near nodes and cores, <span class='danger'but will slowly die if not near the blob </span> or if the factory that made you is killed. \
		<br>You can communicate with other blobbernauts and overminds<BR>")
		add_points(-40)
	else
		to_chat(src, "<span class='warning'>You could not conjure a sentience for your blobbernaut. Your points have been refunded. Try again later.</span>")
		B.naut = null

/mob/camera/blob/verb/create_resource_power()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Create a resource tower which will generate points for you."


	var/turf/T = get_turf(src)
	create_resource(T)

/mob/camera/blob/proc/create_resource(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/resource/blob in orange(4, T))
		to_chat(src, "There is a resource blob nearby, move more than 4 tiles away from it!")
		return

	if(!can_buy(40))
		return

	B.change_to(/obj/structure/blob/resource, src)


/mob/camera/blob/verb/create_node_power()
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Create a Node."


	var/turf/T = get_turf(src)
	create_node(T)

/mob/camera/blob/proc/create_node(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T

	if(!B)//We are on a blob
		to_chat(src, "There is no blob here!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/node/blob in orange(5, T))
		to_chat(src, "There is another node nearby, move more than 5 tiles away from it!")
		return

	if(!can_buy(60))
		return


	B.change_to(/obj/structure/blob/node)

/mob/camera/blob/verb/create_factory_power()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a Spore producing blob."


	var/turf/T = get_turf(src)
	create_factory(T)

/mob/camera/blob/proc/create_factory(turf/T)
	if(!T)
		return

	var/obj/structure/blob/B = locate() in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(!isblobnormal(B))
		to_chat(src, "Unable to use this blob, find a normal one.")
		return

	for(var/obj/structure/blob/factory/blob in orange(7, T))
		to_chat(src, "There is a factory blob nearby, move more than 7 tiles away from it!")
		return

	if(!can_buy(60))
		return

	var/obj/structure/blob/factory/F = B.change_to(/obj/structure/blob/factory)
	F.OV = src
	factory_blobs += F

/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob."

	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/verb/remove_blob(turf/T)
	var/obj/structure/blob/B = locate() in T
	if(!B)
		to_chat(src, "You must be on a blob!")
		return

	if(isblobcore(B))
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

	var/obj/structure/blob/B = locate() in T
	if(B)
		to_chat(src, "There is a blob here!")
		return

	var/obj/structure/blob/OB = locate() in circlerange(T, 1)
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

	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in blob_mobs)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35 && !BS.stop_automated_movement)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)
	return

/mob/camera/blob/verb/rename_node(obj/structure/blob/node/target in view())
	set category = "Blob"
	set name = "Rename Node"
	set desc = "Rename blob node"

	if(!target)
		return

	var/new_name = sanitize(input(src, "Enter new name for this node:", "Rename Node", target.given_name) as text|null)
	if(new_name)
		target.given_name = new_name

/mob/camera/blob/proc/prompt_upgrade(obj/structure/blob/B)
	var/list/datum/callback/blob_upgrade = list(
		"Resource" = CALLBACK(src, PROC_REF(create_resource)),
		"Node"     = CALLBACK(src, PROC_REF(create_node)),
		"Factory"  = CALLBACK(src, PROC_REF(create_factory)),
	)
	var/static/list/icon/upgrade_icon = list(
		"Resource" = icon('icons/mob/blob.dmi', "radial_resource"),
		"Node"     = icon('icons/mob/blob.dmi', "radial_node"),
		"Factory"  = icon('icons/mob/blob.dmi', "radial_factory"),
	)
	var/choice = show_radial_menu(src, B, upgrade_icon)
	var/datum/callback/CB = blob_upgrade[choice]
	CB?.Invoke(get_turf(B))
