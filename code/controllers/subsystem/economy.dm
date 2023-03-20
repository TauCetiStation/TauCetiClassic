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

	monitor_cargo_shop()

	var/obj/item/device/radio/intercom/announcer = new /obj/item/device/radio/intercom(null)
	announcer.config(list("Supply" = 1))
	announcer.autosay("Выплата дивидендов через 1 минуту. Сконцентрируйте максимальное количество капитала на счету Карго к тому моменту.", "StockBond", "Supply", freq = radiochannels["Supply"])

	qdel(announcer)

	addtimer(CALLBACK(src, .proc/dividend_payment), 1 MINUTE)

/datum/controller/subsystem/economy/proc/dividend_payment()
	// All investors should have an equal opportunity to profit. Thus capital amount should be tallied before dividend distribution.
	var/list/capitals = list()
	// If we want all dividend payouts to be traceable `total_dividend_payout` and `departmental_payouts` should be removed in favour of per-stock transactions.
	var/list/departmental_payouts = list()

	for(var/department in total_department_stocks)
		var/datum/money_account/DA = global.department_accounts[department]
		capitals[department] = DA.money

	for(var/datum/money_account/D in all_money_accounts)
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
