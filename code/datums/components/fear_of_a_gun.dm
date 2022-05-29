/datum/component/fear_of_a_gun

/datum/component/fear_of_a_gun/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_CAUGHT_A_BULLET), .proc/gun_fear)

/datum/component/fear_of_a_gun/proc/gun_fear()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = parent
	if(H && !H.species.flags[NO_PAIN])
		H.adjustHalLoss(99)
		to_chat(H, "<span class='userdanger'>Oh no, it's my weakness!</span>")
		
	var/datum/component/karate/K = H.GetComponent(/datum/component/karate)
	if(K)
		qdel(K)

/datum/component/fear_of_a_gun/Destroy()
	UnregisterSignal(parent, list(COMSIG_CAUGHT_A_BULLET))
	. = ..()
 
