/datum/component/karate

/datum/component/karate/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_KISSED_THE_WALL), .proc/side_kick)

/datum/component/karate/proc/side_kick(parent, mob/victim)
	var/mob/living/carbon/human/H = victim
	if(prob(70))
		H.AdjustWeakened(1)
		H.make_dizzy(10)
		to_chat(H, "<span class='userdanger'>This power...</span>")

/datum/component/karate/Destroy()
	UnregisterSignal(parent, list(COMSIG_KISSED_THE_WALL))
	. = ..()
