/datum/component/karate

/datum/component/karate/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_KISSED_THE_WALL), .proc/side_kick)
	RegisterSignal(parent, list(COMSIG_ENGAGE_COMBAT), .proc/recieve_engage_signal)

/datum/component/karate/proc/side_kick(parent, mob/victim)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = victim
	if(prob(70))
		H.AdjustWeakened(1)
		H.make_dizzy(10)
		to_chat(H, "<span class='userdanger'>This power...</span>")

/datum/component/karate/proc/recieve_engage_signal()
	SIGNAL_HANDLER
	return COMPONENT_BLOCK_COMBO

/datum/component/karate/Destroy()
	UnregisterSignal(parent, list(COMSIG_KISSED_THE_WALL))
	UnregisterSignal(parent, list(COMSIG_ENGAGE_COMBAT))
	. = ..()
