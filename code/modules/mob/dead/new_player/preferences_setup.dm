//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/randomize_appearance_for(mob/living/carbon/human/H)
	if(H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE
	s_tone = random_skin_tone()
	h_style = random_hair_style(gender, species, ipc_head)
	grad_style = random_gradient_style()
	f_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_hair_color("gradient")
	randomize_eyes_color()
	randomize_skin_color()
	underwear = rand(0, underwear_t.len)
	undershirt = rand(0, undershirt_t.len)
	undershirt_print = prob(50) ? pick(undershirt_prints_t) : null
	socks = rand(0, socks_t.len)
	backbag = 2
	use_skirt = pick(TRUE, FALSE)
	var/datum/species/S = all_species[species]
	age = rand(S.min_age, S.max_age)
	if(H)
		copy_to(H)


/datum/preferences/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/list/colors_rgb = random_hair_color()

	var/red = colors_rgb[1]
	var/green = colors_rgb[2]
	var/blue = colors_rgb[3]

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue
		if("gradient")
			r_grad = red
			g_grad = green
			b_grad = blue

/datum/preferences/proc/randomize_eyes_color()
	var/list/colors_rgb = random_eye_color()

	r_eyes = colors_rgb[1]
	g_eyes = colors_rgb[2]
	b_eyes = colors_rgb[3]

/datum/preferences/proc/randomize_skin_color()
	var/list/colors_rgb = random_skin_color()

	r_skin = colors_rgb[1]
	g_skin = colors_rgb[2]
	b_skin = colors_rgb[3]

/datum/preferences/proc/update_preview_icon()		//seriously. This is horrendous.
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob

	if(job_preferences["Assistant"] == JP_LOW)
		previewJob = SSjob.GetJob("Assistant")

	if(!previewJob)
		var/highest_pref = 0
		for(var/job in job_preferences)
			if(job_preferences[job] > highest_pref)
				previewJob = SSjob.GetJob(job)
				highest_pref = job_preferences[job]

	if(previewJob)
		if(istype(previewJob, /datum/job/ai))
			parent.show_character_previews(image('icons/mob/AI.dmi', "ai", dir = SOUTH))
			return
		if(istype(previewJob, /datum/job/cyborg))
			parent.show_character_previews(image('icons/mob/robots.dmi', "robot", dir = SOUTH))
			return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES, species)
	copy_to(mannequin)

	var/datum/species/S = all_species[species]
	if(S)
		S.before_job_equip(mannequin, previewJob, TRUE)
	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, GetPlayerAltTitle(previewJob))
	if(S)
		S.after_job_equip(mannequin, previewJob, TRUE)

	// Apply visual quirk effects — only traits that affect sprite/clothing display
	if((QUIRK_FATNESS in all_quirks))
		ADD_TRAIT(mannequin, TRAIT_FAT, INNATE_TRAIT)
		mannequin.update_body()
		mannequin.update_inv_w_uniform()
		mannequin.update_inv_wear_suit()

	// Equip custom jumpsuit from prefs (skip if using job default)
	var/obj/item/clothing/under/color/custom/custom_jumpsuit = spawn_custom_jumpsuit(mannequin)
	if(custom_jumpsuit)
		mannequin.replace_in_slot(SLOT_W_UNIFORM, custom_jumpsuit)

	// Equip loadout items for preview
	var/obj/item/clothing/preview_uniform = istype(mannequin.w_uniform, /obj/item/clothing) ? mannequin.w_uniform : null
	var/obj/item/clothing/preview_suit = istype(mannequin.wear_suit, /obj/item/clothing) ? mannequin.wear_suit : null
	if(gear && gear.len)
		for(var/thing in gear)
			var/datum/gear/G = gear_datums[thing]
			if(!G)
				continue
			// Skip species-whitelisted items if species doesn't match
			if(G.whitelisted && G.whitelisted != species)
				continue
			var/metadata = get_gear_metadata(G)
			var/obj/item/spawned_item = G.spawn_item(mannequin, metadata)
			if(!spawned_item)
				continue
			if(istype(spawned_item, /obj/item/clothing/accessory))
				// Clothing accessories attach to worn clothing, not to a body slot
				if(preview_uniform && preview_uniform.can_attach_accessory(spawned_item))
					preview_uniform.attach_accessory(spawned_item, mannequin)
				else if(preview_suit && preview_suit.can_attach_accessory(spawned_item))
					preview_suit.attach_accessory(spawned_item, mannequin)
				else
					qdel(spawned_item)
			else
				// Map item slot_flags to equip slot; replace whatever the job put there
				var/target_slot = _preview_slot_from_flags(spawned_item.slot_flags)
				if(target_slot)
					mannequin.replace_in_slot(target_slot, spawned_item)
				else if(!mannequin.equip_to_appropriate_slot(spawned_item))
					qdel(spawned_item)

	mannequin.update_inv_back()
	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)

/// Maps an item's slot_flags bitmask to the corresponding equip slot constant.
/// Returns null if the flags don't map to a single clear body slot (e.g. pockets).
/proc/_preview_slot_from_flags(slot_flags)
	if(slot_flags & SLOT_FLAGS_BACK)     return SLOT_BACK
	if(slot_flags & SLOT_FLAGS_OCLOTHING) return SLOT_WEAR_SUIT
	if(slot_flags & SLOT_FLAGS_ICLOTHING) return SLOT_W_UNIFORM
	if(slot_flags & SLOT_FLAGS_GLOVES)   return SLOT_GLOVES
	if(slot_flags & SLOT_FLAGS_EYES)     return SLOT_GLASSES
	if(slot_flags & SLOT_FLAGS_EARS)     return SLOT_L_EAR
	if(slot_flags & SLOT_FLAGS_MASK)     return SLOT_WEAR_MASK
	if(slot_flags & SLOT_FLAGS_HEAD)     return SLOT_HEAD
	if(slot_flags & SLOT_FLAGS_FEET)     return SLOT_SHOES
	if(slot_flags & SLOT_FLAGS_ID)       return SLOT_WEAR_ID
	if(slot_flags & SLOT_FLAGS_BELT)     return SLOT_BELT
	if(slot_flags & SLOT_FLAGS_NECK)     return SLOT_NECK
	return null
