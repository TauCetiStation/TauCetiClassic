/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all APCs & sources

	var/newload = 0				// increased by every machines each tick then becomes...
	var/load = 0				// ...the current load on the powernet
	var/newavail = 0			// increased by every machines each tick then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewload = 0			//the load as it appears on the power console (gradually updated)
	var/number = 0				//Unused //TODEL
	var/perapc = 0				// per-apc avilability
	var/netexcess = 0			//excess power on the powernet (typically avail-load)

/datum/powernet/New()
	SSmachines.powernets += src

/datum/powernet/Destroy()
	//Go away references, you suck!
	for(var/obj/structure/cable/C in cables)
		cables -= C
		C.powernet = null
	for(var/obj/machinery/power/M in nodes)
		nodes -= M
		M.powernet = null

	SSmachines.powernets -= src
	return ..()

/datum/powernet/proc/is_empty()
	return !cables.len && !nodes.len

//remove a cable from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/remove_cable(obj/structure/cable/C)
	cables -= C
	C.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it

//add a cable to the current powernet
//Warning : this proc DON'T check if the cable exists
/datum/powernet/proc/add_cable(obj/structure/cable/C)
	if(C.powernet)// if C already has a powernet...
		if(C.powernet == src)
			return
		else
			C.powernet.remove_cable(C) //..remove it
	C.powernet = src
	cables +=C

//remove a power machine from the current powernet
//if the powernet is then empty, delete it
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/remove_machine(obj/machinery/power/M)
	nodes -=M
	M.powernet = null
	if(is_empty())//the powernet is now empty...
		qdel(src)///... delete it


//add a power machine to the current powernet
//Warning : this proc DON'T check if the machine exists
/datum/powernet/proc/add_machine(obj/machinery/power/M)
	if(M.powernet)// if M already has a powernet...
		if(M.powernet == src)
			return
		else
			M.powernet.remove_machine(M) //..remove it
	M.powernet = src
	nodes[M] = M

//handles the power changes in the powernet
//called every ticks by the powernet controller
/datum/powernet/proc/reset()
	load = newload
	newload = 0
	avail = newavail
	newavail = 0


	viewload = 0.8*viewload + 0.2*load

	viewload = round(viewload)

	var/numapc = 0

	if(nodes && nodes.len)
		for(var/obj/machinery/power/terminal/term in nodes)
			if( istype( term.master, /obj/machinery/power/apc ) )
				numapc++

	if(numapc)
		perapc = avail/numapc

	netexcess = avail - load

	if( netexcess > 100)		// if there was excess power last cycle
		if(nodes && nodes.len)
			for(var/obj/machinery/power/smes/S in nodes)	// find the SMESes in the network
				if(S.powernet == src)
					S.restore()				// and restore some of the power that was used
				else
					error("[S.name] (\ref[S]) had a [S.powernet ? "different (\ref[S.powernet])" : "null"] powernet to our powernet (\ref[src]).") //this line is a faggot and using the normal ERROR proc breaks it
					nodes.Remove(S)

/datum/powernet/proc/get_electrocute_damage()
	if(avail >= 1000)
		return clamp(round(avail/10000), 10, 90) + rand(-5,5)
	else
		return 0
