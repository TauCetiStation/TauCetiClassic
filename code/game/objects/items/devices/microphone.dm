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

	var/last_announce
	var/announce_cooldown = 10 SECONDS

/obj/item/device/microphone/atom_init(mapload)
	. = ..()
	var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(src))
	if(mapload && Table)
		anchored = TRUE
		RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))

	desc += "([department])."

/obj/item/device/microphone/proc/unwrench()
	anchored = FALSE

/obj/item/device/microphone/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = W
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
	if(!isturf(loc) || !is_station_level(z))
		return

	if(!ishuman(user))
		to_chat(user, "<span class='warning'>Вы не знаете как этим пользоваться!</span>")
		return

	var/mob/living/carbon/human/H = user

	if(H.silent || isabductor(H) || HAS_TRAIT(H, TRAIT_MUTE))
		to_chat(user, "<span class='userdange'>Вы немы.</span>")
		return

	if(last_announce + announce_cooldown > world.time)
		return

	playsound(src, 'sound/items/megaphone.ogg', VOL_EFFECTS_MASTER)
	var/new_message = sanitize(input(usr, "Объявление:", "[name]", "") as null|message)
	if(user.incapacitated() || !Adjacent(user) || !length(new_message))
		return

	last_announce = world.time
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
