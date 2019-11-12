/datum/genetics/side_effect
	var/name // name of the side effect, to use as a header in the manual
	var/symptom // description of the symptom of the side effect
	var/treatment // description of the treatment of the side effect
	var/effect // description of what happens when not treated
	var/duration = 0 // delay between start() and finish()

/datum/genetics/side_effect/proc/start(mob/living/carbon/human/H)
	// start the side effect, this should give some cue as to what's happening,
	// such as gasping. These cues need to be unique among side-effects.

/datum/genetics/side_effect/proc/finish(mob/living/carbon/human/H)
	// Finish the side-effect. This should first check whether the cure has been
	// applied, and if not, cause bad things to happen.

/datum/genetics/side_effect/genetic_burn
	name = "Genetic Burn"
	symptom = "Subject's skin turns unusualy red."
	treatment = "None."
	effect = "Subject's skin burns."
	duration = 10*30

/datum/genetics/side_effect/genetic_burn/start(mob/living/carbon/human/H)
	H.emote("me", 1, "starts turning very red..")

/datum/genetics/side_effect/genetic_burn/finish(mob/living/carbon/human/H)
	for(var/bodypart in list(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN))
		var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
		if(prob(85))//#Z2 - now 15% chance even for more burn
			BP.take_damage(0, 5, 0)
		else
			BP.take_damage(0, 20, 0)

/datum/genetics/side_effect/bone_snap
	name = "Bone Snap"
	symptom = "Subject's limbs tremble notably."
	treatment = "None."
	effect = "Subject's bone breaks."
	duration = 10*60

/datum/genetics/side_effect/bone_snap/start(mob/living/carbon/human/H)
	H.emote("me", 1, "'s limbs start shivering uncontrollably.")

/datum/genetics/side_effect/bone_snap/finish(mob/living/carbon/human/H)
	var/bodypart = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)
	var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart]
	if(prob(85))
		BP.take_damage(20)
		BP.fracture()
	else
		BP.take_damage(70)

/datum/genetics/side_effect/monkey //#Z2 Random monkey transform is back
	name = "Monkey"
	symptom = "Subject starts drooling uncontrollably."
	treatment = "None."
	effect = "Subject turns into monkey."
	duration = 10*120

/datum/genetics/side_effect/monkey/start(mob/living/carbon/human/H)
	H.emote("me", 1, "has drool running down from his mouth and hair starts to cover whole body.")

/datum/genetics/side_effect/monkey/finish(mob/living/carbon/human/H)
	H.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/genetics/side_effect/confuse
	name = "Confuse"
	symptom = "Subject starts drooling uncontrollably."
	treatment = "None."
	effect = "Subject becomes confused."
	duration = 10*30

/datum/genetics/side_effect/confuse/start(mob/living/carbon/human/H)
	H.emote("me", 1, "has drool running down from his mouth.")

/datum/genetics/side_effect/confuse/finish(mob/living/carbon/human/H)
	H.confused += 100

/datum/genetics/side_effect/bald_madness
	name = "Bald madness"
	symptom = "Subject becomes bald.."
	treatment = "None."
	effect = "Subject's head turns bald."
	duration = 10*5

/datum/genetics/side_effect/bald_madness/start(mob/living/carbon/human/H)
	H.emote("me", 1, "starts loosing his hair..")

/datum/genetics/side_effect/bald_madness/finish(mob/living/carbon/human/H)
	H.f_style = "Shaved"
	H.h_style = "Skinhead"
	H.update_hair()

/proc/trigger_side_effect(mob/living/carbon/human/H)
	set waitfor = 0
	if(!H || !istype(H))
		return
	var/tp = pick(typesof(/datum/genetics/side_effect) - /datum/genetics/side_effect)
	var/datum/genetics/side_effect/S = new tp
	S.start(H)

	sleep(20)
	if(!H || !istype(H))
		return
	H.Weaken(rand(0, S.duration / 50))

	sleep(S.duration)
	if(!H || !istype(H))
		return
	H.SetWeakened(0)
	S.finish(H)
