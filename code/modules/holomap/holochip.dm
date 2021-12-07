/obj/item/holochip
	name = "Holomap chip"
	desc = "A small holomap module, attached to helmets."
	icon = 'icons/holomaps/holochips.dmi'
	icon_state = "holochip"
	var/color_filter = null		//Color for station's image, defined in flags.dm

	var/mob/living/carbon/human/activator = null
	var/obj/item/holder = null
	var/list/holomap_images = list()

	var/image/holomap_base

	var/frequency		//Frequency for transmitting data
	var/encryption 		//Encryption for double security

/obj/item/holochip/atom_init(obj/item/I)
	. = ..()
	holder = I
	holochips += src
	holomap_base = default_holomap

/obj/item/holochip/Destroy()
	STOP_PROCESSING(SSobj, src)
	deactivate_holomap()
	QDEL_NULL(holomap_base)
	QDEL_LIST(holomap_images)
	holder = null
	activator = null
	holochips -= src
	return ..()

/obj/item/holochip/proc/add_action(mob/living/carbon/human/wearer)
	var/datum/action/toggle_holomap/action = new(src)
	action.Grant(wearer)

/obj/item/holochip/proc/remove_action(mob/living/carbon/human/wearer)
	for(var/datum/action/toggle_holomap/action in wearer.actions)
		if(!istype(action))
			continue
		action.Remove(wearer)

/obj/item/holochip/ui_action_click()
	if(activator)
		deactivate_holomap()
		to_chat(usr, "<span class='notice'>You deactivate the holomap.</span>")
		return
	activate_holomap(usr)
	to_chat(usr, "<span class='notice'>You activate the holomap.</span>")

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
	holomap_base.loc = activator.hud_used.holomap_obj
	activator.hud_used.holomap_obj.overlays += holomap_base
	START_PROCESSING(SSobj, src)

/obj/item/holochip/proc/deactivate_holomap()
	if(!activator)
		return
	activator.hud_used.holomap_obj.overlays.Cut()
	if(length(holomap_images) && activator.client)
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
	qdel(holomap_base)
	activator = null
	STOP_PROCESSING(SSobj, src)

#define COLOR_HMAP_DEAD "#d3212d"
#define COLOR_HMAP_INCAPACITATED "#ffef00"
#define COLOR_HMAP_DEFAULT "#006e4e"

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
		var/turf/marker_location = get_turf(HC)
		if(!is_station_level(marker_location.z))
			continue
		if(!ishuman(HC.holder.loc))
			continue
		var/image/I = image('icons/holomaps/holomap_markers.dmi', "you")
		if(HC != src)
			I =	image(HC.holder.icon, src , HC.holder.icon_state)
			I.transform /= 2
			var/mob/living/carbon/human/H = HC.holder.loc
			if(H.head != HC.holder)
				continue
			if(H.stat == DEAD)
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEAD)
			else if(H.stat == UNCONSCIOUS || H.incapacitated())
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_INCAPACITATED)
			else
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEFAULT)
		I.loc = activator.hud_used.holomap_obj
		I.pixel_x = (marker_location.x - 6) * PIXEL_MULTIPLIER
		I.pixel_y = (marker_location.y - 6) * PIXEL_MULTIPLIER
		I.plane = ABOVE_HUD_PLANE
		I.layer = ABOVE_HUD_LAYER
		holomap_images += I
		animate(I ,alpha = 255, time = 8, loop = -1, easing = SINE_EASING)
		animate(I ,alpha = 0, time = 5, easing = SINE_EASING)
		animate(I ,alpha = 255, time = 2, easing = SINE_EASING)
	activator.client.images += holomap_images

/obj/item/holochip/attack_self(mob/user)
	if(!istype(user, /mob/living/carbon/human))
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
		if(new_frequency < 1200 || new_frequency > 1600)
			new_frequency = sanitize_frequency(new_frequency)
		frequency = new_frequency

	if(href_list["encryption"])
		encryption += text2num(href_list["encryption"])
		encryption = round(encryption)
		encryption = min(100, encryption)
		encryption = max(1, encryption)

	if(usr)
		attack_self(usr)

	return
