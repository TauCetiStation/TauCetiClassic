var/datum/subsystem/economy/SSeconomy

/datum/subsystem/economy
	name = "Economy"
	wait = 2 MINUTES
	init_order = SS_INIT_DEFAULT
	flags = SS_NO_INIT

	var/endtime = 0 //this variable holds the sum of ticks until the next call to fire(). This is necessary to display the remaining time before salary in the PDA

/datum/subsystem/economy/New()
	NEW_SS_GLOBAL(SSeconomy)

/datum/subsystem/economy/fire()	//this prok is called once in "wait" minutes
	set_endtime()
	if(!global.economy_init)
		return
	else
		for(var/datum/money_account/D in all_money_accounts)
			if(D.owner_salary)
				charge_to_account(D.account_number, D.account_number, "pay salary", "CentCom", D.owner_salary)
				to_chat(world, "<span class='warning'>paid to [D.account_number]</span>") // for test

/datum/subsystem/economy/proc/set_endtime()
	endtime = world.timeofday + wait
