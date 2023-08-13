#define SELF_TIP "Имеет эффект при активации."

/datum/mechanic_tip/self_effect
	tip_name = SELF_TIP

/datum/mechanic_tip/self_effect/New(datum/component/bounded/B, atom/type)
	description = "Если держа предмет в руке по нему нажать, то создастся [initial(type.name)]."



/datum/component/self_effect
	// Type of created object
	var/effect_type
	// Time to new object
	var/recharge_time
	// Time to new object, if effect was deleted by time_to_del
	var/recharge_time_after_del
	// Time to del effect
	var/time_to_del
	//current outline color
	var/outline_color
	// Can user do smth
	var/datum/callback/can_callback

	var/atom/movable/effect
	var/have_outline = FALSE
	var/can_spawn_effect = TRUE
	var/can_spawn_effect_timer

/datum/component/self_effect/Initialize(_effect_type, _outline_color, datum/callback/_can_callback, _recharge_time = 0, _recharge_time_after_del = 0, _time_to_del)
	effect_type = _effect_type
	recharge_time = _recharge_time
	recharge_time_after_del = _recharge_time_after_del
	time_to_del = _time_to_del
	can_callback = _can_callback
	outline_color = _outline_color

	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), PROC_REF(do_effect))
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED), PROC_REF(equipped_effect))
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), PROC_REF(dropped_effect))
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(del_effect))

	var/datum/mechanic_tip/self_effect/effect_tip = new(src, effect_type)

	parent.AddComponent(/datum/component/mechanic_desc, list(effect_tip), can_callback)

/datum/component/self_effect/proc/can_effect(datum/source, mob/living/carbon/user)
	if(!can_callback?.Invoke(source, user))
		return FALSE
	if(!can_spawn_effect)
		return FALSE
	return TRUE

/datum/component/self_effect/proc/do_effect(datum/source, mob/living/carbon/user)
	if(!can_effect(source, user))
		return

	var/atom/movable/A = new effect_type(user)
	if(isitem(A))
		if(user.put_in_inactive_hand(A))
			can_spawn_effect = FALSE
			can_spawn_effect_timer = addtimer(CALLBACK(src, PROC_REF(ready_create_effect)), recharge_time, TIMER_STOPPABLE)
			effect = A
			if(time_to_del)
				addtimer(CALLBACK(src, PROC_REF(scatter_effect)), time_to_del)
			remove_outline()
		else
			qdel(A)
	else
		A.forceMove(get_turf(user))

/datum/component/self_effect/proc/dropped_effect()
	QDEL_NULL(effect)
	remove_outline()

/datum/component/self_effect/proc/equipped_effect(datum/source, mob/user)
	if(!can_callback?.Invoke(source, user))
		return

	if(!have_outline && can_spawn_effect)
		create_outline()

/datum/component/self_effect/proc/del_effect()
	QDEL_NULL(effect)

/datum/component/self_effect/proc/scatter_effect()
	if(isitem(effect))
		var/obj/item/I = effect
		if(I)
			var/mob/M = I.loc
			to_chat(M, "<span class='warning'>[effect] was scattered.</span>")

	del_effect()
	if(can_spawn_effect_timer)
		deltimer(can_spawn_effect_timer)
	can_spawn_effect_timer = addtimer(CALLBACK(src, PROC_REF(ready_create_effect)), recharge_time_after_del, TIMER_STOPPABLE)

/datum/component/self_effect/proc/remove_outline()
	if(outline_color)
		var/obj/item/I = parent
		have_outline = FALSE
		I.remove_filter("self_effect_outline")

/datum/component/self_effect/proc/create_outline()
	if(outline_color)
		var/obj/item/I = parent
		have_outline = TRUE
		I.add_filter("self_effect_outline", 2, outline_filter(1, outline_color))

/datum/component/self_effect/proc/ready_create_effect()
	can_spawn_effect = TRUE
	var/obj/item/I = parent
	if(!have_outline && (I.slot_equipped == SLOT_L_HAND || I.slot_equipped == SLOT_R_HAND))
		create_outline()

/datum/component/self_effect/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(SELF_TIP))
	if(can_spawn_effect_timer)
		deltimer(can_spawn_effect_timer)
	return ..()

#undef SELF_TIP
