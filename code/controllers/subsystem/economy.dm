SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 10 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA
	var/payment_counter = 0

//------------TAXES------------
	var/tax_cargo_export = 10 //Station fee earned when supply shuttle exports things. 0 is 0%, 100 is 100%
	var/tax_vendomat_sales = 25 //Station fee earned with every vendomat sale.
	var/tax_income = 0

	//Subsidy coefficient from CentComm
	var/station_subsidy_coefficient = 1.0

	//UNIVERSAL BASE INCOME
	var/ubi = FALSE
	var/ubi_count = 42

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

	var/all_salaries = 0
	for(var/dep_name in global.department_accounts)
		var/datum/money_account/D = department_accounts[dep_name]
		if(D.suspended)
			continue

		//Station to Departments salary transactions
		if(!global.station_account.suspended)
			if(global.station_account.money >= abs(D.subsidy) && D.subsidy > 0)
				charge_to_account(D.account_number, global.station_account.account_number, "[D.owner_name] Department Subsidion", "Station Account", D.subsidy)
				charge_to_account(global.station_account.account_number, D.account_number, "[D.owner_name] Department Subsidion", global.department_accounts[D.department], -D.subsidy)
			if(D.money >= abs(D.subsidy) && D.subsidy < 0)
				charge_to_account(D.account_number, global.station_account.account_number, "[D.owner_name] Department Penalty", "Station Account", D.subsidy)
				charge_to_account(global.station_account.account_number, D.account_number, "[D.owner_name] Department Penalty", global.department_accounts[D.department], -D.subsidy)

		//Departments to personnel salary transactions
		//Choosing a rank
		for(var/r in D.salaries_rank_table)
			var/list/rank_table = D.salaries_rank_table[r]
			var/salary_rank = D.salaries_per_ranks_table[r]
			var/salary = 0
			var/dep_salary = 0

			if(!rank_table.len || rank_table.len == 0)
				continue //Next rank

			//Skimming through personnel of this rank
			for(var/datum/money_account/P in rank_table)
				//Counting a station subsidion from CC
				if(ubi)
					all_salaries += ubi_count
				else
					all_salaries += P.base_salary

				if(P.owner_salary == 0)
					continue //No salary - no transactions. Next personel
				if(P.owner_salary < 0) //Negative salary - pay debt. Next personel
					charge_to_account(P.account_number, D.account_number, "[P.owner_name]'s paycheck payment", global.department_accounts[P.department], salary)
					continue
				if(D.money <= 0 && P.owner_PDA)
					P.owner_PDA.transaction_failure()
					continue //Error no money at dep. account

				//If a dep have enough money it will pay everything, if not - it will divide to everyone who is at the same rank.
				if(salary_rank > D.money)
					salary = round(D.money / rank_table.len * (1 - tax_income * 0.01)) //Dividing money for salaries
				else
					salary = round(P.owner_salary * (1 - tax_income * 0.01)) //Pure salaries

				if(salary == 0 && P.owner_PDA)
					P.owner_PDA.transaction_failure()
					continue //Error no money

				charge_to_account(P.account_number, D.account_number, "[P.owner_name]'s Salary payment", global.department_accounts[P.department], salary)
				dep_salary += salary

			//We want to substract salaries payment from Dep. account all at once to prevent spam.
			charge_to_account(D.account_number, D.account_number, "Salaries of [r] rank payment", D.owner_name, -dep_salary)

	//CentComm to Station Subsidion transaction
	if(!global.station_account.suspended && all_salaries != 0)
		global.station_account.subsidy = all_salaries * station_subsidy_coefficient
		charge_to_account(global.station_account.account_number, global.station_account.account_number, "Station Subsidion", "Central Command", global.station_account.subsidy)

	payment_counter += 1

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
