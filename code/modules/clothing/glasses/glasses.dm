
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	//w_class = ITEM_SIZE_SMALL
	//flags = GLASSESCOVERSEYES
	//slot_flags = SLOT_FLAGS_EYES
	//var/vision_flags = 0
	//var/darkness_view = 0//Base human is 2
	//var/invisa_view = 0
	var/prescription = 0
	body_parts_covered = EYES
	var/toggleable = 0
	var/off_state = "degoggles"
	var/active = 1
	var/sightglassesmod = null
	var/activation_sound = 'sound/items/buttonclick.ogg'

	sprite_sheet_slot = SPRITE_SHEET_EYES

/obj/item/clothing/glasses/attack_self(mob/user)
	if(toggleable)
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(active)
				active = 0
				icon_state = off_state
				vision_flags = 0
				to_chat(usr, "You deactivate the optical matrix on the [src].")
			else
				active = 1
				icon_state = initial(icon_state)
				vision_flags = initial(vision_flags)
				to_chat(usr, "You activate the optical matrix on the [src].")
			playsound(src, activation_sound, VOL_EFFECTS_MASTER, 10, FALSE)
			H.update_inv_glasses()
			H.update_sight()

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	origin_tech = "magnets=2;engineering=2"
	toggleable = 1
	sightglassesmod = "meson"
	vision_flags = SEE_TURFS

/obj/item/clothing/glasses/meson/prescription
	name = "prescription mesons"
	desc = "Optical Meson Scanner with prescription lenses."
	prescription = 1

/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing!"
	icon_state = "purple"
	item_state = "glasses"
	action_button_name = "Toggle Goggles"
	toggleable = 1
	sightglassesmod = "sci"

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = "magnets=2"
//	darkness_view = 3
//	vision_flags = SEE_SELF
	darkness_view = 7
	toggleable = 1
	sightglassesmod = "nvg"
	action_button_name = "Toggle Goggles"
	active = 1
	off_state = "night"
	activation_sound = 'sound/effects/glasses_on.ogg'

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
	toggleable = 1
	action_button_name = "Toggle Goggles"
	vision_flags = SEE_OBJS

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

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	action_button_name = "Flip Welding Goggles"
	var/up = 0

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
			to_chat(usr, "You flip \the [src] down to protect your eyes.")
		else
			up = !up
			flags &= ~GLASSESCOVERSEYES
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			to_chat(usr, "You push \the [src] up out of your face.")

		usr.update_inv_glasses()

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

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDsunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/obj/item/clothing/glasses/hud/security/hud = null

/obj/item/clothing/glasses/sunglasses/sechud/atom_init()
	. = ..()
	hud = new/obj/item/clothing/glasses/hud/security(src)

/obj/item/clothing/glasses/sunglasses/sechud/tactical
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
	toggleable = 1
	sightglassesmod = "thermal"
	action_button_name = "Toggle Goggles"

/obj/item/clothing/glasses/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, "<span class='warning'>The Optical Thermal Scanner overloads and blinds you!</span>")
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= NEARSIGHTED
			spawn(100)
				M.disabilities &= ~NEARSIGHTED
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
	toggleable = 1
	off_state = "thermoncle_off"
	action_button_name = "Toggle Monocle"

/obj/item/clothing/glasses/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	body_parts_covered = 0
	toggleable = 0
	action_button_name = null

/obj/item/clothing/glasses/thermal/jensen
	name = "optical thermal implants"
	desc = "A set of implantable lenses designed to augment your vision."
	icon_state = "thermalimplants"
	item_state = "syringe_kit"

/obj/item/clothing/glasses/thermal/hos_thermals
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "hos_shades"
	item_state = "hos_shades"
	toggleable = 0
	action_button_name = null

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
	action_button_name = "Toggle Goggles"
	active = 1
	off_state = "healthhudnight"

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
	toggleable = 0
	action_button_name = null

/obj/item/clothing/glasses/sunglasses/sechud/gar
	name = "gar HUDsunglasses"
	icon_state = "gars"
	item_state = "gars"

/obj/item/clothing/glasses/sunglasses/gar/super
	name = "supergar sunglasses"
	icon_state = "supergarb"
	item_state = "supergarb"

/obj/item/clothing/glasses/sunglasses/sechud/gar/super
	name = "supergar HUDSunglasses"
	icon_state = "supergars"
	item_state = "supergars"

/obj/item/clothing/glasses/gar/super
	name = "supergar glasses"
	icon_state = "supergar"
	item_state = "supergar"
	toggleable = 0

/obj/item/clothing/glasses/sunglasses/noir
	name = "noir sunglasses"
	desc = "Somehow these seem even more out-of-date than normal sunglasses."
	action_button_name = "Toggle Noir"
	sightglassesmod = "greyscale"
	toggleable = TRUE

/obj/item/clothing/glasses/sunglasses/noir/attack_self(mob/user)
	toggle_noir()

/obj/item/clothing/glasses/sunglasses/noir/verb/toggle_noir()
	set name = "Toggle Noir"
	set category = "Object"

	if(usr.incapacitated())
		return
	active = !active
	to_chat(usr, "<span class='notice'>You toggle the Noire Mode [active ? "on. Let the investigation begin." : "off."]</span>")
