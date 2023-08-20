/datum/role/debtor
	name = "Debtor"
	id = "Debtor"
	logo_state = "debtor"

/datum/role/debtor/forgeObjectives()
	. = ..()
	if(!.)
		return

	AppendObjective(/datum/objective/target/debt, TRUE)
