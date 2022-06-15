/datum/component/bullet_fear

/datum/component/bullet_fear/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_TAKE_BULLET_DAMAGE), .proc/make_me_fear)

/datum/component/bullet_fear/proc/make_me_fear()
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = parent
	if(!H.species.flags[NO_PAIN])
		H.adjustHalLoss(120)
		to_chat(H, "<span class='userdanger'>Oh no, it's my weakness!</span>")

/datum/component/bullet_fear/Destroy()
	UnregisterSignal(parent, list(COMSIG_TAKE_BULLET_DAMAGE))
	return ..()
