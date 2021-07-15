/datum/objective/gang/protect_security
	explanation_text = "Мы хотим заключить сделку со свиньями из службы безопасности после этой смены. Мы чешем им спину, они чешут нашу. Понимаешь? Оградите сотрудников безопасности от любых неприятностей и убедитесь, что они будут живыми."

/datum/objective/gang/protect_security/check_completion()
	for(var/mob/M in global.player_list)
		if(M.mind?.assigned_role in security_positions)
			if(!considered_alive(M.mind) && !M.suiciding)
				return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
