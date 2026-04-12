/obj/item/device/binary_decoder
	name = "binary decoder"
	cases = list("бинарный дешифратор", "бинарного дешифратора", "бинарному дешифратору", "бинарный дешифратор", "бинарным дешифратором", "бинарном дешифраторе")
	desc = "Инструмент, содержащий коды для дешифрации информации о законах ИИ."
	icon_state = "binary_decoder"
	item_state_world = "binary_decoder_world"
	item_state = "analyzer"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY

/obj/item/device/binary_decoder/proc/print_laws(mob/living/silicon/S)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/paper/P = new(usr.loc)
	P.fields = 0
	P.name = "[S.name] Laws:"
	P.info = "<tt>[S.write_laws()]</tt>"
	P.updateinfolinks()
	P.update_icon()
	usr.put_in_hands(P)

/obj/machinery/ai_laws_server
	name = "AI Laws Server"
	cases = list("сервер законов ИИ", "сервера законов ИИ", "серверу законов ИИ", "сервер законов ИИ", "сервером законов ИИ", "сервере законов ИИ")
	desc = "Сервер, на котором хранятся законы ИИ."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE

	required_skills = list(/datum/skill/research = SKILL_LEVEL_PRO)
	fumbling_time = 3 SECONDS
	req_one_access = list(access_tox, access_heads)

	resistance_flags = FULL_INDESTRUCTIBLE

	var/mob/living/silicon/ai/current = null

/obj/machinery/ai_laws_server/attackby(obj/item/I, mob/user)
	if(stat & NOPOWER)
		to_chat(usr, "Сервер законов ИИ обесточен!")
		return

	if(istype(I, /obj/item/device/binary_decoder))
		if(!current)
			to_chat(user, "<span class='warning'><b>Не выбран ИИ для дешифрации информации!</b></span>")
			return
		to_chat(current, "<span class='warning'><b>Кто-то пытается расшифровать ваши законы!</b></span>")
		user.visible_message(
			"<span class='notice'>[user] использует [CASE(I, ACCUSATIVE_CASE)] для подключения к [CASE(src, DATIVE_CASE)].</span>",
			"<span class='notice'>Вы начинаете процесс дешифрации информации о законах ИИ.</span>")
		if(do_skilled(user, src, SKILL_TASK_DIFFICULT, required_skills, -0.2))
			if(current)
				if(!is_skill_competent(user, list(/datum/skill/research = SKILL_LEVEL_TRAINED)))
					if(prob(50))
						current.overload_ai_system()
						user.visible_message(
							"<span class='warning'>[user] делает что-то не так и оборудование начинает страшно пищать.</span>",
							"<span class='warning'>Вы делаете что-то не так и оборудование начинает страшно пищать.</span>")
						playsound(src, 'sound/AI/ionstorm.ogg', VOL_EFFECTS_MASTER, null, FALSE)
						return
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
		to_chat(user, "<span class='warning'>В доступе отказано.</span>")
		return
	if(!do_skill_checks(user))
		return
	current = select_active_ai(user)
	if (!current)
		to_chat(user, "Активных ИИ не обнаружено.")
	else
		to_chat(user, "Выбран [current.name].")
