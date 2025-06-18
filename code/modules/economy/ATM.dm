/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
#define INSURANCE_MANAGEMENT 4

/obj/item/weapon/card/id/var/money = 2000

/obj/machinery/atm
	name = "NanoTrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "atm"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	resistance_flags = FULL_INDESTRUCTIBLE
	var/datum/money_account/authenticated_account
	var/number_incorrect_tries = 0
	var/previous_account_number = 0
	var/max_pin_attempts = 3
	var/ticks_left_locked_down = 0
	var/ticks_left_timeout = 0
	var/machine_id = ""
	var/obj/item/weapon/card/held_card
	var/editing_security_level = 0
	var/view_screen = NO_SCREEN
	var/datum/effect/effect/system/spark_spread/spark_system
	var/money_stock = 15000
	var/money_stock_max = 25000
	var/pin_visible_until = 0

/obj/machinery/atm/atom_init()
	. = ..()
	machine_id = "[station_name()] RT #[num_financial_terminals++]"
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/machinery/atm/Destroy()
	if(spark_system)
		qdel(spark_system)
	return ..()

/obj/machinery/atm/process()
	if(stat & NOPOWER)
		return

	if(ticks_left_timeout > 0)
		ticks_left_timeout--
		if(ticks_left_timeout <= 0)
			authenticated_account = null
	if(ticks_left_locked_down > 0)
		ticks_left_locked_down--
		if(ticks_left_locked_down <= 0)
			number_incorrect_tries = 0

/obj/machinery/atm/proc/deposit(obj/item/I, mob/user, money_sum, stock_string)
	if(prob(50))
		playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
	else
		playsound(src, 'sound/items/polaroid2.ogg', VOL_EFFECTS_MASTER)

	//create a transaction log entry
	var/datum/transaction/T = new()
	T.target_name = authenticated_account.owner_name
	T.purpose = "Credit deposit"
	if(stock_string)
		T.purpose += ". Stock deposit: [stock_string]"

	T.amount = money_sum
	T.source_terminal = machine_id
	T.date = current_date_string
	T.time = worldtime2text()
	authenticated_account.transaction_log.Add(T)

	to_chat(user, "<span class='info'>You insert [I] into [src].</span>")
	attack_hand(user)
	qdel(I)

/obj/machinery/atm/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card))
		if(emagged > 0)
			//prevent inserting id into an emagged ATM
			to_chat(user, "<span class='warning'>[bicon(src)] CARD READER ERROR. This system has been compromised!</span>")
			return

		var/obj/item/weapon/card/id/idcard = I
		if(!held_card)
			usr.drop_from_inventory(idcard, src)
			held_card = idcard
			if(authenticated_account && held_card.associated_account_number != authenticated_account.account_number)
				authenticated_account = null
		return

	if(!authenticated_account)
		return ..()

	if(istype(I, /obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/SC = I
		if((money_stock + SC.worth) > money_stock_max)
			tgui_alert(usr, "Sorry, the ATM cash storage is full and can only hold $[money_stock_max]")
			return

		money_stock += SC.worth
		authenticated_account.adjust_money(SC.worth)

		deposit(SC, user, SC.worth, "")
		return

	if(istype(I, /obj/item/weapon/ewallet))
		var/obj/item/weapon/ewallet/EW = I
		var/stocks_amount = EW.get_stocks()
		var/money_amount = EW.get_money()

		authenticated_account.adjust_stocks(stocks_amount)
		authenticated_account.adjust_money(money_amount)

		var/datum/money_account/wallet_account = get_account(EW.account_number)

		if(wallet_account)
			for(var/stock_type in stocks_amount)
				var/stock_amount = stocks_amount[stock_type]
				wallet_account.adjust_stock(stock_type, -stock_amount)

			wallet_account.adjust_money(-money_amount)

		deposit(EW, user, money_amount, get_stocks_string(stocks_amount))
		return

/obj/machinery/atm/emag_act(mob/user)
	//short out the machine, shoot sparks, spew money!
	emagged = 1
	spark_system.start()
	print_money_stock(rand(100,500))
	//we don't want to grief people by locking their id in an emagged ATM
	release_held_id(user)
	//display a message to the user
	var/response = pick("Initiating withdraw. Have a nice day!", "CRITICAL ERROR: Activating cash chamber panic siphon.","PIN Code accepted! Emptying account balance.", "Jackpot!")
	to_chat(user, "<span class='warning'>[bicon(src)] The [src] beeps: \"[response]\"</span>")
	return TRUE

/obj/machinery/atm/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	to_chat(user, "<span class='red'>[bicon(src)] Artificial unit recognized. Artificial units do not currently receive monetary compensation, as per NanoTrasen regulation #1005.</span>")

/obj/machinery/atm/ui_interact(mob/user)
	if(isobserver(user))
		to_chat(user, "[src]'s UI has no support for observer, ask coder team to implement it.")
		return

	//js replicated from obj/machinery/computer/card
	var/dat = ""
	dat += "For all your monetary needs!<br>"
	dat += "<i>This terminal is</i> [machine_id]. <i>Report this code when contacting NanoTrasen IT Support</i><br/>"

	if(emagged > 0)
		dat += "Card: <span style='color: red;'>LOCKED</span><br><br><span style='color: red;'>Unauthorized terminal access detected! This ATM has been locked. Please contact NanoTrasen IT Support.</span>"
	else
		dat += "Card: <a href='?src=\ref[src];choice=insert_card'>[held_card ? held_card.name : "------"]</a><br><br>"

		if(ticks_left_locked_down > 0)
			dat += "<span class='alert'>Maximum number of pin attempts exceeded! Access to this ATM has been temporarily disabled.</span>"
		else if(authenticated_account)
			if(authenticated_account.suspended)
				dat += "<span class='warning'><b>Access to this account has been suspended, and the funds within frozen.</b></span>"
			else
				switch(view_screen)
					if(CHANGE_SECURITY_LEVEL)
						dat += "Select a new security level for this account:<br><hr>"
						var/text = "Zero - Either the account number or card is required to access this account. EFTPOS transactions will require a card and ask for a pin, but not verify the pin is correct."
						if(authenticated_account.security_level != 0)
							text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=0'>[text]</a>"
						dat += "[text]<hr>"
						text = "One - An account number and pin must be manually entered to access this account and process transactions."
						if(authenticated_account.security_level != 1)
							text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=1'>[text]</a>"
						dat += "[text]<hr>"
						text = "Two - In addition to account number and pin, a card is required to access this account and process transactions."
						if(authenticated_account.security_level != 2)
							text = "<A href='?src=\ref[src];choice=change_security_level;new_security_level=2'>[text]</a>"
						dat += "[text]<hr><br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"
					if(VIEW_TRANSACTION_LOGS)
						dat += "<b>Transaction logs</b><br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a>"
						dat += "<table border=1 style='width:100%'>"
						dat += "<tr>"
						dat += "<td><b>Date</b></td>"
						dat += "<td><b>Time</b></td>"
						dat += "<td><b>Target</b></td>"
						dat += "<td><b>Purpose</b></td>"
						dat += "<td><b>Value</b></td>"
						dat += "<td><b>Source terminal ID</b></td>"
						dat += "</tr>"
						for(var/datum/transaction/T in authenticated_account.transaction_log)
							dat += "<tr>"
							dat += "<td>[T.date]</td>"
							dat += "<td>[T.time]</td>"
							dat += "<td>[T.target_name]</td>"
							dat += "<td>[T.purpose]</td>"
							dat += "<td>$[T.amount]</td>"
							dat += "<td>[T.source_terminal]</td>"
							dat += "</tr>"
						dat += "</table>"
						dat += "<A href='?src=\ref[src];choice=print_transaction'>Print</a><br>"
					if(TRANSFER_FUNDS)
						dat += "<b>Account balance:</b> $[authenticated_account.money]<br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br><br>"
						dat += "<form name='transfer' action='?src=\ref[src]' method='get'>"
						dat += "<input type='hidden' name='src' value='\ref[src]'>"
						dat += "<input type='hidden' name='choice' value='transfer'>"
						dat += "Target account number: <input type='text' name='target_acc_number' value='' style='width:200px; background-color:white;'><br>"
						dat += "Funds to transfer: <input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><br>"
						if(authenticated_account.stocks)
							dat += "Stock type to transfer: <input type='text' name='stock_type' value='' style='width:100px; background-color:white;'> Amount: <input type='text' name='stock_amount' value='' style='width:100px; background-color:white;'><br>"
						dat += "Transaction purpose: <input type='text' name='purpose' value='Funds transfer' style='width:200px; background-color:white;'><br>"
						dat += "<input type='submit' value='Transfer funds'><br>"
						dat += "</form>"
					if(INSURANCE_MANAGEMENT)
						var/datum/data/record/R = find_record("insurance_account_number", authenticated_account.account_number, data_core.general)
						if(R)
							dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br>"
							dat += "<A href='?src=\ref[src]'>Refresh</a><br><br>"
							dat += "<b>Account balance:</b> $[authenticated_account.money]<br>"
							dat += "<b>Medical record id:</b> [R.fields["id"]]<br>"
							dat += "<b>Medical record owner name:</b> [R.fields["name"]]<br>"
							dat += "<b>Insurance type|price:</b> [R.fields["insurance_type"]]|$[SSeconomy.insurance_prices[R.fields["insurance_type"]]]<br>"
							dat += "<b>Pref. insurance type|price:</b> [authenticated_account.owner_preferred_insurance_type]|$[SSeconomy.insurance_prices[authenticated_account.owner_preferred_insurance_type]]<br>"

							dat += "<b>Max. insurance payment:</b> $[authenticated_account.owner_max_insurance_payment]"
							dat += "<form name='change_max_insurance_payment' action='?src=\ref[src]' method='get'>"
							dat += "<input type='hidden' name='src' value='\ref[src]'>"
							dat += "<input type='hidden' name='choice' value='change_max_insurance_payment'>"
							dat += "<input type='text' name='new_max_insurance_payment' value='[authenticated_account.owner_max_insurance_payment]' style='width:150px; background-color:white;'><input type='submit' value='Change max insurance payment'>"
							dat += "</form><br><br>"


							var/time_addition = round((SSeconomy.endtime - world.timeofday) / 600) * 10

							for(var/insurance_type in SSeconomy.insurance_quality_decreasing)
								dat += "<b>Insurance type|price:</b> [insurance_type]|$[SSeconomy.insurance_prices[insurance_type]]<br>"
								var/insurance_price = SSeconomy.insurance_prices[insurance_type]
								var/insurance_price_with_time_addition // An additional $10 for every remaining minute before payday
								if(insurance_price != 0)
									insurance_price_with_time_addition = insurance_price + time_addition
								else
									insurance_price_with_time_addition = 0
								dat += "<A href='?src=\ref[src];choice=change_insurance_immediately;insurance_type=[insurance_type];price_shown_to_client=[insurance_price]'>Change immediately ($[insurance_price_with_time_addition])</a> "
								dat += "<A href='?src=\ref[src];choice=change_preferred_insurance;insurance_type=[insurance_type];price_shown_to_client=[insurance_price]]'>Make a preferrence</a><br><br>"
						else
							dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=0'>Back</a><br><br>"
							dat += "Error, this money account is not connected to your medical record, please check this info and try again.<br>"

					else
						dat += "Welcome, <b>[authenticated_account.owner_name].</b><br/>"
						dat += "<b>Account balance:</b> $[authenticated_account.money]"
						dat += "<br><b>Stock of money in ATM:</b> $[money_stock]"
						dat += "<form name='withdrawal' action='?src=\ref[src]' method='get'>"
						dat += "<input type='hidden' name='src' value='\ref[src]'>"
						dat += "<input type='hidden' name='choice' value='withdrawal'>"
						dat += "<input type='text' name='funds_amount' value='' style='width:200px; background-color:white;'><input type='submit' value='Withdraw funds'>"
						dat += "</form>"
						if(authenticated_account.stocks)
							dat += "<b>Total dividend payouts:</b> [authenticated_account.total_dividend_payouts]$<br>"
							dat += "List of owned <b>stocks:</b><br>"
							for(var/department in authenticated_account.stocks)
								var/ownership_percentage = authenticated_account.stocks[department] / SSeconomy.total_department_stocks[department]
								var/dividend_payout = round(1000.0 * SSeconomy.department_dividends[department] * ownership_percentage, 0.1)
								if(dividend_payout < 0.1)
									dividend_payout = 0.0
								dat += "* <b>[department]:</b> [authenticated_account.stocks[department]]/[SSeconomy.total_department_stocks[department]]. Dividend rate: [round(SSeconomy.department_dividends[department] * 100)]%. 15 minute dividend payout per 1000$: [dividend_payout]$.<br>"
							dat += "<form name='withdrawal_stocks' action='?src=\ref[src]' method='get'>"
							dat += "<input type='hidden' name='src' value='\ref[src]'>"
							dat += "<input type='hidden' name='choice' value='withdrawal_stocks'>"
							dat += "Type: <input type='text' name='stock_type' value='' style='width:100px; background-color:white;'> Amount: <input type='text' name='stock_amount' value='' style='width:100px; background-color:white;'>&nbsp;<input type='submit' value='Withdraw stock'>"
							dat += "</form>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=1'>Change account security level</a><br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=2'>Make transfer</a><br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=3'>View transaction log</a><br>"
						dat += "<A href='?src=\ref[src];choice=view_screen;view_screen=4'>Insurance management</a><br>"
						dat += "<A href='?src=\ref[src];choice=balance_statement'>Print balance statement</a><br>"
						dat += "<A href='?src=\ref[src];choice=logout'>Logout</a><br>"
		else
			dat += "<form name='atm_auth' action='?src=\ref[src]' method='get'>"
			dat += "<input type='hidden' name='src' value='\ref[src]'>"
			dat += "<input type='hidden' name='choice' value='attempt_auth'>"
			dat += "<b>Account:</b> <input type='text' id='account_num' name='account_num' style='width:250px; background-color:white;'><br>"
			dat += "<b>PIN:</b> <input type='text' id='account_pin' name='account_pin' style='width:250px; background-color:white;'><br>"
			dat += "<input type='submit' value='Submit'><br>"
			dat += "</form>"

	var/datum/browser/popup = new(user, "atm", "NanoTrasen Automatic Teller Machine", 550, 650)
	popup.set_content(dat)
	popup.open()

/obj/machinery/atm/is_operational()
	return TRUE

/obj/machinery/atm/proc/transfer_money(target_account, transfer_amount, transfer_purpose)
	if(transfer_amount > authenticated_account.money)
		to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")
		return FALSE

	if(!charge_to_account(target_account, authenticated_account.owner_name, transfer_purpose, machine_id, transfer_amount))
		to_chat(usr, "[bicon(src)]<span class='warning'>Funds transfer failed.</span>")
		return FALSE

	to_chat(usr, "[bicon(src)]<span class='info'>Funds transfer successful.</span>")
	authenticated_account.adjust_money(-transfer_amount)

	//create an entry in the account transaction log
	var/datum/transaction/T = new()
	T.target_name = "Account #[target_account]"
	T.purpose = transfer_purpose
	T.source_terminal = machine_id
	T.date = current_date_string
	T.time = worldtime2text()
	T.amount = "([transfer_amount])"
	authenticated_account.transaction_log.Add(T)
	return TRUE

/obj/machinery/atm/proc/transfer_stocks(target_account, stock_type, transfer_amount, transfer_purpose)
	if(!authenticated_account.stocks)
		to_chat(usr, "[bicon(src)]<span class='warning'>No stocks on this account!</span>")
		return FALSE
	if(!authenticated_account.stocks[stock_type])
		to_chat(usr, "[bicon(src)]<span class='warning'>No stock of type [stock_type] on this account!</span>")
		return FALSE
	if(transfer_amount > authenticated_account.stocks[stock_type])
		to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough [stock_type] stock to do that!</span>")
		return FALSE

	if(!transfer_stock_to_account(target_account, authenticated_account.owner_name, transfer_purpose, machine_id, stock_type, transfer_amount))
		to_chat(usr, "[bicon(src)]<span class='warning'>Funds transfer failed.</span>")
		return FALSE

	to_chat(usr, "[bicon(src)]<span class='info'>Funds transfer successful.</span>")
	authenticated_account.adjust_stock(stock_type, -transfer_amount)

	//create an entry in the account transaction log
	var/datum/transaction/T = new()
	T.target_name = "Account #[target_account]"
	T.purpose = transfer_purpose
	T.source_terminal = machine_id
	T.date = current_date_string
	T.time = worldtime2text()
	T.amount = "0"
	authenticated_account.transaction_log.Add(T)
	return TRUE

/obj/machinery/atm/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["choice"])
		switch(href_list["choice"])
			if("transfer")
				if(!authenticated_account)
					return
				var/target_account = text2num(href_list["target_acc_number"])
				var/money_amount = text2num(href_list["funds_amount"])
				var/stock_type = href_list["stock_type"]
				var/stock_amount = text2num(href_list["stock_amount"])
				var/purpose = href_list["purpose"]

				var/show_invalid_amount_message = FALSE

				if(money_amount > 0.0)
					transfer_money(target_account, money_amount, purpose)
				else if(stock_amount <= 0)
					show_invalid_amount_message = TRUE

				if(stock_amount > 0)
					transfer_stocks(target_account, stock_type, stock_amount, purpose)
				else if(money_amount <= 0.0)
					show_invalid_amount_message = TRUE

				if(show_invalid_amount_message)
					tgui_alert(usr, "That is not a valid amount.")

			if("view_screen")
				view_screen = text2num(href_list["view_screen"])
			if("change_security_level")
				if(authenticated_account)
					var/new_sec_level = max( min(text2num(href_list["new_security_level"]), 2), 0)
					authenticated_account.security_level = new_sec_level
			if("attempt_auth")

				// check if they have low security enabled
				scan_user(usr)

				if(!ticks_left_locked_down)
					var/tried_account_num
					if(!held_card)
						tried_account_num = text2num(href_list["account_num"])
					else
						tried_account_num = held_card.associated_account_number

					var/datum/money_account/MA = get_account(tried_account_num)
					if(!MA)
						to_chat(usr, "[bicon(src)]<span class='warning'>Unable to find your money account!</span>")
						return

					var/security_level_passed = held_card && held_card.associated_account_number == tried_account_num ? ACCOUNT_SECURITY_LEVEL_MAXIMUM : ACCOUNT_SECURITY_LEVEL_STANDARD
					if(href_list["account_pin"])
						authenticated_account = attempt_account_access(tried_account_num, text2num(href_list["account_pin"]), security_level_passed)
					else
						authenticated_account = attempt_account_access_with_user_input(tried_account_num, security_level_passed, usr)
					if(usr.incapacitated() || !Adjacent(usr))
						return

					if(!authenticated_account)
						number_incorrect_tries++
						if(previous_account_number == tried_account_num)
							if(number_incorrect_tries > max_pin_attempts)
								//lock down the atm
								ticks_left_locked_down = 30
								playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)

								//create an entry in the account transaction log
								var/datum/money_account/failed_account = get_account(tried_account_num)
								if(failed_account)
									var/datum/transaction/T = new()
									T.target_name = failed_account.owner_name
									T.purpose = "Unauthorised login attempt"
									T.source_terminal = machine_id
									T.date = current_date_string
									T.time = worldtime2text()
									failed_account.transaction_log.Add(T)
							else
								to_chat(usr, "<span class='warning'>[bicon(src)] Incorrect pin/account combination entered, [max_pin_attempts - number_incorrect_tries] attempts remaining.</span>")
								previous_account_number = tried_account_num
								playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)
						else
							to_chat(usr, "<span class='warning'>[bicon(src)] incorrect pin/account combination entered.</span>")
							number_incorrect_tries = 0
					else
						playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
						ticks_left_timeout = 120
						view_screen = NO_SCREEN

						//create a transaction log entry
						var/datum/transaction/T = new()
						T.target_name = authenticated_account.owner_name
						T.purpose = "Remote terminal access"
						T.source_terminal = machine_id
						T.date = current_date_string
						T.time = worldtime2text()
						authenticated_account.transaction_log.Add(T)

						to_chat(usr, "<span class='notice'>[bicon(src)] Access granted. Welcome user '[authenticated_account.owner_name].'</span>")
						pin_visible_until = world.time + 2 SECONDS

					previous_account_number = tried_account_num
			if("withdrawal")
				var/amount = max(text2num(href_list["funds_amount"]),0)
				if(amount <= 0)
					tgui_alert(usr, "That is not a valid amount.")
				else if(authenticated_account && amount > 0)
					var/response = tgui_alert(usr.client, "In what way would you like to recieve your money?", "Choose money format", list("Chip", "Cash"))
					if(authenticated_account)
						if(amount <= authenticated_account.money)
							authenticated_account.adjust_money(-amount)
							playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
							if(response == "Chip")
								spawn_ewallet(amount, null, src.loc)
							else
								print_money_stock(amount)


							//create an entry in the account transaction log
							var/datum/transaction/T = new()
							T.target_name = authenticated_account.owner_name
							T.purpose = "Credit withdrawal"
							T.amount = "[-amount]"
							T.source_terminal = machine_id
							T.date = current_date_string
							T.time = worldtime2text()
							authenticated_account.transaction_log.Add(T)
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough funds to do that!</span>")

			if("change_insurance_immediately")
				if(!authenticated_account)
					return

				var/insurance_type = href_list["insurance_type"]
				if(!(insurance_type in SSeconomy.insurance_quality_decreasing))
					return

				var/insurance_price = SSeconomy.insurance_prices[insurance_type]

				var/time_addition = round((SSeconomy.endtime - world.timeofday) / 600) * 10 // An additional $10 for every remaining minute before payday
				var/insurance_price_with_addition = insurance_price + time_addition
				if(insurance_price == 0)
					insurance_price_with_addition = 0

				var/price_shown_to_client = text2num(href_list["price_shown_to_client"])
				if(isnull(price_shown_to_client))
					return

				if(price_shown_to_client != insurance_price)
					tgui_alert(usr, "Price of this insurance was changed. Press \"Refresh\" and try again.")
					return
				if(authenticated_account.money < insurance_price_with_addition)
					tgui_alert(usr, "You don't have enough money.")
					return

				var/datum/data/record/R = find_record("insurance_account_number", authenticated_account.account_number, data_core.general)
				if(!R)
					tgui_alert(usr, "Sorry, but your money account is not connected to your medical record, please check this information and try again.")
					return
				R.fields["insurance_type"] = insurance_type

				authenticated_account.owner_preferred_insurance_type = insurance_type
				authenticated_account.owner_max_insurance_payment = max(insurance_price_with_addition, authenticated_account.owner_max_insurance_payment)
				if(insurance_price_with_addition > 0)
					charge_to_account(authenticated_account.account_number, "Medical", "[insurance_type] Insurance payment", "NT Insurance", -insurance_price_with_addition)
					var/med_account_number = global.department_accounts["Medical"].account_number
					charge_to_account(med_account_number, med_account_number,"[insurance_type] Insurance payment", "NT Insurance", insurance_price_with_addition)

			if("change_preferred_insurance")
				if(!authenticated_account)
					return

				var/insurance_type = href_list["insurance_type"]
				if(!(insurance_type in SSeconomy.insurance_quality_decreasing))
					return

				var/insurance_price = SSeconomy.insurance_prices[insurance_type]

				var/price_shown_to_client = text2num(href_list["price_shown_to_client"])
				if(isnull(price_shown_to_client))
					return

				if(price_shown_to_client != insurance_price)
					tgui_alert(usr, "Price of this insurance was changed. Press \"Refresh\" and try again.")
					return

				authenticated_account.owner_preferred_insurance_type = insurance_type
				authenticated_account.owner_max_insurance_payment = max(insurance_price, authenticated_account.owner_max_insurance_payment)

			if("change_max_insurance_payment")
				if(!authenticated_account)
					return

				var/new_max_payment = text2num(href_list["new_max_insurance_payment"])
				if(isnull(new_max_payment))
					return

				if(new_max_payment < 0 || new_max_payment > MAX_INSURANCE_PRICE)
					tgui_alert(usr, "You can only set it in range from 0 to [MAX_INSURANCE_PRICE]")
					return

				authenticated_account.owner_max_insurance_payment = new_max_payment

			if("withdrawal_stocks")
				var/stock_amount = max(text2num(href_list["stock_amount"]),0)
				if(stock_amount <= 0)
					tgui_alert(usr, "That is not a valid amount.")
					return

				var/stock_type = href_list["stock_type"]
				if(!authenticated_account.stocks)
					return
				if(!authenticated_account.stocks[stock_type])
					tgui_alert(usr, "No stock of type [stock_type] on this account.")
					return
				if(authenticated_account.stocks[stock_type] < stock_amount)
					to_chat(usr, "[bicon(src)]<span class='warning'>You don't have enough [stock_type] stock to do that!</span>")
					return

				playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
				authenticated_account.adjust_stock(stock_type, -stock_amount)
				spawn_ewallet(0.0, list("[stock_type]"=stock_amount), loc)

				//create an entry in the account transaction log
				var/datum/transaction/T = new()
				T.target_name = authenticated_account.owner_name
				T.purpose = "Stock withdrawal - [stock_type]: [stock_amount]"
				T.amount = "0"
				T.source_terminal = machine_id
				T.date = current_date_string
				T.time = worldtime2text()
				authenticated_account.transaction_log.Add(T)

			if("balance_statement")
				if(authenticated_account)
					var/obj/item/weapon/paper/R = new(src.loc)
					R.name = "Account balance: [authenticated_account.owner_name]"
					R.info = "<b>NT Automated Teller Account Statement</b><br><br>"
					R.info += "<i>Account holder:</i> [authenticated_account.owner_name]<br>"
					R.info += "<i>Account number:</i> [authenticated_account.account_number]<br>"
					R.info += "<i>Balance:</i> $[authenticated_account.money]<br>"
					if(authenticated_account.stocks)
						R.info += "<i>Owned stocks:</i> [get_stocks_string(authenticated_account.stocks)]<br>"
					R.info += "<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>"
					R.info += "<i>Service terminal ID:</i> [machine_id]<br>"
					R.update_icon()

					//stamp the paper
					var/obj/item/weapon/stamp/centcomm/S = new
					S.stamp_paper(R, "Automatic Teller Machine")

				if(prob(50))
					playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
				else
					playsound(src, 'sound/items/polaroid2.ogg', VOL_EFFECTS_MASTER)
			if ("print_transaction")
				if(authenticated_account)
					var/obj/item/weapon/paper/R = new(src.loc)
					R.name = "Transaction logs: [authenticated_account.owner_name]"
					R.info = "<b>Transaction logs</b><br>"
					R.info += "<i>Account holder:</i> [authenticated_account.owner_name]<br>"
					R.info += "<i>Account number:</i> [authenticated_account.account_number]<br>"
					R.info += "<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>"
					R.info += "<i>Service terminal ID:</i> [machine_id]<br>"
					R.info += "<table border=1 style='width:100%'>"
					R.info += "<tr>"
					R.info += "<td><b>Date</b></td>"
					R.info += "<td><b>Time</b></td>"
					R.info += "<td><b>Target</b></td>"
					R.info += "<td><b>Purpose</b></td>"
					R.info += "<td><b>Value</b></td>"
					R.info += "<td><b>Source terminal ID</b></td>"
					R.info += "</tr>"
					for(var/datum/transaction/T in authenticated_account.transaction_log)
						R.info += "<tr>"
						R.info += "<td>[T.date]</td>"
						R.info += "<td>[T.time]</td>"
						R.info += "<td>[T.target_name]</td>"
						R.info += "<td>[T.purpose]</td>"
						R.info += "<td>$[T.amount]</td>"
						R.info += "<td>[T.source_terminal]</td>"
						R.info += "</tr>"
					R.info += "</table>"
					R.update_icon()

					//stamp the paper
					var/obj/item/weapon/stamp/centcomm/S = new
					S.stamp_paper(R, "Automatic Teller Machine")

				if(prob(50))
					playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER)
				else
					playsound(src, 'sound/items/polaroid2.ogg', VOL_EFFECTS_MASTER)

			if("insert_card")
				if(!held_card)
					//this might happen if the user had the browser window open when somebody emagged it
					if(emagged > 0)
						to_chat(usr, "<span class='warning'>[bicon(src)] The ATM card reader rejected your ID because this machine has been sabotaged!</span>")
					else
						var/obj/item/I = usr.get_active_hand()
						if (istype(I, /obj/item/weapon/card/id))
							usr.drop_from_inventory(I, src)
							held_card = I
							if(ishuman(usr))
								var/mob/living/carbon/human/H = usr
								H.sec_hud_set_ID()
				else
					release_held_id(usr)
			if("logout")
				authenticated_account = null
				//usr << browse(null,"window=atm")

	updateUsrDialog()

//stolen wholesale and then edited a bit from newscasters, which are awesome and by Agouri
/obj/machinery/atm/proc/scan_user(mob/living/carbon/human/human_user)
	if(!authenticated_account)
		if(human_user.wear_id)
			var/obj/item/weapon/card/id/I
			if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				I = human_user.wear_id
			else if(istype(human_user.wear_id, /obj/item/device/pda) )
				var/obj/item/device/pda/P = human_user.wear_id
				I = P.id
			if(I)
				authenticated_account = attempt_account_access(I.associated_account_number)
				if(authenticated_account)
					to_chat(human_user, "<span class='notice'>[bicon(src)] Access granted. Welcome user '[authenticated_account.owner_name].'</span>")

					//create a transaction log entry
					var/datum/transaction/T = new()
					T.target_name = authenticated_account.owner_name
					T.purpose = "Remote terminal access"
					T.source_terminal = machine_id
					T.date = current_date_string
					T.time = worldtime2text()
					authenticated_account.transaction_log.Add(T)

					view_screen = NO_SCREEN

// put the currently held id on the ground or in the hand of the user
/obj/machinery/atm/proc/release_held_id(mob/living/carbon/human/user)
	if(!held_card)
		return
	if(!ishuman(user))
		return

	user.put_in_hands(held_card)
	authenticated_account = null
	held_card = null

/obj/machinery/atm/proc/spawn_ewallet(sum, list/stocks, loc)
	var/obj/item/weapon/ewallet/E = new /obj/item/weapon/ewallet(loc)

	if(sum > 0.0)
		charge_to_account(E.account_number, "E-Transaction", "Cash withdrawal", machine_id, sum)

	if(stocks)
		for(var/department in stocks)
			transfer_stock_to_account(E.account_number, "E-Transaction", "Cash withdrawal", machine_id, department, stocks[department])

	E.issuer_name = authenticated_account.owner_name
	E.issuer_account_number = authenticated_account.account_number

/obj/machinery/atm/proc/print_money_stock(sum)
	if (money_stock < sum)
		if(money_stock)
			sum = money_stock
			money_stock = 0
			tgui_alert(usr, "ATM doesn't have enough funds to give the full amount of money!")
			spawn_money(sum, src.loc)
		else
			tgui_alert(usr, "ATM doesn't have enough funds to do that!")
			return
	else
		money_stock -= sum
		spawn_money(sum, src.loc)

/obj/machinery/atm/examine(mob/user)
	..()
	if(!held_card)
		return

	var/datum/money_account/MA = get_account(held_card.associated_account_number)
	if(!in_range(src, user))
		return
	if(user.mind.get_key_memory(MEM_ACCOUNT_PIN) == MA.remote_access_pin)
		return
	if(pin_visible_until < world.time)
		return
	if(held_card && prob(50))
		to_chat(user, "Вам удаётся подглядеть пин-код: <span class='notice'>[MA.remote_access_pin]</span>.")

	pin_visible_until = 0
