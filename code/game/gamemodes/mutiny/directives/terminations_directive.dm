// This is a parent directive meant to be derived by directives that fit
// the "fire X type of employee" pattern of directives. Simply apply your
// flavor text and override get_crew_to_terminate in your child datum.
// See alien_fraud_directive.dm for an example.
/datum/directive/terminations
	var/list/accounts_to_revoke = list()
	var/list/accounts_to_suspend = list()
	var/list/ids_to_terminate = list()

/datum/directive/terminations/proc/get_crew_to_terminate()
	return list()

/datum/directive/terminations/directives_complete()
	for(var/account_number in accounts_to_suspend)
		if (!accounts_to_suspend[account_number])
			return 0

	for(var/account_number in accounts_to_revoke)
		if (!accounts_to_revoke[account_number])
			return 0

	return ids_to_terminate.len == 0

/datum/directive/terminations/initialize()
	for(var/mob/living/carbon/human/H in get_crew_to_terminate())
		var/datum/money_account/account = H.mind.initial_account
		accounts_to_revoke["[account.account_number]"] = 0
		accounts_to_suspend["[account.account_number]"] = account.suspended
		ids_to_terminate.Add(H.wear_id)

/datum/directive/terminations/get_remaining_orders()
	var/text = ""
	for(var/account_number in accounts_to_suspend)
		if(!accounts_to_suspend[account_number])
			text += "<li>Suspend Account #[account_number]</li>"

	for(var/account_number in accounts_to_revoke)
		if(!accounts_to_revoke[account_number])
			text += "<li>Revoke Account #[account_number]</li>"

	for(var/id in ids_to_terminate)
		text += "<li>Terminate [id]</li>"

	return text
