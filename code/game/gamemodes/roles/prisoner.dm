/datum/role/prisoner
	name = PRISONER
	id = PRISONER
	logo_state = "prisoner"

/datum/role/prisoner/forgeObjectives()
	. = ..()
	if(!.)
		return

	var/record_id = find_record_by_name(null, antag.current.real_name)
	var/datum/data/record/R = find_security_record("id", record_id)

	if(prob(50))
		AppendObjective(/datum/objective/target/assassinate, TRUE)
		antag.skills.add_available_skillset(/datum/skillset/officer)
		R.fields["ma_crim"] = "Статья 301"
	else
		AppendObjective(/datum/objective/steal, TRUE)
		antag.skills.add_available_skillset(/datum/skillset/engineer)
		R.fields["ma_crim"] = "Статья 205, статья 211, статья 216"

	R.fields["criminal"] = "Incarcerated"
	R.fields["notes"] = "Пожизненное заключение."

	antag.skills.maximize_active_skills()
	AppendObjective(/datum/objective/escape)
