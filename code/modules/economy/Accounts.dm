
// float 1-8-23 bits. More then 16777216 lost accuracy in $1
#define MAX_MONEY_ON_ACCOUNT 16777215
#define MIN_MONEY_ON_ACCOUNT -16777215

/datum/money_account
	var/owner_name = ""
	var/owner_salary = 0	//used for payments
	var/base_salary = 0		//used to changes owner_salary
	var/change = "def"		//type of salary change: "perm"-Permanent(only admin can cancel), "temp"-Temporarily or "def"-Default
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/obj/item/device/pda/owner_PDA = null	//contains a PDA linked to an account
	var/suspended = 0
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

/datum/money_account/proc/adjust_money(amount)
	money = clamp(money + amount, MIN_MONEY_ON_ACCOUNT, MAX_MONEY_ON_ACCOUNT)

/datum/money_account/proc/set_salary(amount, ratio = 1)
	owner_salary = amount * ratio
	base_salary = amount
	if(change == "perm")
		return
	else
		change = "def"

/datum/money_account/proc/change_salary(user, user_name, terminal, user_rank, force_rate = null)
	var/new_salary = 0
	var/salary_rate = 0
	var/input_rate = ""
	var/type_change = "temp"	//permanent or temporary change?
	if(force_rate == null)
		if(change == "temp")
			if(alert(user, "The salary of [owner_name] has already changed. Are you sure you want to change your salary?", "Confirm", "Yes", "No") != "Yes")
				return
		var/list/rate = list("+100%", "+50%", "+25%", "0", "-25%", "-50%", "-100%")
		if(user_rank != "Admin")
			if(change == "perm")
				alert(user, "Central Command blocked salary change!")
				return
			rate = rate.Copy(2,7)
		else
			if(alert(user, "Permanent - only admin can return the base salary.\
			Temporarily - any head can return the base salary.", "Choose type of salary change.", "Permanent", "Temporarily") == "Permanent")
				type_change = "perm"
		input_rate = input(user, "Please, select a rate!", "Salary Rate", null) as null|anything in rate
		if(!input_rate)
			return
		salary_rate = text2num(replacetext(replacetext(input_rate, "+", ""), "%", ""))
		new_salary = round(base_salary + (base_salary * (salary_rate/100)))
		if(alert(user, "Now [owner_name] will start receiving a salary of [new_salary] credits. Are you sure?", "Confirm", "Yes", "No") != "Yes")
			return
	else
		new_salary = round(base_salary + (base_salary * (force_rate/100)))
		type_change = "perm"
		salary_rate = force_rate
	if(new_salary == owner_salary)	//there were no changes
		return
	owner_salary = new_salary
	if(new_salary == base_salary)	//return to default
		type_change = "def"
	change = type_change

	if(owner_PDA)
		owner_PDA.transaction_inform(null, user_name, salary_rate, TRUE)

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/proc/create_random_account_and_store_in_mind(mob/living/carbon/human/H, start_money = rand(50, 200) * 10)
	var/datum/money_account/M = create_account(H.real_name, start_money, null)
	if(H.mind)
		var/remembered_info = ""
		remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
		remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
		remembered_info += "<b>Your account funds are:</b> $[M.money]<br>"
		if(M.transaction_log.len)
			var/datum/transaction/T = M.transaction_log[1]
			remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
		H.mind.store_memory(remembered_info)
		H.mind.initial_account = M
	return M

/proc/create_account(new_owner_name = "Default user", starting_funds = 0, obj/machinery/account_database/source_db)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 111111)
	M.adjust_money(starting_funds)

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds
	if(!source_db)
		//set a random date, time and location some time over the past decade
		T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [game_year-rand(1,10)]"
		T.time = "[rand(0,23)]:[rand(11,59)]"
		T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

		M.account_number = rand(111111, 999999)
	else
		T.date = current_date_string
		T.time = worldtime2text()
		T.source_terminal = source_db.machine_id

		M.account_number = next_account_number
		next_account_number += rand(1,25)

		//create a sealed package containing the account details
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(source_db.loc)

		var/obj/item/weapon/paper/R = new /obj/item/weapon/paper(P)
		R.name = "Account information: [M.owner_name]"
		R.info = "<b>Account details (confidential)</b><br><hr><br>"
		R.info += "<i>Account holder:</i> [M.owner_name]<br>"
		R.info += "<i>Account number:</i> [M.account_number]<br>"
		R.info += "<i>Account pin:</i> [M.remote_access_pin]<br>"
		R.info += "<i>Starting balance:</i> $[M.money]<br>"
		R.info += "<i>Date and time:</i> [worldtime2text()], [current_date_string]<br><br>"
		R.info += "<i>Creation terminal ID:</i> [source_db.machine_id]<br>"
		R.info += "<i>Authorised NT officer overseeing creation:</i> [source_db.held_card.registered_name]<br>"
		P.update_icon()

		//stamp the paper
		var/obj/item/weapon/stamp/centcomm/S = new
		S.stamp_paper(R, "Accounts Database")

	//add the account
	M.transaction_log.Add(T)
	all_money_accounts.Add(M)

	return M

/proc/charge_to_account(attempt_account_number, source_name, purpose, terminal_id, amount)
	var/money = round(amount, 1)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number && !D.suspended)
			D.adjust_money(money)

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = source_name
			T.purpose = purpose
			T.amount = "[money]"
			T.date = current_date_string
			T.time = worldtime2text()
			T.source_terminal = terminal_id
			D.transaction_log.Add(T)

			if(D.owner_PDA)
				D.owner_PDA.transaction_inform(source_name, terminal_id, money)

			return TRUE
	return FALSE

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(attempt_account_number, attempt_pin_number, security_level_passed = 0)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number) )
				return D
			break

/proc/get_account(account_number)
	for(var/datum/money_account/D in all_money_accounts)
		if(D.account_number == account_number)
			return D

#undef MAX_MONEY_ON_ACCOUNT
#undef MIN_MONEY_ON_ACCOUNT
