/obj/item/weapon/occult_pinpointer
	name = "occult locator"
	icon = 'icons/obj/device.dmi'
	icon_state = "locoff"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/target = null
	var/target_type = /obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	var/active = FALSE

/obj/item/weapon/occult_pinpointer/attack_self()
	if(!active)
		to_chat(usr, "<span class='notice'>You activate the [name]</span>")
		START_PROCESSING(SSobj, src)
	else
		icon_state = "locoff"
		to_chat(usr, "<span class='notice'>You deactivate the [name]</span>")
		STOP_PROCESSING(SSobj, src)
	active = !active

/obj/item/weapon/occult_pinpointer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		target_type = OS.scanned_type
		target = null // So we ain't looking for the old target
		to_chat(user, "<span class='notice'>[src] succesfully extracted [pick("mythical", "magical", "arcane")] knowledge from [I].</span>")
	else
		return ..()

/obj/item/weapon/occult_pinpointer/Destroy()
	active = FALSE
	STOP_PROCESSING(SSobj, src)
	target = null
	return ..()

/obj/item/weapon/occult_pinpointer/process()
	if(!active)
		return
	if(!target)
		target = locate(target_type)
		if(!target)
			icon_state = "locnull"
			return
	set_dir(get_dir(src,target))
	if(get_dist(src,target))
		icon_state = "locon"
