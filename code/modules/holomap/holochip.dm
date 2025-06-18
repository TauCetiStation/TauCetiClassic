#define OFFSET_CORRECTOR 6
/obj/item/holochip
	name = "Holomap chip"
	desc = "A small holomap module, attached to helmets."
	icon = 'icons/holomaps/holochips.dmi'
	icon_state = "holochip"
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

/obj/item/holochip/atom_init(obj/item/I)
	. = ..()
	holder = I
	holomap_toggle_action = new(src)
	if(holomap_custom_key)
		holomap_base = SSholomaps.get_custom_holomap(holomap_custom_key)
	else
		holomap_base = SSholomaps.get_default_holomap()
	instantiate_self_marker()
	RegisterSignal(SSholomaps, COMSIG_HOLOMAP_REGENERATED, PROC_REF(update_holomap_image))

/obj/item/holochip/Destroy()
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

/obj/item/holochip/proc/add_action(mob/living/carbon/human/wearer)
	holomap_toggle_action.Grant(wearer)
	holomap_toggle_action.UpdateButtonIcon()

/obj/item/holochip/proc/remove_action(mob/living/carbon/human/wearer)
	holomap_toggle_action.Remove(wearer)

/obj/item/holochip/process()
	if(!activator || !activator.client || activator.stat == DEAD || activator.head != holder)
		deactivate_holomap()
		return
	handle_markers()

/obj/item/holochip/proc/activate_holomap(mob/user)
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

/obj/item/holochip/proc/deactivate_holomap()
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

/obj/item/holochip/proc/update_holomap_image(datum/source, key)
	SIGNAL_HANDLER

	if(holomap_custom_key != key)
		return

	if(activator && activator.holomap_obj)
		var/mob/user = activator
		deactivate_holomap()
		activate_holomap(user)

/obj/item/holochip/proc/handle_markers()
	if(!activator || !activator.client)
		deactivate_holomap()
		return
	if(length(holomap_images))
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	for(var/obj/item/holochip/HC in SSholomaps.holochips[frequency])
		if(HC.frequency != frequency)
			HC.update_freq(HC.frequency)
			continue
		if(HC.encryption != encryption)
			continue
		if(HC == src)
			handle_own_marker()
			continue
		if(!SSholomaps.holomap_cache[HC])
			continue
		var/image/I = SSholomaps.holomap_cache[HC]
		I.loc = activator.holomap_obj
		holomap_images += I
		animate(I, alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I, alpha = 0, time = 5, easing = SINE_EASING)
		animate(I, alpha = 255, time = 2, easing = SINE_EASING)

	handle_markers_extra()

	activator.client.images |= holomap_images

/obj/item/holochip/proc/handle_markers_extra()    // For shuttle markers and other stuff
	return

/obj/item/holochip/proc/handle_own_marker()
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

/obj/item/holochip/proc/instantiate_self_marker()
	self_marker = image('icons/holomaps/holomap_markers.dmi', "you")
	self_marker.plane = ABOVE_HUD_PLANE
	self_marker.layer = ABOVE_HUD_LAYER

/obj/item/holochip/attack_self(mob/user)
	if(!ishuman(user))
		return
	var/num_frequency = text2num(frequency)
	var/dat = {"<TT>
				<B>Transport layer</B> for holochip:<BR>
				Frequency:
				<A href='byond://?src=\ref[src];num_frequency=-10'>-</A>
				<A href='byond://?src=\ref[src];num_frequency=-1'>-</A>
				[format_frequency(num_frequency)]
				<A href='byond://?src=\ref[src];num_frequency=1'>+</A>
				<A href='byond://?src=\ref[src];num_frequency=10'>+</A><BR>
				Encryption:
				<A href='byond://?src=\ref[src];encryption=-100'>---</A>
				<A href='byond://?src=\ref[src];encryption=-50'>--</A>
				<A href='byond://?src=\ref[src];encryption=-10'>-</A>
				<A href='byond://?src=\ref[src];encryption=-1'>-</A>
				[encryption]
				<A href='byond://?src=\ref[src];encryption=1'>+</A>
				<A href='byond://?src=\ref[src];encryption=10'>+</A>
				<A href='byond://?src=\ref[src];encryption=50'>++</A>
				<A href='byond://?src=\ref[src];encryption=100'>+++</A><BR>
				</TT>"}
	frequency = num2text(num_frequency)

	var/datum/browser/popup = new(user, "holochip")
	popup.set_content(dat)
	popup.open()
	return ..()

/obj/item/holochip/proc/update_freq(new_frequency) //For structurizing holochip' markers
	if(!new_frequency)
		return

	if(frequency)
		var/old_freq = frequency //Handle old freq
		if(SSholomaps.holochips[old_freq])
			SSholomaps.holochips[old_freq] -= src
			if(!length(SSholomaps.holochips[old_freq]))
				SSholomaps.holochips -= old_freq

	var/texted_freq = new_frequency //Handle new freq
	var/freque = SSholomaps.holochips[texted_freq]
	if(!freque) //We need new freq
		SSholomaps.holochips[texted_freq] = list()
		SSholomaps.holochips[texted_freq] += src
	else //Add to existing freq
		freque += src

/obj/item/holochip/proc/freq_remove()
	if(SSholomaps.holochips[frequency] && (src in SSholomaps.holochips[frequency]))
		SSholomaps.holochips[frequency] -= src

/obj/item/holochip/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr) || !ishuman(usr))
		usr << browse(null, "window=holochip")
		onclose(usr, "holochip")
		return

	if (href_list["frequency"])
		var/new_frequency = (frequency + text2num(href_list["frequency"]))
		if(new_frequency < 1200)
			new_frequency = 1200
		else if(new_frequency > 1600)
			new_frequency = 1600
		frequency = new_frequency

	if(href_list["encryption"])
		encryption += text2num(href_list["encryption"])
		encryption = round(encryption)
		encryption = min(1000, encryption)
		encryption = max(1, encryption)
	attack_self(usr)
	update_freq(frequency)

	updateUsrDialog()

//HOLOCHIP ACTION
/datum/action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE
	button_icon_state = "holomap"

/datum/action/toggle_holomap/Activate()
	to_chat(owner, "<span class='notice'>You activate the holomap.</span>")
	var/obj/item/holochip/target_holochip = target
	target_holochip.update_freq(target_holochip.frequency)
	target_holochip.activate_holomap(owner)
	target_holochip = null
	active = TRUE

/datum/action/toggle_holomap/Deactivate()
	var/obj/item/holochip/target_holochip = target
	target_holochip.deactivate_holomap()
	target_holochip = null
	to_chat(owner, "<span class='notice'>You deactivate the holomap.</span>")
	active = FALSE
