///////////////////////////////////
// POWERS
///////////////////////////////////
//#Z2
//Added activation chance for every power

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	mutation=mNobreath
	activation_prob=50

	New()
		block=NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind expands.")
	mutation=mRemote
	activation_prob=50

	New()
		block=REMOTEVIEWBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remoteobserve

	deactivate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs -= /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	mutation=mRegen
	activation_prob=50

	New()
		block=REGENERATEBLOCK

	can_activate(var/mob/M,var/flags)
		if( (HULK in M.mutations) || (mSmallsize in M.mutations))
			return 0
		return ..(M,flags)

	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		var/datum/organ/external/head/H = M.organs_by_name["head"]

		if(H.disfigured) H.disfigured = 0

		if(HUSK in M.mutations)
			M.mutations.Remove(HUSK)
			M.update_mutations()
			M.UpdateAppearance()

		var/datum/organ/external/chest/C = M.get_organ("chest")
		for(var/datum/organ/internal/I in C.internal_organs)
			if(I.damage > 0)
				I.damage -= 0.25

		if(M.getBrainLoss() > 24)
			if(M.getBrainLoss() < 76) M.adjustBrainLoss(-0.25)
		else
			if(prob(20))
				if(M.getOxyLoss() < 126) M.adjustOxyLoss(-1)
				if(M.getBruteLoss() < 126) M.heal_organ_damage(1,0)
				if(M.getFireLoss() < 126) M.heal_organ_damage(0,1)
				if(M.getToxLoss() < 126) M.adjustToxLoss(-1)
				if(M.getCloneLoss() < 126) M.adjustCloneLoss(-1)
			if(M.getBrainLoss()) M.adjustBrainLoss(-0.10)

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Your leg muscles pulsate.")
	mutation=mRun
	activation_prob=50

	New()
		block=INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_messages=list("You feel your voice can penetrate other minds.")
	mutation=mRemotetalk
	activation_prob=50

	New()
		block=REMOTETALKBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remotesay

	deactivate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs -= /mob/living/carbon/human/proc/remotesay

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Your skin feels strange.")
	mutation=mMorph
	activation_prob=50

	New()
		block=MORPHBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/morph

	deactivate(var/mob/M)
		..(M)
		M.verbs -= /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	mutation=mHeatres
	activation_prob=30

	New()
		block=COLDBLOCK

	can_activate(var/mob/M,var/flags)
		if(COLD_RESISTANCE in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	mutation=COLD_RESISTANCE
	activation_prob=30

	New()
		block=FIREBLOCK

	can_activate(var/mob/M,var/flags)
		if(mHeatres in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	mutation=mFingerprints
	activation_prob=50

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels electric.")
	mutation=mShock
	activation_prob=50

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("You feel small.")
	mutation=mSmallsize
	activation_prob=50

	New()
		block=SMALLSIZEBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big, small and regenerate.
		if( (HULK in M.mutations) || (mRegen in M.mutations)) //#Z2
			return 0
		return ..(M,flags)

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags |= 1

	deactivate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags &= ~1 //This may cause issues down the track, but offhand I can't think of any other way for humans to get passtable short of varediting so it should be fine. ~Z

/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	mutation=HULK
	activation_prob=5

	New()
		block=HULKBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big, small and regenerate.
		if( (mSmallsize in M.mutations) || (mRegen in M.mutations)) //#Z2
			return 0
		return ..(M,flags)

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		if(M.client)
			message_admins("[M.name] ([M.ckey]) is now <span class='warning'>Hulk</span>")
		M.verbs += /mob/living/carbon/human/proc/hulk_jump
		M.verbs += /mob/living/carbon/human/proc/hulk_dash
		M.verbs += /mob/living/carbon/human/proc/hulk_smash

		M.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))

		var/list/preserve = list()
		var/mob/living/carbon/human/H = M
		for(var/obj/item/weapon/storage/backpack/W in H)
			preserve += W
		for(var/obj/item/weapon/implant/W in H)
			preserve += W
		for(var/obj/item/weapon/shard/shrapnel/W in H)
			preserve += W
		for(var/obj/item/W in (H.contents-preserve))
			if (W==H.w_uniform) // will be teared
				del(W)
				continue
			H.drop_from_inventory(W)
			if(istype(W.loc,/obj/machinery/))
				W.loc = get_turf(H) // If we transformed in some container like dna_scanner and we can't get our items back anymore, here is solution.

	deactivate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs -= /mob/living/carbon/human/proc/hulk_jump
		M.verbs -= /mob/living/carbon/human/proc/hulk_dash
		M.verbs -= /mob/living/carbon/human/proc/hulk_smash
		M.opacity = 0 // just in case

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		if(fat)
			return "hulk_[fat]_s"
		else
			return "hulk_[g]_s"
		return 0

	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if(!M.lying) // Our Hulk now blocks LoS as mech. He is really big, isnt he?
			M.opacity = 1
		else
			M.opacity = 0
		if(M.health <= 25) // Hulk gene is still with us, so we will get WEAKEN status while health <= 25, until we remove that gene manually
			if(HULK in M.mutations)
				M.mutations.Remove(HULK)
				M.update_mutations()		//update our mutation overlays
			if(prob(25)) M << "\red You suddenly feel very weak." // Less spam to user
			if(!M.lying) //Facken spam fix for collapse
				M.emote("collapse")
			M.Weaken(10)

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	mutation=XRAY
	activation_prob=30

	New()
		block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	mutation=TK
	activation_prob=15

	New()
		block=TELEBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "telekinesishead[fat]_s"
