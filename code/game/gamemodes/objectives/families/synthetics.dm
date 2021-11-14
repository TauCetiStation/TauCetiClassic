/datum/objective/gang/destroy_synthetics
	explanation_text = "МАШИНЫ СКОРО ЗАХВАТЯТ МИР И ИСТРЕБЯТ ВСЕ ЖИВОЕ!!! УНИЧТОЖЬТЕ ВСЕХ СИНТЕТИКОВ НА СТАНЦИИ!!! ОРГАНИКИ ДОЛЖНЫ ПРОЦВЕТАТЬ, А НЕ МАШИНЫ!!!"
	conflicting_types = list(
		/datum/objective/gang/reproduce_synthetics
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
		/datum/objective/gang/destroy_synthetics
	)

/datum/objective/gang/reproduce_synthetics/check_completion()
	var/total_cyborgs = 0
	for(var/mob/living/silicon/S as anything in global.silicon_list)
		if(is_type_in_list(get_area(S), centcom_shuttle_areas))
			total_cyborgs++
		if(total_cyborgs >= 7)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
