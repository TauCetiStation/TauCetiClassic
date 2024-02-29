#define REMOTE_OPEN "Open Door"
#define REMOTE_BOLT "Toggle Bolts"
#define REMOTE_EMERGENCY "Toogle Emergency Access"
#define REMOTE_ELECT "Electrify Door"

/obj/item/device/remote_device
	name = "Remote Controller Device"
	cases = list("пульт удалённого управления", "пульта удалённого управления", "пульту удалённого управления", "пульт удалённого управления", "пультом удалённого управления", "пульте удалённого управления")
	icon = 'icons/obj/remote_device.dmi'
	icon_state = "rdc_white"
	item_state = "electronic"
	w_class = SIZE_TINY
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
				D.diag_hud_set_electrified()
		D.add_hiddenprint(user)
	else
		to_chat(user, "<span class='danger'>[src] does not have access to this door.</span>")

/obj/item/device/remote_device/ERT
	name = "ERT door remote"
	cases = list("пульт удалённого управления \"ОБР\"", "пульта удалённого управления \"ОБР\"", "пульту удалённого управления \"ОБР\"", "пульт удалённого управления \"ОБР\"", "пультом удалённого управления \"ОБР\"", "пульте удалённого управления \"ОБР\"")
	desc = "Этот пульт удалённого управления имеет доступ ко всем шлюзам на станции."
	icon_state = "rdc_white"
	region_access = list(0)

/obj/item/device/remote_device/captain
	name = "command door remote"
	cases = list("пульт удалённого управления \"Командный\"", "пульта удалённого управления \"Командный\"", "пульту удалённого управления \"Командный\"", "пульт удалённого управления \"Командный\"", "пультом удалённого управления \"Командный\"", "пульте удалённого управления \"Командный\"")
	icon_state = "rdc_cap"
	region_access = list(5)

/obj/item/device/remote_device/chief_engineer
	name = "engineering door remote"
	cases = list("пульт удалённого управления \"Инженерный\"", "пульта удалённого управления \"Инженерный\"", "пульту удалённого управления \"Инженерный\"", "пульт удалённого управления \"Инженерный\"", "пультом удалённого управления \"Инженерный\"", "пульте удалённого управления \"Инженерный\"")
	icon_state = "rdc_ce"
	region_access = list(4)

/obj/item/device/remote_device/research_director
	name = "research door remote"
	cases = list("пульт удалённого управления \"Научный\"", "пульта удалённого управления \"Научный\"", "пульту удалённого управления \"Научный\"", "пульт удалённого управления \"Научный\"", "пультом удалённого управления \"Научный\"", "пульте удалённого управления \"Научный\"")
	icon_state = "rdc_rd"
	region_access = list(3)

/obj/item/device/remote_device/head_of_security
	name = "security door remote"
	cases = list("пульт удалённого управления \"Служба Безопасности\"", "пульта удалённого управления \"Служба Безопасности\"", "пульту удалённого управления \"Служба Безопасности\"", "пульт удалённого управления \"Служба Безопасности\"", "пультом удалённого управления \"Служба Безопасности\"", "пульте удалённого управления \"Служба Безопасности\"")
	icon_state = "rdc_hos"
	region_access = list(1)

/obj/item/device/remote_device/quartermaster
	name = "supply door remote"
	cases = list("пульт удалённого управления \"Снабжение\"", "пульта удалённого управления \"Снабжение\"", "пульту удалённого управления \"Снабжение\"", "пульт удалённого управления \"Снабжение\"", "пультом удалённого управления \"Снабжение\"", "пульте удалённого управления \"Снабжение\"")
	icon_state = "rdc_qm"
	region_access = list(7)

/obj/item/device/remote_device/chief_medical_officer
	name = "medical door remote"
	cases = list("пульт удалённого управления \"Медблок\"", "пульта удалённого управления \"Медблок\"", "пульту удалённого управления \"Медблок\"", "пульт удалённого управления \"Медблок\"", "пультом удалённого управления \"Медблок\"", "пульте удалённого управления \"Медблок\"")
	icon_state = "rdc_cmo"
	region_access = list(2)

/obj/item/device/remote_device/head_of_personal
	name = "civillian door remote"
	cases = list("пульт удалённого управления \"Гражд. отделы\"", "пульта удалённого управления \"Гражд. отделы\"", "пульту удалённого управления \"Гражд. отделы\"", "пульт удалённого управления \"Гражд. отделы\"", "пультом удалённого управления \"Гражд. отделы\"", "пульте удалённого управления \"Гражд. отделы\"")
	icon_state = "rdc_hop"
	region_access = list(6, 7, 57)

#undef REMOTE_OPEN
#undef REMOTE_BOLT
#undef REMOTE_EMERGENCY
#undef REMOTE_ELECT
