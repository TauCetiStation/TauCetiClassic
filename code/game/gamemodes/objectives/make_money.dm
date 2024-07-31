/datum/objective/make_money
	explanation_text = "Заработайте много кредитов. Они должны находиться на вашем счёте."
	var/required_money

/datum/objective/make_money/New()
	explanation_text = "Заработайте [required_money] кредитов. Они должны находиться на вашем счёте."

/datum/objective/make_money/check_completion()
	if(owner)
		var/datum/money_account/MA = get_account(owner.get_key_memory(MEM_ACCOUNT_NUMBER))
		if(MA.money >= required_money)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/make_money/faction/check_completion()
	if(faction)
		var/total_money = 0
		for(var/datum/role/R in faction.members)
			var/datum/money_account/MA = get_account(R.antag.get_key_memory(MEM_ACCOUNT_NUMBER))
			total_money += MA.money
		if(total_money >= required_money)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/make_money/faction/traders
	required_money = 20000
