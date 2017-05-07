/obj/item/bodypart/proc/update_limb()
	if(!species.icobase && species.name != S_IPC)
		return

	var/list/remove_overlays = list()

	if(!owner)
		if(lmb_overlay)
			remove_overlays += lmb_overlay
		if(dmg_overlay)
			remove_overlays += dmg_overlay
		if(srg_overlay)
			remove_overlays += srg_overlay
		if(bnd_overlay)
			remove_overlays += bnd_overlay

	if(remove_overlays.len)
		overlays -= remove_overlays

	if(species.name == S_IPC)
		lmb_overlay = image(layer = -BODYPARTS_LAYER + limb_layer_priority)
		if(robot_has_skin)
			lmb_overlay.icon = 'icons/mob/human_races/r_human.dmi'
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
		else
			lmb_overlay.icon = robot_manufacturer_icon
			lmb_overlay.icon_state = body_zone
	else
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
		dmg_overlay = image(icon = species.damage_overlays, icon_state = "[body_zone]_[damage_state]", layer = -DAMAGE_LAYER)
		dmg_overlay.color = species.blood_color

	if(open)
		srg_overlay = image(icon = 'icons/mob/surgery.dmi', icon_state = "[body_zone][round(open)]", layer = -SURGERY_LAYER)
	else
		srg_overlay = null

	if(wounds.len)
		var/found_bandaged_wound = FALSE
		for(var/datum/wound/W in wounds)
			if(W.bandaged)
				found_bandaged_wound = TRUE
				break
		if(found_bandaged_wound)
			if(!bnd_overlay)
				bnd_overlay = image(icon = 'icons/mob/bandages.dmi', icon_state = "[body_zone]", layer = -BANDAGE_LAYER)
		else
			bnd_overlay = null
	else
		bnd_overlay = null

	if(!owner)
		if(lmb_overlay)
			overlays += lmb_overlay
		if(dmg_overlay)
			overlays += dmg_overlay
		if(srg_overlay)
			overlays += srg_overlay
		if(bnd_overlay)
			overlays += bnd_overlay

/obj/item/bodypart/head/update_limb()
	..()

	var/list/remove_overlays = list()

	if(!owner)
		if(h_style_overlay)
			remove_overlays += h_style_overlay
		if(f_style_overlay)
			remove_overlays += f_style_overlay
		if(eyes_overlay)
			remove_overlays += eyes_overlay
		if(ears_overlay)
			remove_overlays += ears_overlay
		if(lips_overlay)
			remove_overlays += lips_overlay

	if(remove_overlays.len)
		overlays -= remove_overlays


	var/list/standing = list()

	if(owner)
		if(!(owner.disabilities & HUSK))

			if(owner.h_style || owner.f_style)
				var/item_blocks_hair = FALSE
				for(var/slot in list(slot_head, slot_wear_mask, slot_wear_suit))
					var/obj/item/I = item_in_slot[slot]
					if(I && (I.flags & BLOCKHAIR))
						item_blocks_hair = TRUE
						break

				if(!item_blocks_hair)
					if(owner.h_style)
						if(!h_style_overlay)
							h_style_overlay = image(layer = -HAIR_LAYER)
						var/datum/sprite_accessory/hair_style = hair_styles_list[owner.h_style]
						if(hair_style && hair_style.species_allowed && (species.name in hair_style.species_allowed))
							h_style_overlay.icon = hair_style.icon
							h_style_overlay.icon_state = hair_style.icon_state + "_s"
							if(hair_style.do_colouration)
								h_style_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.r_hair/255, owner.g_hair/255, owner.b_hair/255)
							standing += h_style_overlay

					if(owner.f_style)
						if(!f_style_overlay)
							f_style_overlay = image(layer = -HAIR_LAYER)
						var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[owner.f_style]
						if(facial_hair_style && facial_hair_style.species_allowed && (species.name in facial_hair_style.species_allowed))
							f_style_overlay.icon = facial_hair_style.icon
							f_style_overlay.icon_state = facial_hair_style.icon_state + "_s"
							if(facial_hair_style.do_colouration)
								f_style_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.r_facial/255, owner.g_facial/255, owner.b_facial/255)
							standing += f_style_overlay
				else
					h_style_overlay = null
					f_style_overlay = null
			else
				h_style_overlay = null
				f_style_overlay = null


			if(species.flags[HAS_LIPS])
				if(owner.lip_style)
					if(!lips_overlay)
						lips_overlay = image(icon = 'icons/mob/human_face.dmi', layer = -BODY_LAYER)
					lips_overlay.icon_state = "lips_[owner.lip_style]_s"
					lips_overlay.color = owner.lip_color
					standing += lips_overlay
				else
					lips_overlay = null

	if(eyes_overlay && species.eyes_icon)
		var/obj/item/organ/eyes/IO = get_organ(BP_EYES)
		if(!IO)
			eyes_overlay.icon_state = "eyes_missing"
		else
			eyes_overlay.icon_state = species.eyes_icon
			if(owner)
				eyes_overlay.color = rgb(owner.r_eyes, owner.g_eyes, owner.b_eyes)

		standing += eyes_overlay

	if(ears)
		if(!ears_overlay)
			ears_overlay = image(icon = 'icons/effects/species.dmi', icon_state = "[ears.icon_state]", layer = -BODY_LAYER + 0.1)

		if(owner)
			ears_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.r_skin/255, owner.g_skin/255, owner.b_skin/255)
			ears.color = ears_overlay.color

		standing += ears_overlay

	if(!owner && standing.len)
		overlays += standing

/obj/item/bodypart/groin/update_limb()
	..()

	overlays -= tail_overlay

	if(!tail)
		return

	if(!tail_overlay)
		tail_overlay = image(icon = 'icons/effects/species.dmi', icon_state = "[tail.icon_state]", layer = -TAIL_LAYER)

	if(owner)
		tail_overlay.color = list(1,0,0, 0,1,0, 0,0,1, owner.r_skin/255, owner.g_skin/255, owner.b_skin/255)
		tail.color = tail_overlay.color
	else
		overlays += tail_overlay

/obj/item/bodypart/proc/get_icon()
	var/list/standing = list()
	//standing += image(icon = src, icon_state = icon_state, layer = -BODYPARTS_LAYER + limb_layer_priority)
	if(lmb_overlay)
		standing += lmb_overlay
	if(dmg_overlay)
		standing += dmg_overlay
	if(srg_overlay)
		standing += srg_overlay
	if(bnd_overlay)
		standing += bnd_overlay
	return standing

/obj/item/bodypart/head/get_icon()
	. = ..()
	if(h_style_overlay)
		. += h_style_overlay
	if(f_style_overlay)
		. += f_style_overlay
	if(lips_overlay)
		. += lips_overlay
	if(species.eyes_icon && eyes_overlay)
		. += eyes_overlay
	if(ears && ears_overlay)
		. += ears_overlay

/obj/item/bodypart/groin/get_icon()
	. = ..()
	if(tail && tail_overlay)
		var/obj/item/clothing/S = owner.get_equipped_item(slot_wear_suit)
		if(!S || !(S.flags_inv & HIDETAIL) && !istype(S, /obj/item/clothing/suit/space))
			. += tail_overlay

var/list/cyberlimb_manufacturers = list("Bishop", "Hephaestus Industries", "Morpheus", "NanoTrasen", "Ward-Takahashi", "Xion")
/mob/living/carbon/human/proc/set_manufacturer_icons(man_name, alt_head, has_skin)
	for(var/obj/item/bodypart/BP in bodyparts)
		switch(man_name)
			if("Bishop")
				if(BP.body_zone == BP_HEAD && alt_head != "Standard")
					if(alt_head == "Monitor")
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
						h_style = "Monitor"
					else
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt.dmi'
				else
					BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
			if("Hephaestus Industries")
				if(BP.body_zone == BP_HEAD && alt_head != "Standard")
					if(alt_head == "Monitor")
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
						h_style = "Monitor"
					else
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_alt.dmi'
				else
					BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
			if("Morpheus")
				if(BP.body_zone == BP_HEAD)
					if(alt_head == "Alt")
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt.dmi'
					else
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
						h_style = "Monitor"
				else
					BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
			if("NanoTrasen")
				BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
			if("Ward-Takahashi")
				if(BP.body_zone == BP_HEAD && alt_head != "Standard")
					if(alt_head == "Monitor")
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
						h_style = "Monitor"
					else
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt.dmi'
				else
					BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
			if("Xion")
				if(BP.body_zone == BP_HEAD && alt_head != "Standard")
					if(alt_head == "Monitor")
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
						h_style = "Monitor"
					else
						BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt.dmi'
				else
					BP.robot_manufacturer_icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
			else
				CRASH("something tried to set for [src] non existent cyberlimb manufacturer: [man_name]")

		BP.robot_has_skin = has_skin
		BP.robot_manufacturer_name = man_name

/*
	For test purpose
*/
/*
/mob/living/carbon/verb/reg_icons(mob/M as mob in view())
	set name = "Regenerate Target Icons"
	set category = "TEST TEST"

	M.regenerate_icons()
*/
