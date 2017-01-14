///////////////////////////////////
// POWERS
///////////////////////////////////
//#Z2
//Added activation chance for every power

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	mutation=NO_BREATH
	activation_prob=50

	New()
		block=NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind expands.")
	mutation=REMOTE_VIEW
	activation_prob=50

	New()
		block=REMOTEVIEWBLOCK

	activate(mob/M, connected, flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remoteobserve

	deactivate(mob/M, connected, flags)
		..(M,connected,flags)
		M.verbs -= /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	mutation=REGEN
	activation_prob=50

	New()
		block=REGENERATEBLOCK

	can_activate(mob/M,flags)
		if((SMALLSIZE in M.mutations))
			return 0
		return ..(M,flags)

	OnMobLife(mob/living/carbon/human/M)
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
	mutation=RUN
	activation_prob=50

	New()
		block=INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_messages=list("You feel your voice can penetrate other minds.")
	mutation=REMOTE_TALK
	activation_prob=50

	New()
		block=REMOTETALKBLOCK

	activate(mob/M, connected, flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remotesay

	deactivate(mob/M, connected, flags)
		..(M,connected,flags)
		M.verbs -= /mob/living/carbon/human/proc/remotesay

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Your skin feels strange.")
	mutation=MORPH
	activation_prob=50

	New()
		block=MORPHBLOCK

	activate(mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/morph

	deactivate(mob/M)
		..(M)
		M.verbs -= /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	mutation=RESIST_HEAT
	activation_prob=30

	New()
		block=COLDBLOCK

	can_activate(mob/M,flags)
		if(COLD_RESISTANCE in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(mob/M,g,fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	mutation=COLD_RESISTANCE
	activation_prob=30

	New()
		block=FIREBLOCK

	can_activate(mob/M,flags)
		if(RESIST_HEAT in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(mob/M,g,fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	mutation=FINGERPRINTS
	activation_prob=50

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels electric.")
	mutation=NO_SHOCK
	activation_prob=50

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("You feel small.")
	mutation=SMALLSIZE
	activation_prob=50

	New()
		block=SMALLSIZEBLOCK

	can_activate(mob/M,flags)
		// Can't be big, small and regenerate.
		if( (REGEN in M.mutations)) //#Z2
			return 0
		return ..(M,flags)

	activate(mob/M, connected, flags)
		..(M,connected,flags)
		M.pass_flags |= 1
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.ventcrawler = 1
			to_chat(H, "\blue \b Ventcrawling allowed")

		var/matrix/Mx = matrix()
		Mx.Scale(0.8) //Makes our hulk to be bigger than any normal human.
		Mx.Translate(0,-2)
		M.transform = Mx

	deactivate(mob/M, connected, flags)
		..(M,connected,flags)
		M.pass_flags &= ~1
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.ventcrawler = 0

		var/matrix/Mx = matrix()
		Mx.Scale(1) ////Reset size of our halfling
		Mx.Translate(0,0)
		M.transform = Mx

/datum/dna/gene/basic/hulk
	name                = "Hulk"
	activation_messages = list("Your muscles hurt.")
	mutation            = HULK
	activation_prob     = 15

/datum/dna/gene/basic/hulk/New()
	block=HULKBLOCK

	/*can_activate(mob/M,flags)
		// Can't be big, small and regenerate.
		if( (SMALLSIZE in M.mutations) || (REGEN in M.mutations)) //#Z2
			return 0
		return ..(M,flags)*/

/datum/dna/gene/basic/hulk/activate(mob/M, connected, flags)
	if(!M.mind)
		return
	if(M.mind.hulkizing)
		return
	M.mind.hulkizing = 1

	..(M,connected,flags)

	addtimer(src, "mutate_user", rand(600, 900), TRUE, M)

/datum/dna/gene/basic/hulk/proc/mutate_user(mob/M)
	if(!M)
		return
	if(!(HULK in M.mutations)) //If user cleans hulk mutation before timer runs out, then there is no mutation.
		M.mind.hulkizing = 0   //We don't want to waste user's try, so user can mutate once later.
		return

	message_admins("[M.name] ([M.ckey]) is a <span class='warning'>Monster</span> (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")
	if(istype(M.loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/DSN = M.loc
		DSN.occupant = null
		DSN.icon_state = "scanner_0"

	var/mob/living/simple_animal/hulk/Monster
	if(istype(M, /mob/living/carbon/human/unathi))
		Monster = new /mob/living/simple_animal/hulk/unathi(get_turf(M))
	else
		if(prob(19))
			Monster = new /mob/living/simple_animal/hulk/unathi(get_turf(M))
		else
			Monster = new /mob/living/simple_animal/hulk/human(get_turf(M))

	var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.set_up(10, 0, M.loc)
	smoke.start()
	playsound(M.loc, 'sound/effects/bamf.ogg', 50, 2)

	Monster.original_body = M
	M.forceMove(Monster)
	M.mind.transfer_to(Monster)

	Monster.attack_log = M.attack_log
	Monster.attack_log += "\[[time_stamp()]\]<font color='blue'> ======MONSTER LIFE======</font>"
	Monster.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
	return

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

	OnDrawUnderlays(mob/M,g,fat)
		return "telekinesishead[fat]_s"
