SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 0.5 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA
	var/payment_counter = 0

	//Station fees earned when supply shuttle exports things. 0 is 0%, 100 is 100%
	var/tax_cargo_export = 10
	var/tax_income = 0
	//Subsidy coefficient from CentComm
	var/station_subsidy_coefficient = 1.0

/datum/controller/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else if (payment_counter)	//to skip first payment
		var/all_salaries = 0
		//Station to Departments salary transactions
		for(var/dep_name in global.department_accounts)
			var/datum/money_account/D = department_accounts[dep_name]
			if(!D.suspended)
				if(!global.station_account.suspended)
					if(global.station_account.money >= abs(D.subsidy) && D.subsidy > 0)
						charge_to_account(D.account_number, global.station_account.account_number, "[D.owner_name] Department Subsidion", "Station Account", D.subsidy)
						charge_to_account(global.station_account.account_number, D.account_number, "[D.owner_name] Department Subsidion", global.department_accounts[D.department], -D.subsidy)
					if(D.money >= abs(D.subsidy) && D.subsidy < 0)
						charge_to_account(D.account_number, global.station_account.account_number, "[D.owner_name] Department Penalty", "Station Account", D.subsidy)
						charge_to_account(global.station_account.account_number, D.account_number, "[D.owner_name] Department Penalty", global.department_accounts[D.department], -D.subsidy)

				//Departments to personnel salary transactions
				var/list/ranks = list("high", "medium", "low")
				skimming_through_ranks:
					for(var/r in ranks)
						var/list/rank_table = D.salaries_rank_table[r]
						var/salary_rank = D.salaries_per_ranks_table[r]
						var/salary = null
						var/dep_salary = 0
						skimming_through_personel:
							if(!rank_table.len || rank_table.len == 0)
								continue skimming_through_ranks //Next rank
							for(var/datum/money_account/P in rank_table)
								if(P.owner_salary == 0)
									continue skimming_through_personel //Next personel
								else if(P.owner_salary < 0)
									charge_to_account(P.account_number, D.account_number, "[P.owner_name]'s paycheck payment", global.department_accounts[P.department], salary)
								else
									if(D.money <= 0 && P.owner_PDA)
										P.owner_PDA.transaction_failure()
										continue skimming_through_personel //Error no money

									if(salary_rank > D.money)
										salary = round(D.money / rank_table.len * (1 - SSeconomy.tax_income*0.01)) //Dividing money for salaries
									else
										salary = round(P.owner_salary * (1 - SSeconomy.tax_income*0.01)) //Pure salaries

									if(salary == 0 && P.owner_PDA)
										P.owner_PDA.transaction_failure()
										continue skimming_through_personel //Error no money

									charge_to_account(P.account_number, D.account_number, "[P.owner_name]'s Salary payment", global.department_accounts[P.department], salary)
									dep_salary += salary
									all_salaries += P.base_salary
						charge_to_account(D.account_number, D.account_number, "Salaries of [r] rank payment", D.owner_name, -dep_salary)
			else
				continue

		//CentComm to Station Subsidion transaction
		if(!global.station_account.suspended)
			global.station_account.subsidy = all_salaries * SSeconomy.station_subsidy_coefficient
			charge_to_account(global.station_account.account_number, global.station_account.account_number, "Station Subsidion", "Central Command", global.station_account.subsidy)
	payment_counter += 1

/datum/controller/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait
