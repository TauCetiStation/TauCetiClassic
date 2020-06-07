// This subtype is used for integrating this system with current chaplain anything.
/datum/religion/chaplain/New()
	..()
	religify_chapel()

/datum/religion/chaplain/proc/religify_chapel()
	for(var/chap_area in typesof(/area/station/civilian/chapel))
		religify(chap_area)

/datum/religion/chaplain/proc/gen_pos_bible_variants()
	var/list/variants = list()
	for(var/info_type in subtypesof(/datum/bible_info))
		var/datum/bible_info/BB = new info_type(src)
		if(!BB.name)
			continue
		variants[BB.name] = BB
	return variants

/datum/religion/chaplain/proc/create_by_chaplain(mob/living/carbon/human/chaplain)
	reset_religion()

	var/new_religion = sanitize_safe(input(chaplain, "You are the crew services officer. Would you like to change your religion? Default is [name], in SPACE.", "Name change", name), MAX_NAME_LEN)
	if(!new_religion)
		new_religion = name
	else
		name = new_religion
		deity_names = deity_names_by_name[name] ? deity_names_by_name[name] : list("Space-Jesus")

	feedback_set_details("religion_name","[new_religion]")

	var/deity_name = pick(deity_names)
	var/new_deity = sanitize_safe(input(chaplain, "Would you like to change your deity? Default is [deity_name].", "Name change", deity_name), MAX_NAME_LEN)
	if(!new_deity)
		new_deity = deity_name
	else
		// Currently no polyteistic support. ~Luduk
		deity_names = list(new_deity)

	gen_bible_info()

	var/obj/item/weapon/storage/bible/B = spawn_bible(chaplain)
	if(!B.god_lore)
		var/new_lore = sanitize_safe(input(chaplain, "You can come up with the lore of your god in [new_religion] religion.", "Lore for new god", ""), MAX_MESSAGE_LEN)
		B.god_lore = new_lore
		lore = new_lore

	chaplain.equip_to_slot_or_del(B, SLOT_L_HAND)

	var/list/bible_variants = gen_pos_bible_variants()

	var/accepted = FALSE
	var/choose_timeout = world.time + 1 MINUTE
	var/new_book_style = bible_info.name

	while(!accepted)
		if(!B)
			break // prevents possible runtime errors
		new_book_style = input(chaplain, "Which bible style would you like?") in bible_variants

		var/datum/bible_info/BB = bible_variants[new_book_style]
		if(BB)
			BB.apply_visuals_to(B)
			bible_info = BB

			chaplain.update_inv_l_hand() // so that it updates the bible's item_state in his hand

		switch(input(chaplain,"Look at your bible - is this what you want?") in list("Yes","No"))
			if("Yes")
				accepted = TRUE
			if("No")
				if(choose_timeout <= world.time)
					to_chat(chaplain, "Welp, out of time, buddy. You're stuck. Next time choose faster.")
					accepted = TRUE

	feedback_set_details("religion_deity","[new_deity]")
	feedback_set_details("religion_book","[new_book_style]")

	// Update the looks of the chapel.
	update_structure_info()
	religify_chapel()
