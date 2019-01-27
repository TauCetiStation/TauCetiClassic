/turf/simulated
	name = "station"
	plane = FLOOR_PLANE

	var/wet = 0
	var/image/wet_overlay = null
	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/dirt = 0

/turf/simulated/atom_init()
	. = ..()
	levelupdate()

/turf/simulated/proc/AddTracks(mob/M,bloodDNA,comingdir,goingdir, blooddatum = null)
	var/typepath
	if(ishuman(M))
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints
	else if(isalien(M))
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints/claws
	else // can shomeone make shlime footprint shprites later pwetty pwease?
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints/paws

	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	if(!blooddatum)
		blooddatum = new /datum/dirt_cover/red_blood
	tracks.AddTracks(bloodDNA,comingdir,goingdir,blooddatum)

/turf/simulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "\red Movement is admin-disabled.")//This is to identify lag problems
		return

	if (istype(A, /mob/living/simple_animal/hulk))
		var/mob/living/simple_animal/hulk/Hulk = A
		if(!Hulk.lying)
			playsound(src, 'sound/effects/hulk_step.ogg', 50, 1)
	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying && !M.crawling)        return

		dirt++
		if (dirt >= 200)
			var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, src)

			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(src)
				dirtoverlay.alpha = 20
			else
				dirtoverlay.alpha = min(dirtoverlay.alpha+5, 255)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M

			//Footstep sound
			if(istype(H:shoes, /obj/item/clothing/shoes) && !H.buckled)
				var/obj/item/clothing/shoes/O = H.shoes

				var/footstepsound = "footsteps"

				if(istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
					footstepsound = "clownstep"
				if(H.shoes.wet)
					footstepsound = 'sound/effects/waterstep.ogg'

				if(H.m_intent == "run")
					if(O.footstep >= 2)
						O.footstep = 0
						playsound(src, footstepsound, 50, 1)
					else
						O.footstep++
				else
					playsound(src, footstepsound, 20, 1)

		// Tracking blood
		var/list/bloodDNA = null
		var/datum/dirt_cover/blooddatum
		if(M.shoes)
			var/obj/item/clothing/shoes/S = M.shoes
			if(S.track_blood && S.blood_DNA)
				bloodDNA   = S.blood_DNA
				blooddatum = new/datum/dirt_cover(S.dirt_overlay)
				S.track_blood--
		else
			if(M.track_blood && M.feet_blood_DNA)
				bloodDNA   = M.feet_blood_DNA
				blooddatum = new/datum/dirt_cover(M.feet_dirt_color)
				M.track_blood--

		if (bloodDNA)
			src.AddTracks(M,bloodDNA,M.dir,0,blooddatum) // Coming
			var/turf/simulated/from = get_step(M,reverse_direction(M.dir))
			if(istype(from) && from)
				from.AddTracks(M,bloodDNA,0,M.dir,blooddatum) // Going

			bloodDNA = null

		switch (src.wet)
			if(1)
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && !((istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP) || (istype(M:wear_suit, /obj/item/clothing/suit/space/rig) && M:wear_suit.flags&NOSLIP)))
						M.slip("the wet floor", 5, 3)
					else
						M.inertia_dir = 0
						return
				else
					if (M.m_intent == "run")
						M.slip("the wet floor", 5, 3)
					else
						M.inertia_dir = 0
						return

			if(2) //lube                //can cause infinite loops - needs work
				M.stop_pulling()
				step(M, M.dir)
				spawn(1) step(M, M.dir)
				spawn(2) step(M, M.dir)
				spawn(3) step(M, M.dir)
				spawn(4) step(M, M.dir)
				M.take_bodypart_damage(2) // Was 5 -- TLE
				M.slip("the floor", 0, 10)
			if(3) // Ice
				if(istype(M, /mob/living/carbon/human)) // Added check since monkeys don't have shoes
					if ((M.m_intent == "run") && (!(istype(M:shoes, /obj/item/clothing/shoes) && M:shoes.flags&NOSLIP) || !(istype(M:wear_suit, /obj/item/clothing/suit/space/rig) && M:wear_suit.flags&NOSLIP)) && prob(30))
						M.slip("the icy floor", 4, 3)
						step(M, M.dir)
					else
						M.inertia_dir = 0
						return
				else
					if (M.m_intent == "run" && prob(30))
						M.slip("the icy floor", 4, 3)
						step(M, M.dir)
					else
						M.inertia_dir = 0
						return

	..()

//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(mob/living/carbon/human/M)
	if (!..())
		return 0

	for(var/obj/effect/decal/cleanable/blood/B in contents)
		if(!B.blood_DNA[M.dna.unique_enzymes])
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			B.virus2 = virus_copylist(M.virus2)
		return 1 //we bloodied the floor



	//if there isn't a blood decal already, make one.
	var/obj/effect/decal/cleanable/blood/newblood = new /obj/effect/decal/cleanable/blood(src)

	//Species-specific blood.
	if(M.species)
		newblood.basedatum = new M.species.blood_color
	else
		newblood.basedatum = new/datum/dirt_cover/red_blood()

	newblood.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	newblood.virus2 = virus_copylist(M.virus2)
	newblood.update_icon()

	return 1 //we bloodied the floor


// Only adds blood on the floor -- Skie
/turf/simulated/proc/add_blood_floor(mob/living/carbon/M)
	if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/Monkey = M
		var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)
		this.blood_DNA[Monkey.dna.unique_enzymes] = Monkey.dna.b_type
		this.basedatum = new Monkey.blood_datum
		this.update_icon()

	else if(istype(M,/mob/living/carbon/human))

		var/obj/effect/decal/cleanable/blood/this = new /obj/effect/decal/cleanable/blood(src)
		var/mob/living/carbon/human/H = M

		//Species-specific blood.
		if(H.species)
			this.basedatum = new/datum/dirt_cover(H.species.blood_color)
		else
			this.basedatum = new/datum/dirt_cover/red_blood()
		this.update_icon()

		this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

	else if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"

	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/blood/oil(src)

//Wet floor procs.
/turf/simulated/proc/make_wet_floor(severity = WATER_FLOOR)
	if(wet < severity)
		wet = severity

		if(severity < LUBE_FLOOR) // Thats right, lube does not add nor clean wet overlay. So if the floor was wet before and we add lube, wet overlay simply stays longer.
			if(!wet_overlay)      // For stealth - floor must be dry, so added lube effect will be invisible.
				wet_overlay = image('icons/effects/water.dmi', "wet_floor", src)
				overlays += wet_overlay

		addtimer(CALLBACK(src, .proc/make_dry_floor), rand(710,800), TIMER_UNIQUE|TIMER_OVERRIDE)

/turf/simulated/proc/make_dry_floor()
	if(wet)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		wet = 0
