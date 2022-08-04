//ADD_TO_GLOBAL_LIST(/obj/item/holochip, holochips)
#define OFFSET_CORRECTOR 6
/obj/item/holochip
	name = "Holomap chip"
	desc = "A small holomap module, attached to helmets."
	icon = 'icons/holomaps/holochips.dmi'
	icon_state = "holochip"
	var/color_filter = null		//Color for station's image, defined in flags.dm

	var/mob/living/carbon/human/activator = null
	var/obj/item/holder = null
	var/list/holomap_images = list()
	var/datum/action/toggle_holomap/holomap_toggle_action = null

	var/image/holomap_base
	var/image/self_marker

	var/frequency		//Frequency for transmitting data
	var/encryption 		//Encryption for double security
	var/raw_freq		//Ref to list of chips wit same freq. Touch only if you know what you do

/obj/item/holochip/atom_init(obj/item/I)
	. = ..()
	//SSholomaps.holochips += src
	holder = I
	holomap_toggle_action = new(src)
	holomap_base = SSholomaps.default_holomap
	instantiate_self_marker()

	return INITIALIZE_HINT_LATELOAD

/obj/item/holochip/atom_init_late()
	. = ..()
	update_freq(frequency) //Because child defines it's freq in init

/obj/item/holochip/Destroy()
	STOP_PROCESSING(SSholomaps, src)
	deactivate_holomap()
	holomap_base = null
	QDEL_NULL(self_marker)
	QDEL_LIST(holomap_images)
	QDEL_NULL(holomap_toggle_action)
	holder = null
	activator = null
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
	activator = user
	holomap_base = SSholomaps.default_holomap
	if(color_filter)
		holomap_base.color = color_filter
	activator.holomap_obj.add_overlay(holomap_base)//hud_used.
	START_PROCESSING(SSholomaps, src)

/obj/item/holochip/proc/deactivate_holomap()
	if(!activator)
		return
	activator.holomap_obj.cut_overlay(holomap_base)//hud_used.
	if(length(holomap_images) && activator.client)
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	holomap_base = null
	activator = null
	STOP_PROCESSING(SSholomaps, src)

/obj/item/holochip/proc/handle_markers()
	if(!activator || !activator.client)
		deactivate_holomap()
		return
	if(length(holomap_images))
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	for(var/obj/item/holochip/HC in raw_freq)
		if(HC.frequency != frequency)
			//HC.update_freq(HC.frequency)
			continue
		if(HC.encryption != encryption)
			continue
		if(HC == src)
			handle_own_marker()
			continue
		if(!SSholomaps.holomap_cache[HC])
			continue
		var/image/I = SSholomaps.holomap_cache[HC]
		I.loc = activator.holomap_obj//hud_used.
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
	self_marker.loc = activator.holomap_obj//hud_used.
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
	var/dat = {"<TT>
				<B>Transport layer</B> for holochip:<BR>
				Frequency:
				<A href='byond://?src=\ref[src];frequency=-10'>-</A>
				<A href='byond://?src=\ref[src];frequency=-1'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];frequency=1'>+</A>
				<A href='byond://?src=\ref[src];frequency=10'>+</A><BR>
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

	var/datum/browser/popup = new(user, "holochip")
	popup.set_content(dat)
	popup.open()
	return ..()

/datum/holochip_frequency
	var/list/holochips = list()

/obj/item/holochip/proc/update_freq(new_frequency) //For structurizing holochip' markers
	if(new_frequency)
		return
	if(raw_freq)
		raw_freq -= src
	var/freque = SSholomaps.holochips[new_frequency]
	if(!freque) //We need new freq
		SSholomaps.holochips[new_frequency] = list()
		SSholomaps.holochips[new_frequency] += src
	else //Add to existing freq
		freque += src
	to_chat(world,"[frequency],[encryption],[SSholomaps.holochips[new_frequency]]")
	raw_freq = SSholomaps.holochips[new_frequency]

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
		encryption = min(100, encryption)
		encryption = max(1, encryption)
	usr << browse(null, "window=holochip")
	update_freq(frequency)

	updateUsrDialog()

//HOLOCHIP ACTION
/datum/action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE

/datum/action/toggle_holomap/Activate()
	to_chat(owner, "<span class='notice'>You activate the holomap.</span>")
	var/obj/item/holochip/target_holochip = target
	target_holochip.activate_holomap(owner)
	target_holochip.update_freq(target_holochip.frequency)
	target_holochip = null
	active = TRUE

/datum/action/toggle_holomap/Deactivate()
	var/obj/item/holochip/target_holochip = target
	target_holochip.deactivate_holomap()
	target_holochip = null
	to_chat(owner, "<span class='notice'>You deactivate the holomap.</span>")
	active = FALSE
