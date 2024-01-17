/mob/living/carbon/human/spawn_gibs()
	if(!species.flags[NO_BLOOD_TRAILS])
		hgibs(loc, dna, species.flesh_color, species.blood_datum)

/mob/living/carbon/human/gib()
	if(!species.flags[NO_BLOOD_TRAILS])
		var/atom/movable/overlay/animation = new (loc)
		flick(icon('icons/mob/mob.dmi', "gibbed-h"), animation)
		QDEL_IN(animation, 2 SECOND)

	for(var/obj/item/organ/external/BP in bodyparts)
		// Only make the limb drop if it's not too damaged
		if(prob(100 - BP.get_damage()))
			// Override the current limb status and don't cause an explosion
			BP.droplimb(TRUE, null, DROPLIMB_EDGE)

	..()

/mob/living/carbon/human/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/effect/decal/remains/human/burned(loc)
	dust_process()

/mob/living/carbon/human/death(gibbed)
	if(stat == DEAD)
		return

	//Handle species-specific deaths.
	if(species?.handle_death(src, gibbed))
		return // death handled by species

	stat = DEAD
	dizziness = 0
	jitteriness = 0

	med_hud_set_health()
	med_hud_set_status()

	if(mind && is_station_level(z))
		global.deaths_during_shift++

	//Check for heist mode kill count.
	if(find_faction_by_type(/datum/faction/heist))
		vox_kills++ //Bad vox. Shouldn't be killing humans.

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp") //let the world KNOW WE ARE DEAD

		update_canmove()

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(SSticker && SSticker.mode)
//		world.log << "k"
		sql_report_death(src)
	if(my_golem)
		my_golem.death()
	if(my_master)
		my_master.my_golem = null
		my_master = null

	if(isshadowling(src))
		var/datum/faction/shadowlings/faction = find_faction_by_type(/datum/faction/shadowlings)
		for(var/datum/role/thrall/T in faction.members)
			if(!T.antag.current)
				continue
			SEND_SIGNAL(T.antag.current, COMSIG_CLEAR_MOOD_EVENT, "thralled")
			SEND_SIGNAL(T.antag.current, COMSIG_ADD_MOOD_EVENT, "master_died", /datum/mood_event/master_died)
			to_chat(T.antag.current, "<span class='shadowling'><font size=3>Sudden realization strikes you like a truck! ONE OF OUR MASTERS HAS DIED!!!</span></font>")

	..(gibbed)

	SSStatistics.add_death_stat(src)

// Called right after we will lost our head
/mob/living/carbon/human/proc/handle_decapitation(obj/item/organ/external/head/BP)
	if(!BP || (BP in bodyparts))
		return

	//Handle brain slugs.
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


	organ_head_list += BP

	if(ischangeling(src))
		var/datum/role/changeling/Host = mind.GetRoleByType(/datum/role/changeling)
		if(Host.chem_charges >= 35 && Host.geneticdamage < 10)
			for(var/obj/effect/proc_holder/changeling/headcrab/crab in Host.purchasedpowers)
				crab.sting_action(src)
			return

	var/obj/item/organ/internal/IO = organs_by_name[O_BRAIN]
	if(IO && IO.parent_bodypart == BP_HEAD)
		SSStatistics.add_death_stat(src) // because mind transfer to brain
		BP.transfer_identity(src)

		BP.name = "[real_name]'s head"

		if(BP.vital)
			death()
			BP.brainmob.death()
			if(HAS_TRAIT(src, TRAIT_NO_CLONE))
				ADD_TRAIT(BP.brainmob, TRAIT_NO_CLONE, GENERIC_TRAIT)

			tod = null // These lines prevent reanimation if head was cut and then sewn back, you can only clone these bodies
			timeofdeath = 0

/obj/item/organ/external/head/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src


/mob/living/carbon/human/proc/makeSkeleton()
	if(!species || (isskeleton(src)))
		return
	if(f_style)
		f_style = "Shaved"
	if(h_style)
		h_style = "Bald"
	set_species(species.skeleton_type)
	add_status_flags(DISFIGURED)
	regenerate_icons()
	return

/mob/living/carbon/human/proc/ChangeToHusk()
	if(HUSK in mutations)
		return
	if(species.flags[HAS_HAIR])
		if(f_style)
			f_style = "Shaved" // we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
		if(h_style)
			h_style = "Bald"
	else if(species.name == SKRELL)
		r_hair = 85
		g_hair = 85 // grey
		b_hair = 85

	mutations.Add(HUSK)
	add_status_flags(DISFIGURED)	//makes them unknown without fucking up other stuff like admintools
	update_hair()
	update_body()

/mob/living/carbon/human/proc/Drain()
	if(fake_death)
		fake_death = 0
	ChangeToHusk()
	mutations.Add(NOCLONE)
	return
