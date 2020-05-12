/datum/dna/gene/monkey
	name="Monkey"

/datum/dna/gene/monkey/New()
	block=MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(mob/M,flags)
	return istype(M, /mob/living/carbon/human) || istype(M,/mob/living/carbon/monkey)

/datum/dna/gene/monkey/activate(mob/living/carbon/human/H, connected, flags)
	if(!istype(H))
		//testing("Cannot monkey-ify [H], type is [H.type].")
		return

	H.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/dna/gene/monkey/deactivate(mob/living/carbon/monkey/M, connected, flags)
	if(!istype(M))
		//testing("Cannot humanize [M], type is [M.type].")
		return

	M.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)
