/datum/fanatics_rune
	var/name
	var/desc
	var/req_near_fanatics = 1
	var/list/message_parts = list("фха", "эка", "ки", "йа", "лю", "нгор", "вло", "чаар", "краа", "зьи", "тсиа", "цуэ")
	var/parts_len = 3
	var/use_time = 5 SECOND
	var/message = ""

	var/obj/effect/fanatics_rune/holder

/datum/fanatics_rune/Destroy()
	holder = null
	return ..()

/datum/fanatics_rune/proc/can_action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	if(!is_station_level(center.z))
		to_chat(user, "<span class='fanatics'>Пелена между этой реальностью и Затимисом мешает использовать чары здесь. В пределах станции они должны подействовать.</span>")
		return FALSE

	var/list/fanatics = list()
	for(var/mob/living/carbon/human/H in range(1, center))
		if(isfanatic(H) && H.stat == CONSCIOUS && (!istype(H.wear_mask, /obj/item/clothing/mask/muzzle) || !H.silent || !HAS_TRAIT(H, TRAIT_MUTE)))
			fanatics += H
	if(length(fanatics) < req_near_fanatics)
		to_chat(user, "<span class='fanatics'>Нужно больше людей для использования чар.</span>")
		return FALSE

	user.visible_message("<span class='userdanger'>[user] presses his hand to the [bicon(holder)] rune.</span>", \
		"<span class='fanatics'>Вы прижимаете руку к руне, пытаясь связаться с иной реальностью.</span>")

	if(user.is_busy() || !do_after(user, use_time, target = holder))
		return FALSE

	for(var/i in 0 to parts_len)
		message += pick(message_parts)
		if(prob(45))
			message += pick("-", "`", "'")
	message += "!!!"

	for(var/mob/living/carbon/human/H in fanatics)
		ADD_TRAIT(H, TRAIT_DISTORTED_INVOCATION, GENERIC_TRAIT)
		H.chat_color = "#ff0000"
		H.say(message)
		H.chat_color = initial(H.chat_color)
		playsound(H.loc, pick(SOUNDIN_FANATICS_CRY), VOL_EFFECTS_MASTER, 45, vary = FALSE)
		REMOVE_TRAIT(H, TRAIT_DISTORTED_INVOCATION, GENERIC_TRAIT)

	return TRUE

/datum/fanatics_rune/proc/before_action(mob/living/carbon/user)
	if(!can_action(user))
		return
	action(user)

/datum/fanatics_rune/proc/action(mob/living/carbon/user)
	return

///////////////////////////////////////////////////runes///////////////////////////////////////////////////////

/datum/fanatics_rune/convert_sacrifice
	name = "Обращение и Жертвоприношение"
	desc = "Позволяет Ϻрα'αрχѣ проникнуть в разум гуманоида на руне и обратить его. Или поглотить, если это невозможно."
	use_time = 10 SECOND

/datum/fanatics_rune/convert_sacrifice/before_action(mob/living/carbon/user)
	var/list/candidates = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/human/C in center)
		if(!isfanatic(C))
			candidates += C
	if(!length(candidates))
		to_chat(user, "<span class='fanatics'>Руна пуста.</span>")
		return
	..()

/datum/fanatics_rune/convert_sacrifice/action(mob/living/carbon/human/user)
	var/list/candidates = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/human/C in center)
		if(!isfanatic(C))
			candidates += C

	if(!length(candidates))
		to_chat(user, "<span class='fanatics'>Руна пуста.</span>")
		return
	var/mob/living/carbon/human/H = pick(candidates)
	var/datum/faction/fanatics/F = find_faction_by_type(/datum/faction/fanatics)

	if((F.sacrifice_target == H.mind) || (H.stat == DEAD) || jobban_isbanned(H, ROLE_FANATIC) || H.ismindprotect() || H.species.flags[TRAIT_NO_BLOOD])
		for(var/datum/role/fanatic/fanatic in F.members)
			var/mob/living/carbon/human/member = fanatic.antag.current
			to_chat(member, "<span class='fanatics'>Душа [H.real_name] поглощена в Затимис.</span>")
		F.sacrificed += H
		H.gib()

	else
		for(var/datum/role/fanatic/fanatic in F.members)
			var/mob/living/carbon/human/member = fanatic.antag.current
			to_chat(member, "<span class='fanatics'>Ϻрα'αрχѣ сковало кровавые узы с [H.real_name].</span>")
		add_faction_member(F, H, TRUE, TRUE)

	F.add_new_rune()
	holder.visible_message("<span class='userdanger'>[bicon(holder)] Руна таинственно исчезает в небытие.</span>")
	holder.disappearance()


/datum/fanatics_rune/cauldron_of_blood
	name = "Котел Крови"
	desc = "Ускоряет ритм сердцебиения цели и повышает кровяное давление, заставляя цель испытывать сильную боль и разрывая артерии в ней. Вокруг руны должно находиться по меньшей мере три последователя."
	req_near_fanatics = 3

/datum/fanatics_rune/cauldron_of_blood/action(mob/living/carbon/human/user)
	var/list/heretics = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/human/C in range(7, center))
		if(!isfanatic(C) && C.stat != DEAD && !C.species.flags[TRAIT_NO_BLOOD])
			heretics += C

	if(!length(heretics))
		to_chat(user, "<span class='fanatics'>Нет целей.</span>")
		return FALSE

	for(var/mob/living/carbon/human/M in heretics)
		var/list/healthy_parts = list()
		for(var/obj/item/organ/external/E in M.bodyparts)
			if(!E.is_artery_cut())
				LAZYADD(healthy_parts, E)

		if(length(healthy_parts))
			for(var/obj/item/organ/external/B in healthy_parts)
				if(prob(40))
					M.blood_remove(50)
					M.adjustHalLoss(30)
					M.vomit(vomit_type = VOMIT_BLOOD)
					to_chat(M, "<span class='userdanger'>Из вас вырывается поток крови!</span>")
					break
				else
					var/obj/item/organ/external/target = pick(healthy_parts)
					to_chat(M, "<span class='userdanger'>Кровь в вашем теле начинает течь невыносимо быстро, разрывая вены и артерии!</span>")
					M.adjustHalLoss(50)
					target.status |= ORGAN_ARTERY_CUT
					break

		else
			for(var/obj/item/organ/external/head/H in M.bodyparts)
				to_chat(M, "<span class='userdanger'>Вы чувствуете сильное головное давление, словно ваша голова вот-вот ло-О--</span>")
				H.take_damage(150)
	playsound(holder, 'sound/magic/transfer_blood.ogg', VOL_EFFECTS_MASTER)


/datum/fanatics_rune/cure
	name = "Восстановление"
	desc = "Кровавые чары сращивают кости, затягивают раны, исцеляют ожоги и восстанавливают органы существам поблизости. Рядом с руной должно находиться как минимум 3 последователя."
	req_near_fanatics = 3

/datum/fanatics_rune/cure/action(mob/living/carbon/human/user)
	var/list/fanatics = list()
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/human/H in range(1, center))
		if(isfanatic(H))
			fanatics += H
	for(var/mob/living/carbon/human/H in fanatics)
		user.adjustBruteLoss(-50)
		user.adjustFireLoss(-50)
		for(var/obj/item/organ/external/E in H.bodyparts)
			if(E.is_broken())
				E.status &= ~ORGAN_BROKEN
			if(E.is_artery_cut())
				E.status &= ~ORGAN_ARTERY_CUT
		for(var/obj/item/organ/internal/IO in H.organs)
			if(IO.damage > 0)
				IO.damage = max(IO.damage - 5, 0)
	playsound(holder, 'sound/magic/transfer_blood.ogg', VOL_EFFECTS_MASTER)


/datum/fanatics_rune/communication
	name = "Сообщение"
	desc = "Передаёт сообщение в последователей."
	use_time = 15 SECOND
	var/information

/datum/fanatics_rune/communication/action(mob/living/carbon/human/user)
	information = sanitize(input(user, "Введите сообщение:"))
	if(!information)
		return
	var/text = "<span class='fanatics'>[user.real_name]'s voice: [information]</span>"
	if(get_dist(user, holder) > 1)
		return
	for(var/mob/M in global.mob_list)
		if(isobserver(M))
			to_chat(M, "[FOLLOW_LINK(M, user)] [text]")
		if(isfanatic(M))
			to_chat(M, text)
	holder.visible_message("<span class='userdanger'>[bicon(holder)] Руна таинственно исчезает в небытие.</span>")
	holder.disappearance()


/datum/fanatics_rune/armor
	name = "Создание Брони"
	desc = "Сотворяет набор надёжной брони."

/datum/fanatics_rune/armor/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	user.vomit(vomit_type = VOMIT_BLOOD)
	var/obj/item/clothing/suit/hooded/fanatics_robes/R = new(center)
	var/obj/item/clothing/gloves/fanatics/G = new(center)
	R.alpha = 0
	animate(R, alpha = 255, time = 1 SECOND)
	G.alpha = 0
	animate(G, alpha = 255, time = 1 SECOND)
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	holder.visible_message("<span class='userdanger'>На месте [bicon(holder)] руны появляется [bicon(R)] роба и [bicon(G)] перчатки.</span>")
	holder.disappearance()


/datum/fanatics_rune/claymore
	name = "Создание Меча"
	desc = "Сотворяет смертоносный клеймор."

/datum/fanatics_rune/claymore/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	user.vomit(vomit_type = VOMIT_BLOOD)
	var/obj/item/weapon/claymore/fanatics/C = new(center)
	C.alpha = 0
	animate(C, alpha = 255, time = 1 SECOND)
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	holder.visible_message("<span class='userdanger'>На месте [bicon(holder)] руны появляется [bicon(C)] клеймор.</span>")
	holder.disappearance()


/datum/fanatics_rune/charm
	name = "Создание Амулета"
	desc = "Сотворяет защитный амулет."

/datum/fanatics_rune/charm/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	user.vomit(vomit_type = VOMIT_BLOOD)
	var/obj/item/clothing/neck/fanatics_necklace/C = new(center)
	C.alpha = 0
	animate(C, alpha = 255, time = 1 SECOND)
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	holder.visible_message("<span class='userdanger'>На месте [bicon(holder)] руны появляется [bicon(C)] амулет.</span>")
	holder.disappearance()


/datum/fanatics_rune/shield
	name = "Создание Щита"
	desc = "Сотворяет прочный щит."

/datum/fanatics_rune/shield/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	user.vomit(vomit_type = VOMIT_BLOOD)
	var/obj/item/weapon/shield/buckler/fanatics/C = new(center)
	C.alpha = 0
	animate(C, alpha = 255, time = 1 SECOND)
	playsound(holder, 'sound/magic/cult_equip.ogg', VOL_EFFECTS_MASTER)
	holder.visible_message("<span class='userdanger'>На месте [bicon(holder)] руны появляется [bicon(C)] баклер.</span>")
	holder.disappearance()


/datum/fanatics_rune/meet
	name = "Сбор"
	desc = "Болезненно призывает всех последователей на руну. Живых и мёртвых."
	use_time = 30 SECOND

/datum/fanatics_rune/meet/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	for(var/mob/living/carbon/human/H in global.mob_list)
		if(!isfanatic(H) || (get_dist(H, holder) > 3))
			continue
		if(H.buckled)
			H.buckled.unbuckle_mob()
		H.forceMove(center)
		H.adjustHalLoss(110)
	playsound(holder, 'sound/magic/manifest.ogg', VOL_EFFECTS_MASTER)
	holder.visible_message("<span class='userdanger'>[bicon(holder)] Руна таинственно исчезает в небытие.</span>")
	holder.disappearance()

/datum/fanatics_rune/darkness
	name = "Тьма"
	desc = "Из Затимиса вырвется ЭМИ, оставляющий станцию без света. На руне должна находиться батарейка. Этот ритуал можно провести лишь единожды."
	use_time = 30 SECOND

/datum/fanatics_rune/darkness/before_action(mob/living/carbon/user)
	var/datum/faction/fanatics/F = find_faction_by_type(/datum/faction/fanatics)
	if(F.darkness_ritual_complete)
		to_chat(user, "<span class='fanatics'>Этот ритуал можно провести лишь единожды.</span>")
		return FALSE
	var/turf/center = get_turf(holder)
	for(var/atom/A in center.contents)
		if(istype(A, /obj/item/weapon/stock_parts/cell))
			..()
			break
		to_chat(user, "<span class='fanatics'>На руне должна находиться батарейка.</span>")
	return

/datum/fanatics_rune/darkness/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	var/datum/faction/fanatics/F = find_faction_by_type(/datum/faction/fanatics)
	for(var/atom/A in center.contents)
		if(istype(A, /obj/item/weapon/stock_parts/cell))
			F.darkness_ritual_complete = TRUE
			var/obj/item/weapon/stock_parts/cell/C = A
			user.vomit(vomit_type = VOMIT_BLOOD)
			holder.visible_message("<span class='userdanger'>[bicon(holder)] Руна таинственно исчезает в небытие, забирая с собой [bicon(A)] батарейку.</span>")
			power_failure(100)
			empulse(center, 50, 0, 1, EMP_SEBB)
			C.add_filter("disappearance", 1, motion_blur_filter(0, 0))
			animate(C.get_filter("disappearance"), x = 25, y = 25,  time = 4 SECOND)
			animate(C, alpha = 0, time = 2 SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), C), 6 SECONDS)
			holder.disappearance()
			for(var/datum/role/fanatic/fanatic in F.members)
				var/mob/living/carbon/human/member = fanatic.antag.current
				to_chat(member, "<span class='fanatics'>И пришла тьма.</span>")
			return
	to_chat(user, "<span class='fanatics'>На руне должна находиться батарейка.</span>")


/datum/fanatics_rune/madness
	name = "Безумие"
	desc = "Слабые духом существа начнут испытывать сильные галлюцинации. Рядом с руной должно находиться три последователя, а на самой руне смирительная рубашка."
	use_time = 30 SECOND
	req_near_fanatics = 3

/datum/fanatics_rune/madness/before_action(mob/living/carbon/user)
	var/turf/center = get_turf(holder)
	for(var/atom/A in center.contents)
		if(istype(A, /obj/item/clothing/suit/straight_jacket))
			..()
			break
		to_chat(user, "<span class='fanatics'>На руне должна находиться смирительная рубашка.</span>")
	return

/datum/fanatics_rune/madness/action(mob/living/carbon/human/user)
	var/turf/center = get_turf(holder)
	for(var/atom/A in center.contents)
		if(istype(A, /obj/item/clothing/suit/straight_jacket))
			var/obj/item/clothing/suit/straight_jacket/C = A
			user.vomit(vomit_type = VOMIT_BLOOD)
			holder.visible_message("<span class='userdanger'>[bicon(holder)] Руна таинственно исчезает в небытие, забирая с собой [bicon(A)] рубашку.</span>")
			C.add_filter("disappearance", 1, motion_blur_filter(0, 0))
			animate(C.get_filter("disappearance"), x = 25, y = 25,  time = 4 SECOND)
			animate(C, alpha = 0, time = 2 SECONDS)
			addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), C), 6 SECONDS)
			holder.disappearance()
			for(var/mob/living/carbon/human/target in global.human_list)
				if(isfanatic(target))
					to_chat(target, "<span class='fanatics'>Безумие явилось из глубин тьмы.</span>")
					user.playsound_local(null, pick('sound/hallucinations/demons_1.ogg', 'sound/hallucinations/demons_2.ogg', 'sound/hallucinations/demons_3.ogg'), VOL_AMBIENT, vary = FALSE, frequency = null, ignore_environment = TRUE)
					continue
				if(HAS_TRAIT(target, QUIRK_STRONG_MIND))
					continue
				target.hallucination += 600
			return
	to_chat(user, "<span class='fanatics'>На руне должна находиться смирительная рубашка.</span>")


/datum/fanatics_rune/final_ritual
	desc = "Возвышает смертного до чемпиона Мра'арха. На руне должно находиться по меньшей мере 9 последователей."
	use_time = 30 SECOND
	req_near_fanatics = 9

/datum/fanatics_rune/final_ritual/before_action(mob/living/carbon/user)
	if(SSticker.fanatics_end_ritual_has_completed)
		to_chat(user, "<span class='fanatics'>Чемпион уже избран.</span>")
		return
	var/datum/faction/fanatics/C = find_faction_by_type(/datum/faction/fanatics)
	var/datum/objective/target/fanatics_sacrifice/O = C.objective_holder.FindObjective(/datum/objective/target/fanatics_sacrifice)
	if(O)
		if(O.check_completion() != OBJECTIVE_WIN)
			to_chat(user, "<span class='fanatics'>Нужно провести жертвоприношение, иначе возвыситься не выйдет.</span>")
			return

	..()

/datum/fanatics_rune/final_ritual/action(mob/living/carbon/human/user)
	if(SSticker.fanatics_end_ritual_has_completed)
		to_chat(user, "<span class='fanatics'>Чемпион уже избран.</span>")
		return
	if(user.wear_suit)
		qdel(user.wear_suit)
	if(user.shoes)
		qdel(user.shoes)
	if(user.back)
		qdel(user.back)
	if(user.head)
		qdel(user.head)
	if(user.glasses)
		qdel(user.glasses)
	user.equip_to_slot(new /obj/item/clothing/shoes/champion(user), SLOT_SHOES)
	user.equip_to_slot(new /obj/item/clothing/suit/armor/champion_armor(user), SLOT_WEAR_SUIT)
	user.equip_to_slot(new /obj/item/weapon/champion_cape(user), SLOT_BACK)
	user.equip_to_slot(new /obj/item/clothing/head/helmet/space/champion(user), SLOT_HEAD)
	user.equip_to_slot(new /obj/item/clothing/glasses/champion(user), SLOT_GLASSES)
	user.mutations += XRAY
	user.mutations += NO_BREATH
	user.mutations += REGEN
	user.mutations += RUN
	user.update_sight()
	ADD_TRAIT(user, TRAIT_FANATICS_CHAMPION, GENERIC_TRAIT)
	user.playsound_local(null, 'sound/antag/ascend_blade.ogg', VOL_AMBIENT, vary = FALSE, frequency = null, ignore_environment = TRUE)
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			M.playsound_local(null, pick('sound/hallucinations/demons_1.ogg', 'sound/hallucinations/demons_2.ogg', 'sound/hallucinations/demons_3.ogg'), VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)
			if(!isfanatic(M))
				to_chat(M, "<font size='15' color='red'><b>Явился он - мой аватар, он одарит вас истинной болью и смертью.</b></font>")
				continue
			if(HAS_TRAIT(M, TRAIT_FANATICS_CHAMPION))
				to_chat(M, "<span class='piety'><b>Тебе дарована невероятная, божественная сила. Теперь тебе нужно показать всем моё господство. УБЕЙ ВСЕХ НЕВЕРНЫХ.</b></span>")
				continue
			to_chat(M, "<font size='15' color='red'><b>Убейте. Всех. Неверных.</b></font>")
	SSticker.fanatics_end_ritual_has_completed = TRUE
	SSshuttle.incall(0.5)
	animate(holder, color = "#1d1d1d", time = 5 SECOND)
