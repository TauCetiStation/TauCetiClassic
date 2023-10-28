/datum/component/wrench_to_table
	var/obj/structure/table/wrenched_to

	var/datum/callback/on_wrenched
	var/datum/callback/on_unwrenched

/datum/component/wrench_to_table/Initialize(datum/callback/_on_wrenched = null, datum/callback/_on_unwrenched = null)
	var/obj/item/parent_item = parent
	var/obj/structure/table/table = locate(/obj/structure/table, get_turf(parent_item))
	if(table)
		wrenched_to = table
		wrench()

	on_wrenched = _on_wrenched
	on_unwrenched = _on_unwrenched

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), PROC_REF(try_wrench))
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/wrench_to_table/proc/on_destroyed()
	qdel(src)

/datum/component/wrench_to_table/Destroy()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_QDELETING))
	if(wrenched_to)
		UnregisterSignal(wrenched_to, list(COMSIG_PARENT_QDELETING))

	QDEL_NULL(on_wrenched)
	QDEL_NULL(on_unwrenched)
	return ..()

/datum/component/wrench_to_table/proc/try_wrench(datum/source, obj/item/tool,  mob/living/user, params)
	var/obj/item/parent_item = parent
	if(!isturf(parent_item.loc) || !iswrenching(tool))
		return
	if(user.is_busy(parent_item))
		return

	var/obj/structure/table/table = locate(/obj/structure/table, get_turf(parent_item))
	if(!table)
		to_chat(user, "<span class='warning'>[parent_item.name] можно прикрутить только к столу.</span>")
		return
	wrenched_to = table

	if(tool.use_tool(parent, user, SKILL_TASK_VERY_EASY, volume = 50))
		if(!parent_item.anchored)
			to_chat(user, "<span class='warning'>[parent_item.name] прикручен.</span>")
			wrench()
			return
		to_chat(user, "<span class='notice'>[parent_item.name] откручен.</span>")
		unwrench()

/datum/component/wrench_to_table/proc/wrench()
	var/obj/item/parent_item = parent
	parent_item.anchored = TRUE
	RegisterSignal(wrenched_to, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))

	if(on_wrenched)
		on_wrenched.Invoke()

/datum/component/wrench_to_table/proc/unwrench()
	var/obj/item/parent_item = parent
	parent_item.anchored = FALSE
	if(wrenched_to)
		UnregisterSignal(wrenched_to, list(COMSIG_PARENT_QDELETING))
		wrenched_to = null

	if(on_unwrenched)
		on_unwrenched.Invoke()
