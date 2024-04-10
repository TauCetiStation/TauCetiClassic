
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	//w_class = SIZE_TINY
	//flags = GLASSESCOVERSEYES
	//slot_flags = SLOT_FLAGS_EYES
	//var/vision_flags = 0
	//var/darkness_view = 0//Base human is 2
	//var/invisa_view = 0
	var/prescription = 0
	body_parts_covered = EYES
	var/toggleable = FALSE
	var/off_state = "degoggles"
	var/active = TRUE
	var/sightglassesmod = null
	var/activation_sound = 'sound/items/buttonclick.ogg'

	sprite_sheet_slot = SPRITE_SHEET_EYES

/obj/item/clothing/glasses/attack_self(mob/user)
	if(toggleable)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(active)
				active = FALSE
				icon_state = off_state
				vision_flags = 0
				lighting_alpha = null
				to_chat(usr, "You deactivate the optical matrix on the [src].")
			else
				active = TRUE
				icon_state = initial(icon_state)
				vision_flags = initial(vision_flags)
				lighting_alpha = initial(lighting_alpha)
				to_chat(usr, "You activate the optical matrix on the [src].")
			playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
			update_inv_mob()
			H.update_sight()
			update_item_actions()

/obj/item/clothing/glasses/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_GLASSES)
		if(prescription)
			user.clear_fullscreen("nearsighted")

/obj/item/clothing/glasses/dropped(mob/user)
	. = ..()
	if(prescription)
		if(HAS_TRAIT(user, TRAIT_NEARSIGHT))
			user.overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/impaired, 1)

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=2"
	toggleable = TRUE
	sightglassesmod = "meson"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/meson/prescription
	name = "prescription mesons"
	desc = "Optical Meson Scanner with prescription lenses."
	prescription = 1

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing!"
	icon_state = "purple"
	item_state = "glasses"
	toggleable = TRUE
	sightglassesmod = "sci"
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state_world = "night_w"
	item_state = "glasses"
	origin_tech = "magnets=2"
	darkness_view = 7
	toggleable = TRUE
	sightglassesmod = "nvg"
	active = TRUE
	off_state = "night"
	activation_sound = 'sound/effects/glasses_on.ogg'
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"
/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	body_parts_covered = 0

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	body_parts_covered = 0

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	origin_tech = "magnets=3;engineering=3"
	toggleable = TRUE
	vision_flags = SEE_OBJS
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/aviator_orange
	name = "aviator glasses"
	desc = "Stylish glasses with orange lenses"
	icon_state = "aviators_orange"

/obj/item/clothing/glasses/aviator_black
	name = "aviator glasses"
	desc = "Stylish glasses with black lenses"
	icon_state = "aviators_black"

/obj/item/clothing/glasses/aviator_red
	name = "aviator glasses"
	desc = "Stylish glasses with red lenses"
	icon_state = "aviators_red"

/obj/item/clothing/glasses/aviator_mirror
	name = "aviator glasses"
	desc = "Stylish glasses with transparent lenses"
	icon_state = "aviators_mirror"

/obj/item/clothing/glasses/jerusalem
	name = "Jerusalem glasses"
	desc = "Here you can see a small inscription: I hate it here"
	icon_state = "spider_jerusalem"

/obj/item/clothing/glasses/regular
	name = "prescription glasses"
	desc = "Made by Nerd. Co."
	icon_state = "glasses"
	item_state = "glasses"
	prescription = 1
	body_parts_covered = 0

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"
	body_parts_covered = 0

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	body_parts_covered = 0

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = -1
	flash_protection = FLASHES_PARTIAL_PROTECTION
	flash_protection_slots = list(SLOT_GLASSES)

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_GLASSES)
	var/up = 0
	item_action_types = list(/datum/action/item_action/flip_welding_goggles)

/datum/action/item_action/flip_welding_goggles
	name = "Flip Welding Goggles"

/obj/item/clothing/glasses/welding/attack_self()
	toggle()


/obj/item/clothing/glasses/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr

	if(!usr.incapacitated())
		if(up)
			up = !up
			flags |= GLASSESCOVERSEYES
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			flash_protection = FLASHES_FULL_PROTECTION
			to_chat(usr, "You flip \the [src] down to protect your eyes.")
		else
			up = !up
			flags &= ~GLASSESCOVERSEYES
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			flash_protection = NONE
			to_chat(usr, "You push \the [src] up out of your face.")

		update_inv_mob()
		update_item_actions()

/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	//vision_flags = BLIND  	// This flag is only supposed to be used if it causes permanent blindness, not temporary because of glasses

/obj/item/clothing/glasses/sunglasses/blindfold/white
	name = "blind personnel blindfold"
	desc = "Indicates that the wearer suffers from blindness."
	icon_state = "blindfoldwhite"
	item_state = "blindfoldwhite"
	var/colored_before = FALSE

/obj/item/clothing/glasses/sunglasses/blindfold/white/equipped(mob/living/carbon/human/user, slot)
	if(ishuman(user) && slot == SLOT_GLASSES)
		update_icon(user)
	..()

/obj/item/clothing/glasses/sunglasses/blindfold/white/update_icon(mob/living/carbon/human/user)
	if(ishuman(user) && !colored_before)
		colored_before = TRUE
		color = rgb(user.r_eyes, user.g_eyes, user.b_eyes)

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = 1

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/hud/sechud
	name = "HUDsunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	hud_types = list(DATA_HUD_SECURITY)

/obj/item/clothing/glasses/hud/hos_aug
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "hos_shades_ngv"
	item_state = "hos_shades"
	off_state = "hos_shades"
	hud_types = list(DATA_HUD_SECURITY)
	toggleable = TRUE
	active = TRUE
	activation_sound = 'sound/effects/glasses_switch.ogg'
	sightglassesmod  = "hos"
	darkness_view = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	flash_protection = FLASHES_AMPLIFIER
	flash_protection_slots = list(SLOT_GLASSES)
	item_action_types = list(/datum/action/item_action/switch_shades_mode)

/datum/action/item_action/switch_shades_mode
	name = "Switch Shades Mode"

/obj/item/clothing/glasses/hud/hos_aug/attack_self(mob/user)
	. = ..()
	if(active)
		flash_protection = FLASHES_AMPLIFIER
	else
		flash_protection = FLASHES_PARTIAL_PROTECTION

/obj/item/clothing/glasses/sunglasses/hud/sechud/tactical
	name = "tactical HUD"
	desc = "Flash-resistant goggles with inbuilt combat and security information."
	icon_state = "swatgoggles"

/obj/item/clothing/glasses/thermal
	name = "optical thermal scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	invisa_view = 2
	toggleable = TRUE
	sightglassesmod = "thermal"
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protection = FLASHES_AMPLIFIER
	flash_protection_slots = list(SLOT_GLASSES)
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/obj/item/clothing/glasses/thermal/attack_self(mob/user)
	. = ..()
	if(active)
		flash_protection = FLASHES_AMPLIFIER
	else
		flash_protection = NONE

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(ishuman(src.loc))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, "<span class='warning'>The Optical Thermal Scanner overloads and blinds you!</span>")
		if(M.glasses == src)
			M.eye_blind = 3
			M.blurEyes(15)
			M.become_nearsighted(EYE_DAMAGE_TEMPORARY_TRAIT)
			addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, cure_nearsighted), EYE_DAMAGE_TEMPORARY_TRAIT), 10 SECONDS, TIMER_STOPPABLE)
	..()

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = "magnets=3;syndicate=4"

/obj/item/clothing/glasses/thermal/monocle
	name = "thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	flags = null //doesn't protect eyes because it's a monocle, duh
	body_parts_covered = 0
	toggleable = TRUE
	off_state = "thermoncle_off"
	item_action_types = list(/datum/action/item_action/hands_free/toggle_monocle)

/datum/action/item_action/hands_free/toggle_monocle
	name = "Toggle Monocle"

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	body_parts_covered = 0
	toggleable = FALSE
	item_action_types = null

/obj/item/clothing/glasses/thermal/jensen
	name = "optical thermal implants"
	desc = "A set of implantable lenses designed to augment your vision."
	icon_state = "thermalimplants"
	item_state = "syringe_kit"

/obj/item/clothing/glasses/rosas_eyepatch
	name = "white eyepatch"
	icon_state = "rosas_eye"

/obj/item/clothing/glasses/hud/health/night
	name = "night vision health scanner HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	darkness_view = 7
	toggleable = TRUE
	sightglassesmod = "nvg"
	active = TRUE
	off_state = "healthhudnight"
	hud_types = list(DATA_HUD_MEDICAL_ADV)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"

/obj/item/clothing/glasses/gar
	name = "gar glasses"
	icon_state = "gar"
	item_state = "gar"

/obj/item/clothing/glasses/sunglasses/gar
	name = "gar sunglasses"
	icon_state = "garb"
	item_state = "garb"

/obj/item/clothing/glasses/meson/gar
	name = "gar meson scanner"
	icon_state = "garm"
	item_state = "garm"
	toggleable = FALSE
	item_action_types = null

/obj/item/clothing/glasses/sunglasses/hud/sechud/gar
	name = "gar HUDsunglasses"
	icon_state = "gars"
	item_state = "gars"

/obj/item/clothing/glasses/sunglasses/gar/super
	name = "supergar sunglasses"
	icon_state = "supergarb"
	item_state = "supergarb"

/obj/item/clothing/glasses/sunglasses/hud/sechud/gar/super
	name = "supergar HUDSunglasses"
	icon_state = "supergars"
	item_state = "supergars"

/obj/item/clothing/glasses/gar/super
	name = "supergar glasses"
	icon_state = "supergar"
	item_state = "supergar"
	toggleable = FALSE

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Somehow these seem even more out-of-date than normal sunglasses."
	sightglassesmod = "greyscale"
	toggleable = TRUE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_noir)

/datum/action/item_action/hands_free/toggle_noir
	name = "Toggle Noir"

/obj/item/clothing/glasses/sunglasses/noir/attack_self(mob/user)
	toggle_noir()

/obj/item/clothing/glasses/sunglasses/noir/verb/toggle_noir()
	set name = "Toggle Noir"
	set category = "Object"

	if(usr.incapacitated())
		return
	active = !active
	to_chat(usr, "<span class='notice'>You toggle the Noire Mode [active ? "on. Let the investigation begin." : "off."]</span>")
