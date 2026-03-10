/*
Files of holomap module:
code/modules/holomap/holochip.dm
code/datums/components/holomap.dm
code/modules/holomap/holochips.dm
*/
#define OFFSET_CORRECTOR 6
/datum/component/holomap
	// object we bound to

	var/color_filter = null		//Color for station's image, defined in flags.dm

	var/mob/living/carbon/human/activator = null
	var/obj/item/holder
	var/list/holomap_images = list()
	var/datum/action/toggle_holomap/holomap_toggle_action = null

	var/image/holomap_base
	var/holomap_custom_key

	var/image/self_marker

	var/frequency = "1400"		//Frequency for transmitting data
	var/encryption = 500	//Encryption for double security

/datum/component/holomap/Initialize(atom/movable/AM, _min_dist, _max_dist, datum/callback/_resolve_callback, datum/callback/_master_destroyed_callback, tips = TRUE, _vis_radius = TRUE)
	holder = AM //By default, we can set to our like in item itself
	holomap_toggle_action = new(src)
	if(holomap_custom_key)
		holomap_base = SSholomaps.get_custom_holomap(holomap_custom_key)
	else
		holomap_base = SSholomaps.get_default_holomap()
	instantiate_self_marker()

	RegisterSignal(SSholomaps, COMSIG_HOLOMAP_REGENERATED, PROC_REF(update_holomap_image))
	//RegisterSignal(master, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED), PROC_REF(check_bounds))
	//RegisterSignal(master, list(COMSIG_PARENT_QDELETING), PROC_REF(on_master_destroyed))

/datum/component/holomap/Destroy()
	//UnregisterSignal(master, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED))

	STOP_PROCESSING(SSholomaps, src)
	deactivate_holomap()
	holomap_base = null
	QDEL_NULL(self_marker)
	QDEL_LIST(holomap_images)
	QDEL_NULL(holomap_toggle_action)
	holder = null
	activator = null
	freq_remove()
	return ..()

/datum/component/holomap/proc/add_action(mob/living/carbon/human/wearer)
	holomap_toggle_action.Grant(wearer)
	holomap_toggle_action.UpdateButtonIcon()

/datum/component/holomap/proc/remove_action(mob/living/carbon/human/wearer)
	holomap_toggle_action.Remove(wearer)

/datum/component/holomap/process()
	if(!activator || !activator.client || activator.stat == DEAD || activator.head != holder)
		deactivate_holomap()
		return
	handle_markers()

/datum/component/holomap/proc/activate_holomap(mob/user)
	if(activator)
		return
	update_freq(frequency)
	activator = user
	if(holomap_custom_key)
		holomap_base = SSholomaps.get_custom_holomap(holomap_custom_key)
	else
		holomap_base = SSholomaps.get_default_holomap()
	if(color_filter)
		holomap_base.color = color_filter
	activator.holomap_obj?.add_overlay(holomap_base)
	START_PROCESSING(SSholomaps, src)

/datum/component/holomap/proc/deactivate_holomap()
	freq_remove()
	STOP_PROCESSING(SSholomaps, src) //No matter what
	if(!activator || !activator.holomap_obj)
		return
	activator.holomap_obj?.cut_overlay(holomap_base)
	if(length(holomap_images) && activator.client)
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	holomap_base = null
	activator = null

/datum/component/holomap/proc/update_holomap_image(datum/source, key)
	SIGNAL_HANDLER

	if(holomap_custom_key != key)
		return

	if(activator && activator.holomap_obj)
		var/mob/user = activator
		deactivate_holomap()
		activate_holomap(user)

/datum/component/holomap/proc/handle_markers()
	if(!activator || !activator.client)
		deactivate_holomap()
		return
	if(length(holomap_images))
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	for(var/datum/component/holomap/HM in SSholomaps.holomap_components[frequency])
		if(HM.frequency != frequency)
			HM.update_freq(HM.frequency)
			continue
		if(HM.encryption != encryption)
			continue
		if(HM == src)
			handle_own_marker()
			continue
		if(!SSholomaps.holomap_cache[HM])
			continue
		var/image/I = SSholomaps.holomap_cache[HM]
		I.loc = activator.holomap_obj
		holomap_images += I
		animate(I, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I, alpha = 0, time = 5, easing = SINE_EASING)
		animate(I, alpha = 255, time = 2, easing = SINE_EASING)

	handle_markers_extra()

	activator.client.images |= holomap_images

/datum/component/holomap/proc/handle_markers_extra()    // For shuttle markers and other stuff
	return

/datum/component/holomap/proc/update_freq(new_frequency) //For structurizing holochip' markers
	if(!new_frequency)
		return

	if(frequency)
		var/old_freq = frequency //Handle old freq
		if(SSholomaps.holomap_components[old_freq])
			SSholomaps.holomap_components[old_freq] -= src
			if(!length(SSholomaps.holomap_components[old_freq]))
				SSholomaps.holomap_components -= old_freq

	var/texted_freq = new_frequency //Handle new freq
	var/freque = SSholomaps.holomap_components[texted_freq]
	if(!freque) //We need new freq
		SSholomaps.holomap_components[texted_freq] = list()
		SSholomaps.holomap_components[texted_freq] += src
	else //Add to existing freq
		freque += src

/datum/component/holomap/proc/freq_remove()
	if(SSholomaps.holomap_components[frequency] && (src in SSholomaps.holomap_components[frequency]))
		SSholomaps.holomap_components[frequency] -= src

/datum/component/holomap/proc/handle_own_marker()
	if(!self_marker)   // Dunno why but it happens in runtime
		instantiate_self_marker()
	self_marker.loc = activator.holomap_obj
	var/turf/src_turf = get_turf(src)
	self_marker.pixel_x = (src_turf.x - OFFSET_CORRECTOR) * PIXEL_MULTIPLIER
	self_marker.pixel_y = (src_turf.y - OFFSET_CORRECTOR) * PIXEL_MULTIPLIER
	animate(self_marker, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
	animate(self_marker, alpha = 0, time = 5, easing = SINE_EASING)
	animate(self_marker, alpha = 255, time = 2, easing = SINE_EASING)
	holomap_images += self_marker

/datum/component/holomap/proc/instantiate_self_marker()
	self_marker = image('icons/holomaps/holomap_markers.dmi', "you")
	self_marker.plane = ABOVE_HUD_PLANE
	self_marker.layer = ABOVE_HUD_LAYER

//HOLOCHIP ACTION
/datum/action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE
	button_icon_state = "holomap"

/datum/action/toggle_holomap/Activate()
	to_chat(owner, "<span class='notice'>You activate the holomap.</span>")
	var/datum/component/holomap/holomap = target
	holomap.update_freq(holomap.frequency)
	holomap.activate_holomap(owner)
	active = TRUE

/datum/action/toggle_holomap/Deactivate()
	var/datum/component/holomap/holomap = target
	holomap.deactivate_holomap()
	to_chat(owner, "<span class='notice'>You deactivate the holomap.</span>")
	active = FALSE
