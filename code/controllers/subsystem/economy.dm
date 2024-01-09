SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 15 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA
//------------TAXES------------
	var/tax_cargo_export = 10 //Station fee earned when supply shuttle exports things. 0 is 0%, 100 is 100%
	var/tax_vendomat_sales = 25 //Station fee earned with every vendomat sale.

	var/list/total_department_stocks
	var/list/department_dividends
	var/list/stock_splits
	var/list/insurance_prices = list(INSURANCE_NONE = 0, INSURANCE_STANDARD = 10, INSURANCE_PREMIUM = 40)
	var/list/roundstart_insurance_prices = list(INSURANCE_NONE = 0, INSURANCE_STANDARD = 10, INSURANCE_PREMIUM = 40)
	var/list/insurance_quality_decreasing = list(INSURANCE_PREMIUM, INSURANCE_STANDARD, INSURANCE_NONE)

	var/list/subsidion_priority = list("Science" = 1000, "Security" = 1000, "Medical" = 1000, "Engineering" = 1000, "Civilian" = 1000)


/datum/controller/subsystem/economy/proc/set_dividend_rate(department, rate)
	LAZYINITLIST(department_dividends)

	LAZYSET(department_dividends, department, rate)

/datum/controller/subsystem/economy/proc/get_stock_split(department)
	if(!stock_splits)
		return 1.0

	if(!stock_splits[department])
		return 1.0

	return stock_splits[department]

/datum/controller/subsystem/economy/proc/split_shares(department, split)
	LAZYINITLIST(stock_splits)

	if(!stock_splits[department])
		stock_splits[department] = 1.0

	stock_splits[department] *= split

	for(var/datum/money_account/MA as anything in global.all_money_accounts)
		if(!MA.stocks[department])
			continue

		MA.stocks[department] *= split

	total_department_stocks[department] *= split

/datum/controller/subsystem/economy/proc/print_stocks(department, amount)
	LAZYINITLIST(total_department_stocks)

	if(!total_department_stocks[department])
		LAZYSET(total_department_stocks, department, 0)
		LAZYSET(stock_splits, department, 1.0)

	total_department_stocks[department] += amount

/datum/controller/subsystem/economy/proc/issue_founding_stock(account_number, department, amount)
	var/stock_amount = amount * get_stock_split(department)
	print_stocks(department, stock_amount)
	transfer_stock_to_account(account_number, "StockBond", "Stock transfer - [department]: [stock_amount]", "NTGalaxyNet Terminal #[rand(111,1111)]", department, stock_amount, pda_inform=FALSE)

/datum/controller/subsystem/economy/proc/calculate_dividends(capital, department, stock_amount)
	if(!total_department_stocks[department])
		return 0.0
	if(!department_dividends[department])
		return 0.0

	var/ownership_percentage = stock_amount / total_department_stocks[department]
	var/dividend_payout = round(capital * department_dividends[department] * ownership_percentage, 0.1)

	if(dividend_payout < 0.1)
		return 0.0

	return dividend_payout

/datum/controller/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return

	for(var/datum/money_account/D in all_money_accounts)
		if(D.owner_salary && !D.suspended)
			charge_to_account(D.account_number, D.account_number, "Salary payment", "CentComm", D.owner_salary)

	handle_insurances()

	handle_subsidions()


	monitor_cargo_shop()

	var/obj/item/device/radio/intercom/announcer = new /obj/item/device/radio/intercom(null)
	announcer.config(list("Supply" = 1))
	announcer.autosay("Выплата дивидендов через 1 минуту. Сконцентрируйте максимальное количество капитала на счету Карго к тому моменту.", "StockBond", "Supply", freq = radiochannels["Supply"])

	qdel(announcer)

	addtimer(CALLBACK(src, PROC_REF(dividend_payment)), 1 MINUTE)

/datum/controller/subsystem/economy/proc/dividend_payment()
	// All investors should have an equal opportunity to profit. Thus capital amount should be tallied before dividend distribution.
	var/list/capitals = list()
	// If we want all dividend payouts to be traceable `total_dividend_payout` and `departmental_payouts` should be removed in favour of per-stock transactions.
	var/list/departmental_payouts = list()

	for(var/department in total_department_stocks)
		var/datum/money_account/DA = global.department_accounts[department]
		if(DA.suspended)
			capitals[department] = 0.0
			continue

		capitals[department] = DA.money

	for(var/datum/money_account/D in all_money_accounts)
		if(D.suspended)
			continue

		var/total_dividend_payout = 0.0
		for(var/department in D.stocks)
			// Don't pay stocks to ourselves, less transaction spam.
			if(D == global.department_accounts[department])
				continue
			var/dividend_payout = calculate_dividends(capitals[department], department, D.stocks[department])
			total_dividend_payout += dividend_payout
			if(!departmental_payouts[department])
				departmental_payouts[department] = 0.0
			departmental_payouts[department] += dividend_payout

		if(total_dividend_payout > 0.0)
			D.total_dividend_payouts += total_dividend_payout
			charge_to_account(D.account_number, D.account_number, "Dividend payout", "StockBond", total_dividend_payout)

	for(var/department in departmental_payouts)
		var/datum/money_account/DA = global.department_accounts[department]
		charge_to_account(DA.account_number, DA.account_number, "Dividend payout to investors", "StockBond", -departmental_payouts[department])

/datum/controller/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait



/datum/controller/subsystem/economy/proc/handle_insurances()
	var/insurance_sum = 0
	var/list/problem_record_id = list()
	for(var/datum/data/record/R in data_core.general)
		if(!R)
			continue
		var/datum/money_account/MA = get_account(R.fields["insurance_account_number"])
		if(!MA)
			R.fields["insurance_type"] = INSURANCE_NONE
			problem_record_id.Add(R.fields["id"])
			continue
		var/insurance_type = get_next_insurance_type(R.fields["insurance_type"], MA)
		var/insurance_price = SSeconomy.insurance_prices[insurance_type]
		R.fields["insurance_type"] = insurance_type
		if(insurance_price == 0)
			continue
		insurance_sum += insurance_price
		charge_to_account(MA.account_number, "Medical", "[insurance_type] Insurance payment", "NT Insurance", -insurance_price)

	if(insurance_sum > 0)
		var/med_account_number = global.department_accounts["Medical"].account_number
		charge_to_account(med_account_number, med_account_number, "Insurance", "NT Insurance", insurance_sum)

	if(problem_record_id.len)
		send_message_about_problem_insurances(problem_record_id)

/proc/get_insurance_type(mob/living/carbon/human/H)
	var/datum/data/record/R = find_record("fingerprint", md5(H.dna.uni_identity), data_core.general)
	if(!R)
		return INSURANCE_NONE
	return R.fields["insurance_type"]


/proc/get_next_insurance_type(current_insurance_type, datum/money_account/MA, list/insurance_prices=SSeconomy.insurance_prices)
	if(MA.suspended)
		return INSURANCE_NONE

	var/current_insurance_price = insurance_prices[current_insurance_type]
	if(current_insurance_type == MA.owner_preferred_insurance_type && MA.money >= current_insurance_price  && MA.owner_max_insurance_payment >= current_insurance_price)
		return current_insurance_type

	var/prefprice = insurance_prices[MA.owner_preferred_insurance_type]
	if(MA.money >= prefprice && MA.owner_max_insurance_payment >= prefprice)
		return MA.owner_preferred_insurance_type

	for(var/insurance_type in SSeconomy.insurance_quality_decreasing)
		var/insprice = insurance_prices[insurance_type]
		if(MA.money >= insprice && MA.owner_max_insurance_payment >= insprice)
			return insurance_type


/proc/send_message_about_problem_insurances(list/message)
	var/message_text
	message_text += "<B>ID of Medical Records With Data Problems:</B><br>"
	for(var/r in message)
		message_text += "<b>[r]</b> <br>"
	for(var/obj/machinery/computer/med_data/comp in global.med_record_consoles_list)
		if(!(comp.stat & (BROKEN | NOPOWER)))
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comp.loc )
			intercept.name = "Records With Insurance Problems"
			intercept.info = message_text
			intercept.update_icon()

/datum/controller/subsystem/economy/proc/handle_subsidions()
	for(var/department in subsidion_priority)
		if(!global.station_account.money)
			break
		var/subsidion_amount = subsidion_priority[department]
		var/datum/money_account/department_account = global.department_accounts[department]
		if(department_account.money >= subsidion_amount)
			continue
		var/needed_to_pay = subsidion_amount - department_account.money
		if(!needed_to_pay || needed_to_pay < 0)
			continue
		if(global.station_account.money < needed_to_pay)
			charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Субсидии отделу [department_account.owner_name] из бюджета станции", "Бюджет станции", -global.station_account.money)
			charge_to_account(department_account.account_number, department_account.owner_name, "Субсидии отделу из бюджета станции", "Бюджет станции", global.station_account.money)
			break
		charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Субсидии отделу [department_account.owner_name] из бюджета станции", "Бюджет станции", -needed_to_pay)
		charge_to_account(department_account.account_number, department_account.owner_name, "Субсидии отделу из бюджета станции", "Бюджет станции", needed_to_pay)
		continue

