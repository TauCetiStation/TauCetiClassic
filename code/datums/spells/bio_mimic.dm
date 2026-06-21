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
	var/mob/living/carbon/human/caster = owner
	if(!ishuman(caster))
		return
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

	caster.bio_mimic_uses++
	caster.bio_mimic_last_target = target

	if(caster.bio_mimic_uses >= 4)
		caster.special_voice = ""
		caster.visible_message("<span class='warning'>[caster]'s appearance shimmers and shifts!</span>",
			"<span class='warning'>Your appearance shifts to permanently match [target.real_name]!</span>")
		caster.real_name = target.real_name
		caster.name = target.real_name
		caster.dna.real_name = target.real_name
		caster.dna.uni_identity = target.dna.uni_identity
		caster.dna.struc_enzymes = target.dna.struc_enzymes
		caster.UpdateAppearance(target.dna.uni_identity)
		domutcheck(caster, null)
		caster.adjustCloneLoss(5 * caster.bodyparts.len)
		caster.bio_mimic_uses = 0
		caster.bio_mimic_last_target = null
		Remove(caster)
		return

	caster.special_voice = target.real_name
	caster.visible_message("<span class='notice'>[caster]'s voice shifts subtly.</span>",
		"<span class='notice'>You mimic [target.real_name]'s voice!</span>")
	to_chat(caster, "<span class='notice'>Use [4 - caster.bio_mimic_uses] more times to permanently mimic appearance.</span>")

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
