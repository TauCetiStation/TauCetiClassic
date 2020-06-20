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
#define UNATHI_REPLACE_OUTFIT list( \
			/obj/item/clothing/shoes/boots/combat = /obj/item/clothing/shoes/boots/combat/cut \
			)

#define TAJARAN_REPLACE_OUTFIT list( \
			/obj/item/clothing/shoes/boots/combat = /obj/item/clothing/shoes/boots/combat/cut \
			)

#define SKRELL_REPLACE_OUTFIT list()

#define VOX_REPLACE_OUTFIT list()

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
	var/id = null         /// Type path of item to go in the idcard slot
	var/l_pocket = null   /// Type path of item for left pocket slot
	var/r_pocket = null   /// Type path of item for right pocket slot
	var/suit_store = null /// Type path of item to go in suit storage slot (make sure it's valid for that suit)

	var/r_hand = null     /// Type path of item to go in the right hand
	var/l_hand = null     /// Type path of item to go in left hand

	//var/toggle_helmet = TRUE  /// Should the toggle helmet proc be called on the helmet during equip
	var/internals_slot = null /// ID of the slot containing a gas tank

	var/list/backpack_contents = null /// list of items that should go in the backpack of the user. Format of this list should be: list(path=count,otherpath=count)

	var/box                           /// Internals box. Will be inserted at the start of backpack_contents
	var/advanced_survival_kit = FALSE

	var/list/implants = null  /// Any implants the mob should start implanted with. Format of this list is (typepath, typepath, typepath)

	//
	var/datum/sprite_accessory/undershirt = null  /// Any undershirt. While on humans it is a string, here we use paths to stay consistent with the rest of the equips.
	
	//var/accessory = null  /// Any clothing accessory item

	var/can_be_admin_equipped = TRUE   /// Set to FALSE if your outfit requires runtime parameters

	/**
	  * extra types for chameleon outfit changes, mostly guns
	  * Format of this list is (typepath, typepath, typepath)
	  * These are all added and returns in the list for get_chamelon_diguise_info proc
	  */
	var/list/chameleon_extras

/datum/outfit/proc/species_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	switch(H.get_species())
		if(HUMAN)
			return
		if(UNATHI)
			species_replace_outfit(UNATHI_REPLACE_OUTFIT)
			unathi_equip(H)
		if(TAJARAN)
			species_replace_outfit(TAJARAN_REPLACE_OUTFIT)
			tajaran_equip(H)
		if(SKRELL)
			species_replace_outfit(SKRELL_REPLACE_OUTFIT)
			skrell_equip(H)
		if(VOX)
			species_replace_outfit(VOX_REPLACE_OUTFIT)
			vox_equip(H)
	return

/datum/outfit/proc/change_slot_equip(var/slot, var/item_type)
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
	return

/datum/outfit/proc/species_replace_outfit(var/list/replace_outfit = null)
	var/list/outfit_types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses)
	var/list/outfit_slot_types = list(SLOT_W_UNIFORM, SLOT_WEAR_SUIT, SLOT_BACK, SLOT_BELT, SLOT_GLOVES, SLOT_SHOES, SLOT_HEAD, SLOT_WEAR_MASK, SLOT_TIE, SLOT_L_EAR, SLOT_R_EAR, SLOT_GLASSES)
	for(var/I in 1 to outfit_types.len)
		if(replace_outfit[outfit_types[I]])
			change_slot_equip(outfit_slot_types[I], replace_outfit[outfit_types[I]])

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
	species_equip(H, visualsOnly)
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

	/*
	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		if(U)
			U.attach_accessory(new accessory(H))
		else
			WARNING("Unable to equip accessory [accessory] in outfit [name]. No uniform present!")
	*/

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
			var/list/box_survival_kit_items = H.species.survival_kit_items
			if(box == /obj/item/weapon/storage/box/survival)
				if(advanced_survival_kit)
					for(var/I in 1 to box_survival_kit_items.len)
						if(box_survival_kit_items[I] == /obj/item/weapon/tank/emergency_oxygen)
							box_survival_kit_items[I] = /obj/item/weapon/tank/emergency_oxygen/engi
				box = new box()
				for(var/type in box_survival_kit_items)
					new type(box)
			H.equip_to_slot_or_del(box, SLOT_IN_BACKPACK)

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H), SLOT_IN_BACKPACK, TRUE)

	/*
	if(!H.head && toggle_helmet && istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/HS = H.wear_suit
		HS.ToggleHelmet()
	*/

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		apply_fingerprints(H)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_icons()
		if(implants)
			for(var/implant_type in implants)
				var/obj/item/weapon/implant/I = new implant_type(H)
				I.imp_in = H
				I.implanted = 1
				H.update_icons()

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

/// Return a list of all the types that are required to disguise as this outfit type
/datum/outfit/proc/get_chameleon_disguise_info()
	var/list/types = list(uniform, suit, back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand)
	types += chameleon_extras
	listclearnulls(types)
	return types

/// Return a json list of this outfit
/datum/outfit/proc/get_json_data()
	. = list()
	.["outfit_type"] = type
	.["name"] = name
	.["uniform"] = uniform
	.["suit"] = suit
	//.["toggle_helmet"] = toggle_helmet
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
	.["box"] = box
	.["implants"] = implants
	//.["accessory"] = accessory

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
	//toggle_helmet = outfit_data["toggle_helmet"]
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
	box = text2path(outfit_data["box"])
	var/list/impl = outfit_data["implants"]
	implants = list()
	for(var/I in impl)
		var/imptype = text2path(I)
		if(imptype)
			implants += imptype
	//accessory = text2path(outfit_data["accessory"])
	return TRUE
