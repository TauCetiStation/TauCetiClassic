/datum/component/mob_modifier/mouse
	var/message = NONE // Text that will be printed in chat upon getting abilities

/datum/component/mob_modifier/mouse/Initialize(strength)
	if(!istype(parent, /mob/living/simple_animal/mouse))
		return COMPONENT_INCOMPATIBLE

	if(!apply())
		return COMPONENT_NOT_ATTACHED

	if(need_updates)
		RegisterSignal(parent, list(COMSIG_MOB_MOD_UPDATE), .proc/on_revert)

	applied = TRUE

/datum/component/mob_modifier/mouse/apply(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	if(!M)
		return
	if(message)
		to_chat(M, "<span class='notice'>[message]</span>")
	return ..()

