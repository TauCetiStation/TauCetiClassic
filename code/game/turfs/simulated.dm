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
	var/footstep
	var/barefootstep
	var/clawfootstep
	var/heavyfootstep

/turf/simulated/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/simulated/atom_init_late()
	levelupdate()

/turf/simulated/proc/AddTracks(mob/M,bloodDNA,comingdir,goingdir, blooddatum = null)
	var/typepath
	if(ishuman(M))
		typepath = /obj/effect/decal/cleanable/blood/tracks/footprints
	else if(isxeno(M))
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
		to_chat(usr, "<span class='warning'>Movement is admin-disabled.</span>")//This is to identify lag problems
		return

	if (istype(A, /mob/living/simple_animal/hulk))
		var/mob/living/simple_animal/hulk/Hulk = A
		if(!Hulk.lying)
			playsound(src, 'sound/effects/hulk_step.ogg', VOL_EFFECTS_MASTER)
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
		newblood.basedatum = new(M.species.blood_datum)
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
			this.basedatum = new(H.species.blood_datum)
		else
			this.basedatum = new/datum/dirt_cover/red_blood()
		this.update_icon()

		this.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

	else if( istype(M, /mob/living/carbon/xenomorph ))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"

	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/blood/oil(src)

/turf/simulated/proc/add_vomit_floor(mob/living/carbon/C, toxvomit = 0)
	var/obj/effect/decal/cleanable/vomit/V = new /obj/effect/decal/cleanable/vomit(src)
	// Make toxins vomit look different
	if(toxvomit)
		var/datum/reagent/new_color = locate(/datum/reagent/luminophore) in C.reagents.reagent_list
		if(!new_color)
			V.icon_state = "vomittox_[pick(1,4)]"
		else
			V.icon_state = "vomittox_nc_[pick(1,4)]"
			V.alpha = 127
			V.color = new_color.color
			V.light_color = V.color
			V.set_light(3)
			V.stop_light()

//Wet floor procs.
/turf/simulated/proc/make_wet_floor(severity = WATER_FLOOR)
	addtimer(CALLBACK(src, .proc/make_dry_floor), rand(71 SECONDS, 80 SECONDS), TIMER_UNIQUE|TIMER_OVERRIDE)
	if(wet < severity)
		wet = severity
		UpdateSlip()

		if(severity < LUBE_FLOOR) // Thats right, lube does not add nor clean wet overlay. So if the floor was wet before and we add lube, wet overlay simply stays longer.
			if(!wet_overlay)      // For stealth - floor must be dry, so added lube effect will be invisible.
				wet_overlay = image('icons/effects/water.dmi', "wet_floor", src)
				add_overlay(wet_overlay)

/turf/simulated/proc/make_dry_floor()
	if(wet)
		if(wet_overlay)
			cut_overlay(wet_overlay)
			wet_overlay = null
		wet = 0
		UpdateSlip()

/turf/simulated/proc/UpdateSlip()
	switch(wet)
		if(WATER_FLOOR)
			AddComponent(/datum/component/slippery, 5, NO_SLIP_WHEN_WALKING)
		if(LUBE_FLOOR)
			AddComponent(/datum/component/slippery, 10, SLIDE | GALOSHES_DONT_HELP)
		else
			qdel(GetComponent(/datum/component/slippery))
