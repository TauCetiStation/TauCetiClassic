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

/datum/controller/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else if (payment_counter)	//to skip first payment
		for(var/datum/money_account/D in all_money_accounts)
			if(D.owner_salary && !D.suspended)
				charge_to_account(D.account_number, D.account_number, "Salary payment", "CentComm", D.owner_salary)
				var/acc = get_med_account_number()
				var/insurance_price = get_insurance_price(D.account_number)
				charge_to_account(D.account_number, "Medical","Insurance", "NT Insurance", -1 * insurance_price)
				charge_to_account(acc,acc,"Insurance",D.account_number,insurance_price)

		monitor_cargo_shop()

	payment_counter += 1

/datum/controller/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait

/proc/get_med_account_number()
	for(var/datum/money_account/D in all_money_accounts)
		if(D.owner_name == "Medical Account")
			return D.account_number



/proc/get_insurance_price(var/account_number)
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.mind)
			if(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER) == account_number)
				var/insurance_price = 0
				var/insurance = H.insurance
				if(insurance == "Standart")
					insurance_price = 80
				
				else if (insurance == "Premium")
					insurance_price = 200

				return insurance_price
				
