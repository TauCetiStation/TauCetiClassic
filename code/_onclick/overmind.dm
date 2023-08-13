// Blob Overmind Controls
/mob/camera/blob/RegularClickOn(atom/A) // Expand blob
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
	var/obj/structure/blob/B = locate() in T
	if(!B)
		return
	if(isblobnormal(B))
		prompt_upgrade(B)
		return
	if(isblobnode(B))
		var/obj/structure/blob/node/N = B
		rename_node(N)
		return
	..()
