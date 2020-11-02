
/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/equip_time = 0
	var/equipping = 0
	var/rig_restrict_helmet = 0 // Stops the user from equipping a rig helmet without attaching it to the suit first.
	var/gang //Is this a gang outfit?
	var/species_restricted_locked = FALSE

	/*
		Sprites used when the clothing item is refit. This is done by setting icon_override.
		For best results, if this is set then sprite_sheets should be null and vice versa, but that is by no means necessary.
		Ideally, sprite_sheets_refit should be used for "hard" clothing items that can't change shape very well to fit the wearer (e.g. helmets, hardsuits),
		while sprite_sheets should be used for "flexible" clothing items that do not need to be refitted (e.g. vox wearing jumpsuits).
	*/
	var/list/sprite_sheets_refit = null
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'

	// Which slot should we use on species.sprite_sheets, as for the species specified above.
	var/sprite_sheet_slot

/obj/item/clothing/atom_init()
	. = ..()
	if (!species_restricted_locked)
		update_species_restrictions()

/*
	This is for the Vox among you.
	Finds whether a sprite for this piece of clothing for a Vox exists, and if it does
	allows Vox to wear this.
*/
var/global/list/specie_sprite_sheet_cache = list()
var/global/list/icon_state_allowed_cache = list()

/obj/item/clothing/proc/get_sprite_sheet_icon_list(specie, overwrite_slot = null)
	// Return list of icon states of current spirte_sheet_slot or null
	if(!specie || !(specie in global.all_species))
		return
	var/slot = sprite_sheet_slot
	if(overwrite_slot)
		slot = overwrite_slot
	var/sprite_sheet_cache_key = "[specie]|[slot]"
	if(global.specie_sprite_sheet_cache[sprite_sheet_cache_key])
		. = global.specie_sprite_sheet_cache[sprite_sheet_cache_key]
	else
		var/datum/species/S = global.all_species[specie]
		var/i_path = S.sprite_sheets[slot]
		// If you specified the mob as sprite_sheet_restricted, but
		// want to use default sprite sheets for some "slots"
		// then specify it.
		if(i_path)
			global.specie_sprite_sheet_cache[sprite_sheet_cache_key] = icon_states(i_path)
			. = global.specie_sprite_sheet_cache[sprite_sheet_cache_key]

/obj/item/clothing/proc/update_species_restrictions()
	if(!species_restricted)
		species_restricted = list("exclude")

	var/exclusive = !("exclude" in species_restricted)

	for(var/specie in global.sprite_sheet_restricted)
		if(exclusive)
			species_restricted -= specie
		else
			species_restricted |= specie

	if(!sprite_sheet_slot)
		if(!species_restricted.len || (species_restricted.len == 1 && exclusive))
			species_restricted = null
		return

	for(var/specie in global.sprite_sheet_restricted)
		var/allowed = FALSE
		var/cache_key = "[specie]|[icon_state]"

		if(global.icon_state_allowed_cache[cache_key])
			allowed = TRUE
		else
			var/list/icons_exist = get_sprite_sheet_icon_list(specie)
			if(icons_exist)
				var/t_state
				if(sprite_sheet_slot == SPRITE_SHEET_HELD || sprite_sheet_slot == SPRITE_SHEET_GLOVES || sprite_sheet_slot == SPRITE_SHEET_BELT)
					t_state = item_state

				if(sprite_sheet_slot == SPRITE_SHEET_UNIFORM)
					t_state = item_color

				if(!t_state)
					t_state = icon_state

				if (sprite_sheet_slot == SPRITE_SHEET_UNIFORM)
					t_state = "[t_state]_s"

				if("[t_state]" in icons_exist)
					allowed = TRUE

		if(allowed)
			if(exclusive)
				species_restricted |= specie
			else
				species_restricted -= specie

			global.icon_state_allowed_cache[cache_key] = TRUE

	if(!species_restricted.len || (species_restricted.len == 1 && exclusive))
		species_restricted = null

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M, slot)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(species_restricted && istype(M,/mob/living/carbon/human))

		var/wearable = null
		var/exclusive = null
		var/mob/living/carbon/human/H = M

		if("exclude" in species_restricted)
			exclusive = 1

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = 1
			else
				if(H.species.name in species_restricted)
					wearable = 1

			if(!wearable && (slot != SLOT_L_STORE && slot != SLOT_R_STORE)) //Pockets.
				to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")
				return 0

	return 1

/obj/item/clothing/proc/refit_for_species(target_species)
	//Set species_restricted list
	switch(target_species)
		if(HUMAN , SKRELL)	//humanoid bodytypes
			species_restricted = list("exclude" , UNATHI , TAJARAN , DIONA , VOX, VOX_ARMALIS)
		else
			species_restricted = list(target_species)

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	//Set icon
	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)

/obj/item/clothing/head/helmet/refit_for_species(target_species)
	//Set species_restricted list
	switch(target_species)
		if(SKRELL)
			species_restricted = list("exclude" , UNATHI , TAJARAN , DIONA , VOX, VOX_ARMALIS)
		if(HUMAN)
			species_restricted = list("exclude" , SKRELL , UNATHI , TAJARAN , DIONA , VOX, VOX_ARMALIS)
		else
			species_restricted = list(target_species)

	if(target_species == VOX)
		flags &= ~BLOCKHAIR

	//Set icon
	if (sprite_sheets_refit && (target_species in sprite_sheets_refit))
		icon_override = sprite_sheets_refit[target_species]
	else
		icon_override = initial(icon_override)

	//Set icon
	if (sprite_sheets_obj && (target_species in sprite_sheets_obj))
		icon = sprite_sheets_obj[target_species]
	else
		icon = initial(icon)


/obj/item/clothing/MouseDrop(obj/over_object)
	if (ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
		if (loc != usr)
			return
		if (!over_object)
			return

		if (!usr.incapacitated())
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)

//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = ITEM_SIZE_NORMAL
	throwforce = 2
	slot_flags = SLOT_FLAGS_EARS

	sprite_sheet_slot = SPRITE_SHEET_EARS

/obj/item/clothing/ears/attack_hand(mob/user)
	if (!user) return

	if (src.loc != user || !istype(user,/mob/living/carbon/human))
		..()
		return

	var/mob/living/carbon/human/H = user
	if(H.l_ear != src && H.r_ear != src)
		..()
		return

	if(!canremove)
		return

	var/obj/item/clothing/ears/O
	if(slot_flags & SLOT_FLAGS_TWOEARS)
		O = (H.l_ear == src ? H.r_ear : H.l_ear)
		if(!user.unEquip(O))
			return
		if(!istype(src,/obj/item/clothing/ears/offear))
			qdel(O)
			O = src
	else
		O = src

	if(!user.unEquip(src))
		return

	if (O)
		user.put_in_hands(O)
		O.add_fingerprint(user)

	if(istype(src,/obj/item/clothing/ears/offear))
		qdel(src)

/obj/item/clothing/ears/offear
	name = "Other ear"
	w_class = ITEM_SIZE_HUGE
	icon = 'icons/mob/screen1_Midnight.dmi'
	icon_state = "block"
	slot_flags = SLOT_FLAGS_EARS | SLOT_FLAGS_TWOEARS

/obj/item/clothing/ears/offear/atom_init()
	. = ..()
	var/obj/O = loc
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	dir = O.dir

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_FLAGS_EARS | SLOT_FLAGS_TWOEARS

//Glasses
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = ITEM_SIZE_SMALL
	flags = GLASSESCOVERSEYES
	slot_flags = SLOT_FLAGS_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
          // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/


//Gloves
/obj/item/clothing/gloves
	name = "gloves"
	gender = PLURAL //Carn: for grammarically correct text-parsing
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	siemens_coefficient = 0.9
	var/wired = FALSE
	var/obj/item/weapon/stock_parts/cell/cell = 0
	var/clipped = FALSE
	var/protect_fingers = TRUE // Are we gonna get hurt when searching in the trash piles
	body_parts_covered = ARMS
	slot_flags = SLOT_FLAGS_GLOVES
	hitsound = list('sound/items/misc/glove-slap.ogg')
	attack_verb = list("challenged")
	species_restricted = list("exclude" , UNATHI , TAJARAN, VOX, VOX_ARMALIS)
	species_restricted_locked = TRUE
	sprite_sheet_slot = SPRITE_SHEET_GLOVES

/obj/item/clothing/gloves/emp_act(severity)
	if(cell)
		//why is this not part of the powercell code?
		cell.charge -= 1000 / severity
		if (cell.charge < 0)
			cell.charge = 0
		if(cell.reliability != 100 && prob(50/severity))
			cell.reliability -= 10 / severity
	..()


//Head
/obj/item/clothing/head
	name = "head"
	icon = 'icons/obj/clothing/hats.dmi'
	body_parts_covered = HEAD
	slot_flags = SLOT_FLAGS_HEAD
	w_class = ITEM_SIZE_SMALL
	var/blockTracking = 0

	sprite_sheet_slot = SPRITE_SHEET_HEAD

//Mask
/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	slot_flags = SLOT_FLAGS_MASK
	body_parts_covered = FACE|EYES

	sprite_sheet_slot = SPRITE_SHEET_MASK

/obj/item/clothing/proc/speechModification(message)
	return message

//Shoes
/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	siemens_coefficient = 0.9
	body_parts_covered = LEGS
	slot_flags = SLOT_FLAGS_FEET
	var/clipped_status = NO_CLIPPING

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	species_restricted = list("exclude" , UNATHI , TAJARAN, VOX, VOX_ARMALIS)

	sprite_sheet_slot = SPRITE_SHEET_FEET

//Cutting shoes
/obj/item/clothing/shoes/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I))
		switch(clipped_status)
			if(CLIPPABLE)
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				user.visible_message("<span class='red'>[user] cuts the toe caps off of [src].</span>","<span class='red'>You cut the toe caps off of [src].</span>")

				name = "mangled [name]"
				desc = "[desc]<br>They have the toe caps cut off of them."
				if("exclude" in species_restricted)
					species_restricted -= UNATHI
					species_restricted -= TAJARAN
					species_restricted -= VOX
				src.icon_state += "_cut"
				user.update_inv_shoes()
				clipped_status = CLIPPED
			if(NO_CLIPPING)
				to_chat(user, "<span class='notice'>You have no idea of how to clip [src]!</span>")
			if(CLIPPED)
				to_chat(user, "<span class='notice'>[src] have already been clipped!</span>")
	else
		return ..()

/obj/item/clothing/shoes/play_unique_footstep_sound()
	..()
	if(wet)
		playsound(src, 'sound/effects/mob/footstep/wet_shoes_step.ogg', VOL_EFFECTS_MASTER)

/obj/item/proc/negates_gravity()
	return 0

//Suit
/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	slot_flags = SLOT_FLAGS_OCLOTHING
	var/blood_overlay_type = "suit"
	siemens_coefficient = 0.9
	w_class = ITEM_SIZE_NORMAL

	sprite_sheet_slot = SPRITE_SHEET_SUIT

/obj/item/clothing/proc/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	return

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | THICKMATERIAL | PHORONGUARD
	flags_pressure = STOPS_PRESSUREDMAGE
	item_state = "space"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = HEAD|FACE|EYES
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude", DIONA, VOX, VOX_ARMALIS)
/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. \"NSS EXODUS\" is written in large block letters on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = ITEM_SIZE_LARGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = THICKMATERIAL | PHORONGUARD | BLOCKUNIFORM
	flags_pressure = STOPS_PRESSUREDMAGE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/suit_cooling_unit)
	slowdown = 3
	equip_time = 100 // Bone White - time to equip/unequip. see /obj/item/attack_hand (items.dm) and /obj/item/clothing/mob_can_equip (clothing.dm)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude", DIONA, VOX, VOX_ARMALIS)
	var/list/supporting_limbs //If not-null, automatically splints breaks. Checked when removing the suit.

/obj/item/clothing/suit/space/equipped(mob/M)
	check_limb_support()
	..()

/obj/item/clothing/suit/space/dropped()
	check_limb_support()
	..()

// Some space suits are equipped with reactive membranes that support
// broken limbs - at the time of writing, only the ninja suit, but
// I can see it being useful for other suits as we expand them. ~ Z
// The actual splinting occurs in /obj/item/organ/external/proc/fracture()
/obj/item/clothing/suit/space/proc/check_limb_support()

	// If this isn't set, then we don't need to care.
	if(!supporting_limbs || !supporting_limbs.len)
		return

	var/mob/living/carbon/human/H = src.loc

	// If the holder isn't human, or the holder IS and is wearing the suit, it keeps supporting the limbs.
	if(!istype(H) || H.wear_suit == src)
		return

	// Otherwise, remove the splints.
	for(var/obj/item/organ/external/BP in supporting_limbs)
		BP.status &= ~ORGAN_SPLINTED
	supporting_limbs = list()

//Under clothing
/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	permeability_coefficient = 0.90
	slot_flags = SLOT_FLAGS_ICLOTHING
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = ITEM_SIZE_NORMAL
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = SUIT_SENSOR_OFF
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/list/accessories = list()
	var/displays_id = 1
	var/rolled_down = 0
	var/basecolor

	sprite_sheet_slot = SPRITE_SHEET_UNIFORM

/obj/item/clothing/under/emp_act(severity)
	..()
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emplode(severity)

/obj/item/clothing/under/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(istype(A))
		. = TRUE
	else
		return FALSE
	if(accessories.len && (A.slot in list("utility","armband")))
		for(var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				return FALSE

/obj/item/clothing/under/verb/removetie()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	handle_accessories_removal()

/obj/item/clothing/under/proc/handle_accessories_removal()
	if(!isliving(usr))
		return
	if(usr.incapacitated())
		return
	if(!Adjacent(usr))
		return
	if(!accessories.len)
		return
	if(!istype(usr, /mob/living))
		return

	if(!usr.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	var/obj/item/clothing/accessory/A
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		A = accessories[1]
	remove_accessory(usr, A)

/obj/item/clothing/under/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(QDELETED(A) || !(A in accessories))
		return
	if(!isliving(user))
		return
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	A.on_removed(user)
	accessories -= A
	A.update_icon()
	to_chat(user, "<span class='notice'>You remove [A] from [src].</span>")
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.update_inv_w_uniform()
		action_button_name = null


/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(I.sharp && !ishuman(loc)) //you can cut only clothes lying on the floor
		for (var/i in 1 to 3)
			new /obj/item/stack/medical/bruise_pack/rags(get_turf(src), null, null, crit_fail)
		qdel(src)
		return

	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(can_attach_accessory(A))
			user.drop_item()
			accessories += A
			A.on_attached(src, user)

			if(istype(loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()
			action_button_name = "Use inventory."
			return
		else
			to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")

	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_accessory(I, user, params)
		return

	return ..()

/obj/item/clothing/under/AltClick()
	handle_accessories_removal()

/obj/item/clothing/under/attack_hand(mob/user)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(accessories.len && loc == user)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_hand(user)
		return

	if ((ishuman(usr) || ismonkey(usr)) && loc == user)	//make it harder to accidentally undress yourself
		return

	..()

/obj/item/clothing/under/examine(mob/user)
	..()
	switch(src.sensor_mode)
		if(SUIT_SENSOR_OFF)
			to_chat(user, "Its sensors appear to be disabled.")
		if(SUIT_SENSOR_BINARY)
			to_chat(user, "Its binary life sensors appear to be enabled.")
		if(SUIT_SENSOR_VITAL)
			to_chat(user, "Its vital tracker appears to be enabled.")
		if(SUIT_SENSOR_TRACKING)
			to_chat(user, "Its vital tracker and tracking beacon appear to be enabled.")

	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "[bicon(A)] \A [A] is attached to it.")

/obj/item/clothing/under/proc/set_sensors(mob/usr)
	var/mob/M = usr
	if (istype(M, /mob/dead)) return
	if (usr.incapacitated())
		return
	if(has_sensor >= 2)
		to_chat(usr, "The controls are locked.")
		return 0
	if(has_sensor <= 0)
		to_chat(usr, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(usr, src) > 1)
		to_chat(usr, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (src.loc == usr)
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				to_chat(usr, "You disable your suit's remote sensing equipment.")
			if(SUIT_SENSOR_BINARY)
				to_chat(usr, "Your suit will now report whether you are live or dead.")
			if(SUIT_SENSOR_VITAL)
				to_chat(usr, "Your suit will now report your vital lifesigns.")
			if(SUIT_SENSOR_TRACKING)
				to_chat(usr, "Your suit will now report your vital lifesigns as well as your coordinate position.")
	else if (istype(src.loc, /mob))
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				M.visible_message("<span class='warning'>[usr] disables [src.loc]'s remote sensing equipment.</span>", viewing_distance = 1)
			if(SUIT_SENSOR_BINARY)
				M.visible_message("[usr] turns [src.loc]'s remote sensors to binary.", viewing_distance = 1)
			if(SUIT_SENSOR_VITAL)
				M.visible_message("[usr] sets [src.loc]'s sensors to track vitals.", viewing_distance = 1)
			if(SUIT_SENSOR_TRACKING)
				M.visible_message("[usr] sets [src.loc]'s sensors to maximum.", viewing_distance = 1)

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.incapacitated())
		return

	if(copytext(item_color,-2) != "_d")
		basecolor = item_color
	if((basecolor + "_d_s") in icon_states('icons/mob/uniform.dmi'))
		item_color = item_color == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
		usr.update_inv_w_uniform()
	else
		to_chat(usr, "<span class='notice'>You cannot roll down the uniform!</span>")

/obj/item/clothing/under/rank/atom_init()
	sensor_mode = pick(SUIT_SENSOR_OFF, SUIT_SENSOR_BINARY, SUIT_SENSOR_VITAL, SUIT_SENSOR_TRACKING)
	. = ..()
