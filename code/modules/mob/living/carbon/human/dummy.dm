/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays()

//Inefficient pooling/caching way.
var/global/list/human_dummy_list = list()
var/global/list/dummy_mob_list = list()

/proc/generate_or_wait_for_human_dummy(slotkey, species)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	var/mob/living/carbon/human/dummy/D = global.human_dummy_list[slotkey]
	if(istype(D))
		UNTIL(!D.in_use)
	if(QDELETED(D))
		D = new(null, species)
		global.human_dummy_list[slotkey] = D
		global.dummy_mob_list += D
	else
		D.regenerate_icons() //they were cut in wipe_state()
	D.in_use = TRUE
	return D

/proc/generate_dummy_lookalike(slotkey, mob/target)
	if(!istype(target))
		return generate_or_wait_for_human_dummy(slotkey)

	var/mob/living/carbon/human/dummy/copycat = generate_or_wait_for_human_dummy(slotkey)

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		copycat.dna = carbon_target.dna.Clone()

		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			human_target.copy_clothing_prefs(copycat)

		copycat.UpdateAppearance()
	else
		//even if target isn't a carbon, if they have a client we can make the
		//dummy look like what their human would look like based on their prefs
		target?.client?.prefs?.copy_to(copycat, icon_updates=TRUE)

	return copycat

/proc/unset_busy_human_dummy(slotkey)
	if(!slotkey)
		return
	var/mob/living/carbon/human/dummy/D = global.human_dummy_list[slotkey]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE


/proc/clear_human_dummy(slotkey)
	if(!slotkey)
		return

	var/mob/living/carbon/human/dummy/dummy = global.human_dummy_list[slotkey]

	global.human_dummy_list -= slotkey
	if(istype(dummy))
		global.dummy_mob_list -= dummy
		qdel(dummy)
