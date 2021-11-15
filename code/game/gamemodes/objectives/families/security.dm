/datum/objective/gang/protect_security
	explanation_text = "Мы хотим заключить сделку со свиньями из службы безопасности после этой смены. Мы чешем им спину, они чешут нашу. Понимаешь? Оградите сотрудников безопасности от любых неприятностей и убедитесь, что они будут живыми."
	conflicting_types = list(
		/datum/objective/gang/kill_security,
		/datum/objective/gang/kill_heads,
	)

/datum/objective/gang/protect_security/check_completion()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H?.mind.assigned_role in security_positions)
			if(!considered_alive(H.mind))
				return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/gang/kill_security
	explanation_text = "Некое объединение \"Сильные. Индивидуальные. Независимые. ДИКие. АвТоритетные.\" имеет какие-то тёрки с персоналом и поэтому строят козни им. Компания хочет убедиться, что никто их планы не нарушит, а нарушить могут только Сотдурники Безопасности. Поэтому, я вам приказываю убить всю охрану на объекте."
	conflicting_types = list(
		/datum/objective/gang/protect_security,
		/datum/objective/gang/kill_heads,
	)

/datum/objective/gang/kill_security/check_completion()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H?.mind.assigned_role in security_positions)
			if(considered_alive(H.mind))
				return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/gang/kill_heads
	explanation_text = "Корпорации давно прогнили, там царит блат и коррупция. Вы думаете, что на эту станцию прилетели самые умные капитаны, директоры и докторы? Нет! На станции полной богатеньких, наивных дурачков, которые за всю свою жизнь не открывали книжек. Вы должны таким главам преподнести урок, урок боли. Либо убейте, либо пригласите их в наше интеллигентное общество. К слову, некоторые умнейшие люди уже состоят в нашем сообществе и дослужились до высоких должностей НТ."
	conflicting_types = list(
		/datum/objective/gang/kill_security,
		/datum/objective/gang/protect_security,
	)

/datum/objective/gang/kill_heads/check_completion()
	for(var/mob/living/carbon/human/H as anything in global.human_list)
		if(H?.mind.assigned_role in command_positions)
			if(considered_alive(H.mind) && H.mind.GetFactionFromRoleByType(/datum/role/gangster) != faction)
				return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
