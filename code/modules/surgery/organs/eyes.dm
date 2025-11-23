/obj/item/organ/internal/eyes
	name = "eyes"
	icon_state = "eyes"
	item_state_world = "eyes_world"
	cases = list("глаза", "глаз", "глазам", "глаза", "глазами", "глазах")
	organ_tag = O_EYES
	parent_bodypart = BP_HEAD
	max_damage = 45
	min_bruised_damage = 15
	min_broken_damage = 35
	cybernetic_version = /obj/item/organ/internal/eyes/cybernetic
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0
	var/darksight = 2
	var/nighteyes = FALSE

/obj/item/organ/internal/eyes/proc/update_colour()
	if(!owner)
		return
	var/obj/item/organ/external/head/head = owner.bodyparts_by_name[BP_HEAD]
	r_eyes = head.r_eyes
	g_eyes = head.g_eyes
	b_eyes = head.b_eyes


/obj/item/organ/internal/eyes/insert_organ(mob/living/carbon/human/M)
	..()

	if(nighteyes)
		ADD_TRAIT(owner, TRAIT_NIGHT_EYES, GENERIC_TRAIT)

// Apply our eye colour to the target.
	if(istype(M))
		var/mob/living/carbon/human/eyes = M
		var/obj/item/organ/external/head/head = M.bodyparts_by_name[BP_HEAD]
		if(head)
			head.r_eyes = r_eyes
			head.g_eyes = g_eyes
			head.b_eyes = b_eyes
			eyes.update_eyes()

/obj/item/organ/internal/eyes/remove(mob/living/carbon/human/M)

	if(nighteyes)
		REMOVE_TRAIT(owner, TRAIT_NIGHT_EYES, GENERIC_TRAIT)

	if(istype(M))
		var/mob/living/carbon/human/eyes = M
		var/obj/item/organ/external/head/head = M.bodyparts_by_name[BP_HEAD]
		if(head)
			head.r_eyes = 0
			head.g_eyes = 0
			head.b_eyes = 0
			eyes.update_eyes()

	..()

/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = organs_by_name[O_EYES]
	if(eyes)
		eyes.update_colour()
		regenerate_icons()

/obj/item/organ/internal/eyes/tajaran
	name = "tajaran eyeballs"
	icon = 'icons/obj/special_organs/tajaran.dmi'
	darksight = 8
	nighteyes = TRUE

/obj/item/organ/internal/eyes/unathi
	name = "unathi eyeballs"
	icon = 'icons/obj/special_organs/unathi.dmi'
	darksight = 3

/obj/item/organ/internal/eyes/vox
	name = "vox eyeballs"
	icon = 'icons/obj/special_organs/vox.dmi'
	sterile = TRUE

/obj/item/organ/internal/eyes/skrell
	name = "skrell eyeballs"
	icon = 'icons/obj/special_organs/skrell.dmi'

/obj/item/organ/internal/eyes/diona
	name = "nutrient sac"
	icon = 'icons/obj/objects.dmi'
	icon_state = "podkid"
	item_state_world = "podkid"
	compability = list(DIONA)
	tough = TRUE

/obj/item/organ/internal/eyes/night_vision
	name = "strange eye"
	desc = "A pair of eyes that copy the abilities of the Tajaran."
	darksight = 8
	nighteyes = TRUE

/obj/item/organ/internal/eyes/dark_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can bit better see in the dark."
	darksight = 8

/obj/item/organ/internal/eyes/cybernetic
	name = "cybernetic eyes"
	icon_state = "eyes-prosthetic"
	desc = "An electronic device designed to mimic the functions of a pair of human eyes. Have a built-in basic night vision device."
	item_state_world = "eyes-prosthetic_world"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	durability = 0.8
	compability = list(VOX, HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)

/obj/item/organ/internal/eyes/cybernetic/insert_organ(mob/living/carbon/human/M)
	..()
	M.AddSpell(new /obj/effect/proc_holder/spell/no_target/cybernetic_nightvision)

/obj/item/organ/internal/eyes/cybernetic/remove(mob/living/carbon/human/M)
	M.RemoveSpell(new /obj/effect/proc_holder/spell/no_target/cybernetic_nightvision)
	if(HAS_TRAIT(M, TRAIT_CYBER_NIGHT_EYES))
		REMOVE_TRAIT(M, TRAIT_CYBER_NIGHT_EYES, GENERIC_TRAIT)
		M.update_body(BP_HEAD)
		M.clear_fullscreen("cy_impaired")
	..()

/obj/item/organ/internal/eyes/ipc
	name = "cameras"
	cases = list("камеры", "камер", "камерам", "камеры", "камерами", "камерах")
	requires_robotic_bodypart = TRUE
	status = ORGAN_ROBOT
	durability = 0.8
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	item_state_world = "camera"


/obj/item/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(owner && is_bruised())
		owner.blurEyes(20)
	if(owner && is_broken())
		owner.eye_blind = 20
