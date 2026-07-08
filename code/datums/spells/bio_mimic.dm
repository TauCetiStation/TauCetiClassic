/datum/action/innate/bio_mimic
	name = "Voice Mimic"
	action_type = AB_INNATE
	button_icon = 'icons/hud/actions.dmi'
	background_icon_state = "bg_default"
	button_icon_state = "shapeshift"
	var/range = 7

/datum/action/innate/bio_mimic/Activate()
	if(!owner)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/caster = owner
	var/list/targets = list()
	for(var/mob/living/carbon/human/M in oview(range, caster))
		targets += M

	if(!targets.len)
		to_chat(caster, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/human/target = input(caster, "Choose a target to mimic.", "Voice Mimic") as null|anything in targets
	if(!target)
		return
	if(!(target in oview(range, caster)))
		to_chat(caster, "<span class='notice'>They are too far away!</span>")
		return

	caster.special_voice = target.real_name
	caster.visible_message("<span class='notice'>[caster]'s voice shifts subtly.</span>",
		"<span class='notice'>You mimic [target.real_name]'s voice!</span>")

	Remove(caster)

	if(caster.bio_mimic_voice_timer)
		deltimer(caster.bio_mimic_voice_timer)
	caster.bio_mimic_voice_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(clear_bio_mimic_voice), WEAKREF(caster)), 30 SECONDS)

/proc/clear_bio_mimic_voice(datum/weakref/ref)
	var/mob/living/carbon/human/caster = ref.resolve()
	if(!caster)
		return
	caster.special_voice = ""
	caster.bio_mimic_voice_timer = null
	to_chat(caster, "<span class='notice'>Your voice returns to normal.</span>")

/proc/try_bio_mimic_transform(mob/living/carbon/human/H)
	var/list/targets = list()
	for(var/mob/living/carbon/human/M in oview(7, H))
		if(M != H)
			targets += M
	if(!targets.len)
		return
	var/mob/living/carbon/human/target = pick(targets)
	H.special_voice = ""
	H.visible_message("<span class='warning'>[H]'s appearance shimmers and shifts!</span>",
		"<span class='warning'>Your appearance shifts to permanently match [target.real_name]!</span>")
	H.real_name = target.real_name
	H.name = target.real_name
	H.dna.real_name = target.real_name
	H.dna.uni_identity = target.dna.uni_identity
	H.dna.struc_enzymes = target.dna.struc_enzymes
	H.UpdateAppearance(target.dna.uni_identity)
	domutcheck(H, null)
	H.adjustCloneLoss(5 * H.bodyparts.len)
	H.bio_transform_doses = 0
	H.bio_mimic_spell_given = FALSE
	for(var/datum/action/innate/bio_mimic/A in H.actions)
		A.Remove(H)
