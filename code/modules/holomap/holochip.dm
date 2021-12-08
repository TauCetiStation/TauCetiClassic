ADD_TO_GLOBAL_LIST(/obj/item/holochip, holochips)
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

	// Magic numbers for placing holomarker on the holomap
	var/magic_number_self = 6

/obj/item/holochip/atom_init(obj/item/I)
	. = ..()
	holder = I
	holomap_toggle_action = new(src)
	holomap_base = global.default_holomap
	instantiate_self_marker()

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
	holomap_base = default_holomap
	if(color_filter)
		holomap_base.color = color_filter
	activator.hud_used.holomap_obj.add_overlay(holomap_base)
	START_PROCESSING(SSholomaps, src)

/obj/item/holochip/proc/deactivate_holomap()
	if(!activator)
		return
	activator.hud_used.holomap_obj.cut_overlay(holomap_base)
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
	for(var/obj/item/holochip/HC in holochips)
		if(HC.frequency != frequency && HC.encryption != encryption)
			continue
		if(HC == src)
			handle_own_marker()
			continue
		if(!global.holomap_cache[HC])
			continue
		var/image/I = global.holomap_cache[HC]
		I.loc = activator.hud_used.holomap_obj
		holomap_images += I
		animate(I ,alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I ,alpha = 0, time = 5, easing = SINE_EASING)
		animate(I ,alpha = 255, time = 2, easing = SINE_EASING)

	handle_markers_extra()

	activator.client.images |= holomap_images

/obj/item/holochip/proc/handle_markers_extra()    // For shuttle markers and other stuff
	return

/obj/item/holochip/proc/handle_own_marker()
	if(!self_marker)   // Dunno why but it happens in runtime
		instantiate_self_marker()
	self_marker.loc = activator.hud_used.holomap_obj
	var/turf/src_turf = get_turf(src)
	self_marker.pixel_x = (src_turf.x - magic_number_self) * PIXEL_MULTIPLIER
	self_marker.pixel_y = (src_turf.y - magic_number_self) * PIXEL_MULTIPLIER
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
				<A href='byond://?src=\ref[src];frequency=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];frequency=2'>+</A>
				<A href='byond://?src=\ref[src];frequency=10'>+</A><BR>
				Encryption:
				<A href='byond://?src=\ref[src];encryption=-5'>-</A>
				<A href='byond://?src=\ref[src];encryption=-1'>-</A>
				[encryption]
				<A href='byond://?src=\ref[src];encryption=1'>+</A>
				<A href='byond://?src=\ref[src];encryption=5'>+</A><BR>
				</TT>"}

	var/datum/browser/popup = new(user, "holochip")
	popup.set_content(dat)
	popup.open()
	return ..()

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

	updateUsrDialog()
