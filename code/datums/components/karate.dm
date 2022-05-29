/datum/component/karate

/datum/component/karate/Initialize()
  if(!ishuman(parent))
    return COMPONENT_INCOMPATIBLE
  RegisterSignal(parent, list(COMSIG_PUMPED_LIMIT_RICHED), .proc/strengthen_muscles)
  RegisterSignal(parent, list(COMSIG_CAUGHT_A_BULLET), .proc/gun_fear)

/datum/component/karate/proc/gun_fear()
    SIGNAL_HANDLER
    var/mob/living/carbon/human/H = parent
    if(H && !H.species.flags[NO_PAIN])
        H.adjustHalLoss(99)
        to_chat(H, "<span class='userdanger'>Oh no, it's my weakness!</span>")
    qdel(src)

/datum/component/karate/proc/strengthen_muscles(parent, obj/item/organ/external/BP)
    SIGNAL_HANDLER
    if(BP && BP.max_pumped)
        if(BP.max_pumped > 0 && BP.max_pumped < 300)
            BP.max_pumped += 10
            to_chat(parent, "<span class='notice'>The blood pumps, the limbs obey!</span>")
        else
            to_chat(parent, "<span class='notice'>The blood quickens! </span>")
