/proc/random_blood_type()
	return pickweight(list(
		BLOOD_O_MINUS  = 4,
		BLOOD_O_PLUS   = 36,
		BLOOD_A_MINUS  = 3,
		BLOOD_A_PLUS   = 28,
		BLOOD_B_MINUS  = 1,
		BLOOD_B_PLUS   = 20,
		BLOOD_AB_MINUS = 1,
		BLOOD_AB_PLUS  = 5
	))

/proc/random_hair_style(gender, species = HUMAN, ipc_head)
	var/h_style = "Bald"

	var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache, species, gender, ipc_head)

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_gradient_style()
	return pick(hair_gradients)

/proc/random_facial_hair_style(gender, species = HUMAN)
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache, species, gender)

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

/proc/random_unique_name(gender, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender == FEMALE)
			. = capitalize(pick(global.first_names_female)) + " " + capitalize(pick(global.last_names))
		else
			. = capitalize(pick(global.first_names_male)) + " " + capitalize(pick(global.last_names))

		if(!findname(.))
			break

/proc/random_name(gender, species = HUMAN)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/proc/random_skin_tone()
	switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
		if("caucasian")		. = -10
		if("afroamerican")	. = -115
		if("african")		. = -165
		if("latino")		. = -55
		if("albino")		. = 34
		else				. = rand(-185,34)
	return min(max( .+rand(-25, 25), -185),34)

/proc/skintone2racedescription(tone)
	switch (tone)
		if(30 to INFINITY)		return "albino"
		if(20 to 30)			return "pale"
		if(5 to 15)				return "light skinned"
		if(-10 to 5)			return "white"
		if(-25 to -10)			return "tan"
		if(-45 to -25)			return "darker skinned"
		if(-65 to -45)			return "brown"
		if(-INFINITY to -65)	return "black"
		else					return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

//helper for inverting armor blocked values into a multiplier
#define blocked_mult(blocked) max(1 - (blocked / 100), 0)

/proc/do_mob(mob/user , mob/target, time = 30, check_target_zone = FALSE, uninterruptible = FALSE, progress = TRUE, datum/callback/extra_checks = null)
	if(!user || !target)
		return FALSE

	time *= (1.0 + user.mood_multiplicative_actionspeed_modifier)

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	target.in_use_action = TRUE

	if(check_target_zone)
		check_target_zone = user.get_targetzone()

	var/user_loc = user.loc

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, time, target)
		else
			progress = FALSE

	var/endtime = world.time+time
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)
		if(QDELETED(user) || QDELETED(target))
			. = FALSE
			break
		if(uninterruptible)
			continue
		if(user.loc != user_loc || target.loc != target_loc || user.incapacitated() || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(HAS_TRAIT(user, TRAIT_MULTITASKING))
			if(user.hand != busy_hand)
				if(user.get_inactive_hand() != holding)
					. = FALSE
					break
			else
				if(user.get_active_hand() != holding)
					. = FALSE
					break
		else
			if(user.hand != busy_hand)
				. = FALSE
				break
			if(user.get_active_hand() != holding)
				. = FALSE
				break

		if(check_target_zone && user.get_targetzone() != check_target_zone)
			. = FALSE
			break
	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target)
		target.in_use_action = FALSE

/proc/do_after(mob/user, delay, needhand = TRUE, atom/target, can_move = FALSE, progress = TRUE, datum/callback/extra_checks)
	if(!user || target && QDELING(target))
		return FALSE

	delay *= (1.0 + user.mood_multiplicative_actionspeed_modifier)

	var/busy_hand = user.hand
	user.become_busy(_hand = busy_hand)

	var/target_null = TRUE
	var/atom/Tloc = null
	if(target)
		target_null = FALSE
		if(target != user)
			target.in_use_action = TRUE
			Tloc = target.loc

	var/atom/Uloc = null
	if(!can_move)
		Uloc = user.loc

	var/obj/item/holding = user.get_active_hand()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if (progress)
		if(user.client && (user.client.prefs.toggles & SHOW_PROGBAR))
			progbar = new(user, delay, target)
		else
			progress = FALSE

	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(QDELETED(user) || !target_null && QDELETED(target))
			. = FALSE
			break

		if(user.incapacitated(NONE))
			. = FALSE
			break

		if(Uloc && (user.loc != Uloc) || Tloc && (Tloc != target.loc))
			. = FALSE
			break
		if(extra_checks && !extra_checks.Invoke(user, target))
			. = FALSE
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull && QDELETED(holding))
				. = FALSE
				break

			if(HAS_TRAIT(user, TRAIT_MULTITASKING))
				if(user.hand != busy_hand)
					if(user.get_inactive_hand() != holding)
						. = FALSE
						break
				else
					if(user.get_active_hand() != holding)
						. = FALSE
						break
			else
				if(user.hand != busy_hand)
					. = FALSE
					break
				if(user.get_active_hand() != holding)
					. = FALSE
					break

	if(progress)
		qdel(progbar)
	if(user)
		user.become_not_busy(_hand = busy_hand)
	if(target && target != user)
		target.in_use_action = FALSE

//Returns true if this person has a job which is a department head
/mob/proc/is_head_role()
	. = FALSE
	if(!mind || !mind.assigned_job)
		return
	return mind.assigned_job.head_position

/mob/proc/IsShockproof()
	return HAS_TRAIT(src, TRAIT_SHOCKIMMUNE)

/mob/proc/IsClumsy()
	return HAS_TRAIT(src, TRAIT_CLUMSY)

/mob/proc/ClumsyProbabilityCheck(probability)
	if(HAS_TRAIT(src, TRAIT_CLUMSY) && prob(probability))
		return TRUE
	return FALSE

/proc/health_analyze(mob/living/M, mob/living/user, mode, output_to_chat, hide_advanced_information, scan_hallucination = FALSE, advanced = FALSE)
	var/message = ""
	var/insurance_type

	if(ishuman(M))
		insurance_type = get_insurance_type(M)

	if(!output_to_chat)
		message += "<HTML><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>Результаты сканирования [M.name]</title></head><BODY>"

	if(user.ClumsyProbabilityCheck(50) || (user.getBrainLoss() >= 60 && prob(50)))
		user.visible_message("<span class='warning'>[user] сканирует жизненные показатели пола!</span>", "<span class = 'warning'>Вы пытаетесь просканировать жизненные показатели пола!</span>")
		message += "<span class='notice'>Результаты сканирования пола:\n&emsp; Общее состояние: здоров</span><br>"
		message += "<span class='notice'>&emsp; Специфика повреждений: [0]-[0]-[0]-[0]</span><br>"
		message += "<span class='notice'>Типы: Асфиксия/Интоксикация/Термические/Механические</span><br>"
		message += "<span class='notice'>Температура тела: ???</span>"
		if(!output_to_chat)
			message += "</BODY></HTML>"
		return message
	user.visible_message("<span class='notice'>[user] сканирует жизненные показатели [M].</span>","<span class='notice'>Вы просканировали жизненные показатели [M].</span>")

	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		message += "<span class='notice'>Результаты сканирования [M]:\n&emsp; Общее состояние: мёртв</span><br>"
	else
		message += "<span class='notice'>Результаты сканирования [M]:\n&emsp; Общее состояние: [M.stat > 1 ? "мёртв" : "Здоровье: [M.health - M.halloss]%"]</span><br>"
	message += "&emsp; Типы: <font color='blue'>Асфиксия</font>/<font color='green'>Интоксикация</font>/<font color='#FFA500'>Термические</font>/<font color='red'>Механические</font><br>"
	message += "&emsp; Специфика повреждений: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font><br>"
	message += "<span class='notice'>Температура тела: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span><br>"
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		message += "<span class='notice'>Время смерти: [M.tod]</span><br>"
	if(ishuman(M) && mode)
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		message += "<span class='notice'>Обнаруженные повреждения:</span><br>"
		if(length(damaged))
			for(var/obj/item/organ/external/BP in damaged)
				message += "<span class='notice'>&emsp; [capitalize(CASE(BP, NOMINATIVE_CASE))]: \
					[(BP.brute_dam > 0) ? "<span class='warning'>[BP.brute_dam]</span>" : 0]\
					[(BP.status & ORGAN_BLEEDING) ? "<span class='warning bold'> \[Кровотечение\]</span>" : "&emsp;"] - \
					[(BP.burn_dam > 0) ? "<font color='#FFA500'>[BP.burn_dam]</font>" : 0]\
					[BP.controller.bodypart_type == BODYPART_ROBOTIC ? " (Кибернетический)" : ""]</span><br>"
		else
			message += "<span class='notice'>&emsp; Конечности целы.</span><br>"

	if(hide_advanced_information)
		if(!output_to_chat)
			message += "</BODY></HTML>"

		return message

	OX = M.getOxyLoss() > 50 ? "<font color='blue'><b>Обнаружено сильное кислородное голодание</b></font>" : "Уровень кислорода в крови субъекта в норме"
	TX = M.getToxLoss() > 50 ? "<font color='green'><b>Обнаружено опасное количество токсинов</b></font>" : "Уровень токсинов в крови субъекта минимальный"
	BU = M.getFireLoss() > 50 ? "<font color='#FFA500'><b>Обнаружена серьезная ожоговая травма</b></font>" : "Термических травм не обнаружено"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Обнаружена серьезная анатомическая травма</b></font>" : "Механических травм не обнаружено"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='warning'>Обнаружено сильное кислородное голодание</span>" : "Уровень кислорода в крови субъекта в норме"
	message += "[OX]<br>[TX]<br>[BU]<br>[BR]<br>"
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.reagents.total_volume && advanced)
			message += "<span class='warning'>Обнаруженные вещества в крови:</span><br>"
			for(var/datum/reagent/R in C.reagents.reagent_list)
				message += "&emsp; <span class='notice'>\
					[R.overdose != 0 && R.volume >= R.overdose ? "<span class='bold warning'>OD: </span>" : ""]\
					[round(R.volume, 1)]u [R.name]</span><br>"
		if(C.virus2.len)
			if(C.is_infected_with_zombie_virus() && advanced)
				message += "<span class='warning'>Внимание: Обнаружена нетипичная активность патогена в крови!</span><br>"
			for (var/ID in C.virus2)
				if (ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					message += "<span class='warning'>Внимание: Обнаружен патоген [V.fields["name"]] в крови. Известный антиген: [V.fields["antigen"]]</span><br>"
		if(C.roundstart_quirks.len)
			message += "\t<span class='info'>Объект имеет следующие физиологические особенности: [C.get_trait_string()].</span><br>"
	if(M.getCloneLoss())
		to_chat(user, "<span class='warning'>Объект, по-видимому, был некачественно клонирован.</span>")
	if(M.has_brain_worms())
		message += "<span class='warning'>Объект страдает от аномальной активности мозга. Рекомендуется дополнительное сканирование.</span><br>"
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.has_brain() && H.should_have_organ(O_BRAIN))
			message += "<span class='warning'>У субъекта отсутствует мозг.</span><br>"
	else if(M.getBrainLoss() >= 100)
		message += "<span class='warning'>Мозг субъекта мёртв.</span><br>"
	else if(M.getBrainLoss() >= 60)
		message += "<span class='warning'>Обнаружено тяжелое повреждение головного мозга. Вероятна умственная отсталость.</span><br>"
	else if(M.getBrainLoss() >= 10)
		message += "<span class='warning'>Обнаружено значительное повреждение головного мозга. Возможно, у пациента было сотрясение мозга.</span><br>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/found_bleed
		var/found_broken
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				if(((BP.body_zone == BP_L_ARM) || (BP.body_zone == BP_R_ARM) || (BP.body_zone == BP_L_LEG) || (BP.body_zone == BP_R_LEG)) && !(BP.status & ORGAN_SPLINTED))
					message += "<span class='warning'>Обнаружен незафиксированный перелом в [CASE(BP, PREPOSITIONAL_CASE)]. При транспортировке рекомендуется наложение шины.</span><br>"
				if(!found_broken)
					found_broken = TRUE

			if(!found_bleed && (BP.status & ORGAN_ARTERY_CUT))
				found_bleed = TRUE

			if(BP.has_infected_wound())
				message += "<span class='warning'>Обнаружена инфекция в [CASE(BP, PREPOSITIONAL_CASE)]. Рекомендуется дезинфекция.</span><br>"

		if(found_bleed)
			message += "<span class='warning'>Обнаружено артериальное кровотечение. Для определения местоположения требуется медицинский сканер.</span><br>"
		if(found_broken)
			message += "<span class='warning'>Обнаружен перелом костей. Для определения местоположения требуется медицинский сканер.</span><br>"

		var/blood_volume = H.blood_amount()
		var/blood_percent =  100.0 * blood_volume / BLOOD_VOLUME_NORMAL
		var/blood_type = H.dna.b_type
		if(blood_volume <= BLOOD_VOLUME_SAFE && blood_volume > BLOOD_VOLUME_OKAY)
			message += "<span class='warning bold'>Внимание: критический уровень крови: [blood_percent]% [blood_volume]сл.</span><span class='notice'>Группа крови: [blood_type]</span><br>"
		else if(blood_volume <= BLOOD_VOLUME_OKAY)
			message += "<span class='warning bold'>Внимание: Уровень крови КРИТИЧЕСКИЙ: [blood_percent]% [blood_volume]сл.</span><span class='notice bold'>Группа крови: [blood_type]</span><br>"
		else
			message += "<span class='notice'>Уровень крови нормальный: [blood_percent]% [blood_volume]сл. Группа крови: [blood_type]</span><br>"

		var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
		if(Heart)
			switch(Heart.heart_status)
				if(HEART_FAILURE)
					message += "<span class='notice'><font color='red'>Внимание! Остановка сердца!</font></span><br>"
				if(HEART_FIBR)
					message += "<span class='notice'>Состояние сердца пациента: <font color='blue'>Внимание! Сердце подвержено фибрилляции.</font></span><br>"
			message += "<span class='notice'>Пульс пациента: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] уд/мин.</font></span><br>"
	var/list/reflist = list(message, scan_hallucination)
	SEND_SIGNAL(M, COMSIG_LIVING_HEALTHSCAN, reflist)
	message = reflist[1]

	if(insurance_type)
		message += "<span class='notice'><font color='blue'>Страховка: [insurance_type]</font></span><br>"

	if(!output_to_chat)
		message += "</BODY></HTML>"

	return message

/proc/get_sound_by_voice(mob/user, male_sounds, female_sounds)
	if(user.gender == FEMALE)
		return pick(female_sounds)

	else if(user.gender == NEUTER)
		return pick(user.neuter_gender_voice == MALE ? male_sounds : female_sounds)

	return pick(male_sounds)

/proc/get_germ_level_name(germ_level)
	switch(germ_level)
		if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE_PLUS)
			return "Лёгкая инфекция"
		if(INFECTION_LEVEL_ONE_PLUS to INFECTION_LEVEL_ONE_PLUS_PLUS)
			return "Лёгкая инфекция+"
		if(INFECTION_LEVEL_ONE_PLUS_PLUS to INFECTION_LEVEL_TWO)
			return "Лёгкая инфекция++"
		if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO_PLUS)
			return "Острая инфекция"
		if(INFECTION_LEVEL_TWO_PLUS to INFECTION_LEVEL_TWO_PLUS_PLUS)
			return "Острая инфекция+"
		if(INFECTION_LEVEL_TWO_PLUS_PLUS to INFECTION_LEVEL_THREE)
			return "Острая инфекция++"
		if(INFECTION_LEVEL_THREE to INFINITY)
			return "Сепсис"
	return
