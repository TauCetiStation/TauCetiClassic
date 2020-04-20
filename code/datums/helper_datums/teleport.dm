//wrapper
/proc/do_teleport(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null, adest_checkdensity = 1, arespect_entrydir=null, aentrydir=null, checkspace=null)
	var/datum/teleport/instant/science/D = new
	if(D.start(arglist(args)))
		return 1
	return 0

/datum/teleport
	var/atom/movable/teleatom //atom to teleport
	var/atom/destination //destination to teleport to
	var/precision = 0 //teleport precision
	var/datum/effect/effect/system/effectin //effect to show right before teleportation
	var/datum/effect/effect/system/effectout //effect to show right after teleportation
	var/soundin //soundfile to play before teleportation
	var/soundout //soundfile to play after teleportation
	var/force_teleport = 1 //if false, teleport will use Move() proc (dense objects will prevent teleportation)
	var/dest_checkdensity = TELE_CHECK_NONE //if we can't teleport onto dense atoms (more advanced method of the above).
	var/dest_checkspace = 0
	                                        //NONE means - yes, we can! TURFS - yes, if no dense turfs. ALL - no, we can't at all.
	var/respect_entrydir = FALSE            //respects atom entry dir (if we enter from north, then we can exit only from south).
	var/entrydir = SOUTH


/datum/teleport/proc/start(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null, adest_checkdensity=null, arespect_entrydir=null, aentrydir=null, checkspace=null)
	if(!initTeleport(arglist(args)))
		return 0
	return 1

/datum/teleport/proc/initTeleport(ateleatom,adestination,aprecision,afteleport,aeffectin,aeffectout,asoundin,asoundout,adest_checkdensity,arespect_entrydir,aentrydir,checkspace)
	if(!setTeleatom(ateleatom))
		return 0
	if(!setDestination(adestination))
		return 0
	if(!setPrecision(aprecision))
		return 0
	if(adest_checkdensity)
		dest_checkdensity = adest_checkdensity
	if(checkspace)
		dest_checkspace = checkspace
	if(arespect_entrydir)
		respect_entrydir = arespect_entrydir
	if(aentrydir)
		entrydir = aentrydir
	setEffects(aeffectin,aeffectout)
	setForceTeleport(afteleport)
	setSounds(asoundin,asoundout)
	return 1

//must succeed
/datum/teleport/proc/setPrecision(aprecision)
	if(isnum(aprecision))
		precision = aprecision
		return 1
	return 0

//must succeed
/datum/teleport/proc/setDestination(atom/adestination)
	if(istype(adestination))
		destination = adestination
		return 1
	return 0

//must succeed in most cases
/datum/teleport/proc/setTeleatom(atom/movable/ateleatom)
	if(istype(ateleatom, /obj/effect) && !istype(ateleatom, /obj/effect/dummy/chameleon))
		qdel(ateleatom)
		return 0
	if(istype(ateleatom))
		teleatom = ateleatom
		return 1
	return 0

//custom effects must be properly set up first for instant-type teleports
//optional
/datum/teleport/proc/setEffects(datum/effect/effect/system/aeffectin=null,datum/effect/effect/system/aeffectout=null)
	effectin = istype(aeffectin) ? aeffectin : null
	effectout = istype(aeffectout) ? aeffectout : null
	return 1

//optional
/datum/teleport/proc/setForceTeleport(afteleport)
	force_teleport = afteleport
	return 1

//optional
/datum/teleport/proc/setSounds(asoundin=null,asoundout=null)
	soundin = isfile(asoundin) ? asoundin : null
	soundout = isfile(asoundout) ? asoundout : null
	return 1

//placeholder
/datum/teleport/proc/teleportChecks()
	return 1

/datum/teleport/proc/playSpecials(atom/location,datum/effect/effect/system/effect,sound)
	if(location)
		if(effect)
			spawn(0)
				src = null
				effect.attach(location)
				effect.start()
		if(sound)
			spawn(0)
				src = null
				playsound(location, sound, VOL_EFFECTS_MASTER)
	return

//do the monkey dance
/datum/teleport/proc/doTeleport()
	var/turf/destturf
	var/turf/curturf = get_turf(teleatom)
	if(precision)
		var/list/posturfs = list()
		var/turf/center = get_turf(destination)
		if(!center)
			return 0
		if(respect_entrydir)
			var/turf/T = get_step(destination, entrydir)
			if(!density_checks(T))
				return 0
			if(dest_checkspace && istype(T, /turf/space))
				return 0
			posturfs += T
		else
			for(var/turf/T in RANGE_TURFS(precision,center))
				if(!density_checks(T))
					continue
				if(dest_checkspace && istype(T, /turf/space))
					continue
				posturfs += T
		destturf = safepick(posturfs - center)
	else
		destturf = get_turf(destination)
		if(istype(destturf, /turf/space) && (destturf.x <= TRANSITIONEDGE || destturf.x >= (world.maxx - TRANSITIONEDGE - 1) || destturf.y <= TRANSITIONEDGE || destturf.y >= (world.maxy - TRANSITIONEDGE - 1)))
			return 0

	if(!destturf || !curturf)
		return 0

	playSpecials(curturf,effectin,soundin)

	if(force_teleport)
		if(teleatom.buckled_mob)
			teleatom.unbuckle_mob()
		teleatom.forceMove(destturf)
		playSpecials(destturf,effectout,soundout)
	else
		if(teleatom.Move(destturf))
			playSpecials(destturf,effectout,soundout)

	if(isliving(teleatom))
		var/mob/living/L = teleatom
		if(L.buckled)
			L.buckled.unbuckle_mob()

	teleatom.newtonian_move(entrydir)
	return 1

/datum/teleport/proc/teleport()
	if(teleportChecks())
		return doTeleport()
	return 0

/datum/teleport/proc/density_checks(turf/T)
	var/turf/center = get_turf(destination)
	if(T == center)
		return FALSE
	if(istype(T, /turf/space) && (T.x <= TRANSITIONEDGE || T.x >= (world.maxx - TRANSITIONEDGE - 1) || T.y <= TRANSITIONEDGE || T.y >= (world.maxy - TRANSITIONEDGE - 1)))
		return FALSE //No teleports into the void, dunno how to fix that with another method.
	if(locate(/obj/effect/portal) in T)
		return FALSE
	if(dest_checkdensity)
		if(T.density)
			return FALSE
		if(dest_checkdensity == TELE_CHECK_ALL)
			T.Enter(teleatom)                   //We want do normal bumping/checks with teleatom first (maybe we got access to that door or to push the atom on the other side),
			var/obj/effect/E = new(center)      //then we do the real check (if we can enter from destination turf onto target turf).
			E.invisibility = 101                //Because, checking this with teleatom - won't give us accurate data, since teleatom is far away at this time.
			if(!T.Enter(E))                     //That's why we test this with the "fake dummy".
				qdel(E)
				return FALSE
			qdel(E)
	return TRUE

//teleports when datum is created
/datum/teleport/instant/start(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	if(..())
		if(teleport())
			return 1
	return 0


/datum/teleport/instant/science/setEffects(datum/effect/effect/system/aeffectin,datum/effect/effect/system/aeffectout)
	if(aeffectin==null || aeffectout==null)
		var/datum/effect/effect/system/spark_spread/aeffect = new
		aeffect.set_up(5, 1, teleatom)
		effectin = effectin || aeffect
		effectout = effectout || aeffect
		return 1
	else
		return ..()

/datum/teleport/instant/science/setPrecision(aprecision)
	..()
	if(istype(teleatom, /obj/item/weapon/storage/backpack/holding))
		precision = rand(1,100)

	var/list/bagholding = teleatom.search_contents_for(/obj/item/weapon/storage/backpack/holding)
	if(bagholding.len)
		precision = max(rand(1,100)*bagholding.len,100)
		if(istype(teleatom, /mob/living))
			var/mob/living/MM = teleatom
			to_chat(MM, "<span class='warning'>The bluespace interface on your bag of holding interferes with the teleport!</span>")
	return 1
