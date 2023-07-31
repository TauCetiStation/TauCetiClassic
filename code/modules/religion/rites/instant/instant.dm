/datum/religion_rites/instant/cult
	religion_type = /datum/religion/cult

/datum/religion_rites/instant/chaplain
	religion_type = /datum/religion/chaplain

/datum/religion_rites/instant/cult/sacrifice
	name = "Жертвоприношение"
	desc = "Душа для древнего бога."
	ritual_length = (5 SECONDS)
	invoke_msg = "Для моих богов!!"
	favor_cost = 50
	can_talismaned = FALSE

/datum/religion_rites/instant/cult/sacrifice/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		return TRUE
	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только человек может пройти через ритуал.</span>")
		return FALSE
	if(AOG.buckled_mob.get_species() == HOMUNCULUS)
		to_chat(user, "<span class='warning'>Тело гомункула не годится.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/cult/sacrifice/invoke_effect(mob/user, obj/AOG)
	..()
	var/datum/religion/cult/R = religion
	var/datum/mind/sacrifice_target = R.mode.sacrifice_target

	var/mob/living/silicon/S = locate() in get_turf(AOG)
	if(S)
		R.mode.sacrificed += S.mind
		if(sacrifice_target && sacrifice_target == S.mind)
			R.send_message_to_members("<span class='[religion.style_text]'>[pick("Я̔̓̀͝͠͝ п͒̓͋̚̚͝р̀̒̾̒͑̀ѝ̈́͆́͌͝н̐͆͛̿͌͝и̒́͌̀̈́̿м͆͛̈́́͠͝а̽͐͋̽̚ю́̈́͆̕̕ т̒̿͛͑̿͑в̈́͆͊̿̕̕о́́̾͋͒̔ю͊͛̔̚̕͝ ж̓͋̈́̐͑͘е̓͋͘͠͝͝р͆̀̓̚̕͝т͋͛͋͊͝͠в͆͌͊̐̓̚у̾͋̒̈́̔͝", "Я͆̐͛ п͑̐̔р̒͆͘и͐͒̕н͑͘͝ӥ́͋͝м̀͌͌а͛͑̚ю̐͝ ж̓͆͝е̿̿р͊̓̿т̓́͘в̈́̚̚у͌̿͑ о̀̽̔б̈́̓͠р̀̽͊е͛̚͝ч͋̀̕е̾͘͝н̈́̓͠н͑͆о̐͑͝г͋̒͠о͛̚̕", "Ж͆͘͝е͋͑̽р̚͝т̽̓̈́в̿̓͠а̔͑̕ п̈́͒́р̐̈́̚и̚͠н̈́͆̾я̀̈́͘т͐́̽а͆͑͛")]</span>", null, 6, user)
			R.adjust_favor(300 * divine_power)
		S.dust()
	else if(ishuman(AOG.buckled_mob))
		R.mode.sacrificed += AOG.buckled_mob.mind
		if(sacrifice_target && sacrifice_target == AOG.buckled_mob.mind)
			R.send_message_to_members("<span class='[religion.style_text]'>[pick("Я̔̓̀͝͠͝ п͒̓͋̚̚͝р̀̒̾̒͑̀ѝ̈́͆́͌͝н̐͆͛̿͌͝и̒́͌̀̈́̿м͆͛̈́́͠͝а̽͐͋̽̚ю́̈́͆̕̕ т̒̿͛͑̿͑в̈́͆͊̿̕̕о́́̾͋͒̔ю͊͛̔̚̕͝ ж̓͋̈́̐͑͘е̓͋͘͠͝͝р͆̀̓̚̕͝т͋͛͋͊͝͠в͆͌͊̐̓̚у̾͋̒̈́̔͝", "Я͆̐͛ п͑̐̔р̒͆͘и͐͒̕н͑͘͝ӥ́͋͝м̀͌͌а͛͑̚ю̐͝ ж̓͆͝е̿̿р͊̓̿т̓́͘в̈́̚̚у͌̿͑ о̀̽̔б̈́̓͠р̀̽͊е͛̚͝ч͋̀̕е̾͘͝н̈́̓͠н͑͆о̐͑͝г͋̒͠о͛̚̕", "Ж͆͘͝е͋͑̽р̚͝т̽̓̈́в̿̓͠а̔͑̕ п̈́͒́р̐̈́̚и̚͠н̈́͆̾я̀̈́͘т͐́̽а͆͑͛")]</span>", null, 6, user)
			R.adjust_favor(300 * divine_power)
		AOG.buckled_mob.gib()

	R.adjust_favor(calc_sacrifice_favor(AOG.buckled_mob) * divine_power)

	playsound(AOG, 'sound/magic/disintegrate.ogg', VOL_EFFECTS_MASTER)
	return TRUE

/datum/religion_rites/instant/cult/sacrifice/proc/calc_sacrifice_favor(mob/L)
	if(!istype(L))
		return 0

	var/sacrifice_favor = 0
	if(isanimal(L))
		sacrifice_favor += 100
	else if(ismonkey(L))
		sacrifice_favor += 150
	else if(ishuman(L) && L.mind && L.ckey)
		sacrifice_favor += 350
	else
		sacrifice_favor += 200

	if(L.stat == DEAD)
		sacrifice_favor *= 0.5
	if(!L.ckey)
		sacrifice_favor  *= 0.5
	if(iscultist(L))
		sacrifice_favor *= 2

	return sacrifice_favor

/datum/religion_rites/instant/cult/convert
	name = "Обращение"
	desc = "Лучшая промывка мозгов в галактике!"
	ritual_length = (10 SECONDS)
	invoke_msg = "Служи ему!!!"
	favor_cost = 100
	can_talismaned = FALSE

/datum/religion_rites/instant/cult/convert/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>Для обращения нужно существо на алтаре.</span>")
		return FALSE

	if(!religion.can_convert(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Вы не можете обратить это существо.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/convert/invoke_effect(mob/user, obj/AOG)
	..()

	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>Для обращения нужно существо на алтаре.</span>")
		return FALSE

	if(!religion.can_convert(AOG.buckled_mob))
		return FALSE

	religion.add_member(AOG.buckled_mob, CULT_ROLE_HIGHPRIEST)
	if(iscarbon(AOG.buckled_mob))
		var/mob/living/carbon/C = AOG.buckled_mob
		C.uncuff()
	to_chat(AOG.buckled_mob, "<span class='[religion.style_text]'>Помогай другим культистам в тёмных делах. Их цель - твоя цель, а твоя - их. Вы вместе служите Тьме и тёмным богам.</span>")
	religion.adjust_favor(300 * divine_power)
	return TRUE

/datum/religion_rites/instant/cult/emp
	name = "ЭМИ"
	desc = "Производит электрический импульс фотонов."
	ritual_length = (5 SECONDS)
	invoke_msg = "Энергетический импульс!!!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_TECH = 2,
	)

/datum/religion_rites/instant/cult/emp/invoke_effect(mob/user, obj/AOG)
	..()
	var/turf/turf = get_turf(AOG)
	playsound(AOG, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER, 25)
	turf.hotspot_expose(700, 125)
	empulse(turf, 3 * sqrt(divine_power), 5 * divine_power)
	return TRUE

/datum/religion_rites/instant/cult/drain_torture
	name = "Высасывание Жизни"
	desc = "Высасывает жизнь из людей на заряженных столах пыток!"
	ritual_length = (1 SECONDS)
	invoke_msg = "Дай мне сил!!!"
	favor_cost = 100

	needed_aspects = list(
		ASPECT_OBSCURE = 1,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/instant/cult/drain_torture/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(table.buckled_mob && table.buckled_mob.stat != DEAD && table.buckled_mob.get_species() != HOMUNCULUS)
			return TRUE

	to_chat(user, "<span class='warning'>На заряженном столе пыток должна лежать хотя бы одна жертва.</span>")
	return FALSE

/datum/religion_rites/instant/cult/drain_torture/invoke_effect(mob/user, obj/AOG)
	..()
	var/drain = 0
	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(!table.buckled_mob || table.buckled_mob.stat == DEAD || table.buckled_mob.get_species() == HOMUNCULUS)
			continue
		var/bdrain = rand(10, 25) * divine_power
		to_chat(table.buckled_mob, "<span class='userdanger'>Вы чувствуете слабость.</span>")
		table.buckled_mob.take_overall_damage(bdrain, 0)
		table.buckled_mob.Paralyse(5 SECONDS)
		playsound(table, 'sound/magic/transfer_blood.ogg', VOL_EFFECTS_MASTER)
		drain += bdrain

	if(!drain)
		return FALSE

	user.visible_message("<span class='userdanger'>Кровь течет из пустоты в [user]!</span>", \
		"<span class='[religion.style_text]'>Кровь начинает течь из дыры в пространстве в твое слабое смертное тело. Ты чувствуешь... переполненность.</span>", \
		"<span class='userdanger'>Вы слышите течение жидкости.</span>")

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(prob(drain * 1.5))
				if(BP.is_stump || BP.status & (ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_DEAD | ORGAN_ARTERY_CUT))
					BP.rejuvenate()
					to_chat(user, "<span class='[religion.style_text]'>Ты чувствуешь прилив сил в [BP].</span>")
	if(isliving(user))
		var/mob/living/L = user
		L.heal_overall_damage(1.2 * drain, drain)
	return TRUE

/datum/religion_rites/instant/cult/raise_torture
	name = "Воскрешение"
	desc = "Уничтожает существ на столах пыток, но возрождает человека на алтаре."
	ritual_length = (10 SECONDS)
	invoke_msg = "Восстань из мертвых!!!"
	favor_cost = 300
	can_talismaned = FALSE

	needed_aspects = list(
		ASPECT_OBSCURE = 2,
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/instant/cult/raise_torture/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	if(!AOG.buckled_mob || AOG.buckled_mob.stat != DEAD || !ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>На алтаре должен лежать мертвый человек.</span>")
		return FALSE

	var/datum/religion/cult/C = religion
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(table.buckled_mob?.stat != DEAD && AOG.buckled_mob.get_species() != HOMUNCULUS)
			return TRUE

	to_chat(user, "<span class='warning'>На заряженном столе пыток должна лежать хотя бы одна жертва.</span>")
	return FALSE

/datum/religion_rites/instant/cult/raise_torture/invoke_effect(mob/user, obj/AOG)
	..()
	if(!AOG.buckled_mob || AOG.buckled_mob.stat != DEAD || !ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>На алтаре должен лежать мертвый человек.</span>")
		return FALSE

	var/mob/living/carbon/human/corpse_to_raise
	var/list/mob/living/carbon/human/targets_on_tables = list()

	var/datum/religion/cult/C = religion
	if(C.mode.sacrifice_target && C.mode.sacrifice_target == AOG.buckled_mob.mind)
		to_chat(user, "<span class='[religion.style_text]'>Я̿̀͝ ӟ́͌͝а̓͌́п̒͛̈́р͌͌̕е̾̈́̀щ̈́̚а̓͊ю̔͌͋ е̽̕г͆͛ӧ́̕̕ в̈́͝о͆̽̈́с̾͐̐к̽͒͌р̔̔̕е͋͑̈́ш̀̕͝а́͒̕т̈́̽̒ь͊̓̕!</span>")
		return FALSE
	if(AOG.buckled_mob.mind)
		corpse_to_raise = AOG.buckled_mob

	var/w_class_sum = 0
	for(var/obj/machinery/optable/torture_table/table in C.torture_tables)
		if(!table.buckled_mob || table.buckled_mob.stat == DEAD || AOG.buckled_mob.get_species() == HOMUNCULUS)
			continue
		targets_on_tables += table.buckled_mob
		w_class_sum += table.buckled_mob.w_class
		if(w_class_sum >= corpse_to_raise.w_class)
			break

	if(w_class_sum < corpse_to_raise.w_class)
		to_chat(user, "<span class='[religion.style_text]'>Не хватает тел для жертвы.</span>")
		return FALSE

	corpse_to_raise.revive()
	religion.add_member(corpse_to_raise, CULT_ROLE_HIGHPRIEST) // all checks in proc add_member, No reason to worry
	corpse_to_raise.visible_message("<span class='[religion.style_text]'>Глаза, раньше бездыханного тела, загораются слабым красным светом.</span>", \
		"<span class='[religion.style_text]'>Жизнь... Я снова живу...</span>", \
		"<span class='[religion.style_text]'>Вы слышите слабый, но знакомый шепот.</span>")
	playsound(AOG, 'sound/magic/cult_revive.ogg', VOL_EFFECTS_MASTER)
	user.say(pick("Паснар вал'кериам усинар!", "Саврае инес амутан!", "Йам'тотх ремиум ил'тарат!", "Хаккрутйу гопоенйим!", "Храсаи пивроиашан!", "Фирййи прхив мазенхор!", "Танах ех вакантахе!", "Облияе на ораие!", "Миуф хон внор'с!", "Вакабаи хий фен йусших!"))


	for(var/mob/M in targets_on_tables)
		M.visible_message("<span class='[religion.style_text]'>[M] разрывается на части, чёрный дым стремительно поднимается от останков.</span>", \
			"<span class='[religion.style_text]'>Вы чувствуете, как ваша кровь кипит, разрывая вас же на части.</span>", \
			"<span class='[religion.style_text]'>Вы слышите тысячи голосов, все из них кричат от боли.</span>")

		if(M.mind)
			C.mode.sacrificed += M.mind

		if(C.mode.sacrifice_target && C.mode.sacrifice_target == M.mind)
			to_chat(user, "<span class='[religion.style_text]'>Я принимаю жертву, ваша цель теперь может считаться выполненной.</span>")
			C.adjust_favor(300 * divine_power)

		M.gib()

	to_chat(corpse_to_raise, "<span class='[religion.style_text]'>Твоя кровь пульсирует, а голова раскалывается. Мир становится красным. Внезапно ты осознаешь ужаснейшую истину. Вуаль реальности повредилась. В твоей некогда гнившей ране пустило корни что-то зловещее.</span>")
	to_chat(corpse_to_raise, "<span class='[religion.style_text]'>Помогай своим собратьям в их темных делах. Их цель - твоя цель, а ваша - их. Отплати Темнейшему за свое воскрешение достойно.</span>")

	return TRUE

/mob/living/carbon/human/homunculus
	name = "homunculus of god"

/mob/living/carbon/human/homunculus/atom_init(mapload)
	gender = pick(MALE, FEMALE)
	height = pick(global.heights_list)
	r_eyes = rand(0, 255)
	g_eyes = rand(0, 255)
	b_eyes = rand(0, 255)

	. = ..(mapload, HOMUNCULUS)

	var/obj/item/organ/external/E = get_bodypart(BP_HEAD)
	var/list/facials = get_valid_styles_from_cache(facial_hairs_cache, E.species, gender)
	if(facials.len > 0)
		f_style = pick(facials)
	var/list/hairs = get_valid_styles_from_cache(hairs_cache, E.species, gender)
	if(hairs.len > 0)
		h_style = pick(hairs)
	update_hair()

	ADD_TRAIT(src, TRAIT_SOULSTONE_IMMUNE, GENERIC_TRAIT)

/datum/religion_rites/instant/cult/create_slave
	name = "Создание Гомункула"
	desc = "Призыв ужаснейшего существа, существующего только благодаря силе Нар-Си."
	ritual_length = (1 SECONDS) // plus 10 seconds of pollGhostCandidates
	invoke_msg = "Приди же!!!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_SPAWN = 2,
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/instant/cult/create_slave/invoke_effect(mob/user, obj/AOG)
	..()
	var/list/candidates = pollGhostCandidates("Не хотите ли вы стать гомункулом [religion.name]?", ROLE_CULTIST, IGNORE_NARSIE_SLAVE, 10 SECONDS)
	if(!candidates.len)
		to_chat(user, "<span class='warning'>Ни одна душа не захотела вселяться в гомункула.</span>")
		return FALSE
	playsound(AOG, 'sound/magic/manifest.ogg', VOL_EFFECTS_MASTER)
	for(var/i in 1 to divine_power)
		if(candidates.len < divine_power)
			return TRUE

		var/mob/M = pick(candidates)
		candidates -= M
		var/mob/living/carbon/human/homunculus/H = new(get_turf(AOG))

		H.visible_message("<span class='userdanger'>На алтаре появляется фигура. Фигура... человека.</span>", \
			"<span class='[religion.style_text]'>Вы чувствуете наслаждение от очередного вашего воскрешения.</span>", \
			"<span class='userdanger'>Вы слышите, как течет жидкость.</span>")

		H.real_name = "homunculus of [pick(religion.deity_names)] [num2roman(rand(1, 20))]"
		H.universal_speak = TRUE
		H.key = M.key

		religion.add_member(H, CULT_ROLE_HIGHPRIEST)

		to_chat(H, "<span class='[religion.style_text]'>Твоя кровь пульсирует, а голова раскалывается. Мир становится красным. Внезапно ты осознаешь ужаснейшую истину. Вуаль реальности повредилась. В твоей некогда гнившей ране пустило корни что-то зловещее.</span>")
		to_chat(H, "<span class='[religion.style_text]'>Помогай своим собратьям в их темных делах. Их цель - твоя цель, а ваша - их. Отплати Темнейшему за свое воскрешение достойно.</span>")

	return TRUE

/datum/religion_rites/instant/cult/summon_acolyt
	name = "Призыв Аколита"
	desc = "Телепортирует на алтарь тело аколита."
	ritual_length = (20 SECONDS)
	invoke_msg = "Появись же!!!"
	favor_cost = 300

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_MYSTIC = 1,
		ASPECT_RESOURCES = 1,
	)

/datum/religion_rites/instant/cult/summon_acolyt/invoke_effect(mob/user, obj/AOG)
	..()

	var/list/cultists = list()
	for(var/mob/M in religion.members)
		if(iscarbon(M))
			cultists += M

	if(!cultists.len)
		to_chat(user, "<span class='warning'>В вашей религии нет членов, даже вы не член её...</span>")
		return FALSE

	var/mob/living/carbon/cultist = input("Выберите, кого хотите призвать.", religion.name) as null|anything in cultists - user
	if(!cultist)
		return FALSE

	cultist.visible_message("<span class='userdanger'>[cultist] внезапно исчезает!</span>")
	cultist.forceMove(get_turf(AOG))

	if(AOG.can_buckle && !AOG.buckled_mob)
		AOG.user_buckle_mob(cultist, user)

	cultist.visible_message("<span class='userdanger'>С красной вспышкой появляется [cultist].</span>", \
		"<span class='[religion.style_text]'>Вас на мгновенье ослепила красная вспышка. Теперь вы видите перед собой внезапно появившееся тело.</span>", \
		"<span class='[religion.style_text]'>Вы слышите хлопок и чувствуете запах озона.</span>")

	return TRUE

/datum/religion_rites/instant/cult/brainswap
	name = "Обмен Разумов"
	desc = "Вы обмениваетесь разумом с существом на алтаре."
	ritual_length = (13 SECONDS)
	invoke_msg = "Хаккрутжу гопоенжим!!"
	favor_cost = 300

	can_talismaned = FALSE

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_OBSCURE = 2,
	)

/datum/religion_rites/instant/cult/brainswap/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	if(!isliving(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>На алтаре должно лежать живое существо.</span>")
		return FALSE

	if(AOG.buckled_mob.get_species() == HOMUNCULUS)
		to_chat(user, "<span class='warning'>Тело гомункула слишком слабо.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/brainswap/invoke_effect(mob/user, obj/AOG)
	..()
	if(!isliving(AOG.buckled_mob))
		return FALSE

	var/bdam = round(rand(2, 10) / divine_power)
	var/mob/living/target = AOG.buckled_mob
	to_chat(user, "<span class='notice'>Вы чувствуете, как теряете концентрацию...</span>")
	to_chat(target, "<span class='warning'>Вы чувствуете, как теряете концентрацию...</span>")

	if(!do_after(user, 5 SECONDS, FALSE, target))
		return FALSE

	if(target.ismindprotect())
		for(var/obj/item/weapon/implant/mind_protect/L in target)
			if(L.implanted)
				qdel(L)
		target.sec_hud_set_implants()

	var/converted = iscultist(target)
	if(!converted)
		converted = religion.add_member(target, CULT_ROLE_HIGHPRIEST)

	if(!converted)
		to_chat(user, "<span class='danger'>Попытки вселиться в данное существо обречены на провал.</span>")
		return TRUE

	target.adjustBrainLoss(bdam)
	if(isliving(user))
		var/mob/living/L = user
		L.adjustBrainLoss(bdam)
	to_chat(user, "<span class='danger'>Ваш разум перемещается в другое тело. Вы чувствуете, как частичка себя теряется в забвенье.</span>")
	target.logout_reason = LOGOUT_SWAP
	user.logout_reason = LOGOUT_SWAP
	var/mob/dead/observer/ghost = target.ghostize(FALSE)
	user.mind.transfer_to(target)
	ghost.mind.transfer_to(user)
	user.key = ghost.key
	user.say("Йу'Аи! Лаури лантар ласси сринен'ни н'тим ве рмар алдарон!!")
	target.say("Йу'Аи! Лаури лантар ласси сринен'ни н'тим ве рмар алдарон!!")
	return TRUE

/datum/religion_rites/instant/cult/give_forcearmor
	name = "Создание Силовой Ауры"
	desc = "Окружает человека на алтаре силовой аурой, которая может блокировать урон. Аспект Хаоса повышает силу щита, а аспект Салютуса - скорость восстановления."
	ritual_length = (15 SECONDS)
	invoke_msg = "Защитись же!!"
	favor_cost = 300
	can_talismaned = FALSE

	needed_aspects = list(
		ASPECT_CHAOS = 2,
		ASPECT_RESCUE = 2,
	)

/datum/religion_rites/instant/cult/give_forcearmor/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	if(AOG.buckled_mob.get_species() == HOMUNCULUS)
		to_chat(user, "<span class='warning'>Тело гомункула слишком слабо.</span>")
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только люди могут пройти через этот ритуал.</span>")
		return FALSE

	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
		return FALSE

	if(AOG.buckled_mob.GetComponent(/datum/component/forcefield))
		to_chat(user, "<span class='warning'>Эта оболочка уже под защитой.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/give_forcearmor/invoke_effect(mob/user, obj/AOG)
	..()
	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!H)
		return FALSE

	if(isliving(user))
		var/mob/living/L = user
		L.take_overall_damage(20, 10)
	H.take_overall_damage(10, 20)

	var/obj/effect/effect/forcefield/rune/R = new
	var/list/diffs = religion.get_aspect_diffs(needed_aspects)
	var/shield_health = 30 * sqrt(diffs[ASPECT_CHAOS] + 1)
	var/reactivation_time = 1 MINUTE / sqrt(diffs[ASPECT_RESCUE] + 1)
	var/recharge_time = 2.5 MINUTE / sqrt(diffs[ASPECT_RESCUE] + 1)
	H.AddComponent(/datum/component/forcefield, "power aura", shield_health, reactivation_time, recharge_time, R, FALSE, TRUE)
	SEND_SIGNAL(H, COMSIG_FORCEFIELD_PROTECT, H)

	return TRUE

/datum/religion_rites/instant/cult/upgrade_tome
	name = "Улучшение Тома"
	desc = "Заменяет старую книгу из библиотеки на мощный артефакт."
	ritual_length = (5 SECONDS)
	invoke_msg = "Больше силы!!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_WEAPON = 2,
		ASPECT_TECH = 1,
	)

/datum/religion_rites/instant/cult/upgrade_tome/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	// Can use religion.bible_type, but chaplain does not have an improved book now
	var/obj/item/weapon/storage/bible/tome/T = locate() in AOG.loc
	if(!T)
		to_chat(user, "<span class='warning'>На алтаре должен быть хотя бы один том.</span>")
		return FALSE

	return TRUE

/datum/religion_rites/instant/cult/upgrade_tome/invoke_effect(mob/user, obj/AOG)
	..()
	var/obj/item/weapon/storage/bible/tome/T = locate() in AOG.loc
	if(!T)
		return FALSE

	for(var/obj/item/weapon/storage/bible/tome/tome in AOG.loc)
		for(var/i in 1 to divine_power)
			var/obj/item/weapon/storage/bible/tome/upgraded/upgr = new(AOG.loc)
			upgr.religion = tome.religion
		qdel(tome)

	return TRUE

/datum/religion_rites/instant/impose_blind
	name = "Наложить Ослепление"
	desc = "Накладывает ослепление на всех еретиков вокруг."
	ritual_length = (5 SECONDS)
	invoke_msg = "Ослепление!!!"
	favor_cost = 75

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/instant/impose_blind/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/list/heretics = religion.nearest_heretics(AOG, 7)
	if(length(heretics) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/impose_blind/invoke_effect(mob/user, obj/AOG)
	..()
	var/list/affected = religion.nearest_heretics(AOG, 7)
	if(length(affected) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	var/blindless_modifier = clamp(90 / length(affected), 5 * divine_power, 30)
	for(var/mob/living/carbon/C in affected)
		C.blurEyes(blindless_modifier)
		C.eye_blind += blindless_modifier / 2
		if(prob(5))
			C.become_nearsighted(GENETIC_MUTATION_TRAIT)
			if(prob(10))
				C.sdisabilities |= BLIND
		C.show_message("<span class='userdanger'>Внезапно вы видите красную вспышку, которая ослепила вас.</span>", SHOWMSG_VISUAL)
	return TRUE

/datum/religion_rites/instant/impose_deaf
	name = "Наложить Глухоту"
	desc = "Накладывает глухоту на всех еретиков вокруг."
	ritual_length = (5 SECONDS)
	invoke_msg = "Оглохните!!!"
	favor_cost = 50

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/instant/impose_deaf/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/list/heretics = religion.nearest_heretics(AOG, 7)
	if(length(heretics) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/impose_deaf/invoke_effect(mob/living/user, obj/AOG)
	..()
	var/list/affected = religion.nearest_heretics(AOG, 7)
	if(length(affected) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	var/deafness_modifier = max(5 * divine_power, 120 / length(affected))
	for(var/mob/living/carbon/C in affected)
		C.playsound_local(null, 'sound/effects/mob/ear_ring_single.ogg', VOL_EFFECTS_MASTER)
		C.ear_deaf += deafness_modifier
		to_chat(C, "<span class='userdanger'>Мир вокруг вас внезапно становится тихим.</span>")
		if(prob(5))
			C.sdisabilities |= DEAF
	return TRUE

/datum/religion_rites/instant/impose_stun
	name = "Наложить Оглушение"
	desc = "Накладывает оглушение на всех еретиков вокруг."
	ritual_length = (5 SECONDS)
	invoke_msg = "Оглушение!!!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_CHAOS = 1,
		ASPECT_OBSCURE = 1,
	)

/datum/religion_rites/instant/impose_stun/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/list/heretics = religion.nearest_heretics(AOG, 2)
	if(length(heretics) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	return TRUE

/datum/religion_rites/instant/impose_stun/invoke_effect(mob/user, obj/AOG)
	..()
	var/list/heretics = religion.nearest_heretics(AOG, 2)
	if(length(heretics) < 1)
		to_chat(user, "<span class='warning'>Никого нет рядом.</span>")
		return FALSE
	var/stun_modifier = 12 / length(heretics) * round(sqrt(divine_power))
	for(var/mob/living/L in heretics)
		if(!(L.status_flags & CANSTUN)) //Hulks, golems
			L.Stun(stun_modifier / 2, TRUE)
			flash_color(L, flash_time = stun_modifier * 5)
		else
			L.Stun(stun_modifier * 0.8)
			flash_color(L, flash_time = stun_modifier SECONDS)
		if(!(HULK in L.mutations))
			L.Stuttering(stun_modifier)
			L.Weaken(stun_modifier)
			L.show_message("<span class='userdanger'>У вас будто вылетает душа из тела, а по возвращению теряет контроль над телом!</span>", SHOWMSG_VISUAL)
	return TRUE

/datum/religion_rites/instant/communicate
	name = "Общение"
	desc = "Отправляет телепатическое сообщение всем членам религии!"
	ritual_length = (1 SECONDS)
	invoke_msg = "Услышь меня!!!"
	favor_cost = 50

/datum/religion_rites/instant/communicate/invoke_effect(mob/user, obj/AOG)
	..()
	favor_cost = initial(favor_cost) / divine_power
	var/input = sanitize(input(user, "Введите сообщение, которое услышат другие последователи.", "[religion.name]", ""))
	if(!input)
		return FALSE

	var/text = "<span class='[user.my_religion.style_text]'>Аколит [user.real_name]: [input]</span>"
	log_say("([user.my_religion.name]) Аколит [user.real_name]: [input]")
	for(var/mob/M in global.mob_list)
		if(isobserver(M))
			to_chat(M, "[FOLLOW_LINK(M, user)] [text]")
		if(user.my_religion.is_member(M))
			to_chat(M, text)

	playsound(AOG, 'sound/magic/message.ogg', VOL_EFFECTS_MASTER)

	return TRUE
