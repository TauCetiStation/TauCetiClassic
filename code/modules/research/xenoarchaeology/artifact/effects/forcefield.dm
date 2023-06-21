/datum/artifact_effect/forcefield
	log_name = "Force Field"
	var/list/created_field = list()
	type_name = ARTIFACT_EFFECT_PARTICLE

/datum/artifact_effect/forcefield/New()
	..()
	trigger = TRIGGER_TOUCH

/datum/artifact_effect/forcefield/ToggleActivate()
	..()
	if(created_field.len)
		for(var/obj/effect/energy_field/F in created_field)
			created_field.Remove(F)
			qdel(F)
	else if(holder)
		var/turf/T = get_turf(holder)
		while(created_field.len < 16)
			var/obj/effect/energy_field/E = new (locate(T.x,T.y,T.z))
			created_field.Add(E)
			E.strength = 1
			E.density = TRUE
			E.anchored = TRUE
			E.invisibility = 0
		addtimer(CALLBACK(src, PROC_REF(UpdateMove)), 10)
	return FALSE

/datum/artifact_effect/forcefield/process()
	..()
	for(var/obj/effect/energy_field/E in created_field)
		if(E.strength < 1)
			E.Strengthen(0.15)
		else if(E.strength < 5)
			E.Strengthen(0.25)

/datum/artifact_effect/forcefield/UpdateMove()
	if(created_field.len && holder)
		var/turf/T = get_turf(holder)
		while(created_field.len < 16)
			//for now, just instantly respawn the fields when they get destroyed
			var/obj/effect/energy_field/E = new (locate(T.x,T.y,T))
			created_field.Add(E)
			E.anchored = TRUE
			E.density = TRUE
			E.invisibility = 0

		var/obj/effect/energy_field/E = created_field[1]
		E.loc = locate(T.x + 2,T.y + 2,T.z)
		E = created_field[2]
		E.loc = locate(T.x + 2,T.y + 1,T.z)
		E = created_field[3]
		E.loc = locate(T.x + 2,T.y,T.z)
		E = created_field[4]
		E.loc = locate(T.x + 2,T.y - 1,T.z)
		E = created_field[5]
		E.loc = locate(T.x + 2,T.y - 2,T.z)
		E = created_field[6]
		E.loc = locate(T.x + 1,T.y + 2,T.z)
		E = created_field[7]
		E.loc = locate(T.x + 1,T.y - 2,T.z)
		E = created_field[8]
		E.loc = locate(T.x,T.y + 2,T.z)
		E = created_field[9]
		E.loc = locate(T.x,T.y - 2,T.z)
		E = created_field[10]
		E.loc = locate(T.x - 1,T.y + 2,T.z)
		E = created_field[11]
		E.loc = locate(T.x - 1,T.y - 2,T.z)
		E = created_field[12]
		E.loc = locate(T.x - 2,T.y + 2,T.z)
		E = created_field[13]
		E.loc = locate(T.x - 2,T.y + 1,T.z)
		E = created_field[14]
		E.loc = locate(T.x - 2,T.y,T.z)
		E = created_field[15]
		E.loc = locate(T.x - 2,T.y - 1,T.z)
		E = created_field[16]
		E.loc = locate(T.x - 2,T.y - 2,T.z)
