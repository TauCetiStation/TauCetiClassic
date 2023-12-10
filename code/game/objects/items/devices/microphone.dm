ADD_TO_GLOBAL_LIST(/obj/item/device/microphone, all_command_microphones)

/obj/item/device/microphone
	name = "Microphone"
	desc = "Микрофон для озвучивания объявлений отдела"
	icon = 'icons/obj/radio.dmi'
	icon_state = "soyuz_heads"
	w_class = SIZE_SMALL
	flags = CONDUCT

	var/department = "Nothing"
	var/department_genitive = "Nothing's"
	var/datum/announcement/station/command/department/announcement = new

	var/next_announce = 0
	var/announce_cooldown = 5 MINUTES

/obj/item/device/microphone/atom_init(mapload)
	. = ..()
	AddComponent(/datum/component/wrench_to_table)

	desc += " ([department])."

/obj/item/device/microphone/proc/can_use(mob/user)
	if(!anchored || !isturf(loc) || !is_station_level(z))
		return FALSE

	if(user.incapacitated() || !Adjacent(user))
		return FALSE

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>Вы не знаете как этим пользоваться!</span>")
		return FALSE

	var/mob/living/carbon/human/H = user

	if(H.silent || isabductor(H) || HAS_TRAIT(H, TRAIT_MUTE))
		to_chat(user, "<span class='userdange'>Вы немы.</span>")
		return FALSE

	if(next_announce > world.time)
		to_chat(user, "<span class='userdange'>Микрофон перезаряжается.</span>")
		return FALSE

	return TRUE

/obj/item/device/microphone/attack_hand(mob/user)
	. = ..()

	if(!can_use(user))
		return

	playsound(src, 'sound/items/megaphone.ogg', VOL_EFFECTS_MASTER)
	var/new_message = sanitize(input(usr, "Объявление:", "[name]", "") as null|message)
	if(!can_use(user) || !length(new_message))
		return

	next_announce = world.time + announce_cooldown
	announcement.play(department_genitive, new_message, user)
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
