/*
So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
On top of that, now people can add component-speciic procs/vars if they want!
*/

/obj/machinery/atmospherics/components
	var/welded = FALSE //Used on pumps and scrubbers
	var/showpipe = FALSE

	plane = FLOOR_PLANE

	var/list/datum/pipeline/parents
	var/list/datum/gas_mixture/airs

/obj/machinery/atmospherics/components/atom_init()
	parents = new(device_type)
	airs = new(device_type)
	. = ..()

	for(DEVICE_TYPE_LOOP)
		var/datum/gas_mixture/A = new
		A.volume = 200
		AIR_I = A

/*
	Pipenet stuff; housekeeping
*/

/obj/machinery/atmospherics/components/nullifyNode(I)
	..()
	if(NODE_I)
		nullifyPipenet(PARENT_I)
		qdel(AIR_I)
		AIR_I = null

/obj/machinery/atmospherics/components/construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/build_network()
	for(DEVICE_TYPE_LOOP)
		if(!PARENT_I)
			PARENT_I = new /datum/pipeline()
			var/datum/pipeline/P = PARENT_I
			P.build_pipeline(src)

/obj/machinery/atmospherics/components/proc/nullifyPipenet(datum/pipeline/reference)
	var/I = parents.Find(reference)
	reference.other_airs -= AIR_I
	reference.other_atmosmch -= src
	PARENT_I = null

/obj/machinery/atmospherics/components/returnPipenetAir(datum/pipeline/reference)
	var/I = parents.Find(reference)
	return AIR_I

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		var/I = parents.Find(reference)
		return list(NODE_I)
	else
		return ..()

/obj/machinery/atmospherics/components/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	var/I = nodes.Find(A)
	PARENT_I = reference

/obj/machinery/atmospherics/components/returnPipenet(obj/machinery/atmospherics/A = NODE1) //returns PARENT1 if called without argument
	var/I = nodes.Find(A)
	return PARENT_I

/obj/machinery/atmospherics/components/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	var/I = parents.Find(Old)
	PARENT_I = New

/obj/machinery/atmospherics/components/deconstruct(disassembled)
	var/turf/T = get_turf(loc)
	if(!(T && device_type))
		return ..()
	
	//Remove the gas from airs and assume it
	var/datum/gas_mixture/to_release
	for(DEVICE_TYPE_LOOP)
		var/datum/gas_mixture/air = AIR_I
		if(!to_release)
			to_release = new
			to_release.copy_from(air)
			continue
		to_release.merge(air)
	T.assume_air(to_release)

	..()

/*
	Helpers
*/

/obj/machinery/atmospherics/components/proc/update_parents()
	for(DEVICE_TYPE_LOOP)
		var/datum/pipeline/parent = PARENT_I
		if(!parent)
			throw EXCEPTION("Component is missing a pipenet! Rebuilding...")
			build_network()
		parent.update = 1

/obj/machinery/atmospherics/components/returnPipenets()
	. = list()
	for(DEVICE_TYPE_LOOP)
		. += returnPipenet(NODE_I)
