
/obj/item/clothing/under/color
	name = "colored uniform"
	icon_state = "colored"
	item_state_inventory= "colored"
	item_state_world = "colored_w"
	item_state = "colored"
	color = "#818181"
	flags = ONESIZEFITSALL|HEAR_TALK
	var/mutable_appearance/item_under_overlay

// if needed, this can easily be changed to /obj/item/clothing/under
// in case of adding support for /obj/item/clothing, this proc will require some tweaking
/obj/item/clothing/under/color/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	var/mutable_appearance/I = ..()

	var/icon_path = def_icon_path
	var/t_state = item_state ? item_state : icon_state

	var/datum/species/S = H.species

	if(S.sprite_sheets[sprite_sheet_slot])
		icon_path = S.sprite_sheets[sprite_sheet_slot]

	var/fem_appendix = ""

	// we dont have female sprites for fat uniforms
	if(H.gender == FEMALE && S.gender_limb_icons && sprite_sheet_slot != SPRITE_SHEET_UNIFORM_FAT)
		fem_appendix = "_fem"

	// checks if we have a colorless overlay we need to apply
	if(rolled_down || !icon_exists(icon_path, "[t_state]_overlay[fem_appendix]"))
		return I

	// add the colorless overlay
	I.cut_overlays()
	var/mutable_appearance/under_mob_overlay = mutable_appearance(icon = icon_path, icon_state = "[t_state]_overlay[fem_appendix]")
	under_mob_overlay.appearance_flags = RESET_COLOR
	I.add_overlay(under_mob_overlay)

	// re-apply blood & dirt
	if(dirt_overlay && bloodied_icon_state)
		var/mutable_appearance/bloodsies = mutable_appearance(icon = 'icons/effects/blood.dmi', icon_state = bloodied_icon_state)
		bloodsies.color = dirt_overlay.color
		I.add_overlay(bloodsies)

	return I

/obj/item/clothing/under/color/update_icon()
	..()

	// add the colorless overlay
	//var/mutable_appearance/under_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	//under_overlay.appearance_flags = RESET_COLOR
	//add_overlay(under_overlay)

/obj/item/clothing/under/color/dropped()
	. = ..()
	update_world_icon()

// cut_overlay just isnt fast enough for this, unfortunately.
/obj/item/clothing/under/color/putdown_animation()
	return

/obj/item/clothing/under/color/update_world_icon()
	..()

	// add the colorless overlay
	cut_overlay(item_under_overlay)
	item_under_overlay = image(icon, "[icon_state]_overlay")
	item_under_overlay.appearance_flags = RESET_COLOR
	add_overlay(item_under_overlay)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	color = "#303030"

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	color = "#2b4e95"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	color = "#477238"

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	color = "#818181"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	color = "#b9451d"
	has_sensor = 2
	sensor_mode = SUIT_SENSOR_TRACKING

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	color = "#e27285"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	color = "#b91d1d"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	color = "#f1ebdb"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	color = "#f8c53a"

/obj/item/clothing/under/color/lightblue
	name = "lightblue jumpsuit"
	color = "#42bfe8"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	color = "#59cf93"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	color = "#9052bc"

/obj/item/clothing/under/color/lightpurple
	name = "lightpurple jumpsuit"
	color = "#ceaaed"

/obj/item/clothing/under/color/lightgreen
	name = "lightgreen jumpsuit"
	color = "#c4f129"

/obj/item/clothing/under/color/lightbrown
	name = "lightbrown jumpsuit"
	color = "#d39741"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	color = "#855f39"

/obj/item/clothing/under/color/yellowgreen
	name = "yellowgreen jumpsuit"
	color = "#b0dc1d"

/obj/item/clothing/under/color/darkblue
	name = "darkblue jumpsuit"
	color = "#1b2447"

/obj/item/clothing/under/color/lightred
	name = "lightred jumpsuit"
	color = "#e27272"

/obj/item/clothing/under/color/darkred
	name = "darkred jumpsuit"
	color = "#612721"
