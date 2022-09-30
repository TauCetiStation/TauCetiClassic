///////////////////////////////////
// POWERS
///////////////////////////////////
//#Z2
//Added activation chance for every power

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("Вы не чувствуете необходимости дышать.")
	mutation=NO_BREATH
	activation_prob=50

/datum/dna/gene/basic/nobreath/New()
	block=NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_messages=list("Ваше сознание расширяется.")
	mutation=REMOTE_VIEW
	activation_prob=50

/datum/dna/gene/basic/remoteview/New()
	block=REMOTEVIEWBLOCK

/datum/dna/gene/basic/remoteview/activate(mob/M, connected, flags)
	..(M,connected,flags)
	M.verbs += /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/remoteview/deactivate(mob/M, connected, flags)
	..(M,connected,flags)
	M.verbs -= /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("Вы чувствуете себя намного лучше.")
	mutation=REGEN
	activation_prob=50

/datum/dna/gene/basic/regenerate/New()
	block=REGENERATEBLOCK

/datum/dna/gene/basic/regenerate/can_activate(mob/M,flags)
	if((SMALLSIZE in M.mutations))
		return FALSE
	return ..(M,flags)

/datum/dna/gene/basic/regenerate/OnMobLife(mob/living/carbon/human/M)
	if(!istype(M)) return
	var/obj/item/organ/external/head/H = M.bodyparts_by_name[BP_HEAD]

	if(H.disfigured)
		H.disfigured = FALSE

	if(HUSK in M.mutations)
		M.mutations.Remove(HUSK)
		M.update_mutations()
		M.UpdateAppearance()

	var/obj/item/organ/external/chest/BP = M.bodyparts_by_name[BP_CHEST]
	for(var/obj/item/organ/internal/IO in BP.bodypart_organs)
		if(IO.damage > 0)
			IO.damage -= 0.25

	if(M.getBrainLoss() > 24)
		if(M.getBrainLoss() < 76) M.adjustBrainLoss(-0.25)
	else
		if(prob(20))
			if(M.getOxyLoss() < 126) M.adjustOxyLoss(-1)
			if(M.getBruteLoss() < 126) M.heal_bodypart_damage(1,0)
			if(M.getFireLoss() < 126) M.heal_bodypart_damage(0,1)
			if(M.getToxLoss() < 126) M.adjustToxLoss(-1)
			if(M.getCloneLoss() < 126) M.adjustCloneLoss(-1)
		if(M.getBrainLoss()) M.adjustBrainLoss(-0.10)

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Ваши мышцы ног пульсируют.")
	mutation=RUN
	activation_prob=50

/datum/dna/gene/basic/increaserun/New()
	block=INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_messages=list("Ваш голос может проникнуть в другие умы.")
	mutation=REMOTE_TALK
	activation_prob=50

/datum/dna/gene/basic/remotetalk/New()
	block=REMOTETALKBLOCK

/datum/dna/gene/basic/remotetalk/activate(mob/M, connected, flags)
	..(M,connected,flags)
	M.verbs += /mob/living/carbon/human/proc/remotesay
	M.verbs += /mob/proc/toggle_telepathy_hear
	M.verbs += /mob/proc/telepathy_say

/datum/dna/gene/basic/remotetalk/deactivate(mob/M, connected, flags)
	..(M,connected,flags)
	M.verbs -= /mob/living/carbon/human/proc/remotesay
	M.verbs -= /mob/proc/toggle_telepathy_hear
	M.verbs -= /mob/proc/telepathy_say

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Ваша кожа ощущается странно.")
	mutation=MORPH
	activation_prob=50

/datum/dna/gene/basic/morph/New()
	block=MORPHBLOCK

/datum/dna/gene/basic/morph/activate(mob/M)
	..(M)
	M.verbs += /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/morph/deactivate(mob/M)
	..(M)
	M.verbs -= /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Ваша кожа холодная на ощупь.")
	mutation=RESIST_HEAT
	activation_prob=30

/datum/dna/gene/basic/heat_resist/New()
	block=COLDBLOCK

/datum/dna/gene/basic/heat_resist/can_activate(mob/M,flags)
	if(COLD_RESISTANCE in M.mutations)
		return FALSE
	return ..(M,flags)

/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(mob/M,g,fat)
	return "fire[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Ваше тело наполнено теплом.")
	mutation=COLD_RESISTANCE
	activation_prob=30

/datum/dna/gene/basic/cold_resist/New()
	block=FIREBLOCK

/datum/dna/gene/basic/cold_resist/can_activate(mob/M,flags)
	if(RESIST_HEAT in M.mutations)
		return FALSE
	return ..(M,flags)

/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(mob/M,g,fat)
	return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Вы чувствуете, что ваши пальцы онемели.")
	mutation=FINGERPRINTS
	activation_prob=50

/datum/dna/gene/basic/noprints/New()
	block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Ваша кожа словно наэлектризована.")
	mutation=NO_SHOCK
	activation_prob=50

/datum/dna/gene/basic/noshock/New()
	block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Вы чувствуете, что стали меньше.")
	mutation=SMALLSIZE
	activation_prob=50

/datum/dna/gene/basic/midget/New()
	block=SMALLSIZEBLOCK

/datum/dna/gene/basic/midget/can_activate(mob/M,flags)
	// Can't be big, small and regenerate.
	if( (REGEN in M.mutations)) //#Z2
		return FALSE
	return ..(M,flags)

/datum/dna/gene/basic/midget/activate(mob/living/M, connected, flags)
	..(M,connected,flags)
	M.pass_flags |= 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.ventcrawler = 1
		H.update_size_class()
		to_chat(H, "<span class='notice'><b>Вы можете лазить по вентиляции</b></span>")
		H.regenerate_icons()

/datum/dna/gene/basic/midget/deactivate(mob/living/M, connected, flags)
	..(M,connected,flags)
	M.pass_flags &= ~1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.ventcrawler = 0
		H.update_size_class()
		H.regenerate_icons()

/datum/dna/gene/basic/hulk
	name                = "Hulk"
	activation_messages = list("Ваши мышцы болят и ощущаются странно..")
	mutation            = HULK
	activation_prob     = 20

/datum/dna/gene/basic/hulk/New()
	block=HULKBLOCK

/*/datum/dna/gene/basic/hulk/can_activate(mob/M,flags)
	// Can't be big, small and regenerate.
	if( (SMALLSIZE in M.mutations) || (REGEN in M.mutations)) //#Z2
		return FALSE
	return ..(M,flags)*/

/datum/dna/gene/basic/hulk/activate(mob/living/carbon/human/M, connected, flags)
	if(!M.mind)
		return
	if(M.mind.hulkizing)
		return

	..(M,connected,flags)

/mob/living/carbon/human/proc/try_mutate_to_hulk()
	if(!mind)
		return
	if(species.flags[NO_PAIN]) // hulk mechanic is revolving around pain, and also all the species that don't have hulk form have this flag.
		to_chat(src, "<span class='warning'>Ваш ген халка рецессивный!</span>")
		return
	if(mind.hulkizing)
		to_chat(src, "<span class='warning'>Вы больше не чувствуете способность к трансформации!</span>") // Hulk transformation at most 1 time.
		return

	mind.hulkizing = TRUE
	message_admins("[key_name(src)] is a <span class='warning'>Monster</span> [ADMIN_JMP(src)]")
	to_chat(src, "<span class='bold notice'>Вы чувствуете реальную МОЩЬ.</span>")
	if(istype(loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/DSN = loc
		DSN.occupant = null
		DSN.icon_state = "scanner_0"
	var/mob/living/simple_animal/hulk/Monster
	if(CLUMSY in mutations)
		Monster = new /mob/living/simple_animal/hulk/Clowan(get_turf(src))
	else if(get_species() == UNATHI || prob(23))
		Monster = new /mob/living/simple_animal/hulk/unathi(get_turf(src))
	else
		Monster = new /mob/living/simple_animal/hulk/human(get_turf(src))

	var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.set_up(10, 0, loc)
	smoke.start()
	playsound(src, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)

	Monster.original_body = src
	forceMove(Monster)

	client?.show_metahelp_greeting("hulk")
	mind.transfer_to(Monster)

	Monster.attack_log = attack_log
	Monster.attack_log += "\[[time_stamp()]\]<font color='blue'> ======MONSTER LIFE======</font>"
	Monster.say(pick("ГРААААААААГХ!", "ХМММММММГХ!", "ГВАААААРРРРРГХ!", "РРРРРААААА!", "ХАЛК КРУШИТЬ!" ))

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("Стены внезапно исчезли.")
	mutation=XRAY
	activation_prob=30

/datum/dna/gene/basic/xray/New()
	block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("Вы чувствуете себя намного умнее.")
	mutation=TK
	activation_prob=15

/datum/dna/gene/basic/tk/New()
	block=TELEBLOCK

/datum/dna/gene/basic/tk/OnDrawUnderlays(mob/M,g,fat)
	return "telekinesishead[fat]_s"
