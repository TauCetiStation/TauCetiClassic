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
	var/list/accessories
	var/list/valid_accessory_slots
	var/list/restricted_accessory_slots

	var/can_be_modded = FALSE //modding hardsuits with modkits

	var/flashbang_protection = FALSE

//BS12: Species-restricted clothing check.
/obj/item/clothing/mob_can_equip(M, slot)

	//if we can't equip the item anyway, don't bother with species_restricted (cuts down on spam)
	if (!..())
		return 0

	if(species_restricted && ishuman(M))
		var/wearable = null
		var/exclusive = ("exclude" in species_restricted)
		var/mob/living/carbon/human/H = M

		if(H.species)
			if(exclusive)
				if(!(H.species.name in species_restricted))
					wearable = TRUE
			else
				if(H.species.name in species_restricted)
					wearable = TRUE

			if(!wearable && (slot != SLOT_L_STORE && slot != SLOT_R_STORE)) //Pockets.
				to_chat(M, "<span class='warning'>Your species cannot wear [src].</span>")
				return 0

	return 1

/obj/item/clothing/proc/refit_for_species(target_species)
	//Set species_restricted list
	switch(target_species)
		if(HUMAN , SKRELL, PODMAN)	//humanoid bodytypes
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
		if(PODMAN)
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

/obj/item/clothing/emp_act(severity)
	..()
	for(var/obj/item/clothing/accessory/A in accessories)
		A.emplode(severity)

/obj/item/clothing/AltClick(mob/user)
	if(!isliving(user))
		return
	if(user.incapacitated())
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		return

	var/obj/item/I = user.get_active_hand()
	if(!I)
		handle_accessories_removal()
		return

	if(!istype(I, /obj/item/clothing/accessory))
		handle_accessories_removal()
		return

	attach_accessory(I, user)

/obj/item/clothing/proc/can_attach_accessory(obj/item/clothing/accessory/A)
	if(!valid_accessory_slots || !istype(A) || !(A.slot in valid_accessory_slots))
		return FALSE
	. = TRUE

	if(restricted_accessory_slots && (A.slot in restricted_accessory_slots))
		for(var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				return FALSE

/obj/item/clothing/proc/handle_accessories_removal()
	if(!accessories)
		return FALSE

	var/obj/item/clothing/accessory/A
	if(length(accessories) > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in accessories
	else
		A = accessories[1]
	remove_accessory(usr, A)
	return TRUE

/obj/item/clothing/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!(A in accessories))
		return

	A.on_removed(user)
	LAZYREMOVE(accessories, A)
	A.update_icon()
	to_chat(user, "<span class='notice'>You remove [A] from [src].</span>")
	update_inv_mob()

/obj/item/clothing/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/clothing/accessory))
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_accessory(I, user, params)
			return

	return ..()

/obj/item/clothing/attack_hand(mob/user)
	if(!slot_equipped)
		return ..()
	if(!accessories)
		return ..()
	for(var/obj/item/clothing/accessory/A in accessories)
		A.attack_hand(user)
	..()

/obj/item/clothing/examine(mob/user)
	..()
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "[bicon(A)] \A [A] is attached to it.")

/obj/item/clothing/proc/attach_accessory(obj/item/clothing/accessory/A, mob/user)
	if(can_attach_accessory(A))
		user.drop_from_inventory(A, src)
		LAZYADD(accessories, A)
		A.on_attached(src, user)
		update_inv_mob()
		return
	else
		to_chat(user, "<span class='notice'>You cannot attach more accessories of this type to [src].</span>")


/obj/item/clothing/display_accessories()
	var/list/displayed_accessories = list()
	for(var/accessory in accessories)
		displayed_accessories += "[bicon(accessory)] \a [accessory]"

	if(displayed_accessories.len)
		. += " with [get_english_list(displayed_accessories)] attached"

/obj/item/clothing/proc/_spawn_shreds()
	set waitfor = FALSE
	var/turf/T = get_turf(src)
	sleep(1)
	new /obj/effect/decal/cleanable/shreds(T, name)

/obj/item/clothing/atom_destruction(damage_flag)
	switch(damage_flag)
		if(FIRE, ACID)
			return ..()
		else
			_spawn_shreds()
			..()

//Ears: headsets, earmuffs and tiny objects
/obj/item/clothing/ears
	name = "ears"
	w_class = SIZE_SMALL
	throwforce = 2
	slot_flags = SLOT_FLAGS_EARS

	sprite_sheet_slot = SPRITE_SHEET_EARS

/obj/item/clothing/ears/attack_hand(mob/user)
	if (!user) return

	if (src.loc != user || !ishuman(user))
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
	w_class = SIZE_BIG
	icon = 'icons/hud/screen1_Midnight.dmi'
	icon_state = "block"
	slot_flags = SLOT_FLAGS_EARS | SLOT_FLAGS_TWOEARS

/obj/item/clothing/ears/offear/atom_init()
	. = ..()
	var/obj/O = loc
	name = O.name
	desc = O.desc
	icon = O.icon
	icon_state = O.icon_state
	set_dir(O.dir)

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
	w_class = SIZE_TINY
	flags = GLASSESCOVERSEYES
	slot_flags = SLOT_FLAGS_EYES
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/invisa_view = 0
	// Standart hud type
	var/list/hud_types
	// Default huds for fix
	var/list/def_hud_types
	var/mob/living/carbon/glasses_user
	var/lighting_alpha = null

/obj/item/clothing/glasses/atom_init()
	. = ..()
	if(hud_types)
		def_hud_types = hud_types


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
	w_class = SIZE_TINY
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

	dyed_type = DYED_GLOVES

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
	w_class = SIZE_TINY
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

	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN

	sprite_sheet_slot = SPRITE_SHEET_FEET

	dyed_type = DYED_SHOES

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
	w_class = SIZE_SMALL

	sprite_sheet_slot = SPRITE_SHEET_SUIT

	valid_accessory_slots = list("armband", "decor")
	restricted_accessory_slots = list("armband")

/obj/item/clothing/proc/attack_reaction(mob/living/L, reaction_type, mob/living/carbon/human/T = null)
	return

//Spacesuit
//Note: Everything in modules/clothing/spacesuits should have the entire suit grouped together.
//      Meaning the the suit is defined directly after the corrisponding helmet. Just like below!
/obj/item/clothing/head/helmet/space
	name = "space helmet"
	icon_state = "space"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | PHORONGUARD
	flags_pressure = STOPS_PRESSUREDMAGE
	item_state = "space"
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = HEAD|FACE|EYES
	pierce_protection = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude", DIONA, VOX_ARMALIS)
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)

/obj/item/clothing/suit/space
	name = "space suit"
	desc = "A suit that protects against low pressure environments. \"NSS EXODUS\" is written in large block letters on the back."
	icon_state = "space"
	item_state = "s_suit"
	w_class = SIZE_NORMAL//bulky item
	throw_range = 2
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	flags = PHORONGUARD | BLOCKUNIFORM
	flags_pressure = STOPS_PRESSUREDMAGE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/suit_cooling_unit)
	slowdown = 1.5
	equip_time = 100 // Bone White - time to equip/unequip. see /obj/item/attack_hand (items.dm) and /obj/item/clothing/mob_can_equip (clothing.dm)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.2
	species_restricted = list("exclude", DIONA, VOX_ARMALIS)
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
	w_class = SIZE_SMALL
	flags = HEAR_TALK //for webbing vest contents
	var/has_sensor = 1//For the crew computer 2 = unable to change mode
	var/sensor_mode = SUIT_SENSOR_OFF
		/*
		1 = Report living/dead
		2 = Report detailed damages
		3 = Report location
		*/
	var/displays_id = 1
	var/rolled_down = 0
	var/basecolor

	var/fresh_laundered_until = 0

	sprite_sheet_slot = SPRITE_SHEET_UNIFORM
	valid_accessory_slots = list("utility","armband","decor")
	restricted_accessory_slots = list("utility", "armband")

	dyed_type = DYED_UNIFORM

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(slot == SLOT_W_UNIFORM && fresh_laundered_until > world.time)
		fresh_laundered_until = world.time
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if(I.sharp && !ishuman(loc)) //you can cut only clothes lying on the floor
		new /obj/item/stack/sheet/cloth(get_turf(src), 3, null, crit_fail)
		qdel(src)
		return

	return ..()

/obj/item/clothing/under/attack_hand(mob/user)
	if ((ishuman(usr) || ismonkey(usr)) && loc == user)	//make it harder to accidentally undress yourself
		if(accessories && slot_equipped)
			for(var/obj/item/clothing/accessory/A in accessories)
				A.attack_hand(user)
		return

	..()

/obj/item/clothing/under/examine(mob/user)
	..()
	if(fresh_laundered_until > world.time)
		to_chat(user, "It looks fresh and clean.")

	switch(src.sensor_mode)
		if(SUIT_SENSOR_OFF)
			to_chat(user, "Its sensors appear to be disabled.")
		if(SUIT_SENSOR_BINARY)
			to_chat(user, "Its binary life sensors appear to be enabled.")
		if(SUIT_SENSOR_VITAL)
			to_chat(user, "Its vital tracker appears to be enabled.")
		if(SUIT_SENSOR_TRACKING)
			to_chat(user, "Its vital tracker and tracking beacon appear to be enabled.")

/obj/item/clothing/under/hear_talk(mob/M, text, verb, datum/language/speaking)
	for(var/obj/item/clothing/accessory/A in accessories)
		if(A.flags & (HEAR_TALK | HEAR_PASS_SAY | HEAR_TA_SAY))
			A.hear_talk(M, text, verb, speaking)

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
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.update_suit_sensors()

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
		if(iscarbon(src.loc))
			var/mob/living/carbon/C = src.loc
			C.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.incapacitated())
		return

	if(copytext(item_state,-2) != "_d")
		basecolor = item_state
	if((basecolor + "_d") in icon_states('icons/mob/uniform.dmi'))
		item_state = item_state == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
		update_inv_mob()
	else
		to_chat(usr, "<span class='notice'>You cannot roll down the uniform!</span>")

/obj/item/clothing/under/wash_act(w_color)
	. = ..()
	fresh_laundered_until = world.time + 5 MINUTES

/obj/item/clothing/under/rank/atom_init()
	sensor_mode = pick(SUIT_SENSOR_OFF, SUIT_SENSOR_BINARY, SUIT_SENSOR_VITAL, SUIT_SENSOR_TRACKING)
	. = ..()


/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	flags_inv = 0
	body_parts_covered = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
