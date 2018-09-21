/mob/living/carbon/human/gib()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	for(var/obj/item/organ/external/BP in bodyparts)
		// Only make the limb drop if it's not too damaged
		if(prob(100 - BP.get_damage()))
			// Override the current limb status and don't cause an explosion
			BP.droplimb(TRUE, null, DROPLIMB_EDGE)

	flick("gibbed-h", animation)
	if(species)
		hgibs(loc, viruses, dna, species.flesh_color, species.blood_color)
	else
		hgibs(loc, viruses, dna)

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/human/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new /obj/effect/decal/remains/human(loc)

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)


/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)	return
	if(healths)		healths.icon_state = "health5"

	stat = DEAD
	dizziness = 0
	jitteriness = 0
	dog_owner = null

	update_health_hud()
	handle_hud_list()

	//Handle species-specific deaths.
	if(species) species.handle_death(src)

	//Handle brain slugs.
	var/obj/item/organ/external/BP = bodyparts_by_name[BP_HEAD]
	var/mob/living/simple_animal/borer/B

	for(var/I in BP.implants)
		if(istype(I,/mob/living/simple_animal/borer))
			B = I
	if(B)
		if(!B.ckey && ckey && B.controlling)
			B.ckey = ckey
			B.controlling = 0
		if(B.host_brain.ckey)
			ckey = B.host_brain.ckey
			B.host_brain.ckey = null
			B.host_brain.name = "host brain"
			B.host_brain.real_name = "host brain"

		verbs -= /mob/living/carbon/proc/release_control

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if(mode)
		mode.infected_killed(src)
		mode.body_count.Add(mind)

	//Check for heist mode kill count.
	if(ticker.mode && ( istype( ticker.mode,/datum/game_mode/heist) ) )
		//Check for last assailant's mutantrace.
		/*if( LAssailant && ( istype( LAssailant,/mob/living/carbon/human ) ) )
			var/mob/living/carbon/human/V = LAssailant
			if (V.dna && (V.dna.mutantrace == "vox"))*/ //Not currently feasible due to terrible LAssailant tracking.
		//world << "Vox kills: [vox_kills]"
		vox_kills++ //Bad vox. Shouldn't be killing humans.

	if(!gibbed)
		emote("deathgasp") //let the world KNOW WE ARE DEAD

		update_canmove()

		if(is_infected_with_zombie_virus())
			handle_infected_death(src)

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/human/proc/makeSkeleton()
	if(!species || (species.name == SKELETON))
		return
	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"

	set_species(SKELETON)
	status_flags |= DISFIGURED
	regenerate_icons()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in mutations)
		return
	if(f_style)
		f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
	if(h_style)
		h_style = "Bald"

	update_hair()
	mutations.Add(HUSK)
	status_flags |= DISFIGURED	//makes them unknown without fucking up other stuff like admintools
	update_body()
	update_mutantrace()
	return

/mob/living/carbon/human/proc/Drain()
	if(fake_death)
		fake_death = 0
	ChangeToHusk()
	mutations.Add(NOCLONE)
	return
