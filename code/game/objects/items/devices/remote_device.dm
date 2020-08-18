#define REMOTE_OPEN "Open Door"
#define REMOTE_BOLT "Toggle Bolts"
#define REMOTE_EMERGENCY "Toogle Emergency Access"
#define REMOTE_ELECT "Electrify Door"

/obj/item/device/remote_device
	name = "Remote Controller Device"
	icon = 'icons/obj/remote_device.dmi'
	icon_state = "rdc_white"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	var/mode = REMOTE_OPEN
	var/region_access = list(0, 1, 2, 3, 4, 5, 6, 7) // look at access.dm
	var/obj/item/weapon/card/id/ID
	var/emagged = FALSE
	var/disabled = FALSE

/obj/item/device/remote_device/atom_init()
	. = ..()
	remote_device_list += src
	ID = new/obj/item/weapon/card/id
	ID.access = list()
	for(var/access in region_access)
		ID.access += get_region_accesses(access)

/obj/item/device/remote_device/Destroy()
	remote_device_list -= src
	QDEL_NULL(ID)
	return ..()

/obj/item/device/remote_device/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You sneakily swipe through [src], and now it can electrify doors.</span>")
		return TRUE
	return FALSE

/obj/item/device/remote_device/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
		return
	if(mode == REMOTE_OPEN)
		if(emagged)
			mode = REMOTE_ELECT
		else mode = REMOTE_BOLT
	else if(mode == REMOTE_BOLT)
		mode = REMOTE_EMERGENCY
	else if(mode == REMOTE_EMERGENCY)
		mode = REMOTE_OPEN
	else if(mode == REMOTE_ELECT)
		mode = REMOTE_BOLT
	to_chat(user, "Now in mode: [mode].")

/obj/item/device/remote_device/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target, /obj/machinery/door/airlock))
		return
	var/obj/machinery/door/airlock/D = target
	if(disabled || user.client.eye != user.client.mob)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!D.hasPower())
		to_chat(user, "<span class='danger'>[D] has no power!</span>")
		return
	if(!D.requiresID())
		to_chat(user, "<span class='danger'>[D]'s ID scan is disabled!</span>")
		return
	if(D.check_access(ID) && D.canAIControl(user))
		switch(mode)
			if(REMOTE_OPEN)
				if(D.density)
					D.open()
				else
					D.close()
			if(REMOTE_BOLT)
				if(D.locked)
					D.unbolt()
				else
					D.bolt()
			if(REMOTE_EMERGENCY)
				if(D.emergency)
					D.emergency = FALSE
				else
					D.emergency = TRUE
				D.update_icon()
			if(REMOTE_ELECT)
				if(D.secondsElectrified > 0)
					D.secondsElectrified = 0
				else
					D.secondsElectrified = 10
		D.add_hiddenprint(user)
	else
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/device/remote_device/ERT
	name = "ERT door remote"
	desc = "This remote control device can access any door on the station."
	icon_state = "rdc_white"
	region_access = list(0)

/obj/item/device/remote_device/captain
	name = "command door remote"
	icon_state = "rdc_cap"
	region_access = list(5)

/obj/item/device/remote_device/chief_engineer
	name = "engineering door remote"
	icon_state = "rdc_ce"
	region_access = list(4)

/obj/item/device/remote_device/research_director
	name = "research door remote"
	icon_state = "rdc_rd"
	region_access = list(3)

/obj/item/device/remote_device/head_of_security
	name = "security door remote"
	icon_state = "rdc_hos"
	region_access = list(1)

/obj/item/device/remote_device/quartermaster
	name = "supply door remote"
	icon_state = "rdc_qm"
	region_access = list(7)

/obj/item/device/remote_device/chief_medical_officer
	name = "medical door remote"
	icon_state = "rdc_cmo"
	region_access = list(2)

/obj/item/device/remote_device/head_of_personal
	name = "civillian door remote"
	icon_state = "rdc_hop"
	region_access = list(6, 7, 57)

#undef REMOTE_OPEN
#undef REMOTE_BOLT
#undef REMOTE_EMERGENCY
#undef REMOTE_ELECT
