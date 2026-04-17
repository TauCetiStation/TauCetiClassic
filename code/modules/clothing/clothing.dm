/obj/item/clothing
	name = "clothing"
	var/list/species_restricted = null //Only these species can wear this kit.
	var/equip_time = 0
	var/equipping = 0
	var/rig_restrict_helmet = 0 // Stops the user from equipping a rig helmet without attaching it to the suit first.
	var/gang //Is this a gang outfit?
	var/species_restricted_locked = FALSE
	var/list/potentially_protected_organs = list() //These organs can be protected by armor if it has high protective properties

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


/obj/item/clothing/atom_init()
	. = ..()
	if(body_parts_covered & UPPER_TORSO)
		potentially_protected_organs |= O_HEART

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
		render_flags &= ~HIDE_ALL_HAIR

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
	var/check_stats = armor[MELEE] >= PROTECTION_REQUIRED_FOR_ORGANS || armor[BULLET] >= PROTECTION_REQUIRED_FOR_ORGANS || armor[LASER] >= PROTECTION_REQUIRED_FOR_ORGANS || armor[ENERGY] >= PROTECTION_REQUIRED_FOR_ORGANS
	if(potentially_protected_organs.len && check_stats)
		to_chat(user, "<a href='byond://?src=\ref[src];show_organ_protection=1'>Show vital organs protection</a>")
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "[bicon(A)] \A [A] is attached to it.")

/obj/item/clothing/Topic(href, href_list)
	..()
	if(href_list["show_organ_protection"])
		if(armor[MELEE] >= PROTECTION_REQUIRED_FOR_ORGANS)
			to_chat(usr, "<span class='notice'>\The [name] can protect vital organs from <b>impacts.</b></span>")
		if(armor[BULLET] >= PROTECTION_REQUIRED_FOR_ORGANS)
			to_chat(usr, "<span class='notice'>\The [name] can protect vital organs from <b>bullets.</b></span>")
		if(armor[LASER] >= PROTECTION_REQUIRED_FOR_ORGANS)
			to_chat(usr, "<span class='notice'>\The [name] can protect vital organs from <b>lasers.</b></span>")
		if(armor[ENERGY] >= PROTECTION_REQUIRED_FOR_ORGANS)
			to_chat(usr, "<span class='notice'>\The [name] can protect vital organs from <b>energy weapons.</b></span>")

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

	/// Detective Work, used for allowing a given atom to leave its fibers/fingerprints on stuff.
	var/can_leave_fibers = TRUE
	var/can_leave_fingerprints = FALSE

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

//Neck
/obj/item/clothing/neck
	name = "neck"
	icon = 'icons/obj/clothing/neck.dmi'
	slot_flags = SLOT_FLAGS_NECK
	w_class = SIZE_TINY
	sprite_sheet_slot = SPRITE_SHEET_NECK

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
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | PHORONGUARD
	render_flags = parent_type::render_flags | HIDE_ALL_HAIR
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
	flags = PHORONGUARD
	flags_pressure = STOPS_PRESSUREDMAGE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/suit_cooling_unit)
	slowdown = 1.5
	equip_time = 100 // Bone White - time to equip/unequip. see /obj/item/attack_hand (items.dm) and /obj/item/clothing/mob_can_equip (clothing.dm)
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	render_flags = parent_type::render_flags | HIDE_TAIL | HIDE_UNIFORM
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
	var/rolled_down = FALSE
	var/basecolor

	var/fresh_laundered_until = 0

	sprite_sheet_slot = SPRITE_SHEET_UNIFORM
	valid_accessory_slots = list("utility","armband","decor")
	restricted_accessory_slots = list("utility", "armband")

	dyed_type = DYED_UNIFORM

	/// Whether this uniform uses the polychromic system
	var/poly = FALSE
	/// Base style: "std", "std_w", "belt", "belt_w", "turt", "turt_w"
	var/poly_style = "std"
	/// Pattern overlay for second color: "1"-"5", "turt", or null for none
	var/poly_pattern = null
	/// list("#base_color", "#pattern_color")
	var/list/poly_colors = null

/// Shared color palette for polychromic jumpsuit customization (used in UI pickers)
var/global/list/poly_color_palette = list(
	"Фиолетовый"       = "#6E39A9",
	"Фиолетовый V2"    = "#8D45A9",
	"Розовый"           = "#AC1B5B",
	"Светло Розовый"    = "#B25266",
	"Красный"           = "#AB1F1F",
	"Светло Красный"    = "#B1372D",
	"Оранжевый"         = "#B47538",
	"Золотой"           = "#BE902A",
	"Желтый"            = "#C29700",
	"Салатовый"         = "#ADB834",
	"Зеленый"           = "#149605",
	"Зеленый V2"        = "#588142",
	"Темно Синий"       = "#273B75",
	"Синий"             = "#186ABD",
	"Светло Синий"      = "#2789CD",
	"Голубой"           = "#309AA3",
	"Белый"             = "#E6E7F0",
	"Черный"            = "#444444",
	"Черный V2"         = "#222222",
	"Черный V3"         = "#373334"
)

/// Converts a hex color to a color matrix that preserves greyscale detail.
/// Pure multiply: black removes all detail. This matrix keeps ~12% of original brightness
/// so shadows, folds and outlines remain visible even with very dark colors.
/proc/poly_color_matrix(hex_color)
	var/r = hex2num(copytext(hex_color, 2, 4)) / 255
	var/g = hex2num(copytext(hex_color, 4, 6)) / 255
	var/b = hex2num(copytext(hex_color, 6, 8)) / 255
	var/k = 0.12 // detail preservation factor
	// Matrix: output = pixel * (color * (1-k) + k)
	// Black(0,0,0) → pixel * 0.12 (dark grey, details visible)
	// White(1,1,1) → pixel * 1.0 (unchanged)
	return list(
		r * (1 - k) + k, 0, 0, \
		0, g * (1 - k) + k, 0, \
		0, 0, b * (1 - k) + k  \
	)

/// Creates a poly overlay mutable_appearance with RESET_COLOR set.
/// Optionally tints with `color_hex` and applies `human.update_height()`.
/// `icon_file` defaults to the poly uniform sheet; pass blood.dmi for blood overlays.
/proc/make_poly_overlay(state, color_hex = null, mob/living/carbon/human/human = null, icon_file = 'icons/mob/uniform_poly.dmi')
	var/mutable_appearance/overlay = mutable_appearance(icon_file, state)
	if(color_hex)
		overlay.color = poly_color_matrix(color_hex)
	overlay.appearance_flags |= RESET_COLOR
	if(human)
		human.update_height(overlay)
	return overlay

/obj/item/clothing/under/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	if(!poly || !length(poly_colors))
		return ..()
	// Held-in-hand uses world states (w_*). DMI has no d_* details nor blood for world views.
	if(sprite_sheet_slot == SPRITE_SHEET_HELD)
		var/mutable_appearance/held = mutable_appearance('icons/mob/uniform_poly.dmi', get_poly_world_state(), layer)
		held.color = poly_color_matrix(poly_colors[1])
		held.add_overlay(get_poly_world_overlays())
		return held
	var/mutable_appearance/MA = mutable_appearance('icons/mob/uniform_poly.dmi', get_poly_mob_state(H), layer)
	MA.color = poly_color_matrix(poly_colors[1])
	MA.add_overlay(get_poly_mob_overlays(H, bloodied_icon_state))
	return MA

/// Builds detail, pattern and blood overlays for mob-worn display.
/// When `H` is a human, each sub-overlay is passed through `H.update_height()`
/// so height filters don't get clipped. Returns a list of mutable_appearances.
/obj/item/clothing/under/proc/get_poly_mob_overlays(mob/living/carbon/human/H, bloodied_icon_state)
	. = list()
	var/detail_state = get_poly_detail_state(H)
	if(detail_state)
		. += make_poly_overlay(detail_state, null, H)
	var/pattern_state = get_poly_pattern_state(H)
	if(pattern_state && length(poly_colors) >= 2)
		. += make_poly_overlay(pattern_state, poly_colors[2], H)
	if(dirt_overlay && bloodied_icon_state)
		var/mutable_appearance/blood = make_poly_overlay(bloodied_icon_state, null, H, 'icons/effects/blood.dmi')
		blood.color = dirt_overlay.color
		. += blood

/// Builds pattern and blood overlays for inventory/in-hand (world) display.
/obj/item/clothing/under/proc/get_poly_world_overlays()
	. = list()
	if(poly_pattern && length(poly_colors) >= 2)
		var/pat_state = get_poly_world_pattern_state()
		if(pat_state)
			. += make_poly_overlay(pat_state, poly_colors[2])
	if(dirt_overlay)
		var/mutable_appearance/blood = make_poly_overlay("uniformblood", null, null, 'icons/effects/blood.dmi')
		blood.color = dirt_overlay.color
		. += blood

/obj/item/clothing/under/update_icon()
	..()
	cut_overlays()
	if(!poly || !length(poly_colors))
		return
	icon = 'icons/mob/uniform_poly.dmi'
	icon_state = get_poly_world_state()
	color = poly_color_matrix(poly_colors[1])
	add_overlay(get_poly_world_overlays())

/// Returns the world (inventory/in-hand) icon_state for this poly uniform.
/// World states don't vary by gender/fat/species. Belt styles reuse the std world sprite.
/obj/item/clothing/under/proc/get_poly_world_state()
	if(poly_style == "turt" || poly_style == "turt_w")
		return "w_turt"
	if(is_poly_white_base(poly_style))
		return "w_std_w"
	return "w_std"

/// Returns the world pattern icon_state, or null if this style/pattern has none.
/obj/item/clothing/under/proc/get_poly_world_pattern_state()
	if(!poly_pattern)
		return null
	if(poly_style == "turt" || poly_style == "turt_w")
		return "w_turt_pattern"
	return "w_pattern"

/// Returns the style this uniform should RENDER as for a given mob.
/// Fat mobs have no turtleneck sprites in the DMI — downgrade turt → std so the
/// whole appearance (base + detail + pattern) stays consistent.
/obj/item/clothing/under/proc/get_effective_poly_style(mob/living/carbon/human/H)
	if(H && HAS_TRAIT(H, TRAIT_FAT) && (poly_style == "turt" || poly_style == "turt_w"))
		return (poly_style == "turt_w") ? "std_w" : "std"
	return poly_style

/// Returns the mob icon_state for this poly uniform, accounting for gender, fat, and vox
/obj/item/clothing/under/proc/get_poly_mob_state(mob/living/carbon/human/H)
	var/style = get_effective_poly_style(H)
	// Map poly_style to base state prefix
	var/base
	switch(style)
		if("std")
			base = "b_std"
		if("std_w")
			base = "b_std_w"
		if("belt")
			base = "b_belt"
		if("belt_w")
			base = "b_belt_w"
		if("turt")
			base = "b_turt"
		if("turt_w")
			base = "b_turt_w"
		else
			base = "b_std"
	// Roll-down states
	if(rolled_down)
		base = is_poly_white_base(style) ? "b_roll_w" : "b_roll"
	// Vox variant — b_std_w_vox is the only Vox base sprite, used for all styles
	if(H && H.species?.name == VOX)
		return "b_std_w_vox"
	// Fat variant — b_belt_w/b_turt/b_turt_w have no fat sprites; fall through to fem/base
	var/static/list/has_fat = list("b_std", "b_belt", "b_std_w", "b_roll", "b_roll_w")
	if(H && HAS_TRAIT(H, TRAIT_FAT) && (base in has_fat))
		return "[base]_fat"
	// Female variant
	if(H && H.gender == FEMALE)
		return "[base]_fem"
	return base

/// Returns the non-colorable detail overlay state (zippers, seams, etc.)
/// These are drawn on top of the colored layers without tinting.
/obj/item/clothing/under/proc/get_poly_detail_state(mob/living/carbon/human/H)
	var/style = get_effective_poly_style(H)
	// No detail when rolled down
	if(rolled_down)
		return null
	// Turtlenecks have no zipper detail
	if(style == "turt" || style == "turt_w")
		return null
	var/is_belt = (style == "belt" || style == "belt_w")
	// Vox variant — only one sprite exists, used for all patterns
	if(H && H.species?.name == VOX)
		return "d_vox"
	// Fat variant — takes priority over pattern-specific detail
	if(H && HAS_TRAIT(H, TRAIT_FAT))
		return "d_fat"
	// Pattern 5 has its own detail sprite due to zipper position — only for non-belt, non-female
	if(poly_pattern == "5" && !is_belt && !(H && H.gender == FEMALE))
		return "d_p5"
	// Female variant
	if(H && H.gender == FEMALE)
		return is_belt ? "d_belt_fem" : "d_fem"
	// Male variant
	return is_belt ? "d_belt" : "d"

/// Returns the pattern icon_state for the mob overlay
/obj/item/clothing/under/proc/get_poly_pattern_state(mob/living/carbon/human/H)
	if(!poly_pattern)
		return null
	// No pattern when rolled down
	if(rolled_down)
		return null
	// No pattern for fat mobs — fat sprites don't have pattern overlays
	if(H && HAS_TRAIT(H, TRAIT_FAT))
		return null
	// Vox only has one base sprite — no pattern overlays
	if(H && H.species?.name == VOX)
		return null
	var/style = get_effective_poly_style(H)
	// turt pattern uses _white suffix in DMI
	if(poly_pattern == "turt")
		return (H && H.gender == FEMALE) ? "p_turt_white_fem" : "p_turt_white"
	var/pat = "p[poly_pattern]"
	// Belt variants for patterns that have them (p3_belt, p5_belt)
	if((style == "belt" || style == "belt_w") && (poly_pattern == "3" || poly_pattern == "5"))
		pat = "p[poly_pattern]_belt"
	// Fat variant — only p1_fat and p2_fat exist in DMI; p3/p4/p5 fall through to fem/base
	var/static/list/has_fat_pattern = list("1", "2")
	if(H && HAS_TRAIT(H, TRAIT_FAT) && (poly_pattern in has_fat_pattern))
		return "[pat]_fat"
	// Female variant
	if(H && H.gender == FEMALE)
		return "[pat]_fem"
	return pat

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

/obj/item/clothing/under/proc/set_sensors(mob/user)
	var/mob/M = user
	if (istype(M, /mob/dead)) return
	if (user.incapacitated())
		return
	if(has_sensor >= 2)
		to_chat(user, "The controls are locked.")
		return 0
	if(has_sensor <= 0)
		to_chat(user, "This suit does not have any sensors.")
		return 0

	var/list/modes = list("Off", "Binary sensors", "Vitals tracker", "Tracking beacon")
	var/switchMode = input("Select a sensor mode:", "Suit Sensor Mode", modes[sensor_mode + 1]) in modes
	if(get_dist(user, src) > 1)
		to_chat(user, "You have moved too far away.")
		return
	sensor_mode = modes.Find(switchMode) - 1

	if (loc == user)
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				to_chat(user, "You disable your suit's remote sensing equipment.")
			if(SUIT_SENSOR_BINARY)
				to_chat(user, "Your suit will now report whether you are live or dead.")
			if(SUIT_SENSOR_VITAL)
				to_chat(user, "Your suit will now report your vital lifesigns.")
			if(SUIT_SENSOR_TRACKING)
				to_chat(user, "Your suit will now report your vital lifesigns as well as your coordinate position.")
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.update_suit_sensors()

	else if (istype(loc, /mob))
		switch(sensor_mode)
			if(SUIT_SENSOR_OFF)
				M.visible_message("<span class='warning'>[user] disables [loc]'s remote sensing equipment.</span>", viewing_distance = 1)
			if(SUIT_SENSOR_BINARY)
				M.visible_message("[user] turns [loc]'s remote sensors to binary.", viewing_distance = 1)
			if(SUIT_SENSOR_VITAL)
				M.visible_message("[user] sets [loc]'s sensors to track vitals.", viewing_distance = 1)
			if(SUIT_SENSOR_TRACKING)
				M.visible_message("[user] sets [loc]'s sensors to maximum.", viewing_distance = 1)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			C.update_suit_sensors()

/obj/item/clothing/under/verb/toggle()
	set name = "Toggle Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/proc/can_rollsuit(mob/user)
	if(!isliving(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/item/clothing/under/verb/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!can_rollsuit(usr))
		return

	if(copytext(item_state,-2) != "_d")
		basecolor = item_state
	if(icon_exists('icons/mob/uniform.dmi', "[basecolor]_d"))
		item_state = item_state == "[basecolor]" ? "[basecolor]_d" : "[basecolor]"
		update_inv_mob()
	else
		to_chat(usr, "<span class='notice'>You cannot roll down the uniform!</span>")

/obj/item/clothing/under/color/polychromic/rollsuit()
	if(!can_rollsuit(usr))
		return
	if(poly_style == "turt" || poly_style == "turt_w")
		to_chat(usr, "<span class='notice'>You cannot roll down a turtleneck!</span>")
		return

	rolled_down = !rolled_down
	update_inv_mob()

/obj/item/clothing/under/wash_act(w_color)
	if(poly && w_color)
		var/static/list/dye_to_hex = list(
			"red"    = "#CC4444",
			"orange" = "#CC7722",
			"yellow" = "#DAA520",
			"green"  = "#228B22",
			"blue"   = "#4169E1",
			"purple" = "#7B3FA0",
			"white"  = "#FFFFFF",
			"mime"   = "#C8C8C8"
		)
		var/hex = dye_to_hex[w_color]
		if(hex)
			poly_colors = list(poly_colors[1], hex)
			update_icon()
			return
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
