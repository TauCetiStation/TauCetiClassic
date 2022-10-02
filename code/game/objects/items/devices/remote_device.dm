#define REMOTE_OPEN "Open Door"
#define REMOTE_BOLT "Toggle Bolts"
#define REMOTE_EMERGENCY "Toogle Emergency Access"
#define REMOTE_ELECT "Electrify Door"

/obj/item/device/remote_device
	name = "Remote Controller Device"
	icon = 'icons/obj/remote_device.dmi'
	icon_state = "rdc_open"
	item_state = "electronic"
	w_class = SIZE_TINY
	var/mode = REMOTE_OPEN
	var/region_access = list(0, 1, 2, 3, 4, 5, 6, 7) // look at access.dm
	var/obj/item/weapon/card/id/ID
	var/emagged = FALSE
	var/disabled = FALSE
	var/overlay = "rdc_white"

/obj/item/device/remote_device/atom_init()
	. = ..()
	remote_device_list += src
	ID = new/obj/item/weapon/card/id
	ID.access = list()
	for(var/access in region_access)
		ID.access += get_region_accesses(access)
	add_overlay(image(icon, overlay))

/obj/item/device/remote_device/Destroy()
	remote_device_list -= src
	QDEL_NULL(ID)
	return ..()

/obj/item/device/remote_device/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		to_chat(user, "<span class='notice'>You sneakily swipe through [src], and now it can electrify doors.</span>")
		add_overlay(image(icon, "emagged"))
		return TRUE
	return FALSE

/obj/item/device/remote_device/attack_self(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
		return
	if(mode == REMOTE_OPEN)
		if(emagged)
			mode = REMOTE_ELECT
		else
			mode = REMOTE_BOLT
			icon_state = "rdc_bolt"
	else if(mode == REMOTE_BOLT)
		mode = REMOTE_EMERGENCY
		icon_state = "rdc_emergency"
	else if(mode == REMOTE_EMERGENCY)
		mode = REMOTE_OPEN
		icon_state = "rdc_open"
	else if(mode == REMOTE_ELECT)
		mode = REMOTE_BOLT
		icon_state = "rdc_bolt"
	to_chat(user, "Now in mode: [mode].")
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)

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
				D.diag_hud_set_electrified()
		D.add_hiddenprint(user)
	else
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/device/remote_device/ERT
	name = "ERT door remote"
	desc = "This remote control device can access any door on the station."
	region_access = list(0)

/obj/item/device/remote_device/captain
	name = "command door remote"
	overlay = "rdc_cap"
	region_access = list(5)

/obj/item/device/remote_device/chief_engineer
	name = "engineering door remote"
	overlay = "rdc_ce"
	region_access = list(4)

/obj/item/device/remote_device/research_director
	name = "research door remote"
	overlay = "rdc_rd"
	region_access = list(3)

/obj/item/device/remote_device/head_of_security
	name = "security door remote"
	overlay = "rdc_hos"
	region_access = list(1)

/obj/item/device/remote_device/quartermaster
	name = "supply door remote"
	overlay = "rdc_qm"
	region_access = list(7)

/obj/item/device/remote_device/chief_medical_officer
	name = "medical door remote"
	overlay = "rdc_cmo"
	region_access = list(2)

/obj/item/device/remote_device/head_of_personal
	name = "civillian door remote"
	overlay = "rdc_hop"
	region_access = list(6, 7, 57)

#undef REMOTE_OPEN
#undef REMOTE_BOLT
#undef REMOTE_EMERGENCY
#undef REMOTE_ELECT
