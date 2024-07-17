var/global/list/spented_examined_objects = list()

/datum/component/examine_research
	var/datum/research/linked_techweb
	var/points_value = 0
	var/list/extra_check

/datum/component/examine_research/Initialize(linked_techweb_id, research_value, _extra_check)
	for(var/obj/machinery/computer/rdconsole/RD in RDcomputer_list)
		if(RD.id == linked_techweb_id)
			linked_techweb = RD.files
	if(!istype(linked_techweb))
		return COMPONENT_NOT_ATTACHED
	points_value = research_value
	if(points_value <= 0)
		return COMPONENT_NOT_ATTACHED
	if(islist(_extra_check))
		extra_check = _extra_check
	else
		extra_check = list(_extra_check)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/examine_research/proc/calculate_research_value()
	for(var/datum_type in global.spented_examined_objects)
		if(datum_type == parent.type)
			return 0
	return points_value

/datum/component/examine_research/proc/begin_scan(mob/user)
	to_chat(user, "<span class='notice'>You concentrate on scanning [parent].</span>")
	if(!do_after(user, 50, FALSE, parent))
		to_chat(user, "<span class='warning'>You stop scanning [parent].</span>")
		return
	if(calculate_research_value() <= 0)
		to_chat(user, "<span class='warning'>[parent] have no research value.</span>")
		return
	to_chat(user, "<span class='notice'>[parent] scan earned you [points_value] research points.</span>")
	linked_techweb.research_points += points_value
	global.spented_examined_objects += parent.type

/datum/component/examine_research/proc/success_check(mob/living/carbon/human/user)
	var/list/succes_checks = list()
	for(var/check in extra_check)
		switch(check)
			if(DIAGNOSTIC_EXTRA_CHECK)
				if(user.glasses)
					if(isdiagnostichud(user.glasses))
						succes_checks += check
			if(VIEW_EXTRA_CHECK)
				if(user in viewers(parent))
					succes_checks += check
	var/list/diffs = difflist(extra_check, succes_checks)
	if(diffs.len)
		return FALSE
	return TRUE

/datum/component/examine_research/proc/on_examine(datum/source, mob/user)
	SIGNAL_HANDLER
	if(user.is_busy())
		return
	if(!ishuman(user))
		return
	if(!success_check(user))
		return
	INVOKE_ASYNC(src, PROC_REF(begin_scan), user)
