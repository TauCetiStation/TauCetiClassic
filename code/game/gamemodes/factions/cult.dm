/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return FALSE
	if(ishuman(mind.current))
		if((mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(mind.current.get_species() == GOLEM)
			return FALSE
	if(ismindshielded(mind.current))
		return FALSE
	return TRUE

/datum/faction/cult
	name = BLOODCULT
	ID = BLOODCULT
	logo_state = "cult-logo"

	required_pref = ROLE_CULTIST

	initial_role = CULTIST
	late_role = CULTIST
	initroletype = /datum/role/cultist

	max_roles = 4

	var/list/startwords = list("blood","join","self","hell")
	var/list/sacrificed = list()
	var/eldertry = 0

/datum/faction/cult/forgeObjectives()
	. = ..()
	var/list/possibles_objectives = subtypesof(/datum/objective/cult)
	for(var/i in 1 to rand(2, 3))
		AppendObjective(pick_n_take(possibles_objectives))

/datum/faction/cult/GetScoreboard()
	var/dat = ..()
	dat += "<b>Cultists escaped:</b> [get_cultists_out()]"
	return dat

/datum/faction/cult/proc/get_cultists_out()
	var/acolytes_out = 0
	for(var/datum/role/R in members)
		if(R.antag?.current?.stat != DEAD)
			var/area/A = get_area(R.antag.current)
			if(is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_out++

	return acolytes_out

/datum/faction/cult/proc/grant_runeword(mob/living/carbon/human/cult_mob, word)
	if (!word)
		if(length(startwords) > 0)
			word = pick_n_take(startwords)

	if(!cultwords["travel"])
		runerandom()
	if (!word)
		word = pick(cultwords)

	var/wordexp = "[cultwords[word]] is [word]..."
	to_chat(cult_mob, "<span class = 'cult'>You remember one thing from the dark teachings of your master... <b>[wordexp]</b></span>")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0)
