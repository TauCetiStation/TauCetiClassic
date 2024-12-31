
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
	var/list/eye_colour = list(0,0,0)
	var/darksight = 2
	var/nighteyes = FALSE

/obj/item/organ/internal/eyes/proc/update_colour()
	if(!owner)
		return
	eye_colour = list(
		owner.r_eyes ? owner.r_eyes : 0,
		owner.g_eyes ? owner.g_eyes : 0,
		owner.b_eyes ? owner.b_eyes : 0
		)

/obj/item/organ/internal/eyes/insert_organ(mob/living/carbon/human/M)
// Apply our eye colour to the target.
	if(istype(M) && eye_colour)
		var/mob/living/carbon/human/eyes = M
		eyes.r_eyes = eye_colour[1]
		eyes.g_eyes = eye_colour[2]
		eyes.b_eyes = eye_colour[3]
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

/obj/item/organ/internal/eyes/zombie_vision
	name = "zombie eyes"
	desc = "A dead set of eyes that don't blink"
	darksight = 8
	nighteyes = TRUE

/obj/item/organ/internal/eyes/night_vision
	name = "strange eye"
	desc = "Ф pair of eyes that copy the abilities of the Tajaran."
	darksight = 8
	nighteyes = TRUE

/obj/item/organ/internal/eyes/dark_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	darksight = 8

/obj/item/organ/internal/eyes/cybernetic
	name = "cybernetic eyes"
	icon_state = "eyes-prosthetic"
	desc = "An electronic device designed to mimic the functions of a pair of human eyes. It has no benefits over organic eyes, but is easy to produce."
	item_state_world = "eyes-prosthetic_world"
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	compability = list(VOX, HUMAN, PLUVIAN, UNATHI, TAJARAN, SKRELL)

/obj/item/organ/internal/eyes/ipc
	name = "cameras"
	cases = list("камеры", "камер", "камерам", "камеры", "камерами", "камерах")
	requires_robotic_bodypart = TRUE
	status = ORGAN_ROBOT
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	item_state_world = "camera"


/obj/item/organ/internal/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(is_bruised())
		owner.blurEyes(20)
	if(is_broken())
		owner.eye_blind = 20
