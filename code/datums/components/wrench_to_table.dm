/datum/component/wrench_to_table
	var/obj/structure/table/Wrenched_To

	var/datum/callback/on_wrenched
	var/datum/callback/on_unwrenched

/datum/component/wrench_to_table/Initialize(datum/callback/_on_wrenched = null, datum/callback/_on_unwrenched = null)
	var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(parent))
	if(Table)
		Wrenched_To = Table
		wrench()

	on_wrenched = _on_wrenched
	on_unwrenched = _on_unwrenched

	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), PROC_REF(try_wrench))
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/wrench_to_table/proc/on_destroyed()
	qdel(src)

/datum/component/wrench_to_table/Destroy()
	UnregisterSignal(parent, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_QDELETING))
	UnregisterSignal(Wrenched_To, list(COMSIG_PARENT_QDELETING))

	QDEL_NULL(on_wrenched)
	QDEL_NULL(on_unwrenched)
	return ..()

/datum/component/wrench_to_table/proc/try_wrench(datum/source, obj/item/I,  mob/living/user, params)
	var/obj/item/Par = parent
	if(!isturf(Par.loc) || !iswrenching(I))
		return

	var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(parent))
	if(!Table)
		to_chat(user, "<span class='warning'>[Par.name] можно прикрутить только к столу.</span>")
		return
	Wrenched_To = Table

	var/obj/item/weapon/wrench/Tool = I
	if(Tool.use_tool(parent, user, SKILL_TASK_VERY_EASY, volume = 50))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!Par.anchored)
			to_chat(user, "<span class='warning'>[Par.name] прикручен.</span>")
			wrench()
			return
		to_chat(user, "<span class='notice'>[Par.name] откручен.</span>")
		unwrench()

/datum/component/wrench_to_table/proc/wrench()
	var/obj/item/Par = parent
	Par.anchored = TRUE
	RegisterSignal(Wrenched_To, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))

	if(on_wrenched)
		on_wrenched.Invoke()

/datum/component/wrench_to_table/proc/unwrench()
	var/obj/item/Par = parent
	Par.anchored = FALSE
	UnregisterSignal(Wrenched_To, list(COMSIG_PARENT_QDELETING))

	if(on_unwrenched)
		on_unwrenched.Invoke()
