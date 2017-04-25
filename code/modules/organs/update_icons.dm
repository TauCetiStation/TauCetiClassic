/obj/item/bodypart/proc/update_limb()
	if(!species.icobase)
		return

	var/list/remove_overlays = list()

	if(!owner)
		if(lmb_overlay)
			remove_overlays += lmb_overlay
		if(dmg_overlay)
			remove_overlays += dmg_overlay
		if(srg_overlay)
			remove_overlays += srg_overlay

	if(remove_overlays.len)
		overlays -= remove_overlays

	if(owner)
		var/has_gender = owner.species.flags[HAS_GENDERED_ICONS]
		var/has_color = TRUE
		var/husk = (owner.disabilities & HUSK)

		lmb_overlay = image(layer = -BODYPARTS_LAYER + limb_layer_priority)

		if(owner.species.flags[IS_SYNTHETIC]) // TODO: bodyparts for this and ROBOT.
			lmb_overlay.icon = owner.species.icobase
			//icon = owner.species.icobase
			has_gender = FALSE
			has_color = FALSE
		else if(status & ORGAN_ROBOT)
			lmb_overlay.icon = 'icons/mob/human_races/robotic.dmi'
			//icon = 'icons/mob/human_races/robotic.dmi'
			has_gender = FALSE
			has_color = FALSE
		else if(husk) // TODO implement this for exact bodyparts.
			overlays.Cut()
			lmb_overlay.icon = icon = 'icons/mob/human_races/bad_limb.dmi'
			//icon = 'icons/mob/human_races/bad_limb.dmi'
			lmb_overlay.icon_state = body_zone + "_husk"
			//icon_state = body_zone + "_husk"
			has_gender = FALSE
			has_color = FALSE
			return
		else if(status & ORGAN_MUTATED)
			lmb_overlay.icon = owner.species.deform
			//icon = owner.species.deform
		else
			lmb_overlay.icon = owner.species.icobase
			//icon = owner.species.icobase

		if(has_gender)
			var/g = (owner.gender == FEMALE ? "_f" : "_m")
			switch(body_zone)
				if(BP_CHEST)
					lmb_overlay.icon_state = body_zone + g
					//icon_state = body_zone + g
				if(BP_GROIN, BP_HEAD)
					lmb_overlay.icon_state = body_zone + g
					//icon_state = body_zone + g
				else
					lmb_overlay.icon_state = body_zone
					//icon_state = body_zone
			if(owner.species.name == S_HUMAN && (owner.disabilities & FAT))
				lmb_overlay.icon_state += "_fat"
				//icon_state += "_fat"
		else
			lmb_overlay.icon_state = body_zone
			//icon_state = body_zone

		if(has_color)
			if(status & ORGAN_DEAD)
				lmb_overlay.color = list(0.03,0,0, 0,0.2,0, 0,0,0, 0.3,0.3,0.3)
			else if(HULK in owner.mutations)
				lmb_overlay.color = list(0.18,0,0, 0,0.87,0, 0,0,0.15, 0,0,0)
			else
				if(owner.species.flags[HAS_SKIN_TONE])
					lmb_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.s_tone/255,owner.s_tone/255,owner.s_tone/255)
				if(owner.species.flags[HAS_SKIN_COLOR])
					lmb_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.r_skin/255,owner.g_skin/255,owner.b_skin/255)
		//else
		//	color = null

	// Damage overlays
	if( (status & ORGAN_ROBOT) || damage_state == "00")
		dmg_overlay = null
	else
		dmg_overlay = image(icon = species.damage_overlays, icon_state = "[body_zone]_[damage_state]", layer = -DAMAGE_LAYER + limb_layer_priority)
		dmg_overlay.color = species.blood_color

	if(open)
		srg_overlay = image(icon = 'icons/mob/surgery.dmi', icon_state = "[body_zone][round(open)]", layer = -SURGERY_LAYER)
	else
		srg_overlay = null

	if(!owner)
		if(lmb_overlay)
			overlays += lmb_overlay
		if(dmg_overlay)
			overlays += dmg_overlay
		if(srg_overlay)
			overlays += srg_overlay

/obj/item/bodypart/head/update_limb()
	..()

	if(!eyes_overlay)
		return

	overlays -= eyes_overlay

	var/obj/item/organ/eyes/IO = get_organ(BP_EYES)
	if(!IO)
		eyes_overlay.icon_state = "eyes_missing"
	else
		eyes_overlay.icon_state = species.eyes_icon
		if(owner)
			eyes_overlay.color = rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)

	if(!owner)
		overlays += eyes_overlay

/obj/item/bodypart/proc/get_icon()
	var/list/standing = list()
	//standing += image(icon = src, icon_state = icon_state, layer = -BODYPARTS_LAYER + limb_layer_priority)
	if(lmb_overlay)
		standing += lmb_overlay
	if(dmg_overlay)
		standing += dmg_overlay
	if(srg_overlay)
		standing += srg_overlay
	return standing

/obj/item/bodypart/head/get_icon()
	. = ..()
	if(eyes_overlay)
		. += eyes_overlay

/*
	For test purpose
*/
/*
/mob/living/carbon/verb/reg_icons(mob/M as mob in view())
	set name = "Regenerate Target Icons"
	set category = "TEST TEST"

	M.regenerate_icons()
*/
