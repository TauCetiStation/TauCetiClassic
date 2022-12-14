/datum/faction/enemies_of_revolution
	name = "Enemies of the Revolution"
	ID = F_ENEMY_REVS
	initroletype = /datum/role/enemy_of_revolution

/datum/faction/enemies_of_the_revolution/forgeObjectives()
	if(!..())
		return FALSE
	var/datum/objective/custom/custom_obj = AppendObjective(/datum/objective/custom)
	if(custom_obj)
		custom_obj.explanation_text = "Survive at any cost"
	return TRUE
