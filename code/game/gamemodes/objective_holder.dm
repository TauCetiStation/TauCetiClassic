/datum/objective_holder
	var/list/datum/objective/objectives = list()
	var/datum/mind/owner = null
	var/datum/faction/faction = null

/datum/objective_holder/Destroy(force, ...)
	QDEL_LIST(objectives)
	return ..()

/datum/objective_holder/proc/AddObjective(datum/objective/O, datum/mind/M, datum/faction/F)
	ASSERT(!objectives.Find(O))
	objectives.Add(O)
	if(M)
		O.owner = M
	if(F)
		O.faction = F
	if(O.PostAppend())
		return TRUE

	objectives.Remove(O)
	qdel(O)
	return FALSE

/datum/objective_holder/proc/GetObjectives()
	return objectives

/datum/objective_holder/proc/FindObjective(datum/objective/O)
	return locate(O) in objectives

/datum/objective_holder/proc/RemoveObjective(datum/objective/O)
	var/datum/objective/object = FindObjective(O)
	if(!object)
		return
	objectives -= object

/datum/objective_holder/proc/GetObjectiveString(check_success = FALSE, admin_edit = FALSE, datum/mind/M, datum/role/R)
	var/dat = ""
	if(objectives.len)
		var/obj_count = 1
		for(var/datum/objective/O in objectives)
			dat += {"<b>Objective #[obj_count++]</b>: [O.explanation_text]
				[admin_edit ? " - <a href='?src=\ref[M];obj_delete=\ref[O];obj_holder=\ref[src]'>(remove)</a> - <a href='?src=\ref[M];obj_completed=\ref[O];obj_holder=\ref[src]'>(toggle:[O.completion_to_string()])</a>" : ""]
				<br>"}
			if(check_success)
				dat += {"<BR>[O.completion_to_string()]"}
	if(admin_edit)
		if (owner)
			dat += "<b> Manage role: </b> <br/>"
			dat += "<a href='?src=\ref[M];obj_add=1;obj_holder=\ref[src]'>(add personal objective)</a> <br/>"
		else if (faction)
			dat += "<b> Manage faction: </b> <br/>"
			dat += "<a href='?src=\ref[M];obj_add=1;obj_holder=\ref[src]'>(add faction objective)</a> <br/>"
		dat += "<a href='?src=\ref[M];obj_gen=1;obj_holder=\ref[src];obj_owner=[faction?"\ref[faction]":"\ref[R]"]'>(generate objectives)</a> <br/>"
		dat += "<a href='?src=\ref[M];obj_announce=1;obj_owner=[faction?"\ref[faction]":"\ref[R]"]'>(annouce objectives)</a><br/>"
	return dat
