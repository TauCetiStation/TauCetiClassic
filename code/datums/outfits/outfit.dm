/**
  * # Outfit datums
  *
  * This is a clean system of applying outfits to humans, if you need to equip someone in a uniform
  * this is the way to do it cleanly and properly.
  *
  * You can also specify an outfit datum on a job to have it auto equipped to the mob on join
  *
  * /mob/living/carbon/human/proc/equipOutfit(outfit) is the mob level proc to equip an outfit
  * and you pass it the relevant datum outfit
  *
  * outfits can also be saved as json blobs downloadable by a client and then can be uploaded
  * by that user to recreate the outfit, this is used by admins to allow for custom event outfits
  * that can be restored at a later date
  */
/datum/outfit
	var/name = "Naked"  ///Name of the outfit (shows up in the equip admin verb)

	var/uniform = null    /// Type path of item to go in uniform slot
	var/uniform_f = null    /// Type path of item to go in uniform slot	(female)
	var/suit = null       /// Type path of item to go in suit slot
	var/gloves = null     /// Type path of item to go in gloves slot
	var/shoes = null      /// Type path of item to go in shoes slot
	var/head = null       /// Type path of item to go in head slot
	var/mask = null       /// Type path of item to go in mask slot
	var/neck = null       /// Type path of item to go in neck slot
	var/l_ear = null      /// Type path of item to go in left ear slot
	var/r_ear = null      /// Type path of item to go in right ear slot
	var/glasses = null    /// Type path of item to go in the glasses slot

	var/suit_store = null /// Type path of item to go in suit storage slot (make sure it's valid for that suit)
	var/id = null         /// Type path of item to go in the idcard slot
	var/belt = null       /// Type path of item to go in belt slot

	var/l_hand = null     /// Type path of item to go in left hand
	var/r_hand = null     /// Type path of item to go in the right hand
	var/l_pocket = null   /// Type path of item for left pocket slot
	var/r_pocket = null   /// Type path of item for right pocket slot

	var/l_hand_back = null     /// Type path of item to go in the backpack. Otherwise in left hand
	var/r_hand_back = null     /// Type path of item to go in the backpack. Otherwise in right hand
	var/l_pocket_back = null   /// Type path of item in the backpack. Otherwise in the left pocket
	var/r_pocket_back = null   /// Type path of item in the backpack. Otherwise for right pocket slot

	var/back = null       /// Type path of item to go in back slot

	var/list/back_style = BACKPACK_STYLE_COMMON

	var/list/backpack_contents = list() /// list of items that should go in the backpack of the user. Format of this list should be: list(path=count,otherpath=count)
	var/list/implants = null  /// asoc_list implant - bodypart. Any implants the mob should start implanted with. Format of this list is (typepath = bodypart, typepath = bodypart, typepath = bodypart)

	var/internals_slot = null /// ID of the slot containing a gas tank

	/**
	  * Survival box.
	  *
	  * Will be inserted at the start of backpack_contents.
	  * Contents = species_survival_kit_items + advanced_kit_items
	  * Other boxes must be in backpack_contents
	  *
	  */
	var/survival_box = FALSE
	// list of outfit items to add to survival box
	var/list/survival_kit_items = list()
	// list of items to be removed from survival box
	var/list/prevent_survival_kit_items = list()

	// (flavor_misc.dm)
	var/datum/sprite_accessory/outfit_undershirt = null   /// Any undershirt. string. no paths...
	var/datum/sprite_accessory/outfit_underwear_m = null  /// "White", "Grey", "Green", "Blue", "Black", "Mankini", "None"
	var/datum/sprite_accessory/outfit_underwear_f = null  /// "Red", "White", "Yellow", "Blue", "Black", "Thong", "None"

// select backpack type from preferences
/datum/outfit/proc/preference_back(mob/living/carbon/human/H)
	switch(back)
		if(PREFERENCE_BACKPACK)
			back = back_style[H.backbag]
		if(PREFERENCE_BACKPACK_FORCE)
			back = back_style[DEFAULT_FORCED_BACKPACK]

// replaces default human outfit in [slot] on [item_type]
/datum/outfit/proc/change_slot_equip(slot, item_type)
	switch(slot)
		if(SLOT_W_UNIFORM)
			uniform = item_type
		if(SLOT_WEAR_SUIT)
			suit = item_type
		if(SLOT_BACK)
			back = item_type
		if(SLOT_BELT)
			belt = item_type
		if(SLOT_GLOVES)
			gloves = item_type
		if(SLOT_SHOES)
			shoes = item_type
		if(SLOT_HEAD)
			head = item_type
		if(SLOT_WEAR_MASK)
			mask = item_type
		if(SLOT_TIE)
			neck = item_type
		if(SLOT_L_EAR)
			l_ear = item_type
		if(SLOT_R_EAR)
			r_ear = item_type
		if(SLOT_GLASSES)
			glasses = item_type

// SPECIES_EQUIP PROCS
/datum/outfit/proc/unathi_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/proc/tajaran_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/proc/skrell_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/proc/vox_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/**
  * Called at the start of the equip proc
  *
  * Override to change the value of the slots depending on client prefs, species and
  * other such sources of change
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for customization depending on client prefs,species etc
	return

/**
  * Called after the equip proc has finished
  *
  * All items are on the mob at this point, use this proc to toggle internals
  * fiddle with id bindings and accesses etc
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	//to be overridden for toggling internals, id binding, access etc
	return

/**
  * Equips all defined types and paths to the mob passed in
  *
  * Extra Arguments
  * * visualsOnly true if this is only for display (in the character setup screen)
  *
  * If visualsOnly is true, you can omit any work that doesn't visually appear on the character sprite
  */
/datum/outfit/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	preference_back(H)
	pre_equip(H, visualsOnly)
	H.species.species_equip(H, src)	// replaces human outfit on species outfit

	//Start with uniform,suit,backpack for additional slots
	if(uniform_f && H.use_skirt)
		uniform = uniform_f

	var/list/slot2type = list(
		"[SLOT_BACK]"        = back,
		"[SLOT_WEAR_MASK]"   = mask,
		"[SLOT_GLASSES]"     = glasses,
		"[SLOT_GLOVES]"      = gloves,
		"[SLOT_HEAD]"        = head,
		"[SLOT_SHOES]"       = shoes,
		"[SLOT_WEAR_SUIT]"   = suit,
		"[SLOT_W_UNIFORM]"   = uniform,
		"[SLOT_TIE]"         = neck,
		"[SLOT_BELT]"        = belt,
		"[SLOT_WEAR_ID]"     = id
	)

	equip_slots(H, slot2type)

	if(outfit_undershirt)
		H.undershirt = undershirt_t.Find(outfit_undershirt)
		H.update_body()

	if(outfit_underwear_m || outfit_underwear_f)
		var/list/underwear_options
		var/outfit_underwear
		if(H.gender == MALE)
			underwear_options = underwear_m
			outfit_underwear = outfit_underwear_m
		else
			underwear_options = underwear_f
			outfit_underwear = outfit_underwear_f
		H.underwear = underwear_options.Find(outfit_underwear)
		H.update_body()

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.

		slot2type = list(
			"[SLOT_L_EAR]"   = l_ear,
			"[SLOT_R_EAR]"   = r_ear,
			"[SLOT_S_STORE]" = suit_store,
			"[SLOT_L_STORE]" = l_pocket,
			"[SLOT_R_STORE]" = r_pocket
		)

		equip_slots(H, slot2type)

		if(survival_box)
			var/obj/item/weapon/storage/box/survival/SK = new(H)

			species_survival_kit_items:
				for(var/type in H.species.survival_kit_items)
					/*
					is_type_in_list only work on instantinated objects.
					*/
					for(var/type_to_check in prevent_survival_kit_items) // So engineers don't spawn with two oxy tanks.
						if(ispath(type, type_to_check))
							continue species_survival_kit_items
					new type(SK)

			job_survival_kit_items:
				for(var/type in survival_kit_items)
					for(var/type_to_check in H.species.prevent_survival_kit_items) // So IPCs don't spawn with oxy tanks from engi kits
						if(ispath(type, type_to_check))
							continue job_survival_kit_items
					new type(SK)

			if(H.backbag == 1)
				H.equip_to_slot_or_del(SK, SLOT_R_HAND)
			else
				H.equip_to_slot_or_del(SK, SLOT_IN_BACKPACK)

		if(back)
			if(l_pocket_back)
				backpack_contents += l_pocket_back
			if(r_pocket_back)
				backpack_contents += r_pocket_back
			if(l_hand_back)
				backpack_contents += l_hand_back
			if(r_hand_back)
				backpack_contents += r_hand_back

			if(backpack_contents)
				for(var/path in backpack_contents)
					var/number = backpack_contents[path]
					if(!isnum(number))//Default to 1
						number = 1
					for(var/i in 1 to number)
						H.equip_to_slot_or_del(new path(H), SLOT_IN_BACKPACK)
		else
			if(l_pocket_back)
				H.equip_to_slot_or_del(new l_pocket_back(H), SLOT_L_STORE)
			if(r_pocket_back)
				H.equip_to_slot_or_del(new r_pocket_back(H), SLOT_R_STORE)
			if(l_hand_back)
				H.put_in_l_hand(new l_hand_back(H))
			if(r_hand_back)
				H.put_in_r_hand(new r_hand_back(H))

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_equipped_item(internals_slot)
			if(H.internals)
				H.internals.icon_state = "internal1"
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/weapon/implant/I = new implant_type(H)
				I.inject(H, implants[implant_type])

	H.update_body()
	return TRUE

// equip type in slot from slot2type list
/datum/outfit/proc/equip_slots(mob/living/carbon/human/H, list/slot2type)
	for(var/slot in slot2type)
		var/slot_type = slot2type[slot]
		if(!slot_type)
			continue
		H.equip_to_slot_or_del(new slot_type(H), text2num(slot))

/**
  * Apply a fingerprint from the passed in human to all items in the outfit
  *
  * Used for forensics setup when the mob is first equipped at roundstart
  * essentially calls add_fingerprint to every defined item on the human
  *
  */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)

	var/list/slots_fingerprints = list(H.back, H.belt, H.w_uniform, H.wear_suit, H.neck, H.shoes, H.wear_id, H.wear_mask, H.head, H.gloves, H.l_ear, H.r_ear, H.glasses, H.belt, H.s_store, H.l_store, H.r_store)
	for(var/i in slots_fingerprints)
		if(i)
			recursive_add_fingerprints(H, i)

	return TRUE

/datum/outfit/proc/recursive_add_fingerprints(mob/living/carbon/human/H, obj/item/I)
	I.add_fingerprint(H, 1) //The 1 sets a flag to ignore gloves
	if(findtext( "[I.type]/", "/storage/") && I.contents.len)
		for(var/obj/item/contained in I.contents)
			recursive_add_fingerprints(H, contained)

/// Return a json list of this outfit
/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	.["back"] = back
	.["belt"] = belt
	.["gloves"] = gloves
	.["shoes"] = shoes
	.["head"] = head
	.["mask"] = mask
	.["neck"] = neck
	.["l_ear"] = l_ear
	.["r_ear"] = r_ear
	.["glasses"] = glasses
	.["id"] = id
	.["l_pocket"] = l_pocket
	.["r_pocket"] = r_pocket
	.["suit_store"] = suit_store
	.["r_hand"] = r_hand
	.["l_hand"] = l_hand
	.["internals_slot"] = internals_slot
	.["backpack_contents"] = backpack_contents
	.["survival_box"] = survival_box
	.["implants"] = implants

/// Prompt the passed in mob client to download this outfit as a json blob
/datum/outfit/proc/save_to_file(mob/admin)
	var/stored_data = get_json_data()
	var/json = json_encode(stored_data)
	//Kinda annoying but as far as i can tell you need to make actual file.
	var/f = file("data/TempOutfitUpload")
	fdel(f)
	WRITE_FILE(f,json)
	admin << ftp(f,"[name].json")

/// Create an outfit datum from a list of json data
/datum/outfit/proc/load_from(list/outfit_data)
	//This could probably use more strict validation
	name = outfit_data["name"]
	uniform = text2path(outfit_data["uniform"])
	suit = text2path(outfit_data["suit"])
	back = text2path(outfit_data["back"])
	belt = text2path(outfit_data["belt"])
	gloves = text2path(outfit_data["gloves"])
	shoes = text2path(outfit_data["shoes"])
	head = text2path(outfit_data["head"])
	mask = text2path(outfit_data["mask"])
	neck = text2path(outfit_data["neck"])
	l_ear = text2path(outfit_data["l_ear"])
	r_ear = text2path(outfit_data["r_ear"])
	glasses = text2path(outfit_data["glasses"])
	id = text2path(outfit_data["id"])
	l_pocket = text2path(outfit_data["l_pocket"])
	r_pocket = text2path(outfit_data["r_pocket"])
	suit_store = text2path(outfit_data["suit_store"])
	r_hand = text2path(outfit_data["r_hand"])
	l_hand = text2path(outfit_data["l_hand"])
	internals_slot = outfit_data["internals_slot"]
	var/list/backpack = outfit_data["backpack_contents"]
	backpack_contents = list()
	for(var/item in backpack)
		var/itype = text2path(item)
		if(itype)
			backpack_contents[itype] = backpack[item]
	survival_box = outfit_data["survival_box"]
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	return TRUE
