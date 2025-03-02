/obj/item/device/binary_decoder
	name = "binary decoder"
	icon_state = "binary_decoder"
	item_state_world = "binary_decoder_world"
	item_state = "analyzer"
	desc = "Инструмент для прямого чтения и редактирования прошивки электронных устройств."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	origin_tech = "magnets=1;biotech=1"

/obj/item/device/binary_decoder/proc/print_laws(mob/living/silicon/S)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/paper/P = new(usr.loc)
	P.fields = 0
	P.name = "Законы [S.name]:"
	P.info = "<tt>[S.write_laws()]</tt>"
	P.updateinfolinks()
	P.update_icon()
	usr.put_in_hands(P)

/obj/machinery/ai_laws_server
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server"
	name = "AI Laws Server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	required_skills = list(/datum/skill/command = SKILL_LEVEL_NONE, /datum/skill/research = SKILL_LEVEL_PRO)
	fumbling_time = 3 SECONDS
	req_access = list(access_rd)

	resistance_flags = FULL_INDESTRUCTIBLE

	var/mob/living/silicon/ai/current = null

/obj/machinery/ai_laws_server/attackby(obj/item/I, mob/user)
	if(stat & NOPOWER)
		to_chat(usr, "Консоль загрузки законов обесточена!")
		return

	if(istype(I, /obj/item/device/binary_decoder))
		if(!current)
			to_chat(user, "<span class='warning'><b>Не выбран ИИ для дешифрации информации!</b></span>")
			return
		if(do_skilled(user, src, SKILL_TASK_DIFFICULT, required_skills, -0.2))
			if(current)
				var/obj/item/device/binary_decoder/D = I
				D.print_laws(current)
				current.statelaws(forced = TRUE)

/obj/machinery/ai_laws_server/attack_hand(mob/user)
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
		to_chat(user, "Активных ИИ не обнаружено.")
	else
		to_chat(user, "[current.name] selected for law changes.")
