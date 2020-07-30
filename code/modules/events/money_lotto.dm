/datum/event/money_lotto
	var/winner_name = "John Smith"
	var/winner_sum = 0
	var/deposit_success = 0

/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	var/list/employee_accounts = all_money_accounts
	for(var/i in department_accounts)
		employee_accounts.Remove(department_accounts[i])
	employee_accounts.Remove(station_account)

	if(employee_accounts.len)
		var/datum/money_account/D = pick(employee_accounts)
		winner_name = D.owner_name
		if(charge_to_account(D.account_number, "[system_name()] Daily Grand Slam -Stellar- Lottery", "Winner!", "Biesel TCD Terminal #[rand(111,333)]", winner_sum))
			deposit_success = 1

/datum/event/money_lotto/announce()
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "NanoTrasen Editor"
	newMsg.is_admin_message = 1

	newMsg.body = "TC Daily wishes to congratulate <b>[winner_name]</b> for recieving the [system_name()] Stellar Slam Lottery, and receiving the out of this world sum of [winner_sum] credits!"
	if(!deposit_success)
		newMsg.body += "<br>Unfortunately, we were unable to verify the account details provided, so we were unable to transfer the money. Send a cheque containing the sum of $500 to TCD 'Stellar Slam' office on Biesel Prime containing updated details, and your winnings'll be resent within the month."

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "[system_name()] Daily")
			FC.messages += newMsg
			break

	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("[system_name()] Daily")
