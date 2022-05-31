/datum/component/fear_of_a_gun

/datum/component/fear_of_a_gun/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_CAUGHT_A_BULLET), .proc/gun_fear)

/datum/component/fear_of_a_gun/proc/gun_fear()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = parent
	if(H && !H.species.flags[NO_PAIN])
		H.adjustHalLoss(120)
		to_chat(H, "<span class='userdanger'>Oh no, it's my weakness!</span>")

/datum/component/fear_of_a_gun/Destroy()
	UnregisterSignal(parent, list(COMSIG_CAUGHT_A_BULLET))
	. = ..()
 
