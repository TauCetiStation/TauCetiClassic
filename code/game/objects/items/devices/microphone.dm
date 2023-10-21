/obj/item/device/microphone
	name = "Microphone"
	desc = "Микрофон для озвучивания объявлений отдела "
	icon = 'icons/obj/radio.dmi'
	icon_state = "soyuz_heads"
	w_class = SIZE_SMALL
	flags = CONDUCT

	var/department = "Nothing"
	var/department_genitive = "Nothing's"
	var/datum/announcement/station/command/department/announcement = new

/obj/item/device/microphone/atom_init(mapload)
	. = ..()
	var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(src))
	if(mapload && Table)
		anchored = TRUE
		RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))

	desc += "([department])."

/obj/item/device/cardpay/proc/unwrench()
	anchored = FALSE

/obj/item/device/microphone/attackby(obj/item/weapon/O, mob/user)
	if(istype(O, /obj/item/weapon/wrench) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = O
		if(Tool.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.SetNextMove(CLICK_CD_INTERACT)
			var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(src))
			if(!anchored)
				if(!Table)
					to_chat(user, "<span class='warning'>Микрофон можно прикрутить только к столу.</span>")
					return
				to_chat(user, "<span class='warning'>Микрофон прикручен.</span>")
				anchored = TRUE
				RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))
				return
			to_chat(user, "<span class='notice'>Микрофон откручен.</span>")
			anchored = FALSE

	return ..()

/obj/item/device/microphone/attack_hand(mob/user)
	. = ..()
	if(!isturf(loc))
		return

	playsound(src, 'sound/items/megaphone.ogg', VOL_EFFECTS_MASTER)
	var/new_message = sanitize(input(usr, "Объявление:", "[name]", "") as null|message)
	if(user.incapacitated() || !Adjacent(user) || !length(new_message))
		return

	announcement.play(department_genitive, new_message)
	message_admins("[key_name_admin(usr)] has made a department announcement. [ADMIN_JMP(usr)]")

// Heads
/obj/item/device/microphone/cap
	name = "Captain's Microphone"
	department = "Кабинет Капитана"
	department_genitive = "Кабинета Капитана"
	announcement = new /datum/announcement/station/command/department/captain

/obj/item/device/microphone/hop
	name = "Head of Personnel's Microphone"
	department = "Кабинет ГП"
	department_genitive = "Кабинета ГП"
	announcement = new /datum/announcement/station/command/department/hop

/obj/item/device/microphone/hos
	name = "Head of Security's Microphone"
	department =  "Кабинет ГСБ"
	department_genitive = "Кабинета ГСБ"
	announcement = new /datum/announcement/station/command/department/hos

/obj/item/device/microphone/rd
	name = "Research Director's Microphone"
	department = "Кабинет ДИР"
	department_genitive = "Кабинета ДИР"
	announcement = new /datum/announcement/station/command/department/rd

/obj/item/device/microphone/cmo
	name = "Chief Medical Officer's Microphone"
	department = "Кабинет Главврача"
	department_genitive = "Кабинета Главврача"
	announcement = new /datum/announcement/station/command/department/cmo

/obj/item/device/microphone/ce
	name = "Chief Engineer's Microphone"
	department = "Кабинет СИ"
	department_genitive = "Кабинета СИ"
	announcement = new /datum/announcement/station/command/department/ce
