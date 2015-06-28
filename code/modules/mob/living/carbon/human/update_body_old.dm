//FORCE MOB SPRITE
/mob/living/carbon/human/proc/update_body_f(var/update_icons=1)

	var/husk_color_mod = rgb(96,88,80)
	var/hulk_color_mod = rgb(48,224,40)
	var/necrosis_color_mod = rgb(10,50,0)

	var/husk = (HUSK in src.mutations)
	var/fat = (FAT in src.mutations)
	var/hulk = (HULK in src.mutations)
	var/skeleton = (SKELETON in src.mutations)

	var/g = (gender == FEMALE ? "f" : "m")
	var/has_head = 0

	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.

	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		qdel(stand_icon)

	stand_icon = new(species.icon_template ? species.icon_template : 'icons/mob/human.dmi',"blank")

	var/icon_key = "[species.race_key][g][s_tone]"
	for(var/datum/organ/external/part in organs)

		if(istype(part,/datum/organ/external/head) && !(part.status & ORGAN_DESTROYED))
			has_head = 1

		if(part.status & ORGAN_DESTROYED)
			icon_key = "[icon_key]0"
		else if(part.status & ORGAN_ROBOT)
			icon_key = "[icon_key]2"
		else if(part.status & ORGAN_DEAD) //Do we even have necrosis in our current code? ~Z
			icon_key = "[icon_key]3"
		else
			icon_key = "[icon_key]1"

	icon_key = "[icon_key][husk ? 1 : 0][fat ? 1 : 0][hulk ? 1 : 0][skeleton ? 1 : 0][s_tone]"

	var/icon/base_icon
	//if(human_icon_cache[icon_key])
		//Icon is cached, use existing icon.
		//base_icon = human_icon_cache[icon_key]

		//log_debug("Retrieved cached mob icon ([icon_key] \icon[human_icon_cache[icon_key]]) for [src].")

	//else

	//BEGIN CACHED ICON GENERATION.

		//Icon is not cached, generate and store it.
		//Robotic limbs are handled in get_icon() so all we worry about are missing or dead limbs.
		//No icon stored, so we need to start with a basic one.
	var/datum/organ/external/chest = get_organ("chest")
	base_icon = chest.get_icon(g)

	for(var/datum/organ/external/part in organs)

		var/icon/temp //Hold the bodypart icon for processing.

		if(part.status & ORGAN_DESTROYED)
			continue

		if (istype(part, /datum/organ/external/groin) || istype(part, /datum/organ/external/head))
			temp = part.get_icon(g)
		else
			temp = part.get_icon()

		if(part.status & ORGAN_DEAD)
			temp.ColorTone(necrosis_color_mod)
			temp.SetIntensity(0.7)

		//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
		//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
		if(part.icon_position&(LEFT|RIGHT))

			var/icon/temp2 = new('icons/mob/human.dmi',"blank")

			temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
			temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)

			if(!(part.icon_position & LEFT))
				temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

			if(!(part.icon_position & RIGHT))
				temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

			base_icon.Blend(temp2, ICON_OVERLAY)

			if(part.icon_position & LEFT)
				temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

			if(part.icon_position & RIGHT)
				temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

			base_icon.Blend(temp2, ICON_UNDERLAY)

		else

			base_icon.Blend(temp, ICON_OVERLAY)

	if(!skeleton)
		if(husk)
			base_icon.ColorTone(husk_color_mod)
		else if(hulk)
			var/list/tone = ReadRGB(hulk_color_mod)
			base_icon.MapColors(rgb(tone[1],0,0),rgb(0,tone[2],0),rgb(0,0,tone[3]))

	//Handle husk overlay.
	if(husk)
		var/icon/mask = new(base_icon)
		var/icon/husk_over = new(race_icon,"overlay_husk")
		mask.MapColors(0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,1, 0,0,0,0)
		husk_over.Blend(mask, ICON_ADD)
		base_icon.Blend(husk_over, ICON_OVERLAY)


	//Skin tone.
	if(!husk && !hulk)
		if(species.flags & HAS_SKIN_TONE)
			if(s_tone >= 0)
				base_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				base_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		//human_icon_cache[icon_key] = base_icon

		//log_debug("Generated new cached mob icon ([icon_key] \icon[human_icon_cache[icon_key]]) for [src]. [human_icon_cache.len] cached mob icons.")

	//END CACHED ICON GENERATION.

	stand_icon.Blend(base_icon,ICON_OVERLAY)

	//Skin colour. Not in cache because highly variable (and relatively benign).
	if (species.flags & HAS_SKIN_COLOR)
		stand_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

	if(has_head)
		//Eyes
		if(!skeleton)
			var/icon/eyes = new/icon('icons/mob/human_face.dmi', species.eyes)
			eyes.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
			stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(lip_style && (species && species.flags & HAS_LIPS))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "lips_[lip_style]_s"), ICON_OVERLAY)

	//Underwear
	if(underwear >0 && underwear < 12 && species.flags & HAS_UNDERWEAR)
		if(!fat && !skeleton)
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

	if(undershirt>0 && undershirt < 5 && species.flags & HAS_UNDERWEAR)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "undershirt[undershirt]_s"), ICON_OVERLAY)

	if(update_icons)
		update_icons()

	//tail
	update_tail_showing(0)