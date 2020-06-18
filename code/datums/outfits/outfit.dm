/**
  * # Outfit datums
  *
  * This is a clean system of applying outfits to mobs, if you need to equip someone in a uniform
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
	var/uniform = null  /// Type path of item to go in uniform slot	
	var/suit = null     /// Type path of item to go in suit slot	
	var/back = null     /// Type path of item to go in back slot
	var/belt = null     /// Type path of item to go in belt slot
	var/gloves = null   /// Type path of item to go in gloves slot
	var/shoes = null    /// Type path of item to go in shoes slot
	var/head = null     /// Type path of item to go in head slot
	var/mask = null     /// Type path of item to go in mask slot
	var/neck = null     /// Type path of item to go in neck slot
	var/l_ear = null    /// Type path of item to go in left ear slot
	var/r_ear = null    /// Type path of item to go in right ear slot
	var/glasses = null  /// Type path of item to go in the glasses slot
	var/id = null       /// Type path of item to go in the idcard slot
	var/l_pocket = null /// Type path of item for left pocket slot
	var/r_pocket = null /// Type path of item for right pocket slot

	/**
	  * Type path of item to go in suit storage slot
	  *
	  * (make sure it's valid for that suit)
	  */
	var/suit_store = null

	
	var/r_hand = null    ///Type path of item to go in the right hand
	var/l_hand = null    //Type path of item to go in left hand

	
	var/toggle_helmet = TRUE  /// Should the toggle helmet proc be called on the helmet during equip

	
	var/internals_slot = null ///ID of the slot containing a gas tank

	/**
	  * list of items that should go in the backpack of the user
	  *
	  * Format of this list should be: list(path=count,otherpath=count)
	  */
	var/list/backpack_contents = null

	
	var/box  /// Internals box. Will be inserted at the start of backpack_contents

	/** 
	  * Any implants the mob should start implanted with
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  */
	var/list/implants = null

  /// Any undershirt. While on humans it is a string, here we use paths to stay consistent with the rest of the equips.
	var/datum/sprite_accessory/undershirt = null

	/// Set to FALSE if your outfit requires runtime parameters
	var/can_be_admin_equipped = TRUE

	/**
	  * extra types for chameleon outfit changes, mostly guns
	  *
	  * Format of this list is (typepath, typepath, typepath)
	  *
	  * These are all added and returns in the list for get_chamelon_diguise_info proc
	  */
	var/list/chameleon_extras

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
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots
	if(uniform)
		H.equip_to_slot_or_del(new uniform(H), SLOT_W_UNIFORM, TRUE)
	if(suit)
		H.equip_to_slot_or_del(new suit(H), SLOT_WEAR_SUIT, TRUE)
	if(back)
		H.equip_to_slot_or_del(new back(H), SLOT_BACK, TRUE)
	if(belt)
		H.equip_to_slot_or_del(new belt(H), SLOT_BELT, TRUE)
	if(gloves)
		H.equip_to_slot_or_del(new gloves(H), SLOT_GLOVES, TRUE)
	if(shoes)
		H.equip_to_slot_or_del(new shoes(H), SLOT_SHOES, TRUE)
	if(head)
		H.equip_to_slot_or_del(new head(H), SLOT_HEAD, TRUE)
	if(mask)	
		H.equip_to_slot_or_del(new mask(H), SLOT_WEAR_MASK, TRUE)
	if(neck)
		H.equip_to_slot_or_del(new neck(H), SLOT_TIE, TRUE)
	if(l_ear)
		H.equip_to_slot_or_del(new l_ear(H), SLOT_L_EAR, TRUE)
	if(r_ear)
		H.equip_to_slot_or_del(new r_ear(H), SLOT_R_EAR, TRUE)
	if(glasses)
		H.equip_to_slot_or_del(new glasses(H), SLOT_GLASSES, TRUE)
	if(id)
		H.equip_to_slot_or_del(new id(H), SLOT_WEAR_ID, TRUE)
	if(suit_store)
		H.equip_to_slot_or_del(new suit_store(H), SLOT_S_STORE, TRUE)

	if(undershirt)
		H.undershirt = initial(undershirt.name)

	if(l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_pocket)
			H.equip_to_slot_or_del(new l_pocket(H), SLOT_L_STORE, TRUE)
		if(r_pocket)
			H.equip_to_slot_or_del(new r_pocket(H), SLOT_R_STORE, TRUE)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H), SLOT_BACK, TRUE)

	post_equip(H, visualsOnly)

	H.update_body()
	return TRUE

/**
  * Apply a fingerprint from the passed in human to all items in the outfit
  *
  * Used for forensics setup when the mob is first equipped at roundstart
  * essentially calls add_fingerprint to every defined item on the human
  *
  */
/datum/outfit/proc/apply_fingerprints(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H.back)
		H.back.add_fingerprint(H,1)	//The 1 sets a flag to ignore gloves
		for(var/obj/item/I in H.back.contents)
			I.add_fingerprint(H,1)
	if(H.wear_id)
		H.wear_id.add_fingerprint(H,1)
	if(H.w_uniform)
		H.w_uniform.add_fingerprint(H,1)
	if(H.wear_suit)
		H.wear_suit.add_fingerprint(H,1)
	if(H.wear_mask)
		H.wear_mask.add_fingerprint(H,1)
	if(H.head)
		H.head.add_fingerprint(H,1)
	if(H.shoes)
		H.shoes.add_fingerprint(H,1)
	if(H.gloves)
		H.gloves.add_fingerprint(H,1)
	if(H.glasses)
		H.glasses.add_fingerprint(H,1)
	if(H.belt)
		H.belt.add_fingerprint(H,1)
		for(var/obj/item/I in H.belt.contents)
			I.add_fingerprint(H,1)
	if(H.s_store)
		H.s_store.add_fingerprint(H,1)
	if(H.l_store)
		H.l_store.add_fingerprint(H,1)
	if(H.r_store)
		H.r_store.add_fingerprint(H,1)
	return 1