SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 15 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA
	var/payment_counter = 0
//------------TAXES------------
	var/tax_cargo_export = 10 //Station fee earned when supply shuttle exports things. 0 is 0%, 100 is 100%
	var/tax_vendomat_sales = 25 //Station fee earned with every vendomat sale.

	var/list/total_department_stocks
	var/list/department_dividends

/datum/controller/subsystem/economy/proc/set_dividend_rate(department, rate)
	LAZYINITLIST(department_dividends)

	LAZYSET(department_dividends, department, rate)

/datum/controller/subsystem/economy/proc/split_shares(department, split)
	for(var/datum/money_account/MA as anything in global.all_money_accounts)
		if(!MA.stocks[department])
			continue

		MA.stocks[department] *= split

/datum/controller/subsystem/economy/proc/print_stocks(department, amount)
	LAZYINITLIST(total_department_stocks)

	if(!total_department_stocks[department])
		LAZYSET(total_department_stocks, department, 0)

	total_department_stocks[department] += amount

/datum/controller/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else if (payment_counter)	//to skip first payment
		for(var/datum/money_account/D in all_money_accounts)
			if(D.owner_salary && !D.suspended)
				charge_to_account(D.account_number, D.account_number, "Salary payment", "CentComm", D.owner_salary)

			var/total_dividend_payout = 0.0
			for(var/department in total_department_stocks)
				if(!total_department_stocks[department])
					continue
				if(!department_dividends[department])
					continue

				var/ownership_percentage = D.stocks[department] / total_department_stocks[department]
				var/dividend_payout = round(global.department_accounts["Cargo"] * department_dividends[department] * ownership_percentage)

				// No control package.
				if(dividend_payout < 0.1)
					continue

			if(total_dividend_payout > 0.0)
				charge_to_account(D.account_number, D.account_number, "Dividend payout", "StockBond", total_dividend_payout)

	payment_counter += 1

/datum/controller/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait
