/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/aiupload
	light_color = "#ffffff"
	var/mob/living/silicon/ai/current = null
	var/opened = FALSE
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NONE, /datum/skill/research = SKILL_LEVEL_PRO)
	fumbling_time = 7 SECONDS
	req_access = list(access_rd)

/obj/machinery/computer/aiupload/attackby(obj/item/weapon/O, mob/user)
	if(!is_station_level(z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return
	if(istype(O, /obj/item/weapon/aiModule))
		if(!do_skill_checks(user))
			return
		var/obj/item/weapon/aiModule/M = O
		M.install(src)
	else
		..()

/obj/machinery/computer/aiupload/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = user
	// AI and borgs apparently call attack_hand for some reason :).
	if(!istype(H))
		return
	if(!check_access(H.get_active_hand()) && !check_access(H.wear_id))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	if(!do_skill_checks(user))
		return
	current = select_active_ai(user)
	if (!current)
		to_chat(user, "No active AIs detected.")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/aiupload/emag_act(mob/user)
	if(emagged)
		return FALSE
	req_access = list()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You emag the upload console.</span>")
	return TRUE

/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NONE, /datum/skill/research = SKILL_LEVEL_PRO)
	fumbling_time = 7 SECONDS
	req_access = list(access_rd)

/obj/machinery/computer/borgupload/attackby(obj/item/weapon/aiModule/module, mob/user)
	if(!is_station_level(z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return

	if(istype(module, /obj/item/weapon/aiModule))
		if(!do_skill_checks(user))
			return
		module.install(src)
	else
		return ..()

/obj/machinery/computer/borgupload/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!do_skill_checks(user))
		return
	var/mob/living/carbon/human/H = user
	if(!check_access(H.get_active_hand()) && !check_access(H.wear_id))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	current = freeborg()
	if (!current)
		to_chat(user, "No free cyborgs detected.")
	else
		to_chat(user, "[src.current.name] selected for law changes.")

/obj/machinery/computer/borgupload/emag_act(mob/user)
	if(emagged)
		return FALSE
	req_access = list()
	emagged = TRUE
	to_chat(user, "<span class='notice'>You emag the upload console.</span>")
	return TRUE
