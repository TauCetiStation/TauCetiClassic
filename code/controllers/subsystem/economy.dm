var/datum/subsystem/economy/SSeconomy

/datum/subsystem/economy
	name = "Economy"
	wait = 2 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA
	var/payment_counter = 0 

/datum/subsystem/economy/New()
	NEW_SS_GLOBAL(SSeconomy)

/datum/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else if (payment_counter)	//to skip first payment
		for(var/datum/money_account/D in all_money_accounts)
			if(D.owner_salary && !D.suspended)
				charge_to_account(D.account_number, D.account_number, "Salary payment", "CentCom", D.owner_salary)
				if(D.reset_salary)
					D.set_salary(D.base_salary)
	payment_counter += 1

/datum/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait
