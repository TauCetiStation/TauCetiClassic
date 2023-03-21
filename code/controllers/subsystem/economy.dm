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

var/global/list/possible_insurances = list("None" = 0, "roundstartStandart" = 80, "roundstartPremium" = 200, "Standart" = 80, "Premium" = 200)

/datum/controller/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else if (payment_counter)	//to skip first payment
		for(var/datum/money_account/D in all_money_accounts)
			if(D.owner_salary && !D.suspended)
				charge_to_account(D.account_number, D.account_number, "Salary payment", "CentComm", D.owner_salary)
				D.check_insurance()
				if(D.owner_insurance_price)
					insurance_transaction(D)


		monitor_cargo_shop()

	payment_counter += 1

/datum/controller/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait



/proc/insurance_transaction(datum/money_account/D)
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.mind)
			if(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER) == D.account_number)
				if(H.stat != DEAD)
					var/insurance_price = D.owner_insurance_price
					var/med_account_number = global.department_accounts["Medical"].account_number
					charge_to_account(D.account_number, "Medical","Insurance", "NT Insurance", -1 * insurance_price)
					charge_to_account(med_account_number, med_account_number,"Insurance", D.account_number,insurance_price)
