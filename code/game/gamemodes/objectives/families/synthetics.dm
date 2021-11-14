/datum/objective/gang/destroy_synthetics
	explanation_text = "МАШИНЫ СКОРО ЗАХВАТЯТ МИР И ИСТРЕБЯТ ВСЕ ЖИВОЕ!!! УНИЧТОЖЬТЕ ВСЕХ СИНТЕТИКОВ НА СТАНЦИИ!!! ОРГАНИКИ ДОЛЖНЫ ПРОЦВЕТАТЬ, А НЕ МАШИНЫ!!!"
	conflicting_types = list(
		/datum/objective/gang/reproduce_synthetics,
		/datum/objective/gang/build_ai,
	)

/datum/objective/gang/destroy_synthetics/check_completion()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H.spesies.name == IPC && H.mind && H.state != DEAD)
			return OBJECTIVE_LOSS

	if(!global.silicon_list.len && !global.ai_list.len)
		return OBJECTIVE_WIN

	for(var/mob/living/silicon/S as anything in global.silicon_list + global.ai_list)
		if(S.stat != DEAD)
			return OBJECTIVE_LOSS

	return OBJECTIVE_WIN

/datum/objective/gang/reproduce_synthetics
	explanation_text = "За киборгами будущее. Это же очень дешевая рабочая сила для узконаправленных задач. Вот представь, что на станции вместо тебя, того чувака из пробирки и зэка будут работать бездушные машины, а пока они работают ты купаешь в своем джакузи в окружение бухла и наркоты. Так вот, я хочу это осуществить в жизнь. Перевезите 7 боргов на ЦК. Мои чумбы их примут и доставят куда нужно. Ах да, чуть не забыл, главный секрет боргов и ИИ в том, что в качестве процессора служит мозг органика (или нимфа), поэтому придётся вам попотеть для осуществления мечты."
	conflicting_types = list(
		/datum/objective/gang/destroy_synthetics,
		/datum/objective/gang/build_ai,
	)

/datum/objective/gang/reproduce_synthetics/check_completion()
	var/total_cyborgs = 0
	for(var/mob/living/silicon/S as anything in global.silicon_list)
		if(is_type_in_list(get_area(S), centcom_shuttle_areas))
			total_cyborgs++
		if(total_cyborgs >= 7)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/gang/build_ai
	explanation_text = "Я думаю, что вам не нужно доказывать бесполезность всяких киборгов и искусственных интеллектов, но представьте, кто-то думает, что они действительно полезны! Это же бестолковая трата ресурсов и мозгов маленьких миленьких таярочек. Вот вы же раньше уже работали на какой-нибудь другой станции с ИИ, он хотя бы раз использовался не с целью открытия шлюза? Эта же техника нужна буквально только для открытия дверей! А представьте что будет, если на станции два ИИ, а три? Хаос и анархия дверей. Постройте где-нибудь 4 ИИ и тогда все поймут, что это зло!"
	conflicting_types = list(
		/datum/objective/gang/destroy_synthetics,
		/datum/objective/gang/reproduce_synthetics,
	)

/datum/objective/gang/reproduce_synthetics/check_completion()
	var/total_AI = 0
	for(var/mob/living/silicon/S as anything in global.ai_list)
		if(S.stat != DEAD)
			total_AI++
		if(total_AI >= 4)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
