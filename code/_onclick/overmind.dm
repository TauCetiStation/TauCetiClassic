// Blob Overmind Controls
/mob/camera/blob/RegularClickOn(atom/A, params) // Expand blob
	var/turf/T = get_turf(A)
	if(T)
		expand_blob(T)
	return TRUE

/mob/camera/blob/CtrlClickOn(atom/A) // Remove blob
	var/turf/T = get_turf(A)
	if(T)
		remove_blob(T)

/mob/camera/blob/MiddleClickOn(atom/A) // Rally spores
	var/turf/T = get_turf(A)
	if(T)
		rally_spores(T)

/mob/camera/blob/AltClickOn(atom/A) // Create a shield
	var/turf/T = get_turf(A)
	if(T)
		create_shield(T)

/mob/camera/blob/ShiftClickOn(atom/A)
	var/turf/T = get_turf(A)
	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		return
	if(isblobnormal(B))
		var/static/list/blob_upgrade = list(
			"Cancel"   = null,
			"Resource" = .proc/create_resource,
			"Node"     = .proc/create_node,
			"Factory"  = .proc/create_factory,
		)
		// fsr tgui_alerts cannot handle associative lists...
		var/list/buttons = new
		for(var/btn in blob_upgrade)
			buttons.Add(btn)
		var/choice = tgui_alert(src, "Choose new blob type", "Blob Evolution", buttons)
		if(choice && blob_upgrade[choice])
			var/action = blob_upgrade[choice]
			call(src, action)(T)
		return
	if(isblobnode(B))
		var/obj/effect/blob/node/N = B
		rename_node(N)
		return
	..()