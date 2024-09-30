/obj/item/organ/internal/cyberimp/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	implant_overlay = "eye_implant_overlay"
	slot = "eye_sight"
	organ_tag = O_AUG_EYES
	parent_bodypart = O_EYES

	var/vision_flags = 0
	var/lighting_alpha = null
	var/list/eye_colour = list(0,0,0)
	var/list/old_eye_colour = list(0,0,0)
	var/aug_message = "Your vision is augmented!"

	flash_protection_slots = list(O_AUG_EYES)

/obj/item/organ/internal/cyberimp/eyes/proc/update_colour()
	if(!owner)
		return
	eye_colour = list(
		owner.r_eyes ? owner.r_eyes : 0,
		owner.g_eyes ? owner.g_eyes : 0,
		owner.b_eyes ? owner.b_eyes : 0
		)


/obj/item/organ/internal/cyberimp/eyes/insert_organ(mob/living/carbon/human/M, special = 0)
	..()
	if(ishuman(owner) && eye_colour)
		var/mob/living/carbon/human/HMN = owner
		old_eye_colour[1] = HMN.r_eyes
		old_eye_colour[2] = HMN.g_eyes
		old_eye_colour[2] = HMN.b_eyes

		HMN.r_eyes = eye_colour[1]
		HMN.g_eyes = eye_colour[2]
		HMN.b_eyes = eye_colour[3]
		HMN.update_eyes()

	if(aug_message && !special)
		owner.visible_message ("<span class='notice'>[aug_message]</span>")
	M.sight |= vision_flags

/obj/item/organ/internal/cyberimp/eyes/remove(mob/living/carbon/human/M, special = 0)
	..()
	M.sight ^= vision_flags
	if(ishuman(owner) && eye_colour)
		var/mob/living/carbon/human/HMN = owner
		HMN.r_eyes = old_eye_colour[1]
		HMN.g_eyes = old_eye_colour[2]
		HMN.b_eyes = old_eye_colour[3]
		HMN.update_eyes()

/obj/item/organ/internal/cyberimp/eyes/on_life()
	..()
	var/obj/item/organ/internal/cyberimp/eyes/IO = owner.organs_by_name[O_AUG_EYES]
	owner.sight |= vision_flags
	if(IO.lighting_alpha)
		owner.set_lighting_alpha(min(IO.lighting_alpha))


/obj/item/organ/internal/cyberimp/eyes/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	var/save_sight = owner.sight
	owner.sight &= 0
	owner.sdisabilities |= BLIND
	owner.update_sight()
	owner << "<span class='warning'>Static obfuscates your vision!</span>"
	spawn(60 / severity)
		if(owner)
			owner.sight |= save_sight
			owner.sdisabilities ^= BLIND
			owner.update_sight()


/obj/item/organ/internal/cyberimp/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eye implants will give you X-ray vision. Blinking is futile."
	eye_colour = list(0, 0, 0)
	implant_color = "#000000"
	origin_tech = "materials=6;programming=4;biotech=6;magnets=5"
	vision_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS


/obj/item/organ/internal/cyberimp/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_colour = list(255, 204, 0)
	implant_color = "#ffbf00"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protection = FLASHES_AMPLIFIER
	origin_tech = "materials=6;programming=4;biotech=5;magnets=5;syndicate=4"
	aug_message = "You see prey everywhere you look..."

// HUD implants
/obj/item/organ/internal/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	slot = "eye_hud"
	var/hud_types = 0

/obj/item/organ/internal/cyberimp/eyes/hud/insert_organ(mob/living/carbon/M, special = 0)
	..()
	if(hud_types)
		for(var/hud in hud_types)
			var/datum/atom_hud/H = global.huds[hud]
			H.add_hud_to(M)
			for(var/parasit in M.parasites)
				H.add_hud_to(parasit)

/obj/item/organ/internal/cyberimp/eyes/hud/remove(mob/living/carbon/M, special = 0)
	..()
	if(hud_types)
		for(var/hud in hud_types)
			var/datum/atom_hud/H = global.huds[hud_types]
			H.remove_hud_from(M)
			for(var/parasit in M.parasites)
				H.remove_hud_from(parasit)


/obj/item/organ/internal/cyberimp/eyes/hud/on_life()
	var/obj/item/organ/internal/cyberimp/eyes/hud/huds = owner.organs_by_name[O_AUG_EYES]
	if(huds.hud_types)
		for(var/hud in huds.hud_types)
			var/datum/atom_hud/H = global.huds[hud]
			H.add_hud_to(owner)
			for(var/parasit in owner.parasites)
				H.add_hud_to(parasit)

/obj/item/organ/internal/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	eye_colour = list(0,0,208)
	implant_color = "#00ffff"
	origin_tech = "materials=4;programming=3;biotech=4"
	aug_message = "You suddenly see health bars floating above people's heads..."
	hud_types = list(DATA_HUD_MEDICAL)


/obj/item/organ/internal/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	eye_colour = list(208,0,0)
	implant_color = "#ff0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=1"
	aug_message = "Job indicator icons pop up in your vision. That is not a certified surgeon..."
	hud_types = list(DATA_HUD_SECURITY)

// Welding shield implant
/obj/item/organ/internal/cyberimp/eyes/shield
	name = "welding shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	slot = "eye_shield"
	origin_tech = "materials=4;biotech=3"
	implant_color = "#0000007A"
	flash_protection = FLASHES_FULL_PROTECTION
	// Welding with thermals will still hurt your eyes a bit.

/obj/item/organ/internal/cyberimp/eyes/shield/emp_act(severity)
	return
