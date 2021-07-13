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
