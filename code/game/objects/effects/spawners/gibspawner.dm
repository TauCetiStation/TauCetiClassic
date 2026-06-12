/obj/effect/gibspawner
	var/sparks = FALSE //whether sparks spread on Gib()
	var/virusProb = 20 //the chance for viruses to spread on the gibs
	var/list/gibtypes = list()
	var/list/gibamounts = list()
	var/list/gibdirections = list() //of lists

/obj/effect/gibspawner/atom_init(mapload, mob/living/M)
	. = ..()

	if(M && HAS_TRAIT(M, TRAIT_NO_MESSY_GIBS))
		return INITIALIZE_HINT_QDEL

	if(gibtypes.len != gibamounts.len || gibamounts.len != gibdirections.len)
		stack_trace("Gib list length mismatch!")
		return INITIALIZE_HINT_QDEL

	var/obj/effect/decal/cleanable/blood/gibs/gib = null

	if(sparks)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
		s.set_up(2, 1, loc)
		s.start()

	for(var/i = 1, i <= gibtypes.len, i++)
		if(gibamounts[i])
			for(var/j = 1, j <= gibamounts[i], j++)
				var/gib_typepath = gibtypes[i]
				gib = new gib_typepath(loc, M)

				if(!M) // fix missing DNA if we can't pass mob (probably shitspawn), copypaste from gibspawner
					if(istype(src, /obj/effect/gibspawner/xeno))
						gib.blood_DNA["UNKNOWN DNA"] = "X*"
					else if(!istype(src, /obj/effect/gibspawner/robot))
						gib.blood_DNA["Non-human DNA"] = BLOOD_A_PLUS

				var/list/directions = gibdirections[i]
				if(directions.len)
					gib.streak(directions)

	return INITIALIZE_HINT_QDEL

/obj/effect/gibspawner/generic
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs/core
		)
	gibamounts = list(2,2,1)

/obj/effect/gibspawner/generic/atom_init()
	gibdirections = list(
		list(WEST, NORTHWEST, SOUTHWEST, NORTH),
		list(EAST, NORTHEAST, SOUTHEAST, SOUTH),
		list()
		)
	. = ..()

/obj/effect/gibspawner/human
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs/down,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs,
		/obj/effect/decal/cleanable/blood/gibs/core
		)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/human/atom_init()
	gibdirections = list(
		list(NORTH, NORTHEAST, NORTHWEST),
		list(SOUTH, SOUTHEAST, SOUTHWEST),
		list(WEST, NORTHWEST, SOUTHWEST),
		list(EAST, NORTHEAST, SOUTHEAST),
		alldirs,
		alldirs,
		list()
		)
	gibamounts[6] = pick(0,1,2)
	. = ..()

/obj/effect/gibspawner/xeno
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs/xeno/up,
		/obj/effect/decal/cleanable/blood/gibs/xeno/down,
		/obj/effect/decal/cleanable/blood/gibs/xeno,
		/obj/effect/decal/cleanable/blood/gibs/xeno,
		/obj/effect/decal/cleanable/blood/gibs/xeno/body,
		/obj/effect/decal/cleanable/blood/gibs/xeno/limb,
		/obj/effect/decal/cleanable/blood/gibs/xeno/core
		)
	gibamounts = list(1,1,1,1,1,1,1)

/obj/effect/gibspawner/xeno/atom_init()
	gibdirections = list(
		list(NORTH, NORTHEAST, NORTHWEST),
		list(SOUTH, SOUTHEAST, SOUTHWEST),
		list(WEST, NORTHWEST, SOUTHWEST),
		list(EAST, NORTHEAST, SOUTHEAST),
		alldirs,
		alldirs,
		list()
		)
	gibamounts[6] = pick(0,1,2)
	. = ..()

/obj/effect/gibspawner/robot
	sparks = TRUE
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs/robot/up,
		/obj/effect/decal/cleanable/blood/gibs/robot/down,
		/obj/effect/decal/cleanable/blood/gibs/robot,
		/obj/effect/decal/cleanable/blood/gibs/robot,
		/obj/effect/decal/cleanable/blood/gibs/robot,
		/obj/effect/decal/cleanable/blood/gibs/robot/limb
		)
	gibamounts = list(1,1,1,1,1,1)

/obj/effect/gibspawner/robot/atom_init()
	gibdirections = list(
		list(NORTH, NORTHEAST, NORTHWEST),
		list(SOUTH, SOUTHEAST, SOUTHWEST),
		list(WEST, NORTHWEST, SOUTHWEST),
		list(EAST, NORTHEAST, SOUTHEAST),
		alldirs,
		alldirs
		)
	gibamounts[6] = pick(0,1,2)
	. = ..()
