///Footstep component. Plays footsteps at parents location when it is appropriate.
/datum/component/footstep
	///How many steps the parent has taken since the last time a footstep was played.
	var/steps = 0
	///volume determines the extra volume of the footstep. This is multiplied by the base volume, should there be one.
	var/volume
	///e_range stands for extra range - aka how far the sound can be heard. This is added to the base value and ignored if there isn't a base value.
	var/e_range
	///footstep_type is a define which determines what kind of sounds should get chosen.
	var/footstep_type
	///This can be a list OR a soundfile OR null. Determines whatever sound gets played.
	var/footstep_sounds

/datum/component/footstep/Initialize(footstep_type_ = FOOTSTEP_MOB_BAREFOOT, volume_ = 1, e_range_ = 0)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	footstep_type = footstep_type_
	switch(footstep_type)
		if(FOOTSTEP_MOB_HUMAN)
			if(!ishuman(parent))
				return COMPONENT_INCOMPATIBLE
			RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_humanstep)
			return
		if(FOOTSTEP_MOB_CLAW)
			footstep_sounds = global.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			footstep_sounds = global.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			footstep_sounds = global.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			footstep_sounds = global.footstep
		if(FOOTSTEP_MOB_SLIME)
			footstep_sounds = 'sound/effects/mob/footstep/slime1.ogg'
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/play_simplestep) //Note that this doesn't get called for humans.

///Prepares a footstep. Determines if it should get played. Returns the turf it should get played on. Note that it is always a /turf/open
/datum/component/footstep/proc/prepare_step()
	var/turf/simulated/T = get_turf(parent)
	if(!istype(T))
		return

	var/mob/living/LM = parent
	if(!T.footstep || LM.buckled || LM.lying || LM.throwing || LM.crawling || LM.is_ventcrawling)
		if (LM.lying && !LM.buckled && LM.crawling && !(!T.footstep || LM.is_ventcrawling)) //play crawling sound if we're lying
			playsound(T, 'sound/effects/mob/footstep/crawl1.ogg', VOL_EFFECTS_MASTER, 100 * volume)
		return

	if(ishuman(LM))
		var/mob/living/carbon/human/H = LM
		if(!(H.bodyparts_by_name[BP_L_LEG] && H.bodyparts_by_name[BP_L_LEG].is_usable()) && !(H.bodyparts_by_name[BP_R_LEG] && H.bodyparts_by_name[BP_R_LEG].is_usable()))
			return
		if(H.m_intent == MOVE_INTENT_WALK)
			return// stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(steps != 0 && !has_gravity(LM, T)) // don't need to step as often when you hop around
		return
	return T

/datum/component/footstep/proc/play_simplestep()
	var/turf/simulated/T = prepare_step()
	if(!T)
		return
	if(isfile(footstep_sounds) || istext(footstep_sounds))
		playsound(T, footstep_sounds, VOL_EFFECTS_MASTER, volume)
		return
	var/turf_footstep
	switch(footstep_type)
		if(FOOTSTEP_MOB_CLAW)
			turf_footstep = T.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			turf_footstep = T.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			turf_footstep = T.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			turf_footstep = T.footstep
	if(!turf_footstep)
		return
	playsound(T, pick(footstep_sounds[turf_footstep][1]), VOL_EFFECTS_MASTER, footstep_sounds[turf_footstep][2] * volume, TRUE, footstep_sounds[turf_footstep][3] + e_range)

/datum/component/footstep/proc/play_humanstep()
	var/turf/simulated/T = prepare_step()
	if(!T)
		return
	var/mob/living/carbon/human/H = parent

	var/obj/effect/fluid/F = locate(/obj/effect/fluid) in H.loc
	if(F && F.fluid_amount > 0)
		if(F.fluid_amount > 200)
			playsound(T, pick(SOUNDIN_WATER_DEEP), VOL_EFFECTS_MASTER)
			return
		playsound(T, pick(SOUNDIN_WATER_SHALLOW), VOL_EFFECTS_MASTER)
		return

	if(H.shoes) //are we wearing shoes
		playsound(T, pick(global.footstep[T.footstep][1]), VOL_EFFECTS_MASTER, global.footstep[T.footstep][2] * volume, TRUE, global.footstep[T.footstep][3] + e_range)
		H.shoes.play_unique_footstep_sound() // TODO: port https://github.com/tgstation/tgstation/blob/master/code/datums/components/squeak.dm
	else
		playsound(T, pick(global.barefootstep[T.barefootstep][1]), VOL_EFFECTS_MASTER, global.barefootstep[T.barefootstep][2] * volume, TRUE, global.barefootstep[T.barefootstep][3] + e_range)
